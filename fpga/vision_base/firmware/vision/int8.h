#pragma once
#include <stdint.h>
static inline int32_t int8_dot4(uint32_t a,uint32_t b) {
    int32_t value;
    __asm__ volatile(".insn r 0x0b, 0, 0, %0, %1, %2":"=r"(value):"r"(a),"r"(b));
    return value;
}
static inline int32_t int8_mulhi(int32_t a,int32_t b) {
    int32_t value;
    __asm__ volatile(".insn r 0x0b, 1, 0, %0, %1, %2":"=r"(value):"r"(a),"r"(b));
    return value;
}
