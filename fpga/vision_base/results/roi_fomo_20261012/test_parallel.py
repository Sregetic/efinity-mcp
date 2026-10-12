"""This run's camera FOMO/full ROI stress, with normal-view restoration."""
import json
import subprocess
import sys
import time
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
out=Path(sys.argv[1]).resolve();out.mkdir(parents=True,exist_ok=True)
url='ftdi://0x0403:0x6011:4:9/2'
def control(*args,ai=False):
    r=subprocess.run([sys.executable,str(ROOT/'scripts/vision_control.py'),'--url',url,
                      *map(str,args),'--ai-status' if ai else '--roi-status'],capture_output=True,text=True)
    if r.returncode:
        (out/'control_error.log').write_text(r.stdout+r.stderr)
        print(r.stderr,file=sys.stderr)
        r.check_returncode()
    return json.loads(r.stdout)
def save(name,value):
    (out/(name+'.json')).write_text(json.dumps(value,indent=2))
before=control();save('before',before)
try:
    state=control('--menu',10)
    if state['menu_value']!=1:state=control('--key-event',2)
    assert state['menu_value']==1,state
    control('--ai-policy',1)
    time.sleep(4)
    first=control(ai=True);save('ai_first',first)
    assert first['ai_enabled']==1 and ((first['ai_flags']>>11)&3)!=3,first
    subprocess.run([sys.executable,str(ROOT/'scripts/verify_roi_board.py'),'--url',url,
                    '--seconds','60','--output-dir',str(out/'roi')],check=True)
    last=control(ai=True);save('ai_last',last)
    # Page31 carries only14 flag bits, not the DDR completion sequence.
    assert last['ai_frame']!=first['ai_frame'],'FOMO completed frame did not advance during video/ROI stress'
    assert ((last['ai_flags']>>11)&3)==2,last
    record=dict(passed=True,first_fomo_frame=first['ai_frame'],last_fomo_frame=last['ai_frame'],
                scope='Actual continuous camera FOMO alongside live full/2x ROI and frozen rerenders; no physical card accuracy')
finally:
    restore_started=time.monotonic()
    restored=control('--ai-policy',0,'--mode',0,'--median',1,'--memory',0,'--menu',0,'--roi-enable',0,
                     '--sobel-threshold',128,'--canny-threshold',80)
    save('restored',restored)
record['restore_seconds']=time.monotonic()-restore_started
save('result',record)
print('PASS continuous FOMO and full/2x ROI with zero scan/discard growth',flush=True)
