"""Read startup status and actual DDR bytes; never download a program or reset CPU."""
import argparse,json,re,subprocess
from pathlib import Path
from load_vision_ddr import ROOT,IDE,board_location,configuration,validate_image,tcl_path,USER1_KHZ

def main():
 p=argparse.ArgumentParser();p.add_argument('--url',required=True);p.add_argument('--elf',type=Path,required=True);p.add_argument('--weights',type=Path);p.add_argument('--output-dir',type=Path,required=True);p.add_argument('--jtag-khz',type=int,default=USER1_KHZ);p.add_argument('--chunk-bytes',type=int,default=0);p.add_argument('--timeout-seconds',type=int,default=2400);a=p.parse_args()
 if a.jtag_khz<=0 or a.chunk_bytes<0 or a.chunk_bytes%4 or a.timeout_seconds<=0:p.error('Positive JTAG speed/deadline and zero or word-aligned chunk size required')
 _,segments,sym=validate_image(a.elf,a.weights);a.output_dir.mkdir(parents=True,exist_ok=True)
 data=a.elf.read_bytes();expected=[]
 body='halt\nwait_halt 5000\nset boot [read_memory 0x07621000 32 5]\nset state [read_memory 0xf8100004 32 1]\necho "BOOT_STATUS $boot"\necho "CPU_STATE $state"\nif {[lindex $boot 1] != 7 || $state != 1} {resume;echo BOOT_FAILED;shutdown error}\n'
 for i,s in enumerate(segments):
  if not s['size']:continue
  for offset in range(0,s['size'],a.chunk_bytes or s['size']):
   size=min(a.chunk_bytes or s['size'],s['size']-offset)
   path=a.output_dir/(f'segment{i}_{offset:06x}.bin' if a.chunk_bytes else f'segment{i}.bin')
   body+=f'dump_image {tcl_path(path)} {s["address"]+offset:#x} {size}\n';expected.append((path,data[s['offset']+offset:s['offset']+offset+size]))
 if a.weights:
  path=a.output_dir/'weights.bin';body+=f'dump_image {tcl_path(path)} {sym["__weights_start"]:#x} {a.weights.stat().st_size}\n';expected.append((path,a.weights.read_bytes()))
 body+='resume\necho BOOT_READ_COMPLETE\nshutdown\n'
 # Program/weights are static, unlike the cached ROI tensors; reuse loader profile.
 cfg=configuration(board_location(a.url),ROOT/'artifacts/vision_soc/cpu0.yaml',sym,a.jtag_khz)+body
 path=a.output_dir/'read.cfg';path.write_text(cfg)
 # The 178KB camera application took 12.4 minutes with the verified 25kHz read profile.
 r=subprocess.run([str(IDE/'openocd/bin/openocd.exe'),'-f',str(path.resolve())],capture_output=True,text=True,timeout=a.timeout_seconds)
 log=r.stdout+r.stderr;(a.output_dir/'read.log').write_text(log);r.check_returncode()
 if 'BOOT_READ_COMPLETE' not in log:raise RuntimeError('Startup read did not complete')
 status=[int(v,0) for v in re.search(r'^BOOT_STATUS (.*)$',log,re.M)[1].split()]
 state=int(re.search(r'^CPU_STATE (.*)$',log,re.M)[1],0)
 if status[:4]!=[0x56424f31,7,0xef6017,max(s['address']+s['size'] for s in segments)-sym['__app_start']] or status[4]!=(a.weights.stat().st_size if a.weights else 0) or state!=1:raise RuntimeError(f'SPI/CPU startup failed: {status}, CPU{state}')
 for path,data in expected:
  if path.read_bytes()!=data:raise RuntimeError('Autoload DDR byte mismatch: '+path.name)
 result=dict(passed=True,boot_status=status,cpu_state=state,program_bytes=status[3],weights_bytes=status[4],actual_ddr_bytes_verified=True,user1_program_download=False,physical_power_cycle_verified=False,jtag_khz=a.jtag_khz,chunk_bytes=a.chunk_bytes)
 (a.output_dir/'result.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
if __name__=='__main__':main()
