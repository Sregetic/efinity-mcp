OUTPUT_ARCH(riscv)
ENTRY(_boot)
SECTIONS {
 /* ponytail: 4KB ROM carries this firmware; use SPI/USER1 loading when the DDR application outgrows 3840 bytes. */
 .boot 0xf9000000 : { KEEP(*(.boot)) }
 .app 0x07000000 : AT(0xf9000100) {
  __app_start = .; KEEP(*(.text.start)) *(.text*) *(.rodata*) *(.sdata*) *(.data*) .  =  ALIGN(4); __app_end = .;
 }
 __app_load = LOADADDR(.app);
 .bss (NOLOAD) : { .  =  ALIGN(4); __bss_start = .; *(.sbss*) *(.bss*) .  =  ALIGN(4); __bss_end = .; }
 __stack_top = 0x07010000;
 ASSERT(SIZEOF(.boot)<= 256,"bootstrap exceeds reserved 256 bytes")
 ASSERT(SIZEOF(.app)<= 3840,"application exceeds the 4KB boot image")
 ASSERT(__bss_end<0x0700c000,"application and stack overlap")
}

/* Shared control/result records survive USER1 AI application replacement. */
__flyhash_result = 0x07620000;
__flyhash_input = 0x07620100;
__control_state = 0x07620200;
__control_limit = 0x07621000;
