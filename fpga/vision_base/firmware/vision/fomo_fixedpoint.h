#pragma once
#include "int8.h"

static inline uint32_t fomo_negative(int32_t x) {
#ifdef INT8_TEST
    return x < 0;
#else
    // Sapphire has a serial shifter; slt avoids GCC's 31-bit sign shift.
    uint32_t value;
    __asm__("slt %0, %1, zero" : "=r"(value) : "r"(x));
    return value;
#endif
}

static inline int32_t fomo_round_divide(int32_t x, int exponent) {
    const uint32_t mask = (1u << exponent) - 1;
    return (x >> exponent) + (((uint32_t)x & mask) > (mask >> 1) + fomo_negative(x));
}

// Two existing high-product instructions recover Q31 rounding bits exactly.
static inline int32_t fomo_round_high(int32_t a, int32_t b) {
    if (a == INT32_MIN && b == INT32_MIN) return INT32_MAX;
    uint32_t high = (uint32_t)int8_mulhi(a, b);
    uint32_t bits = (uint32_t)int8_mulhi(a, (int32_t)((uint32_t)b << 2));
    int32_t correction = (b >> 30) + (((uint32_t)b >> 29) & 1);
    if (correction & 1) bits += (uint32_t)a;
    if (correction & 2) bits += (uint32_t)a << 1;
    bits &= 3;
    return (int32_t)((high << 1) + (bits >> 1) + (bits & 1));
}

// Both operands are signed16; scaling makes high32 the exact integer product.
static inline int32_t fomo_mul16(int32_t a, int32_t b) {
    return int8_mulhi((int32_t)((uint32_t)a << 16), (int32_t)((uint32_t)b << 16));
}
