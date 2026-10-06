.section .boot,"ax"
.global _boot
_boot:
    la t0,__app_load
    la t1,__app_start
    la t2,__app_end
1:  bgeu t1,t2,2f
    lw t3,0(t0)
    sw t3,0(t1)
    addi t0,t0,4
    addi t1,t1,4
    j 1b
2:  fence rw,rw
    fence.i
    la t0,_start
    jr t0
.section .text.start,"ax"
.global _start
_start:
    la sp,__stack_top
    la t0,trap
    csrw mtvec,t0
    la t0,__bss_start
    la t1,__bss_end
1:  bgeu t0,t1,2f
    sw zero,0(t0)
    addi t0,t0,4
    j 1b
2:  call main
    j trap
