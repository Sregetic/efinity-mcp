// Fixed-vector FOMO bring-up on the existing RV32I/DDR system; no camera AI.
#include <stdint.h>
#include <string.h>
#include "control_service.h"
#include "fomo_runtime.h"

extern "C" const uint8_t fomo_model[];
extern "C" const int8_t fomo_inputs[4][96 * 96 * 3];
extern "C" const int8_t fomo_expected[4][12 * 12 * 4];
extern uint8_t __arena_start[], __arena_limit[];

struct SampleResult {
    uint64_t cycles;
    uint32_t max_diff, mismatches, positive_cells, operators;
};
extern "C" {
volatile uint32_t fomo_status[16];
volatile SampleResult fomo_results[4];
volatile int8_t fomo_outputs[4][576];
volatile uint64_t fomo_layer_cycles[4][25];
volatile char fomo_log[2048];
}

[[noreturn]] static void fail(uint32_t code) {
    fomo_status[2] = code;
    __asm__ volatile("fence rw,rw" ::: "memory");
    fomo_status[1] = 4;
    *reinterpret_cast<volatile uint32_t*>(0xf8100004u) = 3;
    for (;;) control_service_step();
}
extern "C" [[noreturn]] void fomo_kernel_fail() { fail(7); }
extern "C" [[noreturn]] void fomo_runtime_fail(uint32_t code) { fail(code); }
extern "C" void DebugLog(const char* s) {
    uint32_t n = fomo_status[12];
    while (*s && n < sizeof(fomo_log) - 1) fomo_log[n++] = *s++;
    if (n < sizeof(fomo_log) - 1) fomo_log[n++] = '\n';
    fomo_log[n] = 0;
    fomo_status[12] = n;
}
namespace tflite {
int32_t ticks_per_second() { return 100000000; }
int32_t GetCurrentTimeTicks() { return static_cast<int32_t>(fomo_ticks()); }
}

class LayerProfiler final : public tflite::MicroProfiler {
 public:
    unsigned sample = 0, index = 0;
    uint64_t start = 0;
    uint64_t BeginEvent(const char*) override {
        control_service_step();
        fomo_status[11] = index;
        start = fomo_ticks();
        return index;
    }
    void EndEvent(uint64_t handle) override {
        fomo_layer_cycles[sample][handle] = fomo_ticks() - start;
        ++index;
    }
 private:
    TF_LITE_REMOVE_VIRTUAL_DELETE;
};

extern "C" int main() {
    fomo_status[0] = 0x464f4d31;
    fomo_status[1] = 1;
    fomo_status[15] = 100000000;
    // APB firmware_state is two bits: running=1, fixed test done=2, error=3.
    *reinterpret_cast<volatile uint32_t*>(0xf8100004u) = 1;
    if (CONTROL_STATE->magic == 0) control_init(); // Same cold-boot contract as ai_main.c.
    if (CONTROL_STATE->magic != CONTROL_MAGIC) fail(1);
    static LayerProfiler profiler;
    uint64_t begin = fomo_ticks();
    auto &interpreter = *fomo_create(&profiler);
    uint64_t allocation = fomo_ticks() - begin;
    fomo_status[5] = interpreter.arena_used_bytes();
    fomo_status[6] = allocation;
    fomo_status[7] = allocation >> 32;
    auto input = interpreter.input(0);
    auto output = interpreter.output(0);
    fomo_status[8] = input->bytes;
    fomo_status[9] = output->bytes;
    fomo_status[10] = interpreter.operators_size();
    for (unsigned s = 0; s < 4; ++s) {
        memcpy(input->data.int8, fomo_inputs[s], input->bytes);
        profiler.sample = s;
        profiler.index = 0;
        fomo_status[3] = s;
        fomo_status[1] = 2;
        begin = fomo_ticks();
        if (interpreter.Invoke() != kTfLiteOk) fail(6);
        fomo_results[s].cycles = fomo_ticks() - begin;
        fomo_results[s].operators = profiler.index;
        for (unsigned i = 0; i < 576; ++i) {
            int value = output->data.int8[i];
            fomo_outputs[s][i] = value;
            int d = value - fomo_expected[s][i];
            if (d < 0) d = -d;
            if (static_cast<unsigned>(d) > fomo_results[s].max_diff) fomo_results[s].max_diff = d;
            if (d) ++fomo_results[s].mismatches;
        }
        for (unsigned i = 0; i < 576; i += 4) {
            unsigned best = 0;
            for (unsigned c = 1; c < 4; ++c)
                if (output->data.int8[i+c] > output->data.int8[i+best]) best = c;
            if (best && output->data.int8[i+best] >= 0) ++fomo_results[s].positive_cells;
        }
        __asm__ volatile("fence rw,rw" ::: "memory");
        fomo_status[4] = s + 1;
    }
    fomo_status[1] = 3;
    *reinterpret_cast<volatile uint32_t*>(0xf8100004u) = 2;
    for (;;) control_service_step();
}
extern "C" void trap() {
    uint32_t cause, pc, value;
    __asm__ volatile("csrr %0,mcause\ncsrr %1,mepc\ncsrr %2,mtval"
                     : "=r"(cause), "=r"(pc), "=r"(value));
    fomo_status[13] = cause;
    fomo_status[14] = pc;
    fail(0x80000000u | value);
}
