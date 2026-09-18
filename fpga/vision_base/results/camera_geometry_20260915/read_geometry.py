import json,time
from pathlib import Path
from efx_pgm.ftdi_program import acquire_jtag_engine
from efx_pgm.device_utils import DeviceUtils
records=[]
with acquire_jtag_engine(1e6,'ftdi://0x0403:0x6011:4:3/2') as e:
 e.reset()
 for i in range(10):
  e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);v=int(e.read_dr(192));e.go_idle()
  r=(v>>124)&((1<<60)-1);o=(v>>64)&((1<<60)-1)
  records.append(dict(raw=f'{v:048x}',marker=v>>184,rx_beats_max=(r>>48)&4095,rx_lines=(r>>36)&4095,rx_total_beats=(r>>12)&0xffffff,rx_ppc=(r>>8)&15,rx_datatype=(r>>2)&63,rx_valid=r&3,out_min_width=(o>>48)&4095,out_max_width=(o>>36)&4095,out_lines=(o>>24)&4095,out_pixels=o&0xffffff))
  time.sleep(.5)
print(json.dumps(records,indent=2))
Path('results/camera_geometry_20260915/snapshot.json').write_text(json.dumps(records,indent=2),encoding='utf-8')
