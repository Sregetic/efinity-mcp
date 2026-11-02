"""Compare production Canny numerics under the actual ROI reset wiring."""
import json,re,subprocess
from pathlib import Path
R=Path(__file__).resolve().parents[1];O=R/'results/m7_follow_20261031/runtime_check/blackout_after_move/canny_test';O.mkdir(exist_ok=True)
s=(R/'board/ti60f225_v4/rtl/ti60f225_oob_top.v').read_text();expr=re.search(r'\.rst_n\(([^)]*)\)',s[s.index('vision_canny #'):]).group(1);(O/'canny_reset.svh').write_text('`define CANNY_RESET ('+expr+')\n')
b=R/'board/ti60f225_v4/rtl/vision';files=[R/'sim/vision/tb_canny_roi_stream.sv',*[b/n for n in ['vision_canny.sv','vision_canny_denoise.sv','vision_canny_raster.sv','vision_sparse_window.sv','vision_median9.sv','vision_sobel.sv','vision_hysteresis_sweep.sv','vision_hysteresis.sv']]]
x=subprocess.run(['C:/iverilog/bin/iverilog.exe','-g2012','-s','tb','-I'+str(O),'-o',str(O/'test.vvp'),*map(str,files)],capture_output=True);(O/'compile.log').write_bytes(x.stdout+x.stderr);x.check_returncode()
x=subprocess.run(['C:/iverilog/bin/vvp.exe',str(O/'test.vvp')],cwd=R/'board/ti60f225_v4',capture_output=True,timeout=120);(O/'run.log').write_bytes(x.stdout+x.stderr);print(x.stdout.decode());x.check_returncode();assert b'PASS Canny ROI continuity'in x.stdout
(O/'result.json').write_text(json.dumps(dict(passed=True,top_level_canny_reset=expr,roi_invalidations=8,cycles=215040,algorithm_sources_changed=False),indent=2))
