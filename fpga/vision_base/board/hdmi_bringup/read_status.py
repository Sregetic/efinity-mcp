# Run with the process environment from scripts/efinity_env.ps1.
import json,time
from pathlib import Path
from efx_pgm.ftdi_program import acquire_jtag_engine
from efx_pgm.device_utils import DeviceUtils

def ungray(n):
    out=0
    while n:
        out ^= n
        n >>= 1
    return out

records=[]
with acquire_jtag_engine(3e6,'ftdi://0x0403:0x6011:4:5/2') as e:
    e.reset()
    for i in range(6):
        e.write_ir(DeviceUtils.EFX_TI_INSTR['USER1'])
        v=int(e.read_dr(32))
        e.go_idle()
        records.append({'raw':f'{v:08x}','marker':(v>>24)&255,'ref25':ungray((v>>16)&255),'ref27':ungray((v>>8)&255),'pll_lock':(v>>7)&1,'frames':ungray(v&127)})
        time.sleep(0.5)
print(json.dumps(records,indent=2))
Path('status_read.json').write_text(json.dumps(records,indent=2),encoding='utf-8')
