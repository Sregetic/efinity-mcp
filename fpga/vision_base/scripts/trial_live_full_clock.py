# Rejected experimental clock profiles; NOT a production 60 fps preset.
"""Live clock-only profile test with full-frame validation and automatic restoration."""
import time,json
from pathlib import Path
from sensor_register_control import command,raw,transaction,sample
from efx_pgm.ftdi_program import acquire_jtag_engine
r=Path('results/camera_60fps_20260919');rep={'passed':False}
regs={0x36e9:0x44,0x37f9:0x44,0x36ea:0x23,0x36eb:0x0c,0x36ec:0x55,0x36ed:0x18,0x37fa:0x23,0x37fb:0x44,0x37fc:0x20,0x37fd:0x1c}
def select(e):command(e,126,9);time.sleep(.04)
def check(a):
 fps=(a[-1]['sensor_frames']-a[0]['sensor_frames'])/(a[-1]['time_s']-a[0]['time_s'])
 geo=all(x['words']==921600 and x['words_per_line']==640 and x['lines']==1440 and x['data_type']==43 for x in a)
 return fps,geo
with acquire_jtag_engine(1e6,'ftdi://0x0403:0x6011:4:3/2') as e:
 e.reset();select(e);orig={k:transaction(e,k)['value'] for k in list(regs)+[0x320c,0x320d]};rep['original']={f'{k:04x}':v for k,v in orig.items()}
 try:
  rep['writes']=[transaction(e,k,v) for k,v in regs.items()];time.sleep(1)
  a=sample(e,13,30);fps,geo=check(a);rep.update(first_rx=a,first_fps=fps,first_geometry=geo)
  if geo and 50<fps<58:
   hts=(orig[0x320c]<<8)|orig[0x320d];newhts=2*round(hts*fps/60/2);rep['hts_candidate']=newhts
   select(e);rep['hts_writes']=[transaction(e,0x320c,newhts>>8),transaction(e,0x320d,newhts&255)];time.sleep(1)
   a=sample(e,13,30);fps,geo=check(a);rep.update(second_rx=a,second_fps=fps,second_geometry=geo)
  rep['passed']=geo and 58<fps<62
 finally:
  if not rep['passed']:
   select(e);rep['restore']=[transaction(e,k,v) for k,v in orig.items()]
  command(e,126,0)
  (r/'live_full_clock_trial.json').write_text(json.dumps(rep,indent=2))
print(json.dumps({k:v for k,v in rep.items() if k not in ['first_rx','second_rx','writes','restore','original']},indent=2))
