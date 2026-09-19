"""Compare baseline, divider-only and paired high-clock CSI observations."""
import json,time
from pathlib import Path
from sensor_register_control import command,raw,transaction,sample
from efx_pgm.ftdi_program import acquire_jtag_engine
report={};out=Path('results/camera_60fps_20260919/link_probe/clock_error_comparison.json')
def select(e):command(e,126,9);time.sleep(.03)
def observe(e):
 command(e,21,0)
 a=sample(e,13,10);phy=sample(e,15,4)
 command(e,21,1);command(e,126,15);time.sleep(.05);errs=[]
 for _ in range(8):
  v=raw(e)
  assert ((v>>128)&0xffffffff)==0x2609192f
  errs.append(dict(time_s=time.time(),de=(v>>64)&0xffffffff,hs=(v>>32)&0xffffffff,seen=f'{(v>>16)&65535:04x}',live=f'{v&65535:04x}'));time.sleep(.2)
 command(e,21,0)
 return dict(rx=a,physical=phy,csi=errs)
with acquire_jtag_engine(1e6,'ftdi://0x0403:0x6011:4:3/2') as e:
 e.reset();command(e,1,0);command(e,7,3);command(e,11,1)
 select(e);original={k:transaction(e,k)['value'] for k in (0x36eb,0x36ec)}
 try:
  report['baseline']=observe(e)
  if not all(x['words']==921600 and x['lines']==1440 for x in report['baseline']['rx']):raise RuntimeError('Invalid baseline')
  select(e);transaction(e,0x36eb,0x0c);time.sleep(.2);report['divider_only']=observe(e)
  select(e);transaction(e,0x36ec,0x55);time.sleep(.2);report['paired_clock']=observe(e)
 finally:
  select(e)
  for k,v in original.items():transaction(e,k,v)
  report['register_restored']=observe(e)
  command(e,21,0);command(e,126,0);out.write_text(json.dumps(report,indent=2),encoding='utf-8')
for name,r in report.items():
 a=r['rx'];c=r['csi'];print(name,'FPS',(a[-1]['sensor_frames']-a[0]['sensor_frames'])/(a[-1]['time_s']-a[0]['time_s']),'GEOMETRY',[(x['words_per_line'],x['lines']) for x in a[:2]],'DE_DELTA',(c[-1]['de']-c[0]['de'])&0xffffffff,'HS_DELTA',(c[-1]['hs']-c[0]['hs'])&0xffffffff,'FLAGS',[(x['seen'],x['live']) for x in c])
