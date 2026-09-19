import json,time
from pathlib import Path
from sensor_register_control import command,transaction,sample
from efx_pgm.ftdi_program import acquire_jtag_engine
r=Path('results/camera_60fps_20260919/link_probe');r.mkdir(exist_ok=True)
d={}
with acquire_jtag_engine(1e6,'ftdi://0x0403:0x6011:4:3/2') as e:
 e.reset();command(e,126,9);time.sleep(.05)
 old={k:transaction(e,k)['value'] for k in (0x36eb,0x36ec)}
 try:
  d['write']=[transaction(e,0x36eb,0x0c),transaction(e,0x36ec,0x55)];time.sleep(.5)
  d['wire']=sample(e,15,15);d['rx']=sample(e,13,15)
 finally:
  command(e,126,9);time.sleep(.05);d['restore']=[transaction(e,k,v) for k,v in old.items()];command(e,126,0)
  (r/'high_link_clock.json').write_text(json.dumps(d,indent=2))
a=d['wire'];dt=a[-1]['time_s']-a[0]['time_s'];print('peak MHz',sorted(set(x['byte_clock_peak_mhz'] for x in a)));print('lp bursts/s',((a[-1]['lp_entries']-a[0]['lp_entries'])&0xffffffff)/dt)
print('geometry',sorted(set((x['words_per_line'],x['lines'],x['words']) for x in d['rx'])))
