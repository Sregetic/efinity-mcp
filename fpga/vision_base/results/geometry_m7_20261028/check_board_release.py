from pathlib import Path
import sys,subprocess,json
R=Path(__file__).resolve().parents[2];O=Path(__file__).resolve().parent/'board_release';URL=sys.argv[1];rows=[]
def ctl(**kw):
 args=[sys.executable,str(R/'scripts/vision_control.py'),'--url',URL,'--roi-status','--samples','1']
 for k,v in kw.items():
  args.append('--'+k.replace('_','-'));args+=list(map(str,v))if isinstance(v,list)else[str(v)]
 x=subprocess.run(args,capture_output=True,text=True,check=True);s=json.loads(x.stdout);rows.append(dict(command=kw,state=s));return s
def key(v):return ctl(key_event=v)
s=ctl(mode=7,median=1,memory=0,menu=0)
assert s['mode']==7 and s['shape_threshold']==96
assert key(2)['shape_threshold']==112
s=ctl();assert s['threshold']==112 and s['shape_threshold']==112
assert key(4)['shape_threshold']==96
s=ctl();assert s['threshold']==96 and s['shape_threshold']==96
assert key(8)['sidebar_level']==1
assert key(1)['sidebar_level']==2
s=key(1);assert s['sidebar_level']==3 and s['sidebar_edit']==1
assert key(2)['mode']==6
assert key(4)['mode']==7
s=key(1);assert s['sidebar_level']==2 and not s['sidebar_edit']
s=key(4);assert s['sidebar_item']==1
s=key(1);assert s['sidebar_edit'] and s['shape_threshold']==96
assert key(2)['shape_threshold']==112
assert key(2)['shape_threshold']==128
assert key(4)['shape_threshold']==112
assert key(4)['shape_threshold']==96
s=key(1);assert not s['sidebar_edit'] and s['shape_threshold']==96
s=key(4);assert s['sidebar_item']==2
s=key(1);assert s['median']==0 and not s['sidebar_edit']
s=key(1);assert s['median']==1 and not s['sidebar_edit']
s=ctl(menu=0,roi=[0,0,1920,1080],output_size=[1920,1080],position=[0,0],roi_enable=0,memory=1)
assert s['mode']==7 and s['source_frozen'] and s['shape_threshold']==96
(O/'ui_checks.json').write_text(json.dumps(dict(passed=True,checks=len(rows),scope='Actual board firmware events and state readback; electrical key hold not measured',rows=rows),indent=2),encoding='utf-8')
print('PASS actual board M7 live thresholds, 8-mode preview/confirm, direct median toggle; frozen full view ready')
