from pathlib import Path
import json,subprocess,sys
root=Path('F:/Project/fpga/vision_base');sys.path.insert(0,str(root/'scripts'))
from load_vision_ddr import IDE,board_location,configuration,tcl_path,validate_image
out=root/'results/connectome_readout_20261018/ddr_load'
elf=root/'results/connectome_readout_20261018/firmware/vision.elf'
entry,segs,sym=validate_image(elf,None)
segment,=segs
expected=elf.read_bytes()[segment['offset']:segment['offset']+segment['size']]
prefix=(out/'segment0.bin').read_bytes()
assert prefix and expected[:len(prefix)]==prefix,'Partial static readback is not an exact prefix'
(out/'initial_timeout.json').write_text(json.dumps(dict(timeout_seconds=600,phase='full static readback',verified_prefix_bytes=len(prefix),cpu_resumed=False),indent=2))
location=board_location('ftdi://0x0403:0x6011:4:a/2')
tail=out/'segment0_tail.bin'
body=['halt','wait_halt 5000',f'dump_image {tcl_path(tail)} {segment["address"]+len(prefix):#x} {len(expected)-len(prefix)}','echo CONNECTOME_TAIL_READ_COMPLETE','shutdown']
cfg=out/'finish_read.cfg';cfg.write_text(configuration(location,root/'artifacts/vision_soc/cpu0.yaml',sym,25)+'\n'.join(body)+'\n')
print('Verified existing prefix',len(prefix),'reading remaining',len(expected)-len(prefix),'bytes at25kHz; no rewrite',flush=True)
with (out/'finish_read.log').open('w') as log:
 r=subprocess.run([str(IDE/'openocd/bin/openocd.exe'),'-f',str(cfg)],stdout=log,stderr=subprocess.STDOUT,timeout=2400)
r.check_returncode()
assert 'CONNECTOME_TAIL_READ_COMPLETE' in (out/'finish_read.log').read_text()
assert prefix+tail.read_bytes()==expected,'DDR program bytes differ from the ELF'
resume=out/'resume.cfg';resume.write_text(configuration(location,root/'artifacts/vision_soc/cpu0.yaml',sym,5)+f'halt\nwait_halt 5000\nresume {entry:#x}\necho CONNECTOME_VERIFIED_RESUMED\nshutdown\n')
r=subprocess.run([str(IDE/'openocd/bin/openocd.exe'),'-f',str(resume)],capture_output=True,text=True,timeout=60)
(out/'resume.log').write_text(r.stdout+r.stderr);r.check_returncode()
assert 'CONNECTOME_VERIFIED_RESUMED' in r.stdout+r.stderr
record=dict(passed=True,elf=str(elf),load_bytes=len(expected),byte_exact=True,static_read_khz=25,resume_khz=5,fpga_reprogrammed=False,flash_written=False,weights_written=False,initial_timeout_resolved_by_completing_remaining_readback=True)
(out/'result.json').write_text(json.dumps(record,indent=2));print(json.dumps(record,indent=2),flush=True)
