# Rejected experimental clock profiles; NOT a production 60 fps preset.
import json,time,argparse
from pathlib import Path
from sensor_register_control import command,transaction,sample
from efx_pgm.ftdi_program import acquire_jtag_engine
p=argparse.ArgumentParser();p.add_argument('--both',action='store_true');p.add_argument('--mipi',action='store_true');args=p.parse_args()
r=Path('results/camera_60fps_20260919');report={}
with acquire_jtag_engine(1e6,'ftdi://0x0403:0x6011:4:3/2') as e:
 e.reset();report['before']=sample(e,13,12);command(e,126,9);time.sleep(.05)
 orig=transaction(e,0x36eb)['value'];orig2=transaction(e,0x37fc)['value'];orig3=transaction(e,0x37fb)['value'];report['before_divider']=orig;report['before_divider2']=orig2
 report['write']=transaction(e,0x36eb,0x0c)
 if args.both:report['write2']=transaction(e,0x37fc,0x20)
 if args.mipi:report['write3']=transaction(e,0x37fb,0x44)
 time.sleep(1)
 report['after']=sample(e,13,30)
 a=report['after'];fps=(a[-1]['sensor_frames']-a[0]['sensor_frames'])/(a[-1]['time_s']-a[0]['time_s'])
 report['fps']=fps;report['valid']=58<fps<62 and all(x['words']==921600 and x['lines']==1440 and x['words_per_line']==640 for x in a)
 if not report['valid']:
  command(e,126,9);time.sleep(.05);report['restore']=transaction(e,0x36eb,orig)
  if args.both:report['restore2']=transaction(e,0x37fc,orig2)
  if args.mipi:report['restore3']=transaction(e,0x37fb,orig3)
 command(e,126,0)
(r/('live_mipi_trial.json' if args.mipi else ('live_both_dividers_trial.json' if args.both else 'live_divider_trial.json'))).write_text(json.dumps(report,indent=2));print(json.dumps({k:v for k,v in report.items() if k not in ('before','after')},indent=2))

