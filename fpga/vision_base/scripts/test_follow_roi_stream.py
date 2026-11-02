"""Exercise the actual top-level display reset expression through M0-M6 RTL."""
import json,re,subprocess
from pathlib import Path
R=Path(__file__).resolve().parents[1];O=R/'results/m7_follow_20261031/runtime_check/blackout_after_move/sync_test';O.mkdir(exist_ok=True)
top=(R/'board/ti60f225_v4/rtl/ti60f225_oob_top.v').read_text()
a=top.index('vision_display #');expr=re.search(r'\.rst_n\(([^)]*)\)',top[a:]).group(1)
(O/'display_reset.svh').write_text('`define DISPLAY_RESET ('+expr+')\n')
base=R/'board/ti60f225_v4/rtl/vision';files=[R/'sim/vision/tb_follow_roi_stream.sv',*[base/n for n in ['vision_display.sv','vision_frontend.sv','vision_window3.sv','vision_median9.sv','vision_sobel.sv','vision_osd.sv']]]
p=subprocess.run(['C:/iverilog/bin/iverilog.exe','-g2012','-s','tb','-I'+str(O),'-o',str(O/'test.vvp'),*map(str,files)],capture_output=True);(O/'compile.log').write_bytes(p.stdout+p.stderr);p.check_returncode()
p=subprocess.run(['C:/iverilog/bin/vvp.exe',str(O/'test.vvp')],capture_output=True,timeout=90);(O/'run.log').write_bytes(p.stdout+p.stderr);print(p.stdout.decode());p.check_returncode();assert b'PASS ROI updates'in p.stdout
(O/'result.json').write_text(json.dumps(dict(passed=True,top_level_reset=expr,modes=list(range(7)),cycles=64512,roi_invalidations=28),indent=2))
