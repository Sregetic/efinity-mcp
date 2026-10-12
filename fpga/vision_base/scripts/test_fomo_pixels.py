"""Execute production packed-RGB preprocessing and target merging on RV32I."""
import random
import struct
import subprocess
import sys
from pathlib import Path
from load_vision_ddr import ROOT, IDE
sys.path.insert(0, str(ROOT/'models'))
from fomo_post import components

out = ROOT/'results/roi_fomo_20261012/pixels_test'
out.mkdir(parents=True, exist_ok=True)
fixtures = []
for name in ['blank', 'circle', 'rectangle', 'triangle']:
    fixtures.append(struct.unpack('<576b', (ROOT/'models/shape_fomo/test_vectors'/f'{name}_expected_output.bin').read_bytes()))
rng = random.Random(2210)
fixtures += [tuple(rng.randrange(-128, 128) for _ in range(576)) for _ in range(40)]
# All connected; diagonal connectivity; threshold equality; adjacent different classes.
for points in [range(144), [i*13 for i in range(12)], [], [0, 1, 12, 13, 142, 143]]:
    data = [-128]*576
    for i in range(144):
        data[4*i] = -1
    for i in points:
        data[4*i+(i%3+1 if len(points)==6 else 2)] = 0
    fixtures.append(tuple(data))
checks = []
arrays = []
for n, data in enumerate(fixtures):
    arrays.append('{'+','.join(map(str, data))+'}')
    boxes, best = components(data)
    checks.append(f'count=fomo_components(vectors[{n}],boxes,&best);check(count=={len(boxes)}&&best=={best});')
    for i, b in enumerate(boxes):
        checks.append('check('+ '&&'.join(f'boxes[{i}].{k}=={v}' for k, v in b.items())+');')
source = r'''
#include <stdint.h>
#include "fomo_pixels.h"
static uint16_t pixels[1920*1080],packed[9216];static int8_t tensor[27648];static uint8_t gray[1024];
static void finish(unsigned ok){*(volatile unsigned*)0x100000=ok?0x5555:0x3333;for(;;);}
static void check_line(unsigned ok,unsigned line){if(!ok){const char*h="0123456789abcdef";for(int i=12;i>=0;i-=4)*(volatile unsigned char*)0x10000000=h[(line>>i)&15];finish(0);}}
#define check(v) check_line((v),__LINE__)
static void roi(unsigned x,unsigned y,unsigned w,unsigned h){
 fomo_rgb_roi(pixels,x|(y<<16),w|(h<<16),packed,tensor);
 for(unsigned r=0;r<96;r++)for(unsigned c=0;c<96;c++){
  unsigned i=r*96+c;uint16_t p=pixels[(y+r*h/96)*1920+x+c*w/96];uint8_t rgb[3];fomo_rgb(p,rgb);
  check(packed[i]==p);for(unsigned j=0;j<3;j++)check((int)tensor[i*3+j]+128==rgb[j]);
 }
 fomo_gray_roi(pixels,x|(y<<16),w|(h<<16),gray);
 for(unsigned r=0;r<32;r++)for(unsigned c=0;c<32;c++){
  uint8_t rgb[3];fomo_rgb(pixels[(y+r*h/32)*1920+x+c*w/32],rgb);
  check(gray[r*32+c]==(77u*rgb[0]+150u*rgb[1]+29u*rgb[2])/256);
 }
}
'''
source += 'static const int8_t vectors[][576]={'+','.join(arrays)+'};\n'
source += r'''
void main(void){
 for(unsigned p=0;p<65536;p++){
  uint8_t rgb[3];fomo_rgb(p,rgb);
  for(unsigned c=0;c<3;c++){unsigned v=(p>>(10-5*c))&31;check(rgb[c]==((p>>15)?v*8+v/4:v*2));}
 }
 for(unsigned i=0;i<1920*1080;i++)pixels[i]=(uint16_t)(i*251u+(i/1920)*173u);
 roi(0,0,1920,1080);roi(13,7,937,613);roi(1771,990,149,90);roi(1904,1064,16,16);
 struct fomo_detection boxes[144];unsigned count,best;
'''
source += '\n'.join(checks)
source += r'''
 const char*s="PASS RV32I FOMO:65536 packed colors,4 RGB/gray ROIs,48 target grids/threshold/diagonals/boundaries/peak-cell ties\n";
 while(*s)*(volatile unsigned char*)0x10000000=*s++;finish(1);
}
void trap(void){finish(0);}
'''
(out/'test.c').write_text(source)
(out/'start.S').write_text('.section .text.start,"ax"\n.global _start\n_start:\n la sp,__stack_top\n la t0,trap\n csrw mtvec,t0\n call main\n j trap\n')
(out/'link.ld').write_text('OUTPUT_ARCH(riscv)\nENTRY(_start)\nSECTIONS{. = 0x80000000; .text : {*(.text.start) *(.text*)} .rodata : {*(.rodata*)} .data : {*(.data*)} .bss : {*(.bss*)} __stack_top = 0x80700000;}')
subprocess.run([str(IDE/'toolchain/bin/riscv-none-elf-gcc.exe'), '-march=rv32i_zicsr_zifencei', '-mabi=ilp32', '-O2', '-ffreestanding', '-fno-builtin', '-mno-relax', '-msmall-data-limit=0', '-nostdlib', '-I'+str(ROOT/'firmware/vision'), '-T', str(out/'link.ld'), str(out/'start.S'), str(out/'test.c'), str(ROOT/'firmware/vision/flyhash.c'), '-lc', '-lgcc', '-o', str(out/'test.elf')], check=True)
r = subprocess.run([str(IDE/'qemu/qemu-system-riscv32.exe'), '-M', 'virt', '-cpu', 'rv32,m=false,a=false,c=false,f=false,d=false', '-nographic', '-bios', 'none', '-kernel', str(out/'test.elf')], capture_output=True, text=True, timeout=60)
(out/'test.log').write_text(r.stdout+r.stderr)
assert r.returncode == 0 and 'PASS RV32I FOMO' in r.stdout, (r.returncode, r.stdout, r.stderr)
print(r.stdout.strip())
