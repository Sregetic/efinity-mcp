"""Read two actual display rows on F2 I3; assert source and RGB bytes hold."""
import json,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'scripts'))
from capture_mode_images import decode_caps,decode_snapshot,check_row
from efx_pgm.ftdi_program import acquire_jtag_engine
from efx_pgm.device_utils import DeviceUtils
from pyftdi.bits import BitSequence
OUT=Path(__file__).resolve().parent/'static_pixels'
OUT.mkdir(exist_ok=True)
with acquire_jtag_engine(6e6,sys.argv[1]) as e:
 e.reset()
 def command(op,value=0):
  e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2'])
  e.write_dr(BitSequence((0x56495331<<32)|(op<<24)|value,length=192));e.go_idle()
 def read(length=192):
  e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);e.change_state('shift_dr')
  v=e.read(length,first=True,last=True);e.change_state('update_dr');e.go_idle();return v
 def page(n):command(126,n);return int(read())
 try:
  width,height,bits=decode_caps(page(28));assert bits==24
  rows=[]
  for n in range(2):
   previous=decode_snapshot(page(26))['sequence'];command(0x40,540)
   deadline=time.monotonic()+2
   while True:
    h=decode_snapshot(int(read()))
    if h['sequence']==((previous+1)&0xffffffff):break
    if time.monotonic()>deadline:raise TimeoutError(h)
    time.sleep(.01)
   check_row(h,dict(row=540,mode=0,source=0))
   command(126,27);packed=read(192+width*24).tobytes(msby=True)
   check_row(decode_snapshot(int.from_bytes(packed[:24],'little')),h)
   pixels=packed[24:];(OUT/f'row{n}.bin').write_bytes(pixels)
   rows.append(dict(header=h,t=time.monotonic()))
   if n==0:first=pixels;time.sleep(10)
   else:
    assert h['frame_id']==rows[0]['header']['frame_id'],rows
    assert h['config_id']==rows[0]['header']['config_id'],rows
    assert pixels==first,'Static history RGB changed'
  result=dict(passed=True,scope='Actual FPGA display line RAM, not physical HDMI',
   rows=rows,elapsed_seconds=rows[1]['t']-rows[0]['t'],rgb_bytes=len(first),
   differing_bytes=sum(a!=b for a,b in zip(first,pixels)))
  (OUT/'result.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
 finally:command(126,0)
