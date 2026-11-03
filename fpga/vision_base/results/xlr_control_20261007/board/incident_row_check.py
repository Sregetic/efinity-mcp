import sys,time,json
from pathlib import Path
ROOT=Path.cwd();sys.path.insert(0,str(ROOT/'scripts'))
from capture_mode_images import decode_snapshot,check_row,rgb_bytes,write_png
from efx_pgm.ftdi_program import acquire_jtag_engine
from efx_pgm.device_utils import DeviceUtils
from pyftdi.bits import BitSequence
out=ROOT/'results/xlr_control_20261007/board/incident_rows';out.mkdir(parents=True,exist_ok=True)
rows=[];images={0:bytearray(),1:bytearray()}
with acquire_jtag_engine(6e6,'ftdi://0x0403:0x6011:4:9/2') as e:
 e.reset();ftdi=e._engine_provider._ctrl._ftdi;old=ftdi.get_latency_timer();ftdi.set_latency_timer(1)
 def cmd(op,value):
  e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);e.write_dr(BitSequence((0x56495331<<32)|(op<<24)|value,length=192));e.go_idle()
 def read(n=192):
  e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);e.change_state('shift_dr');v=e.read(n,first=True,last=True);e.change_state('update_dr');e.go_idle();return v
 try:
  for i in range(32):
   for source in [1,0]:
    cmd(126,26);before=decode_snapshot(int(read()));expected=(before['sequence']+1)&0xffffffff
    cmd(0x40,(source<<11)|480);deadline=time.monotonic()+1
    while True:
     h=decode_snapshot(int(read()))
     if h['sequence']==expected:break
     if time.monotonic()>deadline:raise TimeoutError(str(h))
    check_row(h,dict(source=source,row=480,sequence=expected));cmd(126,27);raw=read(192+1920*24).tobytes(msby=True);check_row(decode_snapshot(int.from_bytes(raw[:24],'little')),h)
    rgb=rgb_bytes(raw[24:],2 if source else 0);images[source].extend(rgb)
    means=[sum(rgb[c::3])/1920 for c in range(3)]
    rows.append(dict(i=i,t=time.monotonic(),source=source,mean_rgb=means,magenta=sum(1 for x in range(0,len(rgb),3) if rgb[x]>rgb[x+1]+30 and rgb[x+2]>rgb[x+1]+30),header=h))
   time.sleep(.08)
 finally:cmd(126,0);ftdi.set_latency_timer(old)
for source,pixels in images.items():write_png(out/f'source{source}_time_strip.png',1920,32,pixels)
(out/'rows.json').write_text(json.dumps(rows,indent=2));print('row samples',len(rows));print([(r['source'],r['mean_rgb'],r['magenta']) for r in rows[::8]])
