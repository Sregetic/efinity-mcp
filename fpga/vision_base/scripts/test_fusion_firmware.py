"""Production RV32I coordinate transform, fusion and snapshot ownership checks."""
from pathlib import Path
import subprocess
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'results/fusion_roi_20261008/firmware_test';OUT.mkdir(parents=True,exist_ok=True)
BIN=Path('F:/Efinity/efinity-riscv-ide-2026.1/toolchain/bin')
source=r'''
#include <stdint.h>
#define CONTROL_TEST
static uint32_t c[32],f[64],flip=0,reads=0;
#define CTRL_R(off) (c[(off)/4])
#define CTRL_W(off,v) (c[(off)/4]=(v))
#define CONTROL_STATE (&state)
extern struct vision_control_state state;
#define FUSION_TEST
static uint32_t read_f(unsigned off){
 if(off==0x10){reads++;if(flip&&reads==2){f[4]++;f[5]=99;flip=0;}}
 return f[off/4];
}
#define FUS_R(off) read_f(off)
#define FUS_W(off,v) (f[(off)/4]=(v))
#include "fusion_service.h"
struct vision_control_state state;volatile uint32_t fusion_result[16];
static void finish(unsigned ok){*(volatile unsigned *)0x100000=ok?0x5555:0x3333;for(;;);}
static void check(unsigned ok){if(!ok)finish(0);}
static void puts(const char*s){while(*s)*(volatile unsigned char*)0x10000000=*s++;}
static void box(struct fusion_job*j,unsigned x,unsigned y,unsigned w,unsigned h){
 uint64_t v=(1ull<<63)|(1ull<<62)|(2ull<<60)|((uint64_t)x<<36)|((uint64_t)y<<24)|((uint64_t)(x+w-1)<<12)|(y+h-1);
 j->g.hi=v>>32;j->g.lo=v;
}
void main(void){
 struct fusion_job j={0};state.good=1;
 box(&j,802,402,160,120);check(fusion_roi(&j,1,0,0));
 check(j.xy==(780u|(385u<<16))&&j.wh==(200u|(150u<<16))&&j.geometry_class==2);
 state.serial=17;state.commit[0]=(200u<<12)|100;state.commit[1]=(800u<<12)|600;
 state.commit[2]=(1600u<<12)|900;state.commit[3]=(100u<<12)|50;j.g.render=17;
 box(&j,302,202,320,180);check(fusion_roi(&j,1,0,0));
 check(j.xy==(280u|(184u<<16))&&j.wh==(200u|(152u<<16)));
 j.g.render=18;check(!fusion_roi(&j,1,0,0));j.g.render=17;
 state.pending=1;check(!fusion_roi(&j,1,0,0));state.pending=0;
 j.g.hi&=~(1u<<30);check(!fusion_roi(&j,1,0,0));
 check(fusion_roi(&j,0,280u|(185u<<16),200u|(150u<<16)));check(j.geometry_class==0);
 check(fusion_roi(&j,0,10u|(185u<<16),200u|(150u<<16)));check(j.geometry_class==0);
check(fusion_roi(&j,0,10u|(10u<<16),10u|(10u<<16)));check(j.box0==0xffffffffu&&j.box1==0);
box(&j,102,52,400,200);check(!fusion_roi(&j,1,0,0));
 int8_t scores[4]={-100,-80,50,-100};j.geometry_class=2;j.test=1;j.minimum_margin=16;
 check(((fusion_flags(&j,2,scores)>>8)&7)==FUS_TEST);j.test=0;
 check(((fusion_flags(&j,2,scores)>>8)&7)==FUS_AGREE);j.geometry_class=1;
 check(((fusion_flags(&j,2,scores)>>8)&7)==FUS_CONFLICT);j.minimum_margin=0;
 check(((fusion_flags(&j,2,scores)>>8)&7)==FUS_UNKNOWN);
 f[4]=1;f[5]=10;flip=1;struct fusion_geometry g=fusion_geometry_read();check(g.sequence==2&&g.frame==99);
 j.g=g;j.model=7;fusion_publish(&j,123,0x203,0x12345678);
 check(fusion_result[0]==0x46555331&&fusion_result[1]==1&&fusion_result[15]==0&&fusion_result[3]==99&&fusion_result[4]==123&&fusion_result[6]==7);
 check(f[0x84/4]==99&&f[0x88/4]==123&&f[0x90/4]==7&&f[2]==1);
 puts("PASS RV32I fusion: padded ROI inverse mapping, config/pending/no-target, synthetic/agree/conflict/unknown, seqlock retry and complete publication\n");finish(1);
}
void trap(void){finish(0);}
'''
(OUT/'test.c').write_text(source)
(OUT/'start.S').write_text('.section .text.start,"ax"\n.global _start\n_start:\n la sp,__stack_top\n la t0,trap\n csrw mtvec,t0\n call main\n j trap\n')
(OUT/'link.ld').write_text('OUTPUT_ARCH(riscv)\nENTRY(_start)\nSECTIONS{. = 0x80000000; .text : {*(.text.start) *(.text*)} .rodata : {*(.rodata*)} .data : {*(.data*)} .bss : {*(.bss*)} __stack_top = 0x80100000;}')
subprocess.run([str(BIN/'riscv-none-elf-gcc.exe'),'-march=rv32i_zicsr_zifencei','-mabi=ilp32','-Os','-ffreestanding','-fno-builtin','-mno-relax','-msmall-data-limit=0','-nostdlib','-I'+str(ROOT/'firmware/vision'),'-T',str(OUT/'link.ld'),str(OUT/'start.S'),str(OUT/'test.c'),str(ROOT/'firmware/vision/flyhash.c'),'-lgcc','-o',str(OUT/'test.elf')],check=True)
r=subprocess.run(['F:/Efinity/efinity-riscv-ide-2026.1/qemu/qemu-system-riscv32.exe','-M','virt','-cpu','rv32,m=false,a=false,c=false,f=false,d=false','-nographic','-bios','none','-kernel',str(OUT/'test.elf')],capture_output=True,text=True,timeout=30)
(OUT/'test.log').write_text(r.stdout+r.stderr)
assert r.returncode==0 and 'PASS RV32I fusion' in r.stdout,(r.returncode,r.stdout,r.stderr)
print(r.stdout.strip())
