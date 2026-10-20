"""Exercise the unchanged Flash application while full-frame ROI is active."""
import argparse,json,struct,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('--url',required=True);a=p.parse_args();out=Path(__file__).resolve().parent
def control(*args):
    r=subprocess.run([sys.executable,str(ROOT/'scripts/vision_control.py'),'--url',a.url,'--roi-status',*map(str,args)],check=True,capture_output=True,text=True)
    return json.loads(r.stdout)
before=control();network=control('--menu',10)['menu_value']
(out/'ai_before.json').write_text(json.dumps(before,indent=2))
try:
    if network!=1:control('--key-event',2)
    assert control()['menu_value']==1
    control('--memory',0,'--menu',0,'--roi',0,0,1920,1080,'--output-size',1920,1080,'--position',0,0,'--roi-enable',1,'--ai-policy',1)
    subprocess.run([sys.executable,str(out/'sample_runtime.py'),'--url',a.url,'--output',str(out/'ai_full_runtime.json'),'--seconds','30'],check=True)
    control('--ai-policy',0)
    subprocess.run([sys.executable,str(ROOT/'scripts/read_fomo_camera.py'),'--url',a.url,'--elf',str(ROOT/'results/canny_flash_20261017/firmware/vision.elf'),'--output-dir',str(out/'fomo_summary'),'--summary'],check=True)
    s=struct.unpack('<24I',(out/'fomo_summary/status.bin').read_bytes());f=struct.unpack('<16I',(out/'fomo_summary/fusion.bin').read_bytes())
    assert s[0]==0x464f4d32 and s[1]==3 and s[2]>0 and s[17]==0 and (f[2]>>13)&3==2,(s,f)
    result=dict(passed=True,sequence=s[2],source=s[3],render=s[5],preprocess_ms=s[8]/100000,invoke_ms=s[9]/100000,postprocess_ms=s[10]/100000,total_ms=s[11]/100000,errors=s[17],selftest=(f[2]>>13)&3,raw_status=s,fusion=f)
    (out/'ai_result.json').write_text(json.dumps(result,indent=2));print(json.dumps(result),flush=True)
finally:
    control('--ai-policy',0)
    current=control('--menu',10)
    if current['menu_value']!=network:control('--key-event',2)
    restored=control('--memory',before['memory'],'--mode',before['mode'],'--median',before['median'],'--menu',before['menu'],'--roi',*before['roi'],'--output-size',*before['output_size'],'--position',*before['position'],'--roi-enable',before['roi_enabled'])
    (out/'ai_restored.json').write_text(json.dumps(restored,indent=2))
