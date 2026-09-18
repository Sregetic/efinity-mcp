import json,time
from pathlib import Path
from efx_pgm.ftdi_program import acquire_jtag_engine
from efx_pgm.device_utils import DeviceUtils
records=[]
with acquire_jtag_engine(1e6,'ftdi://0x0403:0x6011:4:3/2') as e:
 e.reset()
 for i in range(8):
  e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);v=int(e.read_dr(192));e.go_idle()
  t=(v>>64)&((1<<120)-1);m=(v>>32)&0xffffffff
  sums=[(t>>q)&0xffffffff for q in (88,56,24)]
  records.append(dict(marker=v>>184,mean_rgb=[round(x/65536,3) for x in sums],min_rgb=[(m>>q)&255 for q in (24,16,8)],max_rgb=[(t>>q)&255 for q in (16,8,0)],gamma=m&1,raw=f'{v:048x}'))
  time.sleep(.5)
print(json.dumps(records,indent=2))
Path('results/camera_white_roi_20260915/snapshot.json').write_text(json.dumps(records,indent=2),encoding='utf-8')

