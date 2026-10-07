"""Build the RV32I DDR application and its ROM-to-DDR bootstrap."""
import argparse,json,re,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'firmware/vision'
p=argparse.ArgumentParser()
p.add_argument('--load-method',choices=['embedded','user1'],default='embedded')
p.add_argument('--main',type=Path,default=SRC/'main.c')
p.add_argument('--output-dir',type=Path)
p.add_argument('--mulhi-cfu',action='store_true',help='Requires a bitstream with CFU function1; never load this ELF on the old dot4-only build')
a=p.parse_args()
OUT=a.output_dir.resolve() if a.output_dir else ROOT/'artifacts/vision_soc'/('firmware' if a.load_method=='embedded' else 'ddr_firmware')
BIN=Path('F:/Efinity/efinity-riscv-ide-2026.1/toolchain/bin')
OUT.mkdir(parents=True,exist_ok=True)
cmd=[str(BIN/'riscv-none-elf-gcc.exe'),'-march=rv32i_zicsr_zifencei','-mabi=ilp32',
 '-Os','-flto','-ffunction-sections','-fdata-sections','-ffreestanding','-fno-builtin','-fno-pic','-msmall-data-limit=0','-mno-relax',
 '-nostdlib','-I'+str(SRC),*(['-DVISION_MULHI_CFU'] if a.mulhi_cfu else []),'-Wl,--gc-sections','-Wl,-Map='+str(OUT/'vision.map'),
 '-T',str(SRC/('link.ld' if a.load_method=='embedded' else 'link_ddr.ld')),
 str(SRC/'start.S'),str(a.main.resolve()),str(SRC/'flyhash.c'),'-lgcc','-o',str(OUT/'vision.elf')]
subprocess.run(cmd,check=True)
subprocess.run([str(BIN/'riscv-none-elf-objcopy.exe'),'-O','ihex',str(OUT/'vision.elf'),str(OUT/'vision.hex')],check=True)
with (OUT/'vision.dis').open('w') as f:
 subprocess.run([str(BIN/'riscv-none-elf-objdump.exe'),'-d',str(OUT/'vision.elf')],stdout=f,check=True)
dis=(OUT/'vision.dis').read_text()
assert not re.search(r'\b(?:mcycleh?|minstreth?|rdcycleh?|rdinstreth?)\b',dis),'Minimal Sapphire counter CSRs are unmapped; use APB timer0x30'
subprocess.run([str(BIN/'riscv-none-elf-size.exe'),str(OUT/'vision.elf')],check=True)
(OUT/'build.json').write_text(json.dumps(dict(command=cmd,isa='RV32I_Zicsr_Zifencei',
 muldiv=False,mulhi_cfu=a.mulhi_cfu,cache_kb=2,application_base='0x07000000',load_method=a.load_method,
 boot_base='0xf9000000' if a.load_method=='embedded' else None),indent=2))
print('BUILT',OUT/'vision.hex')
