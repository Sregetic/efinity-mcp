#!/usr/bin/env python3
"""Run gamma RTL regressions with Icarus; never invokes Efinity or a programmer."""
from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import tempfile
from pathlib import Path


def executable(value: str | None, name: str) -> str:
    candidate = value or shutil.which(name)
    if not candidate:
        candidate = str(Path("C:/iverilog/bin") / (name + ".exe"))
    if not Path(candidate).is_file():
        raise FileNotFoundError(f"{name} not found; supply --{name} or put it on PATH")
    return str(Path(candidate).resolve())


def run(command: list[str], cwd: Path, log: Path) -> str:
    try:
        proc = subprocess.run(command, cwd=cwd, stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT, text=True, errors="replace", timeout=180)
    except subprocess.TimeoutExpired as exc:
        log.write_text(str(exc), encoding="utf-8")
        raise RuntimeError(f"RTL test timed out; see {log}") from exc
    log.write_text(proc.stdout, encoding="utf-8")
    if proc.returncode:
        raise RuntimeError(f"RTL test exited {proc.returncode}; see {log}\n{proc.stdout[-4000:]}")
    return proc.stdout


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--iverilog")
    parser.add_argument("--vvp")
    parser.add_argument("--output", type=Path, help="New result directory, never overwritten")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    board = root / "board/ti60f225_v4"
    out = args.output.resolve() if args.output else Path(tempfile.mkdtemp(prefix="gamma-tests-"))
    if args.output:
        out.mkdir(parents=True, exist_ok=False)
    summary: dict = {"scope": "Icarus RTL simulation, not Efinity area/timing or board acceptance",
                     "passed": False, "cases": []}
    try:
        ivl, vvp = executable(args.iverilog, "iverilog"), executable(args.vvp, "vvp")
        sources = [root / "sim/gamma/tb_gamma_equivalence.sv",
                   root / "sim/gamma/gamma_correction_legacy_reference.v",
                   board / "rtl/true_dual_port_ram.v",
                   board / "rtl/gamma_conrrection/gamma_correction.v",
                   board / "rtl/vision/rgb_chroma_tone.sv"]
        # Nonmonotonic values expose wrong addresses that smooth gamma curves hide.
        synthetic = out / "address_probe.mem"
        synthetic.write_text("".join(f"{((i*173) ^ (i>>3) ^ 0x295)&1023:03x}\n"
                                     for i in range(1024)), encoding="ascii")
        curves = [board / "rtl/gamma_conrrection/display_gamma_2p2.mem",
                  board / "rtl/gamma_conrrection/2P2.mem", synthetic]
        for curve in curves:
            for width in (8, 10):
                name = f"{curve.stem}-{width}"
                case = {"name": name, "passed": False}
                summary["cases"].append(case)
                image = out / f"{name}.vvp"
                command = [ivl, "-g2012", "-s", "tb_gamma_equivalence",
                           f"-Ptb_gamma_equivalence.DATA_WIDTH={width}",
                           f'-Ptb_gamma_equivalence.CURVE="{curve.as_posix()}"',
                           "-o", str(image), *map(str, sources)]
                run(command, board, out / f"{name}.compile.log")
                text = run([vvp, str(image)], board, out / f"{name}.run.log")
                marker = f"PASS gamma width={width} "
                lines = [line for line in text.splitlines() if line.startswith(marker)]
                if len(lines) != 1 or any(word in text for word in ("ERROR:", "FATAL:", "WARNING:")):
                    raise RuntimeError(f"Missing PASS or simulator diagnostic in {name}:\n{text[-6000:]}")
                case.update(passed=True, result=lines[0])
                print(lines[0])
                image.unlink()
        summary["passed"] = True
        return 0
    except Exception as exc:
        summary["error"] = str(exc)
        print(f"FAIL: {exc}")
        return 1
    finally:
        (out / "summary.json").write_text(json.dumps(summary, indent=2)+"\n", encoding="utf-8")
        print(f"Gamma results: {out}")


if __name__ == "__main__":
    raise SystemExit(main())
