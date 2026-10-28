from pathlib import Path
import sys,subprocess,json
R=Path(__file__).resolve().parents[3];O=Path(__file__).parent;url='ftdi://0x0403:0x6011:4:b/2';rows=[]
def ctl(*args):
 x=subprocess.run([sys.executable,str(R/'scripts/vision_control.py'),'--url',url,'--roi-status','--samples','1',*map(str,args)],capture_output=True,text=True);x.check_returncode();q=json.loads(x.stdout);rows.append(dict(command=args,state=q));(O/'menu_events.json').write_text(json.dumps(rows,indent=2),encoding='utf-8');return q
q=ctl('--menu',0);median=q['median'];assert q['mode']==7 and q['memory']==0
q=ctl('--key-event',8);assert q['sidebar_level']==1
q=ctl('--key-event',1);assert q['sidebar_level']==2 and q['sidebar_item']==0
q=ctl('--key-event',4);assert q['sidebar_item']==1
q=ctl('--key-event',4);assert q['sidebar_item']==2
q=ctl('--key-event',1);assert q['median']==(median^1) and not q['sidebar_edit']
q=ctl('--key-event',1);assert q['median']==median and not q['sidebar_edit']
q=ctl('--key-event',8);assert q['sidebar_level']==1
assert not q['source_held'] and not q['source_frozen'] and not q['scan_error'] and not q['render_error']
(O/'final_state.json').write_text(json.dumps(q,indent=2),encoding='utf-8');print('PASS Flash-loaded application: long KEY0 menu, navigation, median immediate toggle/restore; realtime M7, level1 menu, no hold')
