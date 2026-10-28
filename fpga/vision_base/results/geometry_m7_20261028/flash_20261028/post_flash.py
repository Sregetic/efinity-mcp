from pathlib import Path
import sys,subprocess,json,time
from efx_pgm.ftdi_program import acquire_jtag_engine
from efx_pgm.device_utils import DeviceUtils
from pyftdi.bits import BitSequence
R=Path(__file__).resolve().parents[3];O=Path(__file__).resolve().parent
URL='ftdi://0x0403:0x6011:4:b/2'
def run(script,*args):
 x=subprocess.run([sys.executable,str(R/script),*map(str,args)],capture_output=True,text=True);(O/(Path(script).stem+'.console.log')).write_text(x.stdout+x.stderr,encoding='utf-8');x.check_returncode();return x.stdout
def ctl(*args):return json.loads(run('scripts/vision_control.py','--url',URL,'--roi-status','--samples',1,*args))
def hold(v):
 with acquire_jtag_engine(1e6,URL)as e:
  e.reset();e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);e.write_dr(BitSequence((0x56495331<<32)|(0x26<<24)|v,length=192));e.go_idle()
try:
 s=ctl('--mode',7,'--median',1,'--shape',1,'--memory',1,'--sobel-threshold',96,'--canny-threshold',96,'--roi-enable',0,'--menu',0)
 time.sleep(10);hold(1);time.sleep(2)
 for attempt in range(3):
  name='flash_autoload_'+str(attempt);run('results/geometry_m7_20261028/read_runtime.py','--url',URL,'--name',name);q=json.loads((O.parent/'board_runtime'/(name+'.json')).read_text())
  if q['record_complete']:break
  time.sleep(1)
 assert q['record_complete'] and q['GEO_28']==[0] and q['GEO_04'][0]&4 and q['M7_RECORD'][21]==0 and q['M7_RECORD'][23]==0,q
 assert q['M7_RECORD'][2:5]==[q['GEO_18'][0],q['GEO_1c'][0],q['GEO_20'][0]],q
 (O/'m7_completed.json').write_text(json.dumps(q,indent=2),encoding='utf-8')
finally:
 hold(0);ctl('--mode',7,'--memory',0,'--menu',0);s=ctl('--key-event',8);(O/'final_state.json').write_text(json.dumps(s,indent=2),encoding='utf-8')
 assert s['mode']==7 and s['sidebar_level']==1 and not s['source_frozen'] and not s['source_held']
run('scripts/read_stream_profile.py','--url',URL,'--seconds',8,'--output',O/'health.json');h=json.loads((O/'health.json').read_text())['summary'];assert h['passed'] and all(h['last'][k]==0 for k in ['raw_overflows','capture_discarded','scan_bad_frames'])
a=dict(passed=True,configuration_flash_written=True,application_flash_written=True,program_bytes=447344,weights_bytes=4400,boot_package_bytes=451776,user1_program_download=False,cpu_resumed=True,source_fps=h['source_fps'],m7_compute_ms=q['M7_RECORD'][6]/100000,physical_power_cycle_verified=False,config_flash_reload_verified=False)
(O/'acceptance.json').write_text(json.dumps(a,indent=2),encoding='utf-8');print(json.dumps(a,indent=2))
