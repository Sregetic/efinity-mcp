"""Physical-key policy -> protected camera RGB -> FOMO record; restore live view."""
import argparse
import json
import struct
import subprocess
import sys
import time
from pathlib import Path
from load_vision_ddr import ROOT


def main():
    p=argparse.ArgumentParser()
    p.add_argument('--url',required=True)
    p.add_argument('--elf',type=Path,required=True)
    p.add_argument('--output-dir',type=Path,required=True)
    p.add_argument('--connectome-readout',action='store_true',help='Also export the trained circuit companion head')
    a=p.parse_args();out=a.output_dir;out.mkdir(parents=True,exist_ok=True)
    def control(*args,ai=False):
        r=subprocess.run([sys.executable,str(ROOT/'scripts/vision_control.py'),'--url',a.url,*map(str,args),'--ai-status' if ai else '--roi-status'],check=True,capture_output=True,text=True)
        return json.loads(r.stdout)
    def wait_done(identity):
        deadline=time.monotonic()+20
        while True:
            state=control(ai=True)
            if ((state['ai_flags']>>11)&3)==2 and identity(state):return state
            if (state['ai_flags']>>11)&3==3:raise RuntimeError(state)
            if time.monotonic()>deadline:raise TimeoutError(state)
            time.sleep(.25)
    def read(name,summary=False):
        directory=out/name
        args=[sys.executable,str(ROOT/'scripts/read_fomo_camera.py'),'--url',a.url,'--elf',str(a.elf),'--output-dir',str(directory)]
        if a.connectome_readout:args.append('--connectome-readout')
        if summary:args.append('--summary')
        subprocess.run(args,check=True)
        s=struct.unpack('<24I',(directory/'status.bin').read_bytes())
        f=struct.unpack('<16I',(directory/'fusion.bin').read_bytes())
        if a.connectome_readout:
            head=struct.unpack('<14I',(directory/'readout_record.bin').read_bytes())
            assert head[0]==0x43524431 and not head[13] and head[1:6]==s[2:7], 'Readout source/publication binding changed'
            assert head[9]==int.from_bytes((directory/'readout_scores.bin').read_bytes(),'little')
        return s,f
    before=control();(out/'before.json').write_text(json.dumps(before,indent=2));rows=[]
    try:
        state=control('--ai-policy',0,'--mode',0,'--memory',0,'--recognition-model','fomo')
        assert state['recognition_model']==1,state
        # Bulk source snapshots use the renderer's protected source contract.
        control('--roi',0,0,1920,1080,'--output-size',1920,1080,'--position',0,0,'--roi-enable',1)
        control('--memory',1)
        deadline=time.monotonic()+12
        while True:
            state=control()
            if state['source_held'] and state['source_frozen'] and state['roi_frame_ok'] and not state['render_busy']:break
            if time.monotonic()>deadline:raise TimeoutError(state)
        frame=state['roi_frame_id'];render=state['applied_config_id'];control('--key-event',4)
        wait_done(lambda s:s['ai_frame']==frame and s['ai_render_config']==render)
        first,f=read('frozen');assert first[3]==frame and f[6]==2 and not(f[2]&2)
        xy,wh=struct.unpack('<24I',(out/'frozen/legacy.bin').read_bytes())[6:8]
        subprocess.run([sys.executable,str(ROOT/'scripts/capture_mode_images.py'),'--url',a.url,'--output-dir',str(out/'frozen/source'),
                        '--modes','source','--source-native-order','--current-view','--rows',str(xy>>16),str(wh>>16)],check=True)
        print('PASS camera FOMO frozen source',frame,'sequence',first[2],flush=True)
        time.sleep(2);stable,_=read('stable',True);assert stable[2]==first[2],'FIX reran without a request'
        control('--roi',480,270,960,540,'--output-size',1920,1080,'--position',0,0)
        changed=control('--menu',8,'--key-event',4)
        wait_done(lambda s:s['ai_frame']==frame and s['ai_render_config']==changed['applied_config_id'])
        second,g=read('rerender',True)
        assert second[2]==first[2]+1 and second[3]==frame and second[5]==changed['applied_config_id'] and g[6]==2
        control('--menu',9,'--key-event',2);time.sleep(1);tested,h=read('selftest',True)
        assert tested[2]==second[2] and ((h[2]>>13)&3)==2 and h[3:11]==g[3:11],'Selftest replaced the camera result'
        control('--memory',0,'--roi-enable',0,'--menu',8);control('--key-event',4)
        wait_done(lambda s:s['ai_frame']!=frame and s['ai_render_config']==0)
        live,k=read('live',True)
        assert live[2]==second[2]+1 and live[3]!=frame and k[6]==2
        rows=[dict(case=name,sequence=s[2],source=s[3],render=s[5],context=s[6],invoke_ms=s[9]/100000) for name,s in [('first',first),('stable',stable),('rerender',second),('selftest',tested),('live',live)]]
    finally:
        restored=control('--ai-policy',0,'--memory',0,'--recognition-model',{1:'fomo',2:'m7'}[before['recognition_model']],'--mode',before['mode'],'--median',before['median'],'--menu',0,'--roi-enable',0)
        (out/'restore.json').write_text(json.dumps(restored,indent=2))
    result=dict(passed=True,cases=rows,scope='Actual SRAM key-event policy/CPU/camera leases; not manual pressing or card accuracy')
    (out/'result.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))


if __name__=='__main__':main()
