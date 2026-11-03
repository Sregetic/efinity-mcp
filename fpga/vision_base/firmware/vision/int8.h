#pragma once
#include <stdint.h>
static inline int32_t int8_dot4(uint32_t a,uint32_t b) {
#ifdef INT8_TEST
    int32_t value=0;for(unsigned k=0;k<4;k++)value+=(int8_t)(a>>(8*k))*(int8_t)(b>>(8*k));return value;
#else
    int32_t value;
    __asm__ volatile(".insn r 0x0b, 0, 0, %0, %1, %2":"=r"(value):"r"(a),"r"(b));
    return value;
#endif
}
static inline int32_t int8_mulhi(int32_t a,int32_t b) {
#ifdef INT8_TEST
    return ((int64_t)a*b)>>32;
#else
    int32_t value;
    __asm__ volatile(".insn r 0x0b, 1, 0, %0, %1, %2":"=r"(value):"r"(a),"r"(b));
    return value;
#endif
}
