"""Run the production control policy on RV32I; MMIO model follows bridge ABI."""
from pathlib import Path
import subprocess
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'results/xlr_control_20261007/control_test';OUT.mkdir(parents=True,exist_ok=True)
BIN=Path('F:/Efinity/efinity-riscv-ide-2026.1/toolchain/bin')
source=r'''
#include <stdint.h>
#define CONTROL_TEST
static uint32_t reg[32];
static uint32_t read_reg(unsigned off){return reg[off/4];}
static void write_reg(unsigned off,uint32_t v){
 reg[off/4]=v;
 if(off==8)reg[3]|=1;
 if(off==0x30){
  reg[4]=(reg[4]&~32u)|((v&1)<<5);
  if(v&2)reg[4]|=16;
  if(v&4)reg[4]&=~(1u<<11);
  if(v&8)reg[6]=reg[0x34/4];
 }
}
#define CTRL_R(off) read_reg(off)
#define CTRL_W(off,value) write_reg(off,value)
#define CONTROL_STATE (&state)
extern struct vision_control_state state;
#include "control_service.h"
struct vision_control_state state;
static void finish(unsigned ok){*(volatile unsigned *)0x100000=ok?0x5555:0x3333;for(;;);}
static void check(unsigned ok){if(!ok)finish(0);}
static void event(unsigned op,unsigned v){control_event((op<<24)|v);}
static unsigned threshold(unsigned shift){return (state.settings>>shift)&2047;}
static void apply(void){control_service_step();reg[3]&=~1u;control_service_step();}
static void accept(void){reg[4]&=~16u;reg[6]=reg[0x34/4];control_service_step();}
void main(void){
 reg[4]=1<<8;control_init();check(state.magic==CONTROL_MAGIC&&state.ai_policy==2);event(0x60,1);check(state.ai_policy==1);event(0x60,3);check(state.ai_policy==1);
 event(0x28,96);event(0x29,48);event(1,5);event(255,2);check(threshold(20)==64&&threshold(9)==96);
 event(255,4);check(threshold(20)==48);event(0x29,0);event(255,4);check(threshold(20)==16);
 event(0x29,2047);event(255,2);check(threshold(20)==2047);
 event(1,2);for(unsigned i=0;i<80;i++){event(255,2);check(threshold(9)==112);event(255,4);check(threshold(9)==96);}
 event(1,4);event(255,3);check((state.settings&7)==5&&threshold(9)==112&&threshold(20)==2047);
 event(1,2);event(0x28,96);event(255,6);check(threshold(9)==80);event(0x28,96);
 apply();event(4,2);for(unsigned i=0;i<6;i++)event(255,2);check(((state.settings>>6)&7)==0);
 event(255,4);check(((state.settings>>6)&7)==5);event(5,7);check(((state.settings>>6)&7)==0);
 event(4,0);event(255,16);check(((state.settings>>4)&3)==1);event(255,48);check(((state.settings>>4)&3)==2);event(4,1);event(255,32);check(((state.settings>>4)&3)==2);
 apply();event(1,5);control_service_step();uint32_t first=reg[2];event(0x29,80);control_service_step();check(reg[2]==first);
 reg[3]&=~1u;control_service_step();check(((reg[2]>>20)&2047)==80);apply();
 event(0x30,(13<<12)|7);event(0x31,(37<<12)|45);event(0x32,(80<<12)|64);event(0x33,(8<<12)|12);event(0x34,1);event(0x35,0);
 event(0x30,0);check(state.commit[0]==((13<<12)|7));event(0x35,0);check(state.serial==1&&state.reject);
 control_service_step();check(state.warming&&!(reg[4]&16));reg[5]++;control_service_step();check(state.pending==2&&(reg[4]&16));
 check(reg[0x20/4]==((13<<12)|7)&&reg[0x2c/4]==((8<<12)|12));accept();check(!state.pending&&state.good);
 reg[4]|=(1<<6)|(1<<7);control_service_step();check(!(reg[4]&16));
 // Same frozen source, changed ROI; geometry waits until the engine is ready.
 event(0x30,(24<<12)|15);event(0x35,0);reg[4]&=~(1<<8);control_service_step();check(state.pending==1);
 reg[4]|=1<<8;control_service_step();check(state.pending==2&&reg[0x20/4]==((24<<12)|15));accept();
 event(0x33,(1900<<12)|0);event(0x35,0);control_service_step();check(!state.pending&&reg[0x40/4]==3&&reg[0x38/4]==4);
 event(0x33,0);event(0x35,0);control_service_step();accept();check(state.good);
 reg[4]|=1<<11;reg[4]&=~(1<<8);event(0x35,0);control_service_step();check(!state.good&&state.pending==1);
 reg[4]|=1<<8;control_service_step();accept();check(state.good);reg[4]|=1<<11;control_service_step();check(!state.good);event(0x34,0);event(0x35,0);control_service_step();check(!state.enabled&&!(reg[4]&32));
 reg[4]=(1<<8)|(1<<6);reg[5]=100;event(0x34,1);event(0x35,0);control_service_step();
 check(state.pending==2&&!state.warming&&(reg[4]&16));accept();check(state.good);
 const char *p="PASS RV32I controls independent thresholds16..2047 step16, keys/history, atomic feature wait, immutable ROI commit, fresh capture, frozen rerender, reject and disable\n";
 while(*p)*(volatile unsigned char *)0x10000000=*p++;finish(1);
}
void trap(void){finish(0);}
'''
(OUT/'test.c').write_text(source)
(OUT/'start.S').write_text('.section .text.start,"ax"\n.global _start\n_start:\n la sp,__stack_top\n la t0,trap\n csrw mtvec,t0\n call main\n j trap\n')
(OUT/'link.ld').write_text('OUTPUT_ARCH(riscv)\nENTRY(_start)\nSECTIONS{. = 0x80000000; .text : {*(.text.start) *(.text*)} .rodata : {*(.rodata*)} .data : {*(.data*) *(.sdata*)} .bss : {*(.bss*) *(.sbss*)} __stack_top = 0x80100000;}')
subprocess.run([str(BIN/'riscv-none-elf-gcc.exe'),'-march=rv32i_zicsr_zifencei','-mabi=ilp32','-Os','-ffreestanding','-fno-builtin','-mno-relax','-msmall-data-limit=0','-nostdlib','-I'+str(ROOT/'firmware/vision'),'-T',str(OUT/'link.ld'),str(OUT/'start.S'),str(OUT/'test.c'),'-lgcc','-o',str(OUT/'test.elf')],check=True)
r=subprocess.run(['F:/Efinity/efinity-riscv-ide-2026.1/qemu/qemu-system-riscv32.exe','-M','virt','-cpu','rv32,m=false,a=false,c=false,f=false,d=false','-nographic','-bios','none','-kernel',str(OUT/'test.elf')],capture_output=True,text=True,timeout=30)
(OUT/'test.log').write_text(r.stdout+r.stderr)
assert r.returncode==0 and 'PASS RV32I controls' in r.stdout,(r.returncode,r.stdout,r.stderr)
print(r.stdout.strip())
