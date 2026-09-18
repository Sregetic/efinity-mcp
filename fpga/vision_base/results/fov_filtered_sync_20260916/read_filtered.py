import json,time
from pathlib import Path
from efx_pgm.ftdi_program import acquire_jtag_engine
from efx_pgm.device_utils import DeviceUtils
records=[]
with acquire_jtag_engine(1e6,'ftdi://0x0403:0x6011:4:3/2') as e:
 e.reset()
 for i in range(10):
  e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);v=int(e.read_dr(192));e.go_idle()
  assert v>>184==0xA8,'Unexpected telemetry variant'
  r=(v>>124)&((1<<60)-1);f=(v>>64)&((1<<60)-1)
  records.append(dict(raw=f'{v:048x}',rx_beats_max=(r>>48)&4095,rx_lines=(r>>36)&4095,rx_ppc=(r>>8)&15,filter_words=f>>36,filter_lines=(f>>24)&4095,filter_max_words_per_line=(f>>12)&4095,late_at_frame_end=(f>>4)&255,valid=f&15))
  time.sleep(.5)
print(json.dumps(records,indent=2))
Path('results/fov_filtered_sync_20260916/snapshot.json').write_text(json.dumps(records,indent=2),encoding='utf-8')
