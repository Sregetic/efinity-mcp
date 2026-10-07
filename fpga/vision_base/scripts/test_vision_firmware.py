"""Run the production FlyHash C on RV32I QEMU against the existing reference."""
import json,random,re,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'models'))
from flyhash import encode,edge_features
OUT=ROOT/'results/soc_review_20261006/firmware_test';OUT.mkdir(parents=True,exist_ok=True)
BIN=Path('F:/Efinity/efinity-riscv-ide-2026.1/toolchain/bin')
QEMU='F:/Efinity/efinity-riscv-ide-2026.1/qemu/qemu-system-riscv32.exe'
rng=random.Random(2210)
vectors=[[0]*64,[255]*64,list(range(64)),[255-4*i for i in range(64)]]
vectors += [[rng.randrange(256) for _ in range(64)] for _ in range(28)]
real=json.loads((ROOT/'results/resource_trials_20261005/debug_512_flyhash/edge.json').read_text())['words']
planes=[[0]*4050,[0xffffffff]*4050,[rng.getrandbits(32) for _ in range(4050)],real]
features=[edge_features(bytes((word>>i)&1 for word in plane for i in range(32)),480,270,(0,0,480,270)) for plane in planes]
def array(name,ctype,rows):
 return f'static const {ctype} {name}[{len(rows)}][{len(rows[0])}]={{'+','.join('{'+','.join(str(x)+'u' for x in row)+'}' for row in rows)+'};\n'
source='#include "flyhash.h"\n'+array('inputs','uint8_t',vectors)+array('planes','uint32_t',planes)+array('features','uint8_t',features)
source+=array('hashes','uint32_t',[[(encode(v)>>(32*i))&0xffffffff for i in range(8)] for v in vectors+features])
source+='''
static unsigned plane;
static uint32_t read_word(unsigned i){return planes[plane][i];}
static void puts_uart(const char *s){while(*s)*(volatile unsigned char *)0x10000000=*s++;}
static void finish(unsigned ok){*(volatile unsigned *)0x100000=ok?0x5555:0x3333;for(;;);}
void main(void){
 uint8_t f[64];uint32_t h[8];
 for(unsigned n=0;n<32;n++){flyhash_encode(inputs[n],h);for(unsigned j=0;j<8;j++)if(h[j]!=hashes[n][j]){puts_uart("FAIL hash\\n");finish(0);}}
 for(plane=0;plane<4;plane++){
  flyhash_bitmap(read_word,f);
  for(unsigned j=0;j<64;j++)if(f[j]!=features[plane][j]){puts_uart("FAIL occupancy\\n");finish(0);}
  flyhash_encode(f,h);for(unsigned j=0;j<8;j++)if(h[j]!=hashes[32+plane][j]){puts_uart("FAIL plane hash\\n");finish(0);}
 }
 puts_uart("PASS RV32I FlyHash 32 vectors and 4 complete 480x270 bitmaps (including board readback)\\n");finish(1);
}
void trap(void){puts_uart("FAIL trap\\n");finish(0);}
'''
(OUT/'test.c').write_text(source)
(OUT/'start.S').write_text('.section .text.start,"ax"\n.global _start\n_start:\n la sp,__stack_top\n la t0,trap\n csrw mtvec,t0\n call main\n j trap\n')
(OUT/'link.ld').write_text('OUTPUT_ARCH(riscv)\nENTRY(_start)\nSECTIONS{. = 0x80000000; .text : {*(.text.start) *(.text*)} .rodata : {*(.rodata*)} .data : {*(.data*) *(.sdata*)} .bss : {*(.bss*) *(.sbss*)} __stack_top = 0x80100000;}')
subprocess.run([str(BIN/'riscv-none-elf-gcc.exe'),'-march=rv32i_zicsr_zifencei','-mabi=ilp32','-Os','-flto','-ffunction-sections','-fdata-sections','-ffreestanding','-fno-builtin',
 '-msmall-data-limit=0','-mno-relax','-nostdlib','-I'+str(ROOT/'firmware/vision'),'-T',str(OUT/'link.ld'),str(OUT/'start.S'),
 str(OUT/'test.c'),str(ROOT/'firmware/vision/flyhash.c'),'-lgcc','-o',str(OUT/'test.elf')],check=True)
dis=subprocess.check_output([str(BIN/'riscv-none-elf-objdump.exe'),'-d',str(OUT/'test.elf')],text=True)
assert not re.search(r'\t(?:mul\w*|div\w*|rem\w*)\s',dis),'unexpected M instruction'
(OUT/'test.dis').write_text(dis)
command=[QEMU,'-M','virt','-cpu','rv32,m=false,a=false,c=false,f=false,d=false','-nographic','-bios','none','-kernel',str(OUT/'test.elf')]
r=subprocess.run(command,capture_output=True,text=True,timeout=60)
(OUT/'test.log').write_text(r.stdout+r.stderr)
assert r.returncode==0 and 'PASS RV32I FlyHash' in r.stdout,(r.returncode,r.stdout,r.stderr)
print(r.stdout.strip())
