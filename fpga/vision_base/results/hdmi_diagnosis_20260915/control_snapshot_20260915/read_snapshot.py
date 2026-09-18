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
        e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2'])
        v=int(e.read_dr(192))
        e.go_idle()
        records.append({'raw':f'{v:048x}','active_pixels':(v>>42)&0x3fffff,'video_flags':f'{(v>>34)&255:02x}','pattern_mode':(v>>33)&1,'snapshot_valid':(v>>32)&1,'marker':(v>>24)&255,'frames':ungray((v>>16)&255),'core_ticks':ungray((v>>8)&255),'reset_input':(v>>7)&1,'mipi_pll_lock':(v>>6)&1,'ddr_pll_lock':(v>>5)&1,'video_pll_lock':(v>>4)&1,'global_ready':(v>>3)&1,'video_reset_released':(v>>2)&1,'pattern_reset_released':(v>>1)&1})
        time.sleep(0.5)
for rec in records:
    v=int(rec['raw'],16)
    samples=[]
    for idx in (2,1,0):
        word=(v>>(64+40*idx))&((1<<40)-1)
        codes=[(word>>(10*k))&1023 for k in range(3)]
        rgb=[]
        for code in codes:
            q=(code&255) ^ (255 if code&512 else 0)
            x=q&1
            for b in range(1,8):
                bit=((q>>b)^(q>>(b-1)))&1
                if not code&256:bit^=1
                x|=bit<<b
            rgb.append(x)
        samples.append({'codes_bgr':[f'{c:03x}' for c in codes], 'decoded_bgr':rgb,'clock_word':f'{word>>30:03x}'})
    rec['snapshot_marker']=hex(v>>184)
    rec['samples']=samples
print(json.dumps(records,indent=2))
Path('snapshot.json').write_text(json.dumps(records,indent=2),encoding='utf-8')

