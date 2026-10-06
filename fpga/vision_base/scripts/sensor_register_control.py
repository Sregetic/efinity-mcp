"""Read/write sensor registers through the single-owner FPGA I2C diagnostic port."""
import argparse,json,time
from efx_pgm.ftdi_program import acquire_jtag_engine
from efx_pgm.device_utils import DeviceUtils
from pyftdi.bits import BitSequence

def command(e,op,value):
 e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2'])
 e.write_dr(BitSequence((0x56495331<<32)|(op<<24)|value,length=192));e.go_idle()

def raw(e):
 e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);v=int(e.read_dr(192));e.go_idle()
 if v>>160 != 0x56495331:raise RuntimeError('Invalid JTAG signature')
 return v

def status(e):
 v=raw(e)
 if ((v>>128)&0xffffffff)!=0x26091909:raise RuntimeError('Sensor diagnostic bitstream required')
 flags=(v>>32)&255
 return dict(sequence=(v>>64)&0xffffffff,address=(v>>48)&65535,value=(v>>40)&255,
             busy=(flags>>3)&1,fault=(flags>>2)&1,ack=(flags>>1)&1,request=flags&1)

def transaction(e,address,value=None):
 before=status(e)
 if before['busy'] or before['ack']!=before['request']:raise RuntimeError('Previous sensor command pending')
 command(e,16 if value is None else 17,(address<<8)|(0 if value is None else value))
 deadline=time.monotonic()+2
 while time.monotonic()<deadline:
  time.sleep(.01);s=status(e)
  if s['sequence']==((before['sequence']+1)&0xffffffff) and s['ack']==s['request'] and not s['busy']:
   if s['fault']:raise RuntimeError(f'Sensor transaction failed {s}')
   if s['address']!=address:raise RuntimeError(f'Sensor address mismatch {s}')
   if value is not None and s['value']!=value:raise RuntimeError(f'Sensor write readback mismatch {s}')
   return s
 raise TimeoutError(f'Sensor transaction timeout {address:04x}')

def sample(e,page,count):
 command(e,126,page);time.sleep(.05);rows=[]
 for _ in range(count):
  v=raw(e);geometry=(v>>4)&((1<<60)-1)
  row=dict(time_s=time.time(),page=page,raw=f'{v:048x}')
  if page==13:
   row.update(sensor_frames=(v>>64)&0xffffffff,words_per_line=geometry>>48,lines=(geometry>>36)&4095,
       words=(geometry>>12)&0xffffff,ppc=(geometry>>8)&15,data_type=(geometry>>2)&63)
  elif page==14:
   row.update(overruns=(v>>64)&0xffffffff,words=geometry>>36,lines=(geometry>>24)&4095,
       words_per_line=(geometry>>12)&4095,late=(geometry>>4)&255)
  elif page==15:
   row.update(byte_ticks=(v>>64)&0xffffffff,lp_entries=(v>>32)&0xffffffff)
   if ((v>>128)&0xffffffff)==0x2609191f:row.update(byte_clock_peak_mhz=(v>>16)&65535,byte_clock_window_edges=v&65535)
   else:row.update(hs_entries=v&0xffffffff)
  rows.append(row);time.sleep(.2)
 return rows

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--url',default='ftdi://0x0403:0x6011:4:3/2')
 p.add_argument('--read',nargs='*',type=lambda x:int(x,0));p.add_argument('--write',action='append',default=[],help='address=value, e.g. 0x320e=0x05')
 p.add_argument('--page',type=int,choices=[13,14,15]);p.add_argument('--samples',type=int,default=30)
 a=p.parse_args()
 with acquire_jtag_engine(1e6,a.url) as e:
  e.reset();command(e,126,9);time.sleep(.05)
  out=[]
  for address in a.read or []:out.append(transaction(e,address))
  for spec in a.write:
   k,v=spec.split('=');out.append(transaction(e,int(k,0),int(v,0)))
  if a.page is not None:out.extend(sample(e,a.page,a.samples))
  print(json.dumps(out,indent=2))
