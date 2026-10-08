"""Pause/resume new analysis jobs to verify OLD display without changing records."""
import argparse,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'scripts'))
from load_vision_ddr import IDE,configuration,board_location,validate_image,tcl_path
p=argparse.ArgumentParser();p.add_argument('flags',type=int,choices=[0,5]);a=p.parse_args()
out=Path(__file__).parent;_,_,sym=validate_image(out/'firmware/vision.elf',None)
name='pause' if not a.flags else 'run';cfg=out/(name+'.cfg')
cfg.write_text(configuration(board_location('ftdi://0x0403:0x6011:4:9/2'),ROOT/'artifacts/vision_soc/cpu0.yaml',sym)+f'halt\nwait_halt 5000\nwrite_memory {sym["analysis_control"]:#x} 32 {{{a.flags}}}\nresume\necho ANALYSIS_CONTROL_APPLIED\nshutdown\n')
r=subprocess.run([str(IDE/'openocd/bin/openocd.exe'),'-f',str(cfg)],capture_output=True,text=True,timeout=30)
(out/(name+'.log')).write_text(r.stdout+r.stderr);r.check_returncode()
assert 'ANALYSIS_CONTROL_APPLIED' in r.stdout+r.stderr
print('Analysis flags',a.flags)
