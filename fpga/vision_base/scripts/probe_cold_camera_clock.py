"""Cold-start high-rate CSI diagnosis. Does not issue receiver soft reset."""
import argparse,json,time
from pathlib import Path
from sensor_register_control import command,raw,transaction,sample
from efx_pgm.ftdi_program import acquire_jtag_engine
p=argparse.ArgumentParser();p.add_argument('--all-taps',action='store_true');args=p.parse_args()
out=Path('results/camera_60fps_20260919/link_probe/cold_start_scan.json')
def select(e):command(e,126,9);time.sleep(.03)
def delay(e,tap):
 select(e);before=(raw(e)>>16)&255;command(e,19,tap)
 end=time.monotonic()+1
 while time.monotonic()<end:
  time.sleep(.01);v=raw(e)&0xffffffff
  if v>>24==0xd1 and ((v>>16)&255)==((before+1)&255) and ((v>>8)&63)==tap and not(v&1):return
 raise TimeoutError('delay command')
def error_sample(e,n=3):
 command(e,21,1);command(e,126,15);time.sleep(.05);a=[]
 for _ in range(n):
  v=raw(e)
  if ((v>>128)&0xffffffff)!=0x2609192f:raise RuntimeError('CSI diagnostic marker missing')
  a.append(dict(time_s=time.time(),de=(v>>64)&0xffffffff,hs=(v>>32)&0xffffffff,seen=f'{(v>>16)&65535:04x}',live=f'{v&65535:04x}'));time.sleep(.2)
 command(e,21,0);return a
def metrics(a):
 return dict(fps=((a[-1]['sensor_frames']-a[0]['sensor_frames'])&0xffffffff)/(a[-1]['time_s']-a[0]['time_s']),geometry_ok=all(x['words_per_line']==640 and x['lines']==1440 and x['words']==921600 and x['data_type']==43 for x in a))
r={'trials':[],'accepted_rx_candidate':False}
with acquire_jtag_engine(1e6,'ftdi://0x0403:0x6011:4:3/2') as e:
 e.reset();command(e,1,0);command(e,7,3);command(e,11,1)
 select(e);r['registers']={hex(k):transaction(e,k)['value'] for k in [0x36eb,0x36ec,0x320c,0x320d,0x320e,0x320f]}
 r['boot_rx']=sample(e,13,12);r['boot_metrics']=metrics(r['boot_rx']);r['boot_csi']=error_sample(e)
 print('BOOT',r['boot_metrics'],r['boot_csi'],flush=True)
 if r['boot_metrics']['geometry_ok'] and 57<r['boot_metrics']['fps']<63:r['accepted_rx_candidate']=True;r['selected_tap']=17
 candidates=[17,8,12,4,20,24,28,0,32,36,40,44,48,52,56,60]
 if args.all_taps:candidates+= [i for i in range(64) if i not in candidates]
 try:
  for tap in candidates:
   if r['accepted_rx_candidate']:break
   delay(e,tap);a=sample(e,13,4);m=metrics(a);err=error_sample(e,2)
   item=dict(tap=tap,**m,rx=a,csi=err);r['trials'].append(item)
   print('TAP',tap,m,'DE_DELTA',(err[-1]['de']-err[0]['de'])&0xffffffff,'HS_DELTA',(err[-1]['hs']-err[0]['hs'])&0xffffffff,'ERRORS',err[-1]['seen'],err[-1]['live'],flush=True)
   if m['geometry_ok'] and 57<m['fps']<63:r['accepted_rx_candidate']=True;r['selected_tap']=tap
   out.write_text(json.dumps(r,indent=2),encoding='utf-8')
  if not r['accepted_rx_candidate']:delay(e,17)
 finally:
  command(e,21,0);command(e,126,0);out.write_text(json.dumps(r,indent=2),encoding='utf-8')
print('RX_CANDIDATE',r['accepted_rx_candidate'],r.get('selected_tap'))
