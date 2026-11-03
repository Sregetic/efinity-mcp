import json,subprocess,sys,time
from pathlib import Path
ROOT=Path.cwd();out=ROOT/'results/xlr_control_20261007/board';url='ftdi://0x0403:0x6011:4:9/2'
def control(*args):
 r=subprocess.run([sys.executable,str(ROOT/'scripts/vision_control.py'),'--url',url,'--roi-status',*map(str,args)],capture_output=True,text=True,check=True)
 return json.loads(r.stdout)
initial=control();rows=[]
try:
 for age in range(6):
  s=control('--memory',2,'--index',age);rows.append(s)
  assert s['memory']==2 and s['roi_enabled']==0 and s['roi_frame_ok'] and not s['scan_error'],s
 ids=[s['roi_frame_id'] for s in rows]
 assert len(set(ids))==6 and all(a>b for a,b in zip(ids,ids[1:])),ids
 assert all(s['scan_bad_frames']==initial['scan_bad_frames'] for s in rows),rows
 result=dict(passed=True,scope='Actual pinned six-frame history source IDs and scan status',frame_ids=ids,samples=rows)
finally:
 result_restore=control('--memory',initial['memory'],'--index',0)
 (out/'history.json').write_text(json.dumps(dict(initial=initial,rows=rows,restored=result_restore),indent=2),encoding='utf-8')
result['restored']=result_restore;(out/'history.json').write_text(json.dumps(result,indent=2),encoding='utf-8');print(json.dumps(dict(passed=True,frame_ids=ids,restored_memory=result_restore['memory']),indent=2))
