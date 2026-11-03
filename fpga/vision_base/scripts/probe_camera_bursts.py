"""Compare physical LP/HS bursts with decoded pixel lines, then restore original divider."""
import json,time
from pathlib import Path
from sensor_register_control import command,transaction,sample
from efx_pgm.ftdi_program import acquire_jtag_engine
out=Path('results/camera_60fps_20260919/link_probe');out.mkdir(exist_ok=True)
report={}
with acquire_jtag_engine(1e6,'ftdi://0x0403:0x6011:4:3/2') as e:
 e.reset();command(e,126,9);time.sleep(.05)
 old=transaction(e,0x36eb)['value'];report['original']=old
 try:
  report['baseline_wire']=sample(e,15,25);report['baseline_rx']=sample(e,13,10)
  command(e,126,9);time.sleep(.05);report['change']=transaction(e,0x36eb,0x0c);time.sleep(.5)
  report['fast_wire']=sample(e,15,25);report['fast_rx']=sample(e,13,15)
 finally:
  command(e,126,9);time.sleep(.05);report['restore']=transaction(e,0x36eb,old);time.sleep(.5)
  report['restored_rx']=sample(e,13,10);command(e,126,0)
  (out/'physical_vs_decoded.json').write_text(json.dumps(report,indent=2))
for name in ('baseline_wire','fast_wire'):
 a=report[name];dt=a[-1]['time_s']-a[0]['time_s'];print(name,{k:((a[-1][k]-a[0][k])&0xffffffff)/dt for k in ['byte_ticks','lp_entries','hs_entries']})
for name in ('baseline_rx','fast_rx','restored_rx'):
 a=report[name];dt=a[-1]['time_s']-a[0]['time_s'];print(name,(a[-1]['sensor_frames']-a[0]['sensor_frames'])/dt,sorted(set((x['words_per_line'],x['lines'],x['words']) for x in a)))
