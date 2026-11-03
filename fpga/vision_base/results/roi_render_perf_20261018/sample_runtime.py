"""Bounded USER2 runtime probe; configuration is set/restored by vision_control."""
import argparse,json,statistics,time
from pathlib import Path
from efx_pgm.ftdi_program import acquire_jtag_engine
from efx_pgm.device_utils import DeviceUtils
from pyftdi.bits import BitSequence

p=argparse.ArgumentParser();p.add_argument('--url',required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--seconds',type=int,default=30);a=p.parse_args()
rows=[]
with acquire_jtag_engine(1e6,a.url) as e:
    e.reset()
    ftdi=e._engine_provider._ctrl._ftdi
    latency=ftdi.get_latency_timer();ftdi.set_latency_timer(1)
    def page(n):
        e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);e.write_dr(BitSequence((0x56495331<<32)|(126<<24)|n,length=192));e.go_idle()
        for _ in range(2):
            e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);v=int(e.read_dr(192));e.go_idle()
        assert v>>160==0x56495331 and (v>>128)&0xffffffff==0x26100400+n,(n,hex(v))
        return v
    start=time.monotonic()
    while time.monotonic()-start<a.seconds:
        v=page(18);flags=v&0xffffffff
        assert not flags&0xf00000,hex(flags)  # Existing config/render/scan/reject flags.
        s=dict(t=time.monotonic()-start,frame=(v>>64)&0xffffffff,config=(v>>32)&0xffffffff,flags=flags)
        v=page(20);s.update(discard=(v>>64)&0xffffffff,scan_bad=(v>>32)&0xffffffff,cycles=v&0xffffffff)
        v=page(23);s['deadlines']=v&0xffffffff
        rows.append(s);time.sleep(.002)
    e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);e.write_dr(BitSequence((0x56495331<<32)|(126<<24),length=192));e.go_idle()
    ftdi.set_latency_timer(latency)
assert len(rows)>2 and all(s['discard']==rows[0]['discard'] and s['scan_bad']==rows[0]['scan_bad'] for s in rows)
seconds=rows[-1]['t']-rows[0]['t'];changes=sum(x['frame']!=y['frame'] for x,y in zip(rows,rows[1:]))
ms=[s['cycles']/100000 for s in rows]
result=dict(passed=True,samples=len(rows),seconds=seconds,min_ms=min(ms),median_ms=statistics.median(ms),max_ms=max(ms),mean_ms=statistics.mean(ms),observed_publications=changes,observed_publications_hz=changes/seconds,max_poll_gap_ms=max(y['t']-x['t'] for x,y in zip(rows,rows[1:]))*1000,scan_bad_delta=0,discard_delta=0,deadline_delta=rows[-1]['deadlines']-rows[0]['deadlines'],rows=rows)
a.output.write_text(json.dumps(result,indent=2));print(json.dumps({k:v for k,v in result.items() if k!='rows'}),flush=True)
