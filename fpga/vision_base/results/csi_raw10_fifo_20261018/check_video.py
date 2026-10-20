"""Read-only live CSI/video sampling; restore diagnostic view on exit."""
import argparse,json,sys,time
from pathlib import Path
ROOT=Path('F:/Project/fpga/vision_base');sys.path.insert(0,str(ROOT/'scripts'))
from sensor_register_control import command,raw
from efx_pgm.ftdi_program import acquire_jtag_engine

p=argparse.ArgumentParser();p.add_argument('--url',required=True);p.add_argument('--seconds',type=int,default=60);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
rows=[]
with acquire_jtag_engine(1e6,a.url) as e:
    e.reset();ftdi=e._engine_provider._ctrl._ftdi;latency=ftdi.get_latency_timer();ftdi.set_latency_timer(1)
    def page(n):
        command(e,126,n);raw(e);return raw(e)
    def geometry():
        v=page(13);assert (v>>128)&0xffffffff==0x2609190d,hex(v)
        g=(v>>4)&((1<<60)-1)
        out=dict(width_words=g>>48,lines=(g>>36)&4095,words=(g>>12)&0xffffff,ppc=(g>>8)&15,datatype=(g>>2)&63)
        assert out==dict(width_words=480,lines=1080,words=518400,ppc=4,datatype=43),out
        return out
    try:
        start_geometry=geometry();command(e,21,1)
        start=time.monotonic()
        while time.monotonic()-start<a.seconds:
            v=page(0);s=(v>>96)&0xffffffff
            r=dict(t=time.monotonic()-start,capture=(v>>64)&0xffffffff,display=(v>>32)&0xffffffff,canny=v&0xffffffff,canny_fault=(s>>31)&1)
            v=page(15);assert (v>>128)&0xffffffff==0x2609192f,hex(v)
            r.update(csi_seen=(v>>16)&65535,csi_live=v&65535)
            v=page(20);assert (v>>128)&0xffffffff==0x26100414
            r.update(discard=(v>>64)&0xffffffff,scan_bad=(v>>32)&0xffffffff,render_cycles=v&0xffffffff)
            assert not r['canny_fault'] and not(r['csi_seen']&0x7ffd) and not(r['csi_live']&0x7ffd),r
            rows.append(r);time.sleep(.002)
        end_geometry=geometry()
    finally:
        command(e,21,0);command(e,126,0);ftdi.set_latency_timer(latency)
dt=rows[-1]['t']-rows[0]['t'];assert dt>0
assert all(r['discard']==rows[0]['discard'] and r['scan_bad']==rows[0]['scan_bad'] for r in rows)
rates={k:(rows[-1][k]-rows[0][k])/dt for k in ['capture','display','canny']}
assert 28<rates['capture']<32 and 28<rates['canny']<32,rates
result=dict(passed=True,seconds=dt,samples=len(rows),rates=rates,csi_error_mask='0x7ffd (FIFO-empty is normal)',geometry=start_geometry,end_geometry=end_geometry,scan_bad_delta=0,discard_delta=0,rows=rows)
a.output.write_text(json.dumps(result,indent=2));print(json.dumps({k:v for k,v in result.items() if k!='rows'},indent=2))
