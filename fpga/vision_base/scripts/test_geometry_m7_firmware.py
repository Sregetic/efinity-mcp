"""RV32I service contracts and exact C backend outputs against host fixtures."""
import json
import argparse
import subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--service-only',action='store_true');p.add_argument('--fine-only',action='store_true');p.add_argument('--letters-cases-dir',type=Path);p.add_argument('--fine-cases-dir',type=Path);p.add_argument('--cases-dir',type=Path,default=Path('results/geometry_edge_split_20261028/host_final'));p.add_argument('--output-dir',type=Path,default=Path('results/geometry_edge_split_20261028/rv32_final'));args=p.parse_args()
if args.fine_only and not args.fine_cases_dir:p.error('--fine-only requires --fine-cases-dir')
ROOT=Path(__file__).resolve().parents[1]
OUT=args.output_dir.resolve();OUT.mkdir(parents=True,exist_ok=True)
BIN=Path('F:/Efinity/efinity-riscv-ide-2026.1/toolchain/bin')
(OUT/'start.S').write_text('.section .text.start,"ax"\n.global _start\n_start:\n la sp,__stack_top\n la t0,trap\n csrw mtvec,t0\n call main\n j trap\n',encoding='utf-8')
(OUT/'link.ld').write_text('OUTPUT_ARCH(riscv)\nENTRY(_start)\nSECTIONS{. = 0x80000000; .text : {*(.text.start) *(.text*)} .rodata : {*(.rodata*)} .data : {*(.data*) *(.sdata*)} .bss : {*(.bss*) *(.sbss*)} __stack_top = 0x81000000;}',encoding='utf-8')
def run(name,sources,icount=False):
 if args.fine_only and name!='fine':return
 command=[str(BIN/'riscv-none-elf-gcc.exe'),'-march=rv32i_zicsr_zifencei','-mabi=ilp32','-O2','-DVISION_MULHI_CFU','-DINT8_TEST','-ffreestanding','-fno-builtin','-mno-relax','-msmall-data-limit=0','-ffunction-sections','-fdata-sections','-nostdlib','-Wl,--gc-sections','-I'+str(ROOT/'firmware/vision'),'-T',str(OUT/'link.ld'),str(OUT/'start.S'),*map(str,sources),'-lgcc','-o',str(OUT/(name+'.elf'))]
 r=subprocess.run(command,capture_output=True);(OUT/(name+'.compile.log')).write_bytes(r.stdout+r.stderr);r.check_returncode()
 r=subprocess.run(['F:/Efinity/efinity-riscv-ide-2026.1/qemu/qemu-system-riscv32.exe','-M','virt','-cpu','rv32,m=false,a=false,c=false,f=false,d=false','-nographic','-bios','none',*(['-icount','shift=0,align=off,sleep=off'] if icount else []),'-kernel',str(OUT/(name+'.elf'))],capture_output=True,timeout=180)
 (OUT/(name+'.log')).write_bytes(r.stdout+r.stderr)
 assert r.returncode==0 and b'PASS' in r.stdout,(name,r.returncode,r.stdout,r.stderr)
 print(r.stdout.decode().strip())
run('service',[ROOT/'sim/test_geometry_m7_service.c',ROOT/'firmware/vision/target_track.c'])
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
#include "geometry_letters.h"
extern const uint8_t cases[];
void*memset(void*p,int v,unsigned n){volatile unsigned char*b=p;while(n--)*b++=v;return p;}
static void text(const char*s){while(*s)*(volatile unsigned char*)0x10000000=*s++;}
static void finish(unsigned ok){*(volatile unsigned*)0x100000=ok?0x5555:0x3333;for(;;);}
static unsigned expected[][22]={EXPECT};
void main(void){
 for(unsigned n=0;n<sizeof(expected)/sizeof(expected[0]);n++){
  const uint8_t*input=cases+n*(16200+129600);m7_begin((const uint32_t*)input);
  while(!m7_step(512));m7_letters_begin((const uint32_t*)input);while(!m7_letters_step(64));m7_face_begin((const uint32_t*)input,m7_contours,m7_contour_count);while(!m7_face_step(8));
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
run('backend',[OUT/'backend.c',OUT/'data.S',*[ROOT/'firmware/vision'/p for p in ['geometry_m7.c','geometry_face.c','geometry_letters.c']]])

if args.letters_cases_dir:
 records=json.loads((args.letters_cases_dir/'result.json').read_text(encoding='utf-8'))['frames']
 expected=[];data='.section .rodata\n.balign 16\n.global letter_cases\nletter_cases:\n'
 for name,r in records.items():
  data+='.incbin "'+(args.letters_cases_dir.resolve()/(name+'.bin')).as_posix()+'"\n'
  expected.extend([len(r['boxes']),r['more'],len(r['candidates'])])
  for b in r['boxes']:expected.extend(b)
  for c in r['candidates']:expected.extend([c[2],c[0],c[1],c[7],c[8]])
 (OUT/'letters_data.S').write_text(data,encoding='utf-8')
 source=r'''#include <stdint.h>
#include "geometry_letters.c"
extern const uint32_t letter_cases[];
static const uint16_t expected[]={EXPECTED};
void*memset(void*p,int v,unsigned n){volatile unsigned char*b=p;while(n--)*b++=v;return p;}
static void text(const char*s){while(*s)*(volatile unsigned char*)0x10000000=*s++;}
static void finish(unsigned ok){*(volatile unsigned*)0x100000=ok?0x5555:0x3333;for(;;);}
static void equal(unsigned a,unsigned b){if(a!=b){text("FAIL RV32I letters\n");finish(0);}}
static void box_equal(const struct m7_box*b,unsigned *p){
 equal(b->klass,expected[(*p)++]);equal(b->x0,expected[(*p)++]);equal(b->y0,expected[(*p)++]);equal(b->x1,expected[(*p)++]);equal(b->y1,expected[(*p)++]);
}
void main(void){
 unsigned p=0;
 for(unsigned n=0;n<FRAMES;n++){
  const uint32_t*bits=letter_cases+n*M7_WORDS;m7_begin(bits);while(!m7_step(512));m7_letters_begin(bits);while(!m7_letters_step(64));
  equal(m7_count,expected[p++]);equal(m7_more,expected[p++]);equal(count,expected[p++]);
  for(unsigned i=0;i<m7_count;i++)box_equal(m7_boxes+i,&p);
  for(unsigned i=0;i<count;i++)box_equal(&candidates[i].box,&p);
 }
 equal(p,sizeof(expected)/sizeof(expected[0]));text("PASS RV32I all accepted-edge glyph cases/FRAMES frames/full candidate identities and four displayed boxes equal ASan host\n");finish(1);
}
void trap(void){text("TRAP\n");finish(0);}
'''.replace('EXPECTED',','.join(map(str,expected))).replace('FRAMES',str(len(records)))
 (OUT/'letters.c').write_text(source,encoding='utf-8')
 run('letters',[OUT/'letters.c',OUT/'letters_data.S',ROOT/'firmware/vision/geometry_m7.c'])

if args.fine_cases_dir:
 rows=json.loads((args.fine_cases_dir/'result.json').read_text(encoding='utf-8'))
 data='.section .rodata\n.balign 16\n.global fine_cases\nfine_cases:\n.incbin "'+(args.fine_cases_dir.resolve()/'cases.bin').as_posix()+'"\n'
 (OUT/'fine_data.S').write_text(data,encoding='utf-8')
 expected=[]
 for r in rows:
  a=[len(r['coarse_faces']),len(r['face_boxes']),len(r['merged_boxes']),r['more'],r['face_more']]
  for key in ['coarse_faces','face_boxes','merged_boxes']:
   for b in r[key]:a.extend(b)
   a.extend([0]*(20-5*len(r[key])))
  expected.append('{'+','.join(map(str,a))+'}')
 source=r'''#include <stdint.h>
#include "geometry_face_refine.h"
#include "geometry_letters.h"
extern const uint8_t fine_cases[];
static const uint32_t expected[][65]={EXPECTED};
void*memset(void*p,int v,unsigned n){volatile unsigned char*b=p;while(n--)*b++=v;return p;}
static void text(const char*s){while(*s)*(volatile unsigned char*)0x10000000=*s++;}
static void number(uint32_t v){char b[12];unsigned n=0;do{b[n++]='0'+v%10;v/=10;}while(v);while(n)*(volatile unsigned char*)0x10000000=b[--n];}
static void finish(unsigned ok){*(volatile unsigned*)0x100000=ok?0x5555:0x3333;for(;;);}
static uint32_t counter(void){uint32_t v;__asm__ volatile("rdinstret %0":"=r"(v)::"memory");return v;}
static void check(unsigned yes){if(!yes){text("FAIL fine RV32I\n");finish(0);}}
static void boxes(const struct m7_box*b,unsigned n,const uint32_t*e){
 for(unsigned i=0;i<n;i++){check(b[i].klass==e[0]&&b[i].x0==e[1]&&b[i].y0==e[2]&&b[i].x1==e[3]&&b[i].y1==e[4]);e+=5;}
}
void main(void){
 uint32_t t=counter();__asm__ volatile(".rept 1000\nnop\n.endr":::"memory");uint32_t delta=counter()-t;check(delta>=1000&&delta<=1020);
 text("COUNTER_1000_NOP ");number(delta);text("\n");
 for(unsigned n=0;n<sizeof(expected)/sizeof(expected[0]);n++){
  const uint8_t*input=fine_cases+n*(16200+M7_CACHE_W*M7_CACHE_H);const uint32_t*e=expected[n];
  uint32_t begin=counter();m7_begin((const uint32_t*)input);while(!m7_step(512));m7_letters_begin((const uint32_t*)input);while(!m7_letters_step(64));
  uint32_t geometry=counter();m7_face_begin((const uint32_t*)input,m7_contours,m7_contour_count);while(!m7_face_step(128));
  check(m7_face_count==e[0]);boxes(m7_face_boxes,m7_face_count,e+5);uint32_t coarse=counter();
  m7_face_refine_begin(input+16200,96,1);while(!m7_face_refine_step());
  check(m7_face_count==e[1]&&m7_face_more==e[4]);boxes(m7_face_boxes,m7_face_count,e+25);
  for(unsigned i=0;i<m7_face_count;i++)m7_retain(m7_boxes,&m7_count,&m7_more,m7_face_boxes[i]);m7_more|=m7_face_more;
  check(m7_count==e[2]&&m7_more==e[3]);boxes(m7_boxes,m7_count,e+45);
  uint32_t done=counter();text("CASE ");number(n);text(" GEOMETRY_LETTERS ");number(geometry-begin);text(" COARSE_FACE ");number(coarse-geometry);text(" REFINE ");number(done-coarse);text("\n");
 }
 text("PASS RV32I exact local-edge/refined faces and merged geometry equal ASan host\n");finish(1);
}
void trap(void){text("TRAP fine\n");finish(0);}
'''.replace('EXPECTED',','.join(expected))
 (OUT/'fine.c').write_text(source,encoding='utf-8')
 run('fine',[OUT/'fine.c',OUT/'fine_data.S',*[ROOT/'firmware/vision'/p for p in ['geometry_m7.c','geometry_face.c','geometry_letters.c','geometry_fine_edges.c','geometry_face_refine.c']]],icount=True)
