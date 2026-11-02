"""Board control policy through the same event FIFO as physical keys.

Debounce/long-press pins are exercised by tb_vision_control_bridge; these injected
events prove the on-board firmware and real DDR/display path, not human presses.
"""
import argparse,json,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def main():
 p=argparse.ArgumentParser();p.add_argument('--url',required=True);p.add_argument('--output-dir',required=True,type=Path);a=p.parse_args()
 a.output_dir.mkdir(parents=True,exist_ok=True);rows=[]
 def control(*args,roi=True):
  cmd=[sys.executable,str(ROOT/'scripts/vision_control.py'),'--url',a.url,*map(str,args)]
  cmd+=['--roi-status'] if roi else ['--page','32','--samples','1']
  r=subprocess.run(cmd,check=True,capture_output=True,text=True);v=json.loads(r.stdout)
  if not roi:
   v=v[0];assert v['build']=='26103043',v
  return v
 def settled(label,predicate):
  deadline=time.monotonic()+12
  while True:
   s=control()
   assert not any(s[k] for k in ['config_error','render_error','scan_error','canny_fault']),s
   if predicate(s):rows.append(dict(label=label,**s));return s
   if time.monotonic()>deadline:raise TimeoutError((label,s))
   time.sleep(.1)
 def key(bits):control('--key-event',bits)
 def focus(page):control('--menu',page)
 before=control();(a.output_dir/'before.json').write_text(json.dumps(before,indent=2))
 try:
  control('--menu',0,'--memory',0,'--mode',2,'--sobel-threshold',96,'--canny-threshold',80)
  key(2);settled('Sobel96_to112',lambda s:s['sobel_threshold']==112 and s['canny_threshold']==80)
  key(4);settled('Sobel112_to96',lambda s:s['sobel_threshold']==96)
  control('--sobel-threshold',16);key(4);settled('Sobel_floor16',lambda s:s['sobel_threshold']==16)
  control('--mode',5);key(4);settled('Canny80_to64',lambda s:s['canny_threshold']==64 and s['sobel_threshold']==16)
  key(2);settled('Canny64_to80',lambda s:s['canny_threshold']==80)
  control('--recognition-model','m7','--ai-policy',2,'--mode',5,'--canny-threshold',96)
  settled('M7_on_Canny',lambda s:s['recognition_model']==2 and s['geometry_enabled'] and s['mode']==5)
  control('--mode',2);settled('M7_on_Sobel',lambda s:s['recognition_model']==2 and s['geometry_enabled'] and s['mode']==2)
  control('--ai-policy',0);settled('recognition_off',lambda s:not s['geometry_enabled'] and not s['recognition_enabled'])
  focus(1);assert control(roi=False)['menu']==1
  key(2);settled('median_on',lambda s:s['median']==1)
  key(4);settled('median_off',lambda s:s['median']==0)
  # Freeze before changing any crop; the displayed original must stay identical.
  key(16);s=settled('freeze_direct',lambda s:s['memory']==1 and s['source_frozen'] and s['roi_frame_ok'])
  held=s['roi_frame_id'];focus(2);assert control(roi=False)['menu']==2
  key(2)
  ready=lambda s:s['roi_frame_ok'] and not(s['config_busy'] or s['render_busy'] or s['render_pending']) and s['applied_config_id']==s['requested_config_id']
  s=settled('frozen_zoom2x',lambda s:ready(s) and s['roi']==[480,270,960,540]);assert s['roi_frame_id']==held,(held,s)
  for page,expected,field in [(3,[512,270,960,540],'roi'),(4,[512,286,960,540],'roi')]:
   focus(page);key(2);s=settled('frozen_pan'+str(page),lambda s:ready(s) and s[field]==expected);assert s['roi_frame_id']==held
  focus(5);key(4);s=settled('frozen_view_half',lambda s:ready(s) and s['output_size']==[960,540]);assert s['roi_frame_id']==held
  focus(6);key(2);s=settled('frozen_position_x',lambda s:ready(s) and s['position']==[32,0]);assert s['roi_frame_id']==held
  focus(7);key(2);s=settled('frozen_position_y',lambda s:ready(s) and s['position']==[32,16]);assert s['roi_frame_id']==held
  focus(5);key(2);settled('viewport_clamp',lambda s:ready(s) and s['output_size']==[1920,1080] and s['position']==[0,0])
  focus(2);key(4);settled('zoom1x_disable',lambda s:not s['roi_enabled'] and not s['config_busy'])
  focus(0);key(32);u=control(roi=False);assert u['memory']==2 and u['index']==0,u
  history=[]
  for i in range(7):
   key(2);u=control(roi=False);assert u['index']==(i+1)%7,u;history.append(u)
  key(4);assert control(roi=False)['index']==6
  key(4);assert control(roi=False)['index']==5
  key(32);assert control(roi=False)['memory']==3
  key(32);assert control(roi=False)['memory']==1
  key(16);s=settled('resume_live',lambda s:s['memory']==0 and not s['source_frozen'])
  time.sleep(2);t=control();assert t['roi_frame_id']>s['roi_frame_id'],(s,t)
  result=dict(passed=True,scope='Actual SRAM bootstrap firmware, injected physical-key policy events, DDR and frame publication; not human key presses or real-card accuracy',cases=rows,history=history)
 finally:
  restored=control('--menu',0,'--memory',before['memory'],'--mode',before['mode'],'--median',before['median'],
   '--sobel-threshold',before['sobel_threshold'],'--canny-threshold',before['canny_threshold'],
   '--roi',*before['roi'],'--output-size',*before['output_size'],'--position',*before['position'],'--roi-enable',before['roi_enabled'],'--recognition-model',{1:'fomo',2:'m7'}[before['recognition_model']])
  (a.output_dir/'restore.json').write_text(json.dumps(restored,indent=2))
 result['restored']=restored;(a.output_dir/'result.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))

if __name__=='__main__':main()
