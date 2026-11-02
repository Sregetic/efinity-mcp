"""RV32I executes the production boot parser/copy/CRC against a Flash byte fixture."""

import argparse
import json
import struct
import subprocess
import zlib
from pathlib import Path

from pack_vision_boot import pack, validate_package

ROOT = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser()
p.add_argument("--elf", type=Path, default=ROOT / "build/firmware/vision.elf")
p.add_argument("--output-dir", type=Path, default=ROOT / "build/tests/spi_boot")
args = p.parse_args()
OUT = args.output_dir
OUT.mkdir(parents=True, exist_ok=True)
weights = OUT / "fixture_weights.bin"
weights.write_bytes(bytes(range(32)))
image = pack(args.elf, weights)
unweighted = pack(args.elf)
uh = validate_package(unweighted)
assert uh[4] == uh[6] == 0
header = struct.unpack_from("<8I", image)
assert header[2] > 3840 and len(image) == 32 + header[2] + header[4]
assert header[5] == zlib.crc32(image[32 : 32 + header[2]]) and header[6] == zlib.crc32(
    image[32 + header[2] :]
)
for damaged in [
    image[:31],
    image[:-1],
    image + b"\x00",
    image[:28] + bytes([image[28] ^ 1]) + image[29:],
    image[:32] + bytes([image[32] ^ 1]) + image[33:],
]:
    try:
        validate_package(damaged)
    except ValueError:
        pass
    else:
        raise AssertionError("Damaged boot package accepted")
source = r"""
#include <stdint.h>
static const uint8_t original[]={BYTES};
static uint8_t image[sizeof(original)],app[sizeof(original)] __attribute__((aligned(4))),weights[sizeof(original)] __attribute__((aligned(4)));
static uint32_t gpio[3],status[5],control,position,scenario;
#define BOOT_SPI_TEST
#define GPIO(off) gpio[(off)/4]
#define STATUS status
#define BOOT_DEST(part) ((volatile uint8_t *)(part?weights:app))
#define BOOT_CONTROL_MAGIC control
static void finish(unsigned ok){*(volatile unsigned *)0x100000=ok?0x5555:0x3333;for(;;);}
static void puts(const char*s){while(*s)*(volatile unsigned char*)0x10000000=*s++;}
static void fail(unsigned code){
 static const uint8_t expected[]={7,2,3,4,5,6,4,4,7,7};
 if(code!=expected[scenario]){puts("FAIL boot status\n");finish(0);}
 puts("PASS rejected corrupt SPI boot image\n");finish(1);
}
static uint8_t spi_byte(uint8_t v){
 unsigned n=position++;if(n==1)return scenario==2?0xff:0xef;if(n==2)return 0x60;if(n==3)return 0x17;
 if(n<8)return 0;return n-8<sizeof(image)?image[n-8]:0xff;
}
#include "boot_spi.c"
void main(void){
 scenario=*(volatile uint32_t *)0x80200000;
 for(unsigned i=0;i<sizeof(image);i++)image[i]=original[i];
 uint32_t *h=(uint32_t*)image;
 if(scenario==1)for(unsigned i=0;i<32;i++)image[i]=255;
 if(scenario==3)image[28]^=1;
 if(scenario==4)image[32]^=1;
 if(scenario==5)image[32+h[2]]^=1;
 if(scenario==9){h[4]=h[6]=0;uint32_t crc=~0u;for(unsigned i=0;i<28;i++)crc=crc_byte(crc,image[i]);h[7]=~crc;}
 if(scenario>=6&&scenario<=8){if(scenario==6)h[2]=0x400001;else if(scenario==7)h[3]++;else {h[4]--;uint32_t crc=~0u;for(unsigned i=0;i<h[4];i++)crc=crc_byte(crc,image[32+h[2]+i]);h[6]=~crc;}uint32_t crc=~0u;for(unsigned i=0;i<28;i++)crc=crc_byte(crc,image[i]);h[7]=~crc;}
 uint32_t entry=boot_spi();
 if(scenario==1){if(entry||status[1]!=2||gpio[2])finish(0);puts("PASS blank Flash USER1 development boot\n");finish(1);}
 if((scenario&&scenario!=8&&scenario!=9)||entry!=0x07000000||status[1]!=7||gpio[2]||control)finish(0);
 for(unsigned i=0;i<h[2];i++)if(app[i]!=image[32+i])finish(0);
 for(unsigned i=0;i<h[4];i++)if(weights[i]!=image[32+h[2]+i])finish(0);
 if(scenario==8&&weights[h[4]])finish(0);
 puts("PASS SPI RV32I production header CRC, >3840B program, weights, exact copies and OE release\n");finish(1);
}
void trap(void){finish(0);}
""".replace("BYTES", ",".join(map(str, image)))
(OUT / "test.c").write_text(source)
(OUT / "start.S").write_text(
    '.section .text.start,"ax"\n.global _start\n_start:\n la sp,__stack_top\n la t0,trap\n csrw mtvec,t0\n call main\n j trap\n'
)
(OUT / "link.ld").write_text(
    "OUTPUT_ARCH(riscv)\nENTRY(_start)\nSECTIONS{. = 0x80000000; .text : {*(.text.start) *(.text*) *(.boot.text*)} .rodata : {*(.rodata*)} .data : {*(.data*) *(.sdata*)} .bss : {*(.bss*) *(.sbss*)} __stack_top = 0x81000000;}"
)
BIN = Path("F:/Efinity/efinity-riscv-ide-2026.1/toolchain/bin")
subprocess.run(
    [
        str(BIN / "riscv-none-elf-gcc.exe"),
        "-march=rv32i_zicsr_zifencei",
        "-mabi=ilp32",
        "-Os",
        "-ffreestanding",
        "-fno-builtin",
        "-mno-relax",
        "-msmall-data-limit=0",
        "-nostdlib",
        "-I" + str(ROOT / "firmware/vision"),
        "-T",
        str(OUT / "link.ld"),
        str(OUT / "start.S"),
        str(OUT / "test.c"),
        "-lgcc",
        "-o",
        str(OUT / "test.elf"),
    ],
    check=True,
)
logs = []
for scenario in range(10):
    r = subprocess.run(
        [
            "F:/Efinity/efinity-riscv-ide-2026.1/qemu/qemu-system-riscv32.exe",
            "-M",
            "virt",
            "-cpu",
            "rv32,m=false,a=false,c=false,f=false,d=false",
            "-nographic",
            "-bios",
            "none",
            "-kernel",
            str(OUT / "test.elf"),
            "-device",
            f"loader,addr=0x80200000,data={scenario},data-len=4",
        ],
        capture_output=True,
        text=True,
        timeout=30,
    )
    assert r.returncode == 0 and "PASS" in r.stdout, (
        scenario,
        r.returncode,
        r.stdout,
        r.stderr,
    )
    logs.append(dict(scenario=scenario, output=r.stdout.strip()))
    print(scenario, r.stdout.strip())
(OUT / "result.json").write_text(json.dumps(logs, indent=2))
