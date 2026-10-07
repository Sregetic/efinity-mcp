OUTPUT_ARCH(riscv)
ENTRY(_start)
/* Frame/result pool occupies 0x00000000..0x027fffff. All CPU regions below
   are inside the existing 128MiB DDR window, and outside the frame pool. */
MEMORY {
 APP (rwx) : ORIGIN = 0x07000000, LENGTH = 4M
}
__app_limit = ORIGIN(APP) + LENGTH(APP);
__weights_start = 0x07400000;
__weights_limit = 0x07600000;
__input0 = 0x07600000;
__input1 = 0x07610000;
__input_limit = 0x07620000;
__arena_start = 0x07700000;
__arena_limit = 0x07b00000;
__stack_bottom = 0x07fc0000;
__stack_top = 0x07fe0000;
__debug_work_start = 0x07ff0000;
__debug_work_limit = 0x07ff1000;
SECTIONS {
 .app : {
  __app_start = .; KEEP(*(.text.start)) *(.text*) *(.rodata*) *(.sdata*) *(.data*)
  . = ALIGN(4); __app_end = .;
 } > APP
 .bss (NOLOAD) : {
  . = ALIGN(4); __bss_start = .; *(.sbss*) *(.bss*) *(COMMON)
  . = ALIGN(4); __bss_end = .;
 } > APP
 /DISCARD/ : { *(.boot) }
 ASSERT(__bss_end <= __app_limit,"DDR application exceeds its 4MiB region")
}

/* Shared control/result records survive USER1 AI application replacement. */
__flyhash_result = 0x07620000;
__flyhash_input = 0x07620100;
__control_state = 0x07620200;
__control_limit = 0x07621000;
