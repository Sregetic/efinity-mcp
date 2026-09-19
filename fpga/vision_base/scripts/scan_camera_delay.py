"""Runtime MIPI input-delay eye scan; requires the diagnostic dynamic-delay build."""
import json,time
from pathlib import Path
from sensor_register_control import command,raw,transaction,sample
from efx_pgm.ftdi_program import acquire_jtag_engine
out=Path('results/camera_60fps_20260919/link_probe');out.mkdir(exist_ok=True)
def select(e):command(e,126,9);time.sleep(.02)
def phy(e):
 v=raw(e)&0xffffffff
 if v>>24!=0xd1:raise RuntimeError(f'Dynamic delay status missing: {v:08x}')
 return dict(updates=(v>>16)&255,tap=(v>>8)&63,busy=v&1)
def delay(e,tap):
 select(e);before=phy(e);command(e,19,tap);limit=time.monotonic()+1
 while time.monotonic()<limit:
  time.sleep(.01);p=phy(e)
  if p['updates']==((before['updates']+1)&255) and p['tap']==tap and not p['busy']:return
 raise TimeoutError(f'delay setting {tap}')
def reset_link(e):command(e,20,0);time.sleep(.15)
def rates(a):
 dt=a[-1]['time_s']-a[0]['time_s'];fps=(a[-1]['sensor_frames']-a[0]['sensor_frames'])/dt
 return fps,all(x['lines']==1440 and x['words']==921600 and x['words_per_line']==640 and x['data_type']==43 for x in a)
report={'trials':[],'passed':False};original={}
with acquire_jtag_engine(1e6,'ftdi://0x0403:0x6011:4:3/2') as e:
 e.reset();select(e);original={k:transaction(e,k)['value'] for k in (0x36eb,0x36ec)}
 try:
  delay(e,17);report['baseline_rx']=sample(e,13,6)
  if not rates(report['baseline_rx'])[1]:raise RuntimeError('Baseline geometry failed; reprogram before scan')
  select(e);transaction(e,0x36eb,0x0c);transaction(e,0x36ec,0x55)
  # Soft reset independently invalidated the baseline; scan delay without receiver reset.
  candidates=[17,8,12,4,20,24,28,0,32,36,40,44,48,52,56,60]
  for tap in candidates:
   delay(e,tap);a=sample(e,13,6);fps,geo=rates(a)
   rec={'tap':tap,'fps':fps,'geometry_ok':geo,'rx':a};report['trials'].append(rec)
   print(json.dumps({k:v for k,v in rec.items() if k!='rx'}),flush=True)
   (out/'delay_scan_no_reset.json').write_text(json.dumps(report,indent=2))
   if geo and 57<=fps<=63:
    report['passed']=True;report['selected_tap']=tap;break
 finally:
  if not report['passed']:
   select(e)
   for k,v in original.items():transaction(e,k,v)
   delay(e,17)
  command(e,126,0);(out/'delay_scan_no_reset.json').write_text(json.dumps(report,indent=2))
print('VALID_CANDIDATE',report['passed'],report.get('selected_tap'))

