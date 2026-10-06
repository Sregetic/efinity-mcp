"""Build the RV32I DDR application and its ROM-to-DDR bootstrap."""
import json,re,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'firmware/vision';OUT=ROOT/'artifacts/vision_soc/firmware'
BIN=Path('F:/Efinity/efinity-riscv-ide-2026.1/toolchain/bin')
OUT.mkdir(parents=True,exist_ok=True)
cmd=[str(BIN/'riscv-none-elf-gcc.exe'),'-march=rv32i_zicsr_zifencei','-mabi=ilp32',
 '-Os','-ffreestanding','-fno-builtin','-fno-pic','-msmall-data-limit=0','-mno-relax',
 '-nostdlib','-Wl,--gc-sections','-Wl,-Map='+str(OUT/'vision.map'),'-T',str(SRC/'link.ld'),
 str(SRC/'start.S'),str(SRC/'main.c'),str(SRC/'flyhash.c'),'-lgcc','-o',str(OUT/'vision.elf')]
subprocess.run(cmd,check=True)
subprocess.run([str(BIN/'riscv-none-elf-objcopy.exe'),'-O','ihex',str(OUT/'vision.elf'),str(OUT/'vision.hex')],check=True)
with (OUT/'vision.dis').open('w') as f:
 subprocess.run([str(BIN/'riscv-none-elf-objdump.exe'),'-d',str(OUT/'vision.elf')],stdout=f,check=True)
dis=(OUT/'vision.dis').read_text()
assert not re.search(r'\b(?:mcycleh?|minstreth?|rdcycleh?|rdinstreth?)\b',dis),'Minimal Sapphire counter CSRs are unmapped; use APB timer0x30'
subprocess.run([str(BIN/'riscv-none-elf-size.exe'),str(OUT/'vision.elf')],check=True)
(OUT/'build.json').write_text(json.dumps(dict(command=cmd,isa='RV32I_Zicsr_Zifencei',
 muldiv=False,cache_kb=2,application_base='0x07000000',boot_base='0xf9000000'),indent=2))
print('BUILT',OUT/'vision.hex')
