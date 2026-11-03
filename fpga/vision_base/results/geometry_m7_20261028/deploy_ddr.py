"""Paired SRAM release loader; run after program_vision_sram.ps1 succeeds."""
from pathlib import Path
import sys,subprocess,json,time,argparse
R=Path(__file__).resolve().parents[2];sys.path.insert(0,str(R/'scripts'))
from load_vision_ddr import configuration,validate_image,board_location,tcl_path,IDE
p=argparse.ArgumentParser();p.add_argument('--url',required=True);p.add_argument('--elf',type=Path,default=R/'results/geometry_m7_20261028/release/vision.elf');p.add_argument('--jtag-khz',type=int,default=1000);p.add_argument('--output-dir',type=Path,required=True);a=p.parse_args()
E=a.elf
W=R/'results/edge_visibility_20261027_144437/release/shape_cards_weights.bin'
O=a.output_dir;O.mkdir(exist_ok=True)
entry,segments,sym=validate_image(E,W);image=E.read_bytes();start=time.monotonic()
base=configuration(board_location(a.url),R/'artifacts/vision_soc/cpu0.yaml',sym,a.jtag_khz)
def run(name,commands,marker):
 path=O/(name+'.cfg');path.write_text(base+'if {[catch {\n'+'\n'.join(commands+['echo '+marker])+'\n} failure]} {echo "M7_LOAD_ERROR: $failure"; shutdown error}\nshutdown\n',encoding='utf-8')
 x=subprocess.run([str(IDE/'openocd/bin/openocd.exe'),'-f',str(path)],capture_output=True,text=True,timeout=1500)
 log=x.stdout+x.stderr;(O/(name+'.log')).write_text(log,encoding='utf-8');x.check_returncode()
 if marker not in log:raise RuntimeError(log)
commands=['halt','wait_halt 5000'];checks=[]
payloads=[(f'segment{i}',s['address'],image[s['offset']:s['offset']+s['size']]) for i,s in enumerate(segments) if s['size']]
payloads.append(('weights',sym['__weights_start'],W.read_bytes()))
for name,address,data in payloads:
 for off in range(0,len(data),1024):
  chunk=data[off:off+1024];source=O/f'{name}_{off:06x}.write.bin';readback=O/f'{name}_{off:06x}.read.bin'
  source.write_bytes(chunk)
  commands.extend([f'load_image {tcl_path(source)} {address+off:#x} bin',f'dump_image {tcl_path(readback)} {address+off:#x} {len(chunk)}'])
  checks.append((readback,chunk))
run('load_verify',commands,'M7_ALL_BYTES_READ')
for path,expected in checks:
 if path.read_bytes()!=expected:raise RuntimeError('Actual CPU byte readback mismatch: '+path.name)
run('resume',['halt','wait_halt 5000',f'resume {entry:#x}'],'M7_APP_RUNNING')
record=dict(passed=True,method=f'USER1 {a.jtag_khz}kHz / 1KiB load-and-read chunks, full actual-byte compare before resume',
 elf=str(E),entry=entry,payload_bytes=sum(s['size']for s in segments),weights_bytes=W.stat().st_size,
 jtag_khz=a.jtag_khz,byte_readback_verified=True,flash_written=False,seconds=time.monotonic()-start)
(O/'result.json').write_text(json.dumps(record,indent=2),encoding='utf-8');print(json.dumps(record,indent=2))
