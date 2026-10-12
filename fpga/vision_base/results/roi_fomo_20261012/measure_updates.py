"""Measure distinct displayed ROI frames without adding a hardware probe."""
import json
import subprocess
import sys
import time
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'scripts'))
from efx_pgm.ftdi_program import acquire_jtag_engine
from efx_pgm.device_utils import DeviceUtils
from pyftdi.bits import BitSequence
out=Path(sys.argv[1]);out.mkdir(parents=True,exist_ok=True)
url='ftdi://0x0403:0x6011:4:9/2'
def control(*args):
    r=subprocess.run([sys.executable,str(ROOT/'scripts/vision_control.py'),'--url',url,
                      *map(str,args),'--roi-status'],check=True,capture_output=True,text=True)
    return json.loads(r.stdout)
try:
    s=control('--menu',10)
    if s['menu_value']!=1:control('--key-event',2)
    control('--ai-policy',1)
    rows=[]
    for name,roi in [('full',[0,0,1920,1080]),('zoom',[480,270,960,540])]:
        before=control('--memory',0,'--mode',5,'--median',1,'--roi',*roi,'--output-size',1920,1080,'--position',0,0)
        time.sleep(2);changes=[];last=None;n=0
        with acquire_jtag_engine(1e6,url) as e:
            e.reset();e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2'])
            e.write_dr(BitSequence((0x56495331<<32)|(126<<24)|18,length=192));e.go_idle();time.sleep(.02)
            started=time.monotonic()
            while time.monotonic()-started<20:
                e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);v=int(e.read_dr(192));e.go_idle()
                assert v>>160==0x56495331 and (v>>128)&0xffffffff==0x26100412
                flags=v&0xffffffff;frame=(v>>64)&0xffffffff;n+=1
                assert not(flags&(7<<21))
                if (flags>>30)&1 and frame!=last:
                    last=frame;changes.append(dict(seconds=time.monotonic()-started,frame=last))
            elapsed=time.monotonic()-started
        after=control()
        assert after['scan_bad_frames']==before['scan_bad_frames'] and after['capture_discarded']==before['capture_discarded']
        rows.append(dict(name=name,seconds=elapsed,polls=n,poll_hz=n/elapsed,display_updates=len(changes)-1,
                         display_updates_hz=(len(changes)-1)/elapsed,scan_bad_delta=0,discard_delta=0,changes=changes))
finally:
    restored=control('--ai-policy',0,'--memory',0,'--mode',0,'--median',1,'--roi-enable',0,'--menu',0)
    (out/'restored.json').write_text(json.dumps(restored,indent=2))
(out/'result.json').write_text(json.dumps(dict(passed=True,cases=rows,scope='USER2 high-rate valid displayed frame identity; capture/display refresh/inference rates remain separate'),indent=2))
print(json.dumps([{k:v for k,v in r.items() if k!='changes'} for r in rows],indent=2))
