"""All-target history/identity and the existing RV32 shared service, without a board."""

import argparse
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument(
    "--output-dir",
    type=Path,
    default=ROOT / "results/multi_target_motion_20261102/tests",
)
args = parser.parse_args()
OUT = args.output_dir.resolve()
OUT.mkdir(parents=True, exist_ok=True)


def run(name, args, **kwargs):
    r = subprocess.run(list(map(str, args)), capture_output=True, **kwargs)
    (OUT / (name + ".log")).write_bytes(r.stdout + r.stderr)
    r.check_returncode()
    return r.stdout


def wsl(path):
    s = path.resolve().as_posix()
    return "/mnt/" + s[0].lower() + s[2:]


run(
    "host_compile",
    [
        "wsl.exe",
        "-d",
        "Ubuntu-24.04",
        "--exec",
        "gcc",
        "-O2",
        "-g",
        "-fsanitize=address,undefined",
        "-Wall",
        "-Wextra",
        "-I" + wsl(ROOT / "firmware/vision"),
        wsl(ROOT / "sim/test_target_motion.c"),
        "-o",
        wsl(OUT / "motion_host"),
    ],
)
host = run(
    "host",
    ["wsl.exe", "-d", "Ubuntu-24.04", "--exec", wsl(OUT / "motion_host")],
    timeout=30,
)
assert b"PASS MTK1" in host
(OUT / "start.S").write_text(
    '.section .text.start,"ax"\n.global _start\n_start:\n la sp,__stack_top\n la t0,trap\n csrw mtvec,t0\n call main\n j trap\n'
)
(OUT / "link.ld").write_text(
    "OUTPUT_ARCH(riscv)\nENTRY(_start)\nSECTIONS{. = 0x80000000; .text : {*(.text.start) *(.text*)} .rodata : {*(.rodata*)} .data : {*(.data*) *(.sdata*)} .bss : {*(.bss*) *(.sbss*)} __stack_top = 0x81000000;}"
)
IDE = Path("F:/Efinity/efinity-riscv-ide-2026.1")
run(
    "service_compile",
    [
        IDE / "toolchain/bin/riscv-none-elf-gcc.exe",
        "-march=rv32i_zicsr_zifencei",
        "-mabi=ilp32",
        "-O2",
        "-DVISION_MULHI_CFU",
        "-DVISION_M7_NO_FACE",
        "-DINT8_TEST",
        "-ffreestanding",
        "-fno-builtin",
        "-mno-relax",
        "-msmall-data-limit=0",
        "-ffunction-sections",
        "-fdata-sections",
        "-nostdlib",
        "-Wl,--gc-sections",
        "-I" + str(ROOT / "firmware/vision"),
        "-IDE",
        OUT / "link.ld",
        OUT / "start.S",
        ROOT / "sim/test_target_motion_service.c",
        ROOT / "firmware/vision/target_track.c",
        "-lgcc",
        "-o",
        OUT / "motion.elf",
    ],
)
service = run(
    "service",
    [
        IDE / "qemu/qemu-system-riscv32.exe",
        "-M",
        "virt",
        "-cpu",
        "rv32,m=false,args=false,c=false,f=false,d=false",
        "-nographic",
        "-bios",
        "none",
        "-kernel",
        OUT / "motion.elf",
    ],
    timeout=120,
)
assert b"PASS MTK1" in service
run(
    "line_compile",
    [
        "C:/iverilog/bin/iverilog.exe",
        "-g2012",
        "-s",
        "tb",
        "-o",
        OUT / "line.vvp",
        ROOT / "board/ti60f225_v4/rtl/vision/vision_geometry_m7.sv",
        ROOT / "sim/vision/tb_target_line_overlay.sv",
    ],
)
line = run(
    "line_render",
    ["C:/iverilog/bin/vvp.exe", OUT / "line.vvp", "+output=" + OUT.as_posix()],
    timeout=60,
)
assert b"PASS continuous line raster" in line
(OUT / "result.json").write_text(
    json.dumps(
        dict(
            passed=True,
            host_sanitizers=True,
            rv32_service=True,
            continuous_line_pixels=69120,
            selection_required=False,
            roi_required=False,
            board_access=False,
        ),
        indent=2,
    )
)
print(host.decode().strip())
print(service.decode().strip())
print(line.decode().strip())
