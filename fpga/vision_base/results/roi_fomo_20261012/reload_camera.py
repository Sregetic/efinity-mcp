"""This run's verified firmware reload: fast write, known-good static read speed."""
import json
import subprocess
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'scripts'))
from load_vision_ddr import IDE,board_location,configuration,tcl_path,validate_image

out=Path(sys.argv[1]).resolve();out.mkdir(parents=True,exist_ok=True)
elf=ROOT/'results/roi_fomo_20261012/camera_cooperative/vision.elf'
weights=ROOT/'models/shape_cards_bringup/shape_cards_weights.bin'
entry,segments,sym=validate_image(elf,weights)
location=board_location('ftdi://0x0403:0x6011:4:9/2')
commands=['halt','wait_halt 5000',f'load_image {tcl_path(elf)}',
          f'load_image {tcl_path(weights)} {sym["__weights_start"]:#x} bin','adapter speed 25']
expected=[];data=elf.read_bytes()
for i,s in enumerate(segments):
    if not s['size']:continue
    p=out/f'segment{i}.bin';commands.append(f'dump_image {tcl_path(p)} {s["address"]:#x} {s["size"]}')
    expected.append((p,data[s['offset']:s['offset']+s['size']]))
p=out/'weights.bin';commands.append(f'dump_image {tcl_path(p)} {sym["__weights_start"]:#x} {weights.stat().st_size}')
expected.append((p,weights.read_bytes()))
def run(name,items,speed,marker):
    cfg=out/(name+'.cfg')
    cfg.write_text(configuration(location,ROOT/'artifacts/vision_soc/cpu0.yaml',sym,speed)+
                   'if {[catch {\n'+'\n'.join(items+[f'echo {marker}'])+
                   '\n} failure]} {echo "CAMERA_RELOAD_ERROR: $failure"; shutdown error}\nshutdown\n')
    with (out/(name+'.log')).open('w',encoding='utf-8') as log:
        r=subprocess.run([str(IDE/'openocd/bin/openocd.exe'),'-f',str(cfg)],stdout=log,stderr=subprocess.STDOUT,timeout=2400)
    r.check_returncode()
    assert marker in (out/(name+'.log')).read_text(encoding='utf-8')
run('load',commands,500,'CAMERA_BYTES_READ')
for p,v in expected:assert p.read_bytes()==v,p.name
run('resume',['halt','wait_halt 5000',f'resume {entry:#x}'],5,'CAMERA_VERIFIED_RESUMED')
record=dict(passed=True,write_khz=500,static_read_khz=25,payload_bytes=sum(s['size'] for s in segments),
            weights_bytes=weights.stat().st_size,elf=str(elf),byte_exact=True,flash_written=False)
(out/'verification.json').write_text(json.dumps(record,indent=2))
print(json.dumps(record),flush=True)
