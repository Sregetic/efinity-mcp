import json,time
from pathlib import Path
from sensor_register_control import command,raw,sample
from efx_pgm.ftdi_program import acquire_jtag_engine
out={}
with acquire_jtag_engine(1e6,'ftdi://0x0403:0x6011:4:3/2') as e:
 e.reset();command(e,1,0)
 out['boot']=sample(e,13,5)
 command(e,19,17);time.sleep(.3)
 out['delay_only']=sample(e,13,5)
 command(e,20,0);time.sleep(.3)
 out['reset_after_delay']=sample(e,13,5)
 command(e,126,0)
Path('results/camera_60fps_20260919/link_probe/reset_isolation.json').write_text(json.dumps(out,indent=2))
for k,a in out.items():print(k,[(x['words_per_line'],x['lines'],x['words']) for x in a])
