import json,time,datetime
from pathlib import Path
from efx_pgm.ftdi_program import acquire_jtag_engine
from efx_pgm.device_utils import DeviceUtils
r=[]
with acquire_jtag_engine(1e6,'ftdi://0x0403:0x6011:2:4/2') as e:
 e.reset()
 for i in range(34):
  e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);v=int(e.read_dr(192));e.go_idle()
  r.append({'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'raw':f'{v:048x}','full_range':v&1,'marker':(v>>24)&255})
  time.sleep(0.5)
Path('range_states.json').write_text(json.dumps(r,indent=2));print(json.dumps(r[-4:],indent=2))
