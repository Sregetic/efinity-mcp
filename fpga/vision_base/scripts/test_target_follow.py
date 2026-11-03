"""Run the production RV32 follower without a board; emit ROI and trail vectors."""

import argparse
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
IDE = Path("F:/Efinity/efinity-riscv-ide-2026.1")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--no-face", action="store_true")
    parser.add_argument("--output-dir", type=Path)
    args = parser.parse_args()
    task = ROOT / "results/m7_follow_20261031"
    suffix = "_no_face" if args.no_face else ""
    out = args.output_dir or task / ("service_follow" + suffix)
    out.mkdir(parents=True, exist_ok=True)
    # Own these build inputs; do not run another test to manufacture its cached files.
    (out / "start.S").write_text(
        '.section .text.start,"ax"\n.global _start\n_start:\n la sp,__stack_top\n'
        " la t0,trap\n csrw mtvec,t0\n call main\n j trap\n"
    )
    (out / "link.ld").write_text(
        "OUTPUT_ARCH(riscv)\nENTRY(_start)\nSECTIONS{. = 0x80000000; "
        ".text : {*(.text.start) *(.text*)} .rodata : {*(.rodata*)} "
        ".data : {*(.data*) *(.sdata*)} .bss : {*(.bss*) *(.sbss*)} "
        "__stack_top = 0x81000000;}"
    )
    command = [
        IDE / "toolchain/bin/riscv-none-elf-gcc.exe",
        "-march=rv32i_zicsr_zifencei",
        "-mabi=ilp32",
        "-O2",
        "-DVISION_MULHI_CFU",
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
        "-T",
        out / "link.ld",
        out / "start.S",
        ROOT / "sim/test_target_follow_service.c",
        ROOT / "firmware/vision/target_track.c",
        "-lgcc",
        "-o",
        out / "follow.elf",
    ]
    if args.no_face:
        command.insert(1, "-DVISION_M7_NO_FACE")
    build = subprocess.run(list(map(str, command)), capture_output=True)
    (out / "compile.log").write_bytes(build.stdout + build.stderr)
    build.check_returncode()
    run = subprocess.run(
        [
            str(IDE / "qemu/qemu-system-riscv32.exe"),
            "-M",
            "virt",
            "-cpu",
            "rv32,m=false,a=false,c=false,f=false,d=false",
            "-nographic",
            "-bios",
            "none",
            "-kernel",
            str(out / "follow.elf"),
        ],
        capture_output=True,
        timeout=120,
    )
    (out / "run.log").write_bytes(run.stdout + run.stderr)
    run.check_returncode()
    assert b"PASS TRK1" in run.stdout, run.stdout

    vectors, packets = [], []
    for line in run.stdout.decode().splitlines():
        if line.startswith("TRACK "):
            _, name, *words = line.split()
            values = [int(word, 16) for word in words]
            assert len(values) == 12
            vectors.append(
                dict(
                    name=name,
                    target=values[:4],
                    roi=values[4:8],
                    frame=values[8],
                    render=values[9],
                    context=values[10],
                    config=values[11],
                )
            )
        if line.startswith("TRAIL "):
            _, name, *words = line.split()
            values = [int(word, 16) for word in words]
            assert len(values) == 134
            packets.append(
                dict(
                    name=name,
                    rows=[values[n] | (values[n + 1] << 32) for n in range(0, 134, 2)],
                )
            )
    assert len(vectors) == len(packets) == 6
    # Preserve the existing render consumer's default path; explicit output stays self-contained.
    render = (
        out / "control"
        if args.output_dir
        else task / ("follow_render" + suffix) / "control"
    )
    render.mkdir(parents=True, exist_ok=True)
    (render / "center_vectors.json").write_text(json.dumps(vectors, indent=2))
    (render / "center_vectors.mem").write_text(
        "".join(
            f"{word:08x}\n"
            for case in vectors
            for word in [
                *case["target"],
                *case["roi"],
                case["frame"],
                case["render"],
                case["context"],
                case["config"],
            ]
        )
    )
    (out / "overlay_packets.json").write_text(json.dumps(packets, indent=2))
    for packet in packets:
        (out / (packet["name"] + ".mem")).write_text(
            "".join(f"{word:010x}\n" for word in packet["rows"])
        )
    (out / "result.json").write_text(
        json.dumps(
            dict(
                passed=True,
                isa="RV32I",
                moving_frames=11,
                roi_vectors=len(vectors),
                source="Actual packed16 source sampling/Sobel in a simulated camera, not board latency",
                scope="Fixed zoom, global coordinates, source dedup, hold/loss, reselection and manual ROI",
            ),
            indent=2,
        )
    )
    print(run.stdout.decode().splitlines()[-1])
    print(
        "PASS six production follow ROI descriptors and transformed real-observation trail packets"
    )


if __name__ == "__main__":
    main()
