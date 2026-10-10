"""Float/Q14 comparison and production C on RV32I; never claims card accuracy."""
import json,random,subprocess,sys
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'models'))
from connectome import fixed,floating,Q,GRAPH
OUT=ROOT/'results/connectome_20261010';OUT.mkdir(parents=True,exist_ok=True)
rng=random.Random(2210)
vectors=[[-128]*128,[127]*128,list(range(-128,0)),[0]*128]
vectors.extend([[rng.randrange(-128,128) for i in range(128)] for n in range(28)])
board=ROOT/'results/ai_autoboot_20261010/ai_verified_5khz/result.json'
vectors.append(json.loads(board.read_text())['features'])
expected=[fixed(v) for v in vectors]
errors=[float(np.max(np.abs(floating(v)-q.astype(float)/Q))) for v,q in zip(vectors,expected)]
assert max(errors)<0.002 and all(np.max(np.abs(q.astype(np.int32)))<=Q for q in expected)
assert not np.array_equal(expected[0],expected[1]),'Circuit lost its input dependence'
assert np.array_equal(fixed(vectors[-1]),fixed(vectors[-1])),'Snapshot state leaked between ROIs'
def array(name,kind,rows):return f'static const {kind} {name}[{len(rows)}][{len(rows[0])}]={{'+','.join('{'+','.join(map(str,map(int,row)))+'}' for row in rows)+'};\n'
source='#include "connectome.h"\n'+array('vectors','int8_t',vectors)+array('expected','int16_t',expected)
source+='''
static void finish(unsigned ok){*(volatile unsigned *)0x100000=ok?0x5555:0x3333;for(;;);}
void main(void){int16_t h[80];
 for(unsigned n=0;n<33;n++){connectome_snapshot(vectors[n],h);for(unsigned i=0;i<80;i++)if(h[i]!=expected[n][i])finish(0);}
 const char *p="PASS RV32I connectome33 inputs x80 Q14 states, including verified camera ROI\\n";
 while(*p)*(volatile unsigned char *)0x10000000=*p++;finish(1);
}
void trap(void){finish(0);}
'''
(OUT/'test.c').write_text(source)
(OUT/'start.S').write_text('.section .text.start,"ax"\n.global _start\n_start:\n la sp,__stack_top\n la t0,trap\n csrw mtvec,t0\n call main\n j trap\n')
(OUT/'link.ld').write_text('OUTPUT_ARCH(riscv)\nENTRY(_start)\nSECTIONS{. = 0x80000000; .text : {*(.text.start) *(.text*)} .rodata : {*(.rodata*)} .data : {*(.data*) *(.sdata*)} .bss : {*(.bss*) *(.sbss*)} __stack_top = 0x80100000;}')
BIN=Path('F:/Efinity/efinity-riscv-ide-2026.1/toolchain/bin')
subprocess.run([str(BIN/'riscv-none-elf-gcc.exe'),'-march=rv32i_zicsr_zifencei','-mabi=ilp32','-Os','-ffreestanding','-fno-builtin','-mno-relax','-msmall-data-limit=0','-nostdlib','-I'+str(ROOT/'firmware/vision'),'-T',str(OUT/'link.ld'),str(OUT/'start.S'),str(OUT/'test.c'),'-lgcc','-o',str(OUT/'test.elf')],check=True)
r=subprocess.run(['F:/Efinity/efinity-riscv-ide-2026.1/qemu/qemu-system-riscv32.exe','-M','virt','-cpu','rv32,m=false,a=false,c=false,f=false,d=false','-nographic','-bios','none','-kernel',str(OUT/'test.elf')],capture_output=True,text=True,timeout=120)
(OUT/'test.log').write_text(r.stdout+r.stderr);assert r.returncode==0 and 'PASS RV32I connectome' in r.stdout,(r.returncode,r.stdout,r.stderr)
result=dict(passed=True,vectors=len(vectors),compared_c_q14_states=len(vectors)*80,max_float_q14_state_error=max(errors),max_float_readout_feature_error=4*max(errors),camera_frame_id=json.loads(board.read_text())['frame_id'],trained_readout=False,real_accuracy_verified=False)
(OUT/'host_validation.json').write_text(json.dumps(result,indent=2));print(r.stdout.strip());print(json.dumps(result,indent=2))
