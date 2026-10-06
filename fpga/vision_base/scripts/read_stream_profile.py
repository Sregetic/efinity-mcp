"""Read camera-domain X3 timings and same-source display timings; no video changes."""
import argparse, json, time
from pathlib import Path
from efx_pgm.ftdi_program import acquire_jtag_engine
from efx_pgm.device_utils import DeviceUtils
from pyftdi.bits import BitSequence
p=argparse.ArgumentParser();p.add_argument('--url',required=True);p.add_argument('--output',required=True,type=Path);p.add_argument('--seconds',type=float,default=60);a=p.parse_args()
rows=[]
with acquire_jtag_engine(3e6,a.url) as e:
    e.reset()
    def command(op,value):
        e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);e.write_dr(BitSequence((0x56495331<<32)|(op<<24)|value,length=192));e.go_idle()
    def page(n,tag):
        command(126,n);time.sleep(.02)
        for _ in range(2):
            e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);v=int(e.read_dr(192));e.go_idle()
        if v>>160!=0x56495331 or (v>>128)&0xffffffff!=tag:raise RuntimeError(f'Stream page{n} mismatch: {v:048x}')
        return v
    try:
        command(0x2a,1);time.sleep(.04);start=time.monotonic()
        while time.monotonic()-start<a.seconds:
            s=page(24,0x26100718);q=page(25,0x26100719);d=page(23,0x26100717);c=page(15,0x2610070f)
            error=page(20,0x26100414);raw=page(1,0x26091715)
            rows.append(dict(t=time.monotonic(),frame_id=(s>>64)&0xffffffff,pixels=(s>>32)&0xffffffff,edges=s&0xffffffff,
                pipeline_cycles=(q>>64)&0xffffffff,semantic_min_cycles=(q>>32)&0xffffffff,semantic_max_cycles=q&0xffffffff,
                display_min_cycles=(d>>96)&0xffffffff,display_max_cycles=(d>>64)&0xffffffff,display_samples=(d>>32)&0xffffffff,display_unmatched=d&0xffffffff,
                gray_sum=(c>>32)&0xffffffff,clock_hz=c&0xffffffff,raw_overflows=(raw>>64)&0xffffffff,capture_discarded=(error>>64)&0xffffffff,scan_bad_frames=(error>>32)&0xffffffff))
            time.sleep(.2)
    finally:
        command(0x2a,0);command(126,0)
first,last=rows[0],rows[-1]
a.output.write_text(json.dumps(dict(passed=False,samples=rows),indent=2),encoding='utf-8')
assert last['frame_id']>first['frame_id'],'Direct camera publication stopped'
assert all(r['pixels']==1920*1080 and r['clock_hz']==148500000 for r in rows),rows[-1]
assert all(0<r['pipeline_cycles']<100 and 0<r['semantic_min_cycles']<=r['semantic_max_cycles'] for r in rows),rows[-1]
assert not any(r['raw_overflows'] or r['capture_discarded'] or r['scan_bad_frames'] or r['display_unmatched'] for r in rows),rows[-1]
assert last['display_samples']>first['display_samples'],'No same-source display timestamps'
duration=last['t']-first['t'];hz=last['clock_hz']
summary=dict(passed=True,seconds=duration,source_fps=(last['frame_id']-first['frame_id'])/duration,
    pipeline_us=last['pipeline_cycles']*1e6/hz,semantic_min_us=last['semantic_min_cycles']*1e6/hz,semantic_max_us=last['semantic_max_cycles']*1e6/hz,
    display_min_ms=last['display_min_cycles']*1e3/hz,display_max_ms=last['display_max_cycles']*1e3/hz,
    scope='2PPC ISP grayscale input to direct edge output; display timestamps retain the existing DDR scan path',first=first,last=last)
a.output.write_text(json.dumps(dict(summary=summary,samples=rows),indent=2),encoding='utf-8');print(json.dumps(summary,indent=2))
