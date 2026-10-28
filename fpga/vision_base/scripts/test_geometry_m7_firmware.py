"""RV32I service contracts and exact C backend outputs against host fixtures."""
import json
import argparse
import subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--service-only',action='store_true');p.add_argument('--cases-dir',type=Path,default=Path('results/geometry_edge_split_20261028/host_final'));p.add_argument('--output-dir',type=Path,default=Path('results/geometry_edge_split_20261028/rv32_final'));args=p.parse_args()
ROOT=Path(__file__).resolve().parents[1]
OUT=args.output_dir.resolve();OUT.mkdir(parents=True,exist_ok=True)
BIN=Path('F:/Efinity/efinity-riscv-ide-2026.1/toolchain/bin')
(OUT/'start.S').write_text('.section .text.start,"ax"\n.global _start\n_start:\n la sp,__stack_top\n la t0,trap\n csrw mtvec,t0\n call main\n j trap\n',encoding='utf-8')
(OUT/'link.ld').write_text('OUTPUT_ARCH(riscv)\nENTRY(_start)\nSECTIONS{. = 0x80000000; .text : {*(.text.start) *(.text*)} .rodata : {*(.rodata*)} .data : {*(.data*) *(.sdata*)} .bss : {*(.bss*) *(.sbss*)} __stack_top = 0x81000000;}',encoding='utf-8')
def run(name,sources):
 command=[str(BIN/'riscv-none-elf-gcc.exe'),'-march=rv32i_zicsr_zifencei','-mabi=ilp32','-O2','-DVISION_MULHI_CFU','-DINT8_TEST','-ffreestanding','-fno-builtin','-mno-relax','-msmall-data-limit=0','-ffunction-sections','-fdata-sections','-nostdlib','-Wl,--gc-sections','-I'+str(ROOT/'firmware/vision'),'-T',str(OUT/'link.ld'),str(OUT/'start.S'),*map(str,sources),'-lgcc','-o',str(OUT/(name+'.elf'))]
 r=subprocess.run(command,capture_output=True);(OUT/(name+'.compile.log')).write_bytes(r.stdout+r.stderr);r.check_returncode()
 r=subprocess.run(['F:/Efinity/efinity-riscv-ide-2026.1/qemu/qemu-system-riscv32.exe','-M','virt','-cpu','rv32,m=false,a=false,c=false,f=false,d=false','-nographic','-bios','none','-kernel',str(OUT/(name+'.elf'))],capture_output=True,timeout=180)
 (OUT/(name+'.log')).write_bytes(r.stdout+r.stderr)
 assert r.returncode==0 and b'PASS' in r.stdout,(name,r.returncode,r.stdout,r.stderr)
 print(r.stdout.decode().strip())
run('service',[ROOT/'sim/test_geometry_m7_service.c'])
if args.service_only:raise SystemExit(0)
results=json.loads((args.cases_dir/'result.json').read_text(encoding='utf-8'))
data='.section .rodata\n.balign 16\n.global cases\ncases:\n.incbin "'+(args.cases_dir.resolve()/'cases.bin').as_posix()+'"\n'
(OUT/'data.S').write_text(data,encoding='utf-8')
expect=[]
for r in results:
 row=[len(r['boxes']),r['more']]
 for b in r['boxes']:row.extend(b)
 row.extend([0]*(22-len(row)));expect.append('{'+','.join(map(str,row))+'}')
source=r'''#include <stdint.h>
#include "geometry_m7.h"
#include "geometry_face.h"
extern const uint8_t cases[];
void*memset(void*p,int v,unsigned n){volatile unsigned char*b=p;while(n--)*b++=v;return p;}
static void text(const char*s){while(*s)*(volatile unsigned char*)0x10000000=*s++;}
static void finish(unsigned ok){*(volatile unsigned*)0x100000=ok?0x5555:0x3333;for(;;);}
static unsigned expected[][22]={EXPECT};
void main(void){
 for(unsigned n=0;n<sizeof(expected)/sizeof(expected[0]);n++){
  const uint8_t*input=cases+n*(16200+129600);m7_begin((const uint32_t*)input);
  while(!m7_step(512));m7_face_begin((const uint32_t*)input,m7_contours,m7_contour_count);while(!m7_face_step(8));
  for(unsigned i=0;i<m7_face_count;i++)m7_retain(m7_boxes,&m7_count,&m7_more,m7_face_boxes[i]);m7_more|=m7_face_more;
  if(m7_count!=expected[n][0]||m7_more!=expected[n][1]){text("FAIL RV32I count\n");finish(0);}
  for(unsigned i=0;i<m7_count;i++){
   const struct m7_box*b=&m7_boxes[i];unsigned*v=expected[n]+2+i*5;
   if(b->klass!=v[0]||b->x0!=v[1]||b->y0!=v[2]||b->x1!=v[3]||b->y1!=v[4]){text("FAIL RV32I box\n");finish(0);}
  }
 }
 text("PASS RV32I all shared-edge geometry fixtures equal host boxes\n");finish(1);
}
void trap(void){text("TRAP\n");finish(0);}
'''.replace('EXPECT',','.join(expect))
(OUT/'backend.c').write_text(source,encoding='utf-8')
run('backend',[OUT/'backend.c',OUT/'data.S',*[ROOT/'firmware/vision'/p for p in ['geometry_m7.c','geometry_face.c']]])
