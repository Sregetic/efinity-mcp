from pathlib import Path
import json,time
from efx_pgm.ftdi_program import acquire_jtag_engine
from efx_pgm.device_utils import DeviceUtils
from pyftdi.bits import BitSequence
samples=[]
with acquire_jtag_engine(1e6,'ftdi://0x0403:0x6011:4:b/2') as e:
 e.reset()
 def page(n):
  e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);e.write_dr(BitSequence((0x56495331<<32)|(126<<24)|n,length=192));e.go_idle();v=int(e.read_dr(192));e.go_idle();return v
 try:
  for i in range(3):
   v=page(16);w=page(17);samples.append(dict(epoch=v&0xffffffff,external_hold=(v>>94)&1,mode=(v>>117)&7,canny_status_hex=f'{w:048x}'))
   if i<2:time.sleep(4)
 finally:page(0)
p=Path('results/geometry_m7_20261028/board_release/live_canny_progress.json');p.write_text(json.dumps(samples,indent=2),encoding='utf-8');print(json.dumps(samples,indent=2));assert all(s['external_hold']==0 for s in samples);assert samples[-1]['epoch']>samples[0]['epoch'],'live Canny made no publication'
