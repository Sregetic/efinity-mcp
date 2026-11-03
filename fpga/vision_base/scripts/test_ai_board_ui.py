"""Board AI menu through the physical-key event FIFO; no human press claim."""
import argparse,json,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def main():
 p=argparse.ArgumentParser();p.add_argument('--url',required=True);p.add_argument('--elf',type=Path,required=True);p.add_argument('--output-dir',type=Path,required=True);a=p.parse_args();a.output_dir.mkdir(parents=True,exist_ok=True)
 def control(*args):
  r=subprocess.run([sys.executable,str(ROOT/'scripts/vision_control.py'),'--url',a.url,*map(str,args),'--roi-status'],capture_output=True,text=True,check=True);return json.loads(r.stdout)
 def record(name):
  path=a.output_dir/name
  subprocess.run([sys.executable,str(ROOT/'scripts/read_ai_result.py'),'--url',a.url,'--elf',str(a.elf),'--output-dir',str(path)],capture_output=True,text=True,check=True)
  return json.loads((path/'result.json').read_text())
 before=control();rows=[]
 try:
  control('--memory',0,'--ai-policy',0,'--menu',8);s=control('--key-event',2);assert s['menu']==8 and s['menu_value']==1,s
  control('--key-event',16)
  limit=time.monotonic()+12
  while True:
   s=control()
   if s['memory']==1 and s['source_frozen'] and s['roi_frame_ok'] and not s['render_busy']:break
   if time.monotonic()>limit:raise TimeoutError(s)
  frame=s['roi_frame_id'];control('--key-event',4);time.sleep(1)
  first=record('first');assert first['frame_id']==frame and first['runtime'][0:2]==[2,2],first
  time.sleep(1);stable=record('stable');assert stable['sequence']==first['sequence'],'FIX reran without a key request'
  control('--key-event',4);time.sleep(1);repeat=record('repeat');assert repeat['frame_id']==frame and repeat['sequence']==first['sequence']+1,repeat
  control('--menu',9,'--key-event',2);time.sleep(1);tested=record('selftest')
  assert tested['runtime'][1]==2 and tested['sequence']==repeat['sequence'],'Selftest overwrote the camera task'
  assert tested['fusion_record'][2]&0x7ff==repeat['fusion_record'][2]&0x7ff and tested['fusion_record'][3:14]==repeat['fusion_record'][3:14],'Selftest erased camera fusion fields'
  control('--menu',8,'--key-event',16);time.sleep(1);idle=record('live_idle')
  assert idle['sequence']==repeat['sequence'],'FIX became continuous after unfreezing'
  assert control()['roi_frame_id']!=frame,'Live source did not advance'
  control('--key-event',4);time.sleep(1);live=record('live_once')
  assert live['sequence']==repeat['sequence']+1 and live['frame_id']!=frame,live
  s=control('--key-event',2);assert s['menu_value']==2
  s=control('--key-event',2);assert s['menu_value']==0
  rows=[dict(case=name,frame_id=r['frame_id'],sequence=r['sequence'],runtime=r['runtime']) for name,r in [('first',first),('stable',stable),('repeat',repeat),('selftest',tested),('live_idle',idle),('live_once',live)]]
 finally:
  restored=control('--memory',before['memory'],'--menu',before['menu'],'--mode',before['mode'],'--median',before['median'],'--ai-policy',2)
  (a.output_dir/'restore.json').write_text(json.dumps(restored,indent=2))
 result=dict(passed=True,scope='Real CPU/DMA/DDR with injected physical-key events, not human presses or recognition accuracy',cases=rows)
 (a.output_dir/'result.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))

if __name__=='__main__':main()
