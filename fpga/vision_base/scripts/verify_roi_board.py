"""Actual DDR/ROI board check. Run with Efinity Python after SRAM programming."""
import argparse,json,subprocess,sys,time
from pathlib import Path

root=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--url',required=True);p.add_argument('--output-dir',type=Path,required=True);p.add_argument('--seconds',type=int,default=30);p.add_argument('--snapshots',action='store_true');a=p.parse_args()
out=a.output_dir;out.mkdir(parents=True,exist_ok=True)
records=[]
def control(*args):
    v=subprocess.run([sys.executable,str(root/'scripts/vision_control.py'),'--url',a.url,'--roi-status',*map(str,args)],capture_output=True,text=True,check=True)
    return json.loads(v.stdout)
def save(name,state):
    (out/(name+'.status.json')).write_text(json.dumps(state,indent=2),encoding='utf-8')
    print(name,json.dumps({k:state[k] for k in ['roi_frame_id','applied_config_id','held_source_frame_id','capture_discarded','scan_bad_frames','render_cycles']}),flush=True)
def stable(name):
    samples=[];started=time.monotonic()
    while time.monotonic()-started<a.seconds:
        state=control();samples.append(dict(time_s=time.monotonic(),**state));time.sleep(1)
    (out/(name+'.samples.json')).write_text(json.dumps(samples,indent=2),encoding='utf-8')
    first,last=samples[0],samples[-1]
    assert last['scan_bad_frames']==first['scan_bad_frames'],f'{name}: scan underflow'
    assert last['capture_discarded']==first['capture_discarded'],f'{name}: source overflow'
    assert all(not(s['config_error'] or s['render_error'] or s['scan_error'] or s['canny_fault']) for s in samples),f'{name}: pipeline error'
    assert any(s['roi_frame_ok'] for s in samples),f'{name}: no valid field'
    assert last['roi_frame_id']>first['roi_frame_id'],f'{name}: live publication stopped'
    record=dict(name=name,seconds=last['time_s']-first['time_s'],source_frames=last['rgb_capture_count']-first['rgb_capture_count'],scan_bad_delta=0,source_discard_delta=0)
    records.append(record);print('PASS',json.dumps(record),flush=True)

for name,roi in [('live_full',[0,0,1920,1080]),('live_zoom',[480,270,960,540])]:
    state=control('--memory',0,'--mode',5,'--threshold',128,'--median',1,'--shape',1,'--roi',*roi,'--output-size',1920,1080,'--position',0,0)
    save(name,state);time.sleep(2);stable(name)
control('--memory',1)
deadline=time.monotonic()+10
while True:
    source=control()
    if source['source_held'] and source['source_frozen'] and not(source['render_busy'] or source['render_pending']):break
    if time.monotonic()>deadline:raise TimeoutError('Frozen source has not settled')
# The unified pool keeps acquiring live frames while the leased source stays fixed.
held=(source['held_source_frame_id'],source['held_raw_id_sample']);frozen=[]
for name,roi,size,pos in [
    ('frozen_full',[0,0,1920,1080],[1920,1080],[0,0]),
    ('frozen_zoom',[480,270,960,540],[1920,1080],[0,0]),
    ('frozen_pan',[608,334,960,540],[1920,1080],[0,0]),
    ('frozen_small',[0,0,1920,1080],[960,540],[480,270])]:
    state=control('--roi',*roi,'--output-size',*size,'--position',*pos,'--rerender');save(name,state)
    assert (state['held_source_frame_id'],state['held_raw_id_sample'])==held,'Frozen source changed'
    assert state['roi_frame_id']==held[0] and state['applied_config_id']==state['requested_config_id'],'Wrong source/config published'
    frozen.append(dict(name=name,**state));time.sleep(2)
    if a.snapshots:
        subprocess.run([sys.executable,str(root/'scripts/capture_edge_probe.py'),'--url',a.url,'--output',str(out/name)],check=True)
        context=json.loads((out/(name+'.json')).read_text(encoding='utf-8'))['context']
        assert context['held_source_frame_id']==held[0] and context['applied_config_id']==state['applied_config_id'],'Snapshot identity changed'
final=control('--memory',0,'--roi',0,0,1920,1080,'--output-size',1920,1080,'--position',0,0);save('final_live',final)
(out/'board.verification.json').write_text(json.dumps(dict(passed=True,scope='Actual DDR/ROI runtime; current artifact is recorded by the separate programming log',live=records,frozen=frozen,final=final),indent=2),encoding='utf-8')
print('PASS actual ROI live/frozen shared DDR and immutable-source rerender',flush=True)
