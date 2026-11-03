.section .text.start,"ax"
.global _start
_start:
 la sp,__stack_top
 la t0,trap
 csrw mtvec,t0
 call main
 j trap
