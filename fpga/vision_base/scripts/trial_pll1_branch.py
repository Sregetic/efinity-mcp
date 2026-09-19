# Controlled PLL1 branch test; always restore original registers after observation.
import json,time
from pathlib import Path
from sensor_register_control import command,transaction,sample
from efx_pgm.ftdi_program import acquire_jtag_engine
r=Path('results/camera_60fps_20260919');d={}
with acquire_jtag_engine(1e6,'ftdi://0x0403:0x6011:4:3/2') as e:
 e.reset();command(e,126,9);time.sleep(.05);orig={k:transaction(e,k)['value'] for k in [0x36eb,0x36ec]};d['original']=orig
 try:
  d['writes']=[transaction(e,0x36eb,0x0c),transaction(e,0x36ec,0x55)];time.sleep(1)
  d['rx']=sample(e,13,25)
 finally:
  command(e,126,9);time.sleep(.05);d['restore']=[transaction(e,k,v) for k,v in orig.items()];time.sleep(.5);command(e,126,0)
  (r/'pll1_branch_trial.json').write_text(json.dumps(d,indent=2))
a=d['rx'];print('fps',(a[-1]['sensor_frames']-a[0]['sensor_frames'])/(a[-1]['time_s']-a[0]['time_s']));print('geometry',sorted(set((x['words_per_line'],x['lines'],x['words']) for x in a)))
