#pragma once
#include "int8.h"
#include "fomo_fixedpoint.h"
#include "tensorflow/lite/kernels/internal/common.h"

extern "C" [[noreturn]] void fomo_kernel_fail();
namespace vision_fomo {
// shortcut: this FOMO graph has <=96 channels/taps, Conv<=3x3 and DW3x3/multiplier1;
// extend these checked bounds when replacing the model, not on each pixel.
constexpr int kChannels = 96, kTaps = 96;
using PackedWord = uint32_t __attribute__((may_alias));
static inline uint32_t pack4(const int8_t* p, int count) {
    uint32_t v = 0;
    if (count > 0) v |= (uint8_t)p[0];
    if (count > 1) v |= (uint32_t)(uint8_t)p[1] << 8;
    if (count > 2) v |= (uint32_t)(uint8_t)p[2] << 16;
    if (count > 3) v |= (uint32_t)(uint8_t)p[3] << 24;
    return v;
}
struct Requant {
    int32_t multiplier, times4;
    uint32_t mask, half;
    uint32_t correction_mask;
    uint8_t left, right, correction_shift;
};
static inline int32_t scale(int32_t value, const Requant& q) {
    value = (int32_t)((uint32_t)value << q.left);
    uint32_t bits = (uint32_t)int8_mulhi(value, q.times4);
    bits += ((uint32_t)value << q.correction_shift) & q.correction_mask;
    bits &= 3;
    value = (int32_t)(((uint32_t)int8_mulhi(value, q.multiplier) << 1) + (bits >> 1) + (bits & 1));
    return (value >> q.right) + (((uint32_t)value & q.mask) > q.half + fomo_negative(value));
}
static Requant prepare(int32_t multiplier, int shift) {
    if (multiplier < 0) fomo_kernel_fail(); // TFLite quantization scales are positive.
    const int right = shift > 0 ? 0 : -shift;
    const uint32_t mask = (1u << right) - 1;
    const int correction = (multiplier >> 30) + ((multiplier >> 29) & 1);
    return {multiplier, (int32_t)((uint32_t)multiplier << 2), mask, mask >> 1,
            correction ? UINT32_MAX : 0, (uint8_t)(shift > 0 ? shift : 0),
            (uint8_t)right, (uint8_t)(correction == 2)};
}
static inline int32_t emit(int32_t value, const Requant& q, int offset, int low, int high) {
    value = scale(value, q) + offset;
    return value < low ? low : value > high ? high : value;
}

static void Conv(const tflite::ConvParams& p, const int32_t* multipliers,
                 const int32_t* shifts, const tflite::RuntimeShape& in,
                 const int8_t* input, const tflite::RuntimeShape& filter,
                 const int8_t* weights, const int32_t* bias,
                 const tflite::RuntimeShape& out, int8_t* output) {
    const int ih = in.Dims(1), iw = in.Dims(2), ic = in.Dims(3);
    const int oh = out.Dims(1), ow = out.Dims(2), oc = out.Dims(3);
    const int fh = filter.Dims(1), fw = filter.Dims(2), taps = fh * fw * ic;
    if (oc > kChannels || taps > kTaps || fh > 3 || fw > 3) fomo_kernel_fail();
    const int words = (taps + 3) >> 2;
    alignas(4) uint32_t packed[kChannels * (kTaps / 4)];
    int32_t base[kChannels];
    Requant quant[kChannels];
    for (int c = 0; c < oc; ++c) {
        quant[c] = prepare(multipliers[c], shifts[c]);
        int sum = 0;
        for (int k = 0; k < taps; ++k) sum += weights[k];
        base[c] = (bias ? bias[c] : 0) + fomo_mul16(p.input_offset, sum);
        for (int k = 0; k < words; ++k)
            packed[c*words+k] = pack4(weights+4*k, taps-4*k);
        weights += taps;
    }
    if (fh == 1 && fw == 1 && !(ic & 3) && !((uintptr_t)input & 3) &&
        p.stride_width == 1 && p.stride_height == 1 &&
        p.padding_values.width == 0 && p.padding_values.height == 0) {
        const int pixels = in.Dims(0) * oh * ow;
        const PackedWord* pixel = reinterpret_cast<const PackedWord*>(input);
        for (int n = 0; n < pixels; ++n, pixel += words) {
            const uint32_t* w = packed;
            for (int c = 0; c < oc; ++c) {
                int32_t acc = base[c];
                for (int k = 0; k < words; ++k) acc += int8_dot4(pixel[k], *w++);
                *output++ = emit(acc, quant[c], p.output_offset,
                                 p.quantized_activation_min, p.quantized_activation_max);
            }
        }
        return;
    }
    const int row_stride = iw * ic, image_stride = ih * row_stride;
    const int x_step = p.stride_width*ic, tap_step = p.dilation_width_factor*ic;
    const int first_byte = -p.padding_values.width*ic;
    alignas(4) int8_t patch[kTaps];
    for (int b = 0; b < in.Dims(0); ++b, input += image_stride) {
        int sy_origin = -p.padding_values.height;
        for (int y = 0; y < oh; ++y, sy_origin += p.stride_height) {
            const int8_t* rows[3];
            int sy = sy_origin;
            for (int fy = 0; fy < fh; ++fy, sy += p.dilation_height_factor)
                rows[fy] = sy >= 0 && sy < ih ? input + sy*row_stride : nullptr;
            int sx_origin = -p.padding_values.width, byte_origin = first_byte;
            for (int x = 0; x < ow; ++x, sx_origin += p.stride_width, byte_origin += x_step) {
                int k = 0;
                for (int fy = 0; fy < fh; ++fy) {
                    int sx = sx_origin, byte = byte_origin;
                    for (int fx = 0; fx < fw; ++fx, sx += p.dilation_width_factor, byte += tap_step) {
                        if (rows[fy] && sx >= 0 && sx < iw) {
                            const int8_t* src = rows[fy] + byte;
                            for (int c = 0; c < ic; ++c) patch[k++] = src[c];
                        } else {
                            for (int c = 0; c < ic; ++c) patch[k++] = -p.input_offset;
                        }
                    }
                }
                while (k < 4*words) patch[k++] = 0;
                const PackedWord* pixel = reinterpret_cast<const PackedWord*>(patch);
                const uint32_t* w = packed;
                for (int c = 0; c < oc; ++c) {
                    int32_t acc = base[c];
                    for (int j = 0; j < words; ++j) acc += int8_dot4(pixel[j], *w++);
                    *output++ = emit(acc, quant[c], p.output_offset,
                                     p.quantized_activation_min, p.quantized_activation_max);
                }
            }
        }
    }
}

static void Depthwise(const tflite::DepthwiseParams& p, const int32_t* multipliers,
                      const int32_t* shifts, const tflite::RuntimeShape& in,
                      const int8_t* input, const tflite::RuntimeShape& filter,
                      const int8_t* weights, const int32_t* bias,
                      const tflite::RuntimeShape& out, int8_t* output) {
    const int ih = in.Dims(1), iw = in.Dims(2), channels = in.Dims(3);
    const int oh = out.Dims(1), ow = out.Dims(2);
    const int fh = filter.Dims(1), fw = filter.Dims(2), count = fh * fw;
    if (channels > kChannels || fh != 3 || fw != 3 || p.depth_multiplier != 1) fomo_kernel_fail();
    uint8_t packed[kChannels * 9];
    int32_t base[kChannels];
    Requant quant[kChannels];
    uint8_t zero[kChannels];
    for (int c = 0; c < channels; ++c) {
        quant[c] = prepare(multipliers[c], shifts[c]);
        int sum = 0;
        for (int k = 0; k < count; ++k) {
            int8_t w = weights[k*channels+c];
            packed[c*count+k] = (uint8_t)w;
            sum += w;
        }
        base[c] = (bias ? bias[c] : 0) + fomo_mul16(p.input_offset, sum);
        zero[c] = -p.input_offset;
    }
    const int row_stride = iw * channels, image_stride = ih * row_stride;
    const int x_step = p.stride_width*channels, tap_step = p.dilation_width_factor*channels;
    const int first_byte = -p.padding_values.width*channels;
    for (int b = 0; b < in.Dims(0); ++b, input += image_stride) {
        int sy_origin = -p.padding_values.height;
        for (int y = 0; y < oh; ++y, sy_origin += p.stride_height) {
            const uint8_t* rows[3];
            int sy = sy_origin;
            for (int fy = 0; fy < fh; ++fy, sy += p.dilation_height_factor)
                rows[fy] = sy >= 0 && sy < ih ? reinterpret_cast<const uint8_t*>(input + sy*row_stride) : nullptr;
            int sx_origin = -p.padding_values.width, byte_origin = first_byte;
            for (int x = 0; x < ow; ++x, sx_origin += p.stride_width, byte_origin += x_step) {
                const uint8_t* taps[9];
                int k = 0;
                for (int fy = 0; fy < fh; ++fy) {
                    int sx = sx_origin, byte = byte_origin;
                    for (int fx = 0; fx < fw; ++fx, sx += p.dilation_width_factor, byte += tap_step) {
                        taps[k++] = rows[fy] && sx >= 0 && sx < iw ? rows[fy] + byte : zero;
                    }
                }
                const uint8_t* w = packed;
                for (int c = 0; c < channels; ++c) {
                    int32_t acc = base[c];
                    acc += int8_dot4(taps[0][c], w[0]);
                    acc += int8_dot4(taps[1][c], w[1]);
                    acc += int8_dot4(taps[2][c], w[2]);
                    acc += int8_dot4(taps[3][c], w[3]);
                    acc += int8_dot4(taps[4][c], w[4]);
                    acc += int8_dot4(taps[5][c], w[5]);
                    acc += int8_dot4(taps[6][c], w[6]);
                    acc += int8_dot4(taps[7][c], w[7]);
                    acc += int8_dot4(taps[8][c], w[8]);
                    w += 9;
                    *output++ = emit(acc, quant[c], p.output_offset,
                                     p.quantized_activation_min, p.quantized_activation_max);
                }
            }
        }
    }
}
} // namespace vision_fomo
