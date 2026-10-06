# Rejected experimental clock profiles; NOT a production 60 fps preset.
"""Bounded sensor clock A/B. Restore read-back settings if geometry/rate checks fail."""
import json,time,argparse
from pathlib import Path
from sensor_register_control import command,raw,status,transaction,sample
from efx_pgm.ftdi_program import acquire_jtag_engine

p=argparse.ArgumentParser();p.add_argument('--profile',choices=['fast_clock','divider_only'],default='fast_clock');args=p.parse_args()
out=Path(__file__).resolve().parents[1]/'results/camera_60fps_20260919'
# Clock-only subset of OpenIPC/openhisilicon smart_sc431hai/sc431hai_cfg.h
# high-throughput same-sensor mode. No HDR/window/exposure/gain registers copied.
clock_regs={0x36e9:0x44,0x37f9:0x44,0x36ea:0x23,0x36eb:0x0c,0x36ec:0x55,0x36ed:0x18,
            0x37fa:0x23,0x37fb:0x44,0x37fc:0x20,0x37fd:0x1c}
report={'candidate':{f'{k:04x}':v for k,v in clock_regs.items()},'writes':[],'passed':False}

def read_page(e,page,n=25):
 command(e,126,page);time.sleep(.05);a=[]
 for _ in range(n):
  v=raw(e);a.append({'time_s':time.time(),'raw':f'{v:048x}','hi':(v>>64)&0xffffffff,'mid':(v>>32)&0xffffffff,'lo':v&0xffffffff});time.sleep(.2)
 return a

def apply(e,regs):
 command(e,126,9);time.sleep(.03)
 report['writes'].append(transaction(e,0x0100,0));time.sleep(.05)
 for reg in (0x36e9,0x37f9):report['writes'].append(transaction(e,reg,0x80))
 for reg,val in regs.items():
  if reg not in (0x36e9,0x37f9):report['writes'].append(transaction(e,reg,val))
 for reg in (0x36e9,0x37f9):report['writes'].append(transaction(e,reg,regs[reg]))
 time.sleep(.02);report['writes'].append(transaction(e,0x0100,1));time.sleep(2)

with acquire_jtag_engine(1e6,'ftdi://0x0403:0x6011:4:3/2') as e:
 e.reset();command(e,126,9);time.sleep(.05)
 original={k:transaction(e,k)['value'] for k in clock_regs};report['original']={f'{k:04x}':v for k,v in original.items()}
 (out/f'clock_trial_{args.profile}_original.json').write_text(json.dumps(report,indent=2))
 try:
  command(e,11,0);time.sleep(.3)
  if args.profile=='divider_only':
   clock_regs=dict(original);clock_regs[0x36eb]=0x0c;report['candidate']={f'{k:04x}':v for k,v in clock_regs.items()}
  apply(e,clock_regs)
  rx=sample(e,13,35);report['rx']=rx
  dt=rx[-1]['time_s']-rx[0]['time_s'];fps=(rx[-1]['sensor_frames']-rx[0]['sensor_frames'])/dt;report['rx_fps']=fps
  report['rx_geometry_ok']=all(x['lines']==1440 and x['words_per_line']==640 and x['words']==921600 and x['data_type']==43 for x in rx)
  fov=sample(e,14,20);report['fov']=fov
  report['fov_ok']=all(x['lines']==1080 and x['words_per_line']==480 and x['words']==518400 and x['late']==0 for x in fov) and fov[-1]['overruns']==fov[0]['overruns']
  capture=read_page(e,0,35);report['capture']=capture
  cfps=(capture[-1]['hi']-capture[0]['hi'])/(capture[-1]['time_s']-capture[0]['time_s']);report['capture_fps']=cfps
  errors=read_page(e,1,20);report['write_status']=errors
  report['write_errors_stable']=errors[-1]['hi']==errors[0]['hi']
  report['passed']=58<=fps<=62 and 58<=cfps<=62 and report['rx_geometry_ok'] and report['fov_ok'] and report['write_errors_stable']
 finally:
  if not report['passed']:
   apply(e,original);report['restored']=True
  else:report['restored']=False
  command(e,11,1);command(e,1,0);command(e,126,0)
  (out/f'clock_trial_{args.profile}.json').write_text(json.dumps(report,indent=2))
print(json.dumps({k:v for k,v in report.items() if k not in ['rx','fov','capture','writes','write_status']},indent=2))

