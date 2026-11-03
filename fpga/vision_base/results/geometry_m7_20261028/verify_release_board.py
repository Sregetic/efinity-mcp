from pathlib import Path
import sys,subprocess,json,time,importlib.util
from efx_pgm.ftdi_program import acquire_jtag_engine
from efx_pgm.device_utils import DeviceUtils
from pyftdi.bits import BitSequence
R=Path(__file__).resolve().parents[2];O=Path(__file__).resolve().parent/'board_release';O.mkdir(exist_ok=True);URL=sys.argv[1]
def run(file,*args):
 x=subprocess.run([sys.executable,str(R/file),*map(str,args)],capture_output=True,text=True)
 name=Path(file).stem;(O/(name+'.console.log')).write_text(x.stdout+x.stderr,encoding='utf-8');x.check_returncode();return x.stdout
def ctl(*args):return json.loads(run('scripts/vision_control.py','--url',URL,'--roi-status','--samples','1',*args))
def hold(v):
 with acquire_jtag_engine(1e6,URL)as e:
  e.reset();e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);e.write_dr(BitSequence((0x56495331<<32)|(0x26<<24)|v,length=192));e.go_idle()
def save(name,v):(O/name).write_text(json.dumps(v,indent=2),encoding='utf-8')
assert json.loads((O.parent/'board_load_release/result.json').read_text())['passed']
try:
 ctl('--mode',7,'--median',1,'--shape',1,'--memory',0,'--sobel-threshold',96,'--canny-threshold',96,'--menu',0)
 if len(sys.argv)>2 and sys.argv[2] in ('--continue','--images-only'):
  assert json.loads((O/'ui_checks.json').read_text())['passed'];ctl('--memory',1,'--menu',0)
 else:
  print(run('results/geometry_m7_20261028/check_board_release.py',URL),flush=True)
 time.sleep(10);hold(1);time.sleep(3)
 if len(sys.argv)>2 and sys.argv[2]=='--images-only':
  q=json.loads((O/'completed_geometry.json').read_text());v=q['M7_RECORD']
 else:
  # Sequence zero is an owned producer update, including the frozen bitmap-cache copy.
  for attempt in range(3):
   name='release_frozen_'+str(attempt)
   print(run('results/geometry_m7_20261028/read_runtime.py','--url',URL,'--name',name),flush=True)
   q=json.loads((O.parent/('board_runtime/'+name+'.json')).read_text());v=q['M7_RECORD']
   if q['record_complete']:break
   time.sleep(1)
  assert q['record_complete'] and q['GEO_04'][0]&4 and q['GEO_28']==[0] and v[21]==0 and v[23]==0
  assert (v[2],v[3],v[4])==(q['GEO_18'][0],q['GEO_1c'][0],q['GEO_20'][0])
  save('completed_geometry.json',q)
 print(run('scripts/capture_edge_probe.py','--url',URL,'--output',O/'edge','--keep-held'),flush=True)
 print(run('scripts/capture_mode_images.py','--url',URL,'--output-dir',O/'m7','--current-view','--modes',7),flush=True)
 ctl('--shape',0)
 print(run('scripts/capture_mode_images.py','--url',URL,'--output-dir',O/'canny','--current-view','--modes',5),flush=True)
 print(run('scripts/capture_edge_probe.py','--url',URL,'--output',O/'edge_after','--keep-held'),flush=True)
 e=json.loads((O/'edge.json').read_text());a=json.loads((O/'edge_after.json').read_text())
 assert e['words']==a['words'] and e['canny_epoch']==a['canny_epoch']
 i=json.loads((O/'canny/images.json').read_text());j=json.loads((O/'m7/images.json').read_text())
 assert i['context']['roi_frame_id']==j['context']['roi_frame_id'] and all(x['threshold']==96 for x in i['images']+j['images'])
 x=subprocess.run(['C:/ProgramData/anaconda3/python.exe','-E',str(O.parent/'analyze_release_canny.py')],capture_output=True,text=True)
 (O/'canny_analysis.console.log').write_text(x.stdout+x.stderr,encoding='utf-8');x.check_returncode()
 different=json.loads((O/'canny_numeric.json').read_text())['different_pixels']

finally:
 hold(0)
 s=ctl('--memory',0,'--mode',7,'--median',1,'--shape',1,'--menu',0)
 s=ctl('--key-event',8);save('restored_live.json',s)
 assert s['mode']==7 and not s['source_frozen'] and s['sidebar_level']==1
print(run('scripts/read_stream_profile.py','--url',URL,'--output',O/'health.json','--seconds',8),flush=True)
h=json.loads((O/'health.json').read_text())['summary']
assert h['passed'] and all(h['last'][k]==0 for k in ['raw_overflows','capture_discarded','scan_bad_frames'])
s=ctl();save('final_state.json',s)
assert s['mode']==7 and s['median']==1 and s['memory']==0 and s['threshold']==96 and s['shape_threshold']==96 and s['sidebar_level']==1 and not s['source_held'] and not s['source_frozen']
save('acceptance.json',dict(passed=True,flash_written=False,cpu_resumed=True,physical_targets_checked=False,full_m7_compute_ms=v[6]/100000,contours_ms=v[16]&65535,gray_ms=(v[16]>>16)-(v[16]&65535),source_fps=h['source_fps'],actual_canny_rgb_different_pixels=different))
print('PASS final actual board pair, M7 metadata/control, frozen source identity, Canny RGB numeric equality; live M7/menu restored',flush=True)
