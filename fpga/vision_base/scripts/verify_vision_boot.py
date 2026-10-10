"""Read startup status and actual DDR bytes; never download a program or reset CPU."""
import argparse,json,re,subprocess
from pathlib import Path
from load_vision_ddr import ROOT,IDE,board_location,configuration,validate_image,tcl_path,USER1_KHZ

def main():
 p=argparse.ArgumentParser();p.add_argument('--url',required=True);p.add_argument('--elf',type=Path,required=True);p.add_argument('--weights',type=Path,required=True);p.add_argument('--output-dir',type=Path,required=True);a=p.parse_args()
 _,segments,sym=validate_image(a.elf,a.weights);a.output_dir.mkdir(parents=True,exist_ok=True)
 data=a.elf.read_bytes();expected=[]
 body='halt\nwait_halt 5000\nset boot [read_memory 0x07621000 32 5]\nset state [read_memory 0xf8100004 32 1]\necho "BOOT_STATUS $boot"\necho "CPU_STATE $state"\nif {[lindex $boot 1] != 7 || $state != 1} {resume;echo BOOT_FAILED;shutdown error}\n'
 for i,s in enumerate(segments):
  if not s['size']:continue
  path=a.output_dir/f'segment{i}.bin';body+=f'dump_image {tcl_path(path)} {s["address"]:#x} {s["size"]}\n';expected.append((path,data[s['offset']:s['offset']+s['size']]))
 path=a.output_dir/'weights.bin';body+=f'dump_image {tcl_path(path)} {sym["__weights_start"]:#x} {a.weights.stat().st_size}\n';expected.append((path,a.weights.read_bytes()))
 body+='resume\necho BOOT_READ_COMPLETE\nshutdown\n'
 # Program/weights are static, unlike the cached ROI tensors; reuse loader profile.
 cfg=configuration(board_location(a.url),ROOT/'artifacts/vision_soc/cpu0.yaml',sym,USER1_KHZ)+body
 path=a.output_dir/'read.cfg';path.write_text(cfg)
 r=subprocess.run([str(IDE/'openocd/bin/openocd.exe'),'-f',str(path.resolve())],capture_output=True,text=True,timeout=300)
 log=r.stdout+r.stderr;(a.output_dir/'read.log').write_text(log);r.check_returncode()
 if 'BOOT_READ_COMPLETE' not in log:raise RuntimeError('Startup read did not complete')
 status=[int(v,0) for v in re.search(r'^BOOT_STATUS (.*)$',log,re.M)[1].split()]
 state=int(re.search(r'^CPU_STATE (.*)$',log,re.M)[1],0)
 if status[:3]!=[0x56424f31,7,0xef6017] or state!=1:raise RuntimeError(f'SPI/CPU startup failed: {status}, CPU{state}')
 for path,data in expected:
  if path.read_bytes()!=data:raise RuntimeError('Autoload DDR byte mismatch: '+path.name)
 result=dict(passed=True,boot_status=status,cpu_state=state,program_bytes=status[3],weights_bytes=status[4],actual_ddr_bytes_verified=True,user1_program_download=False,physical_power_cycle_verified=False)
 (a.output_dir/'result.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
if __name__=='__main__':main()
