"""Two synthetic weight versions for the I3 same-source model-swap check."""
import argparse,json,struct,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'scripts'))
from load_vision_ddr import IDE,configuration,board_location,validate_image,tcl_path
p=argparse.ArgumentParser();p.add_argument('version',type=int,choices=[1,2]);a=p.parse_args()
out=Path(__file__).parent/'model_versions'/str(a.version);out.mkdir(parents=True,exist_ok=True)
_,_,s=validate_image(ROOT/'results/fusion_roi_20261008/firmware/vision.elf',None)
blob=bytearray((ROOT/'models/shape_cards_bringup/shape_cards_weights.bin').read_bytes())
if a.version==2:struct.pack_into('<i',blob,160,struct.unpack_from('<i',blob,160)[0]+4096)
weights=out/'weights.bin';weights.write_bytes(blob);location=board_location('ftdi://0x0403:0x6011:4:9/2')
def run(name,body):
    cfg=out/(name+'.cfg');cfg.write_text(configuration(location,ROOT/'artifacts/vision_soc/cpu0.yaml',s)+body)
    r=subprocess.run([str(IDE/'openocd/bin/openocd.exe'),'-f',str(cfg)],capture_output=True,text=True,timeout=120)
    (out/(name+'.log')).write_text(r.stdout+r.stderr);r.check_returncode()
ctrl=s['analysis_control']
# Hot replacement must retain OpenOCD's saved CPU register context until resume.
# A separate connection after bulk writes would save the injected scratch registers.
run('switch',f'''halt
wait_halt 5000
load_image {tcl_path(weights)} {s['__weights_start']:#x} bin
dump_image {tcl_path(out/'readback.bin')} {s['__weights_start']:#x} {len(blob)}
set file [open {tcl_path(weights)} rb]
set expected [read $file]
close $file
set file [open {tcl_path(out/'readback.bin')} rb]
set actual [read $file]
close $file
if {{$expected ne $actual}} {{echo MODEL_READBACK_MISMATCH; shutdown error}}
write_memory {ctrl+20:#x} 32 {{{a.version}}}
set nonce [read_memory {ctrl+32:#x} 32 1]
write_memory {ctrl+32:#x} 32 [list [expr {{($nonce+1)&0xffffffff}}]]
resume
echo MODEL_SWITCHED
shutdown
''')
assert (out/'readback.bin').read_bytes()==blob
(out/'load.json').write_text(json.dumps(dict(passed=True,model_version=a.version,synthetic=True,weights_readback_equal=True,fpga_programmed=False,flash_written=False),indent=2))
print('Published synthetic weight version',a.version)
