"""M7 model/render separation: actual RTL overlays and retired-detector checks."""
from pathlib import Path
import subprocess,json,argparse
ROOT=Path(__file__).resolve().parents[1];RTL=ROOT/'board/ti60f225_v4/rtl/vision'
def wsl(p):
 s=p.resolve().as_posix();return '/mnt/'+s[0].lower()+s[2:]
def run(name,cmd,timeout=240):
 r=subprocess.run(cmd,cwd=ROOT,capture_output=True,timeout=timeout);(OUT/(name+'.log')).write_bytes(r.stdout+r.stderr)
 if r.returncode:print(r.stdout.decode('utf-8','replace'));print(r.stderr.decode('utf-8','replace'));r.check_returncode()
 return r.stdout
parser=argparse.ArgumentParser();parser.add_argument('--modes',type=int,nargs='+',choices=[2,4,5,6],default=[2,4,5,6]);parser.add_argument('--selected',type=int,choices=range(4));parser.add_argument('--output-dir',type=Path,default=ROOT/'results/m7_model_route_20261030');args=parser.parse_args();OUT=args.output_dir.resolve();OUT.mkdir(parents=True,exist_ok=True)
sources=[ROOT/'sim/vision/tb_geometry_m7_labels_display.sv',*[RTL/(n+'.sv') for n in ['vision_geometry_m7','vision_display','vision_frontend','vision_window3','vision_median9','vision_sobel','vision_osd']]]
run('overlay_compile',['wsl.exe','-d','Ubuntu-24.04','--cd',wsl(ROOT),'--exec','verilator','--binary','--timing','-j','4','-Wno-fatal','--top-module','tb','--Mdir',wsl(OUT/'overlay_obj'),*map(wsl,sources)])
rows=[]
for mode in args.modes:
 output=run(f'overlay_{mode}',['wsl.exe','-d','Ubuntu-24.04','--cd',wsl(ROOT),'--exec',wsl(OUT/'overlay_obj/Vtb'),f'+mode={mode}',f'+output={wsl(OUT)}',*([f'+selected={args.selected}'] if args.selected is not None else [])])
 assert b'PASS model M7' in output,output;rows.append(dict(display_mode=mode,selected=args.selected,pixels=2073600,passed=True));print('PASS M7 overlay/labels on display',mode,flush=True)
assert not (RTL/'vision_shape_classifier.sv').exists()
assert 'vision_shape_classifier' not in (ROOT/'board/ti60f225_v4/ti60f225_oob.xml').read_text()
(OUT/'overlay_result.json').write_text(json.dumps(dict(passed=True,tests=rows,legacy_detector_removed=True,scope='Actual RTL synthetic edge displays and C/rectangle/face/letter overlays, not camera accuracy'),indent=2))
