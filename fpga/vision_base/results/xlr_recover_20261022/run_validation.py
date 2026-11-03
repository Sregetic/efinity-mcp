"""Targeted production-path regression for the lossless RAM packing change."""
from pathlib import Path
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent / "regression"
OUT.mkdir(exist_ok=True)
V = "board/ti60f225_v4/rtl/vision/"
display = [V+n+".sv" for n in ["vision_display", "vision_frontend", "vision_window3", "vision_median9", "vision_sobel", "vision_shape_classifier", "vision_osd"]]
cases = [
    ("canny_raster", "sim/vision/tb_canny_raster.sv", [V+"vision_canny_raster.sv", V+"vision_sparse_window.sv"], []),
    ("canny_fit", "sim/vision/tb_canny_fit.sv", [V+"vision_canny_raster.sv", V+"vision_sparse_window.sv"], []),
    ("osd", "sim/vision/tb_osd.sv", [V+"vision_osd.sv"], []),
    ("sapphire_ram", "sim/tb_sapphire_ram.sv", ["rtl/sapphire_ram.sv", "board/ti60f225_v4/rtl/simple_dual_port_ram.v"], []),
    ("line_snapshot", "sim/vision/tb_line_snapshot.sv", [V+"vision_line_snapshot.sv"], []),
    ("edge_overlay", "sim/vision/tb_edge_overlay.sv", display, []),
    ("fusion_display", "sim/vision/tb_fusion_display.sv", display, []),
    ("edge_strength", "sim/vision/tb_edge_strength.sv", display, []),
]
sensor = "board/ti60f225_v4/rtl/cam_i2c_ctrl/i2c/"
for p in sorted((ROOT / "board/ti60f225_v4/sensors").glob("*.json")):
    profile = json.loads(p.read_text())
    table = p.parent / profile["init_file"]
    values = [int(w, 16) for w in table.read_text().split()]
    assert len({v >> 17 for v in values}) <= 16
    cases.append((p.stem, "sim/vision/tb_sensor_boot.sv", [sensor+"i2c_master_reg_set.v", sensor+"i2c_master_reg_rom.v"],
                  ["-Ptb.N="+str(profile["init_length"]), '-Ptb.INIT_FILE="'+table.as_posix()+'"']))
cases=[case for case in cases if case[0] in ["canny_raster","canny_fit","line_snapshot","edge_overlay","fusion_display","edge_strength"]]
records = []
for name, bench, sources, parameters in cases:
    exe = OUT / (name+".vvp")
    cmd = ["C:/iverilog/bin/iverilog.exe", "-g2012", "-s", "tb", *parameters, "-o", str(exe), str(ROOT/bench), *[str(ROOT/s) for s in sources]]
    for stage, args in [("compile", cmd), ("run", ["C:/iverilog/bin/vvp.exe", str(exe)])]:
        with (OUT / (name+"."+stage+".log")).open("wb") as stream:
            subprocess.run(args, cwd=ROOT, stdout=stream, stderr=subprocess.STDOUT, check=True, timeout=300)
    exe.unlink()
    records.append(dict(test=name, passed=True))
    print("PASS", name, flush=True)
(OUT / "verification.json").write_text(json.dumps(dict(passed=True, tests=records, scope="Targeted RTL regression, not physical acceptance"), indent=2))
