"""Run production selftest with RV32I arithmetic references; board tests real CFUs."""
from pathlib import Path
import argparse,subprocess
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--output-dir',type=Path,default=ROOT/'results/ai_board_ui_20261010/selftest_test');args=p.parse_args()
OUT=args.output_dir;OUT.mkdir(parents=True,exist_ok=True)
BIN=Path('F:/Efinity/efinity-riscv-ide-2026.1/toolchain/bin')
source='#define INT8_TEST\n#define VISION_MULHI_CFU\n#include "ai_selftest.h"\n'
source+='''
static void finish(unsigned ok){*(volatile unsigned *)0x100000=ok?0x5555:0x3333;for(;;);}
void main(void){
 if(ai_selftest()!=2)finish(0);
 const char*p="PASS RV32I weight-free feature/FlyHash/connectome selftest\\n";
 while(*p)*(volatile unsigned char*)0x10000000=*p++;finish(1);
}
void trap(void){finish(0);}
'''
(OUT/'test.c').write_text(source)
(OUT/'start.S').write_text('.section .text.start,"ax"\n.global _start\n_start:\n la sp,__stack_top\n la t0,trap\n csrw mtvec,t0\n call main\n j trap\n')
(OUT/'link.ld').write_text('OUTPUT_ARCH(riscv)\nENTRY(_start)\nSECTIONS{. = 0x80000000; .text : {*(.text.start) *(.text*)} .rodata : {*(.rodata*)} .data : {*(.data*) *(.sdata*)} .bss : {*(.bss*) *(.sbss*)} __stack_top = 0x80100000;}')
subprocess.run([str(BIN/'riscv-none-elf-gcc.exe'),'-march=rv32i_zicsr_zifencei','-mabi=ilp32','-Os','-ffreestanding','-fno-builtin','-mno-relax','-msmall-data-limit=0','-nostdlib','-I'+str(ROOT/'firmware/vision'),'-T',str(OUT/'link.ld'),str(OUT/'start.S'),str(OUT/'test.c'),str(ROOT/'firmware/vision/flyhash.c'),'-lgcc','-o',str(OUT/'test.elf')],check=True)
r=subprocess.run(['F:/Efinity/efinity-riscv-ide-2026.1/qemu/qemu-system-riscv32.exe','-M','virt','-cpu','rv32,m=false,a=false,c=false,f=false,d=false','-nographic','-bios','none','-kernel',str(OUT/'test.elf')],capture_output=True,text=True,timeout=60)
(OUT/'test.log').write_text(r.stdout+r.stderr)
assert r.returncode==0 and 'PASS RV32I' in r.stdout,(r.returncode,r.stdout,r.stderr)
print(r.stdout.strip())
