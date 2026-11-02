"""Run the production control policy on RV32I; MMIO model follows bridge ABI."""
from pathlib import Path
import argparse,subprocess
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--output-dir',type=Path,default=ROOT/'results/xlr_control_20261007/control_test');args=p.parse_args()
OUT=args.output_dir;OUT.mkdir(parents=True,exist_ok=True)
BIN=Path('F:/Efinity/efinity-riscv-ide-2026.1/toolchain/bin')
source=r'''
#include <stdint.h>
#define CONTROL_TEST
#define VISION_FOMO
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
static void check_line(unsigned ok,unsigned line){if(!ok){const char*h="0123456789abcdef";for(int i=12;i>=0;i-=4)*(volatile unsigned char*)0x10000000=h[(line>>i)&15];finish(0);}}
#define check(ok) check_line((ok),__LINE__)
static void event(unsigned op,unsigned v){control_event((op<<24)|v);}
static unsigned threshold(unsigned shift){return (state.settings>>shift)&2047;}
static void apply(void){control_service_step();reg[3]&=~1u;control_service_step();}
static void accept(void){reg[4]&=~16u;if(reg[4]&(1u<<6))reg[4]|=1u<<7;reg[6]=reg[0x34/4];control_service_step();}
void main(void){
 reg[4]=1<<8;control_init();check(state.magic==CONTROL_MAGIC&&state.ai_policy==0);
 check(state.settings==(5u|8u|(128u<<9)|(80u<<20))&&state.feature_dirty&&!state.roi_enable&&!state.menu);
 apply();check(reg[2]==state.settings&&!state.feature_dirty&&!state.feature_wait);
 event(0x60,1);check(state.ai_policy==1);event(0x60,3);check(state.ai_policy==1);
 event(0x28,96);event(0x29,48);event(1,5);event(255,2);check(threshold(20)==64&&threshold(9)==96);
 event(255,4);check(threshold(20)==48);event(0x29,0);event(255,4);check(threshold(20)==16);
 event(0x29,2047);event(255,2);check(threshold(20)==2047);
 event(1,2);for(unsigned i=0;i<80;i++){event(255,2);check(threshold(9)==112);event(255,4);check(threshold(9)==96);}
 event(1,4);event(255,3);check((state.settings&7)==5&&threshold(9)==112&&threshold(20)==2047);
 event(1,2);event(0x28,96);event(255,6);check(threshold(9)==80);event(0x28,96);
 apply();event(4,2);for(unsigned i=0;i<6;i++)event(255,2);check(((state.settings>>6)&7)==6);
 event(255,2);check(((state.settings>>6)&7)==0);event(255,4);check(((state.settings>>6)&7)==6);
 event(255,4);check(((state.settings>>6)&7)==5);event(5,7);check(((state.settings>>6)&7)==0);
 event(5,6);check(((state.settings>>6)&7)==6);event(255,32);check(((state.settings>>4)&3)==3&&((state.settings>>6)&7)==0);
 event(255,4);check(((state.settings>>6)&7)==5);event(5,6);check(((state.settings>>6)&7)==0);
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
 event(4,1);unsigned saved_sobel=threshold(9);event(1,6);event(1,7);check((state.settings&7)==6);event(255,1);check((state.settings&7)==0);
 event(23,1);check(threshold(20)==16&&threshold(9)==saved_sobel);event(23,255);check(threshold(20)==255&&!state.shape_threshold);
 // UI reuses the real key event policy; no host is needed for any action.
 event(0x61,1);check(state.menu==1);event(255,2);check(state.settings&8);event(255,4);check(!(state.settings&8));
 event(0x30,0);event(0x31,(1920u<<12)|1080);event(0x32,(1920u<<12)|1080);event(0x33,0);
 event(0x61,2);check(state.menu==2);event(255,2);check(state.roi[0]==((480u<<12)|270)&&state.roi[1]==((960u<<12)|540));
 apply();check(state.pending==2&&reg[0x44/4]==((9u<<15)|(2u<<11)|960));
 event(255,2);check(state.roi[1]==((480u<<12)|270)&&state.key_roi_dirty);accept();accept();check(state.good&&!state.pending);
 event(0x61,3);check(state.menu==3);unsigned old_x=state.roi[0]>>12;event(255,2);check((state.roi[0]>>12)==old_x+32);
 for(unsigned i=0;i<100;i++)event(255,2);check((state.roi[0]>>12)==1440);event(255,4);check((state.roi[0]>>12)==1408);
 event(0x61,4);for(unsigned i=0;i<100;i++)event(255,4);check((state.roi[0]&4095)==0);
 event(0x61,5);event(255,4);check(state.roi[2]==((960u<<12)|540));
 event(0x61,6);for(unsigned i=0;i<100;i++)event(255,2);check(state.roi[3]>>12==960);
 event(0x61,7);for(unsigned i=0;i<100;i++)event(255,2);check((state.roi[3]&4095)==540);
 event(0x61,5);event(255,2);check(state.roi[2]==((1920u<<12)|1080)&&state.roi[3]==0);
 event(0x61,2);for(unsigned i=0;i<10;i++)event(255,4);check(state.roi[0]==0&&state.roi[1]==((1920u<<12)|1080)&&!state.roi_enable);
 event(0x61,8);check(state.menu==8);
 event(255,2);check(state.ai_policy==2&&state.ai_manual==2);event(255,2);check(state.ai_policy==0);event(255,4);check(state.ai_request==0);
 event(255,2);check(state.ai_policy==1&&state.ai_manual);event(255,4);check(state.ai_request==1);
 event(255,16);check(((state.settings>>4)&3)==0);event(255,16);check(((state.settings>>4)&3)==1);
 event(0x61,9);check(state.menu==9);event(255,2);check(state.selftest_request==1);event(255,4);check(state.selftest_request==1);
 event(0x61,10);check(state.menu==10);event(255,2);check(state.ai_manual==3);
 event(0x60,1);check(state.ai_manual==2);event(0x61,8);event(255,2);check(state.ai_policy==2&&state.ai_manual==2);
 event(0x61,10);event(255,4);check(state.ai_manual==2);event(0x61,0);check(state.menu==0);
 event(0x60,1);check(state.ai_manual==2);apply();accept();control_service_step();check(!state.enabled&&!state.pending);
 const char *p="PASS RV32I controls independent thresholds16..2047 step16, keys/history,11-page UI/AI single-shot/selftest/FOMO selection, bounded zoom/pan/viewport, coalesced frozen ROI commits, atomic feature wait and disable\n";
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
