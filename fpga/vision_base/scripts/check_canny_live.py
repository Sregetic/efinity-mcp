"""Sample live Canny display rows without freezing the source or edge plane."""
import argparse,json,time
from pathlib import Path
from capture_mode_images import decode_caps,decode_snapshot,check_row,rgb_bytes

def main():
    from efx_pgm.ftdi_program import acquire_jtag_engine
    from efx_pgm.device_utils import DeviceUtils
    from pyftdi.bits import BitSequence
    p=argparse.ArgumentParser();p.add_argument('--url',required=True);p.add_argument('--output',type=Path,required=True)
    p.add_argument('--row',type=int,required=True);p.add_argument('--bands',type=int,nargs='+',required=True)
    p.add_argument('--seconds',type=float,default=10);a=p.parse_args()
    if not 0<=a.row<1080 or a.seconds<=0 or len(a.bands)%2:p.error('Use a valid row, positive duration and X0 X1 band pairs')
    bands=list(zip(a.bands[::2],a.bands[1::2]))
    if any(not 0<=x0<x1<=1920 for x0,x1 in bands):p.error('Bands must fit1920 pixels')
    rows=[]
    with acquire_jtag_engine(6e6,a.url) as e:
        e.reset();ftdi=e._engine_provider._ctrl._ftdi;latency=ftdi.get_latency_timer();ftdi.set_latency_timer(1)
        def command(op,value):
            e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2'])
            e.write_dr(BitSequence((0x56495331<<32)|(op<<24)|value,length=192));e.go_idle()
        def read(length=192):
            e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);e.change_state('shift_dr')
            v=e.read(length,first=True,last=True);e.change_state('update_dr');e.go_idle();return v
        def page(n):command(126,n);return int(read())
        try:
            width,height,bits=decode_caps(page(28));assert (width,height,bits)==(1920,1080,24)
            start=time.monotonic()
            while time.monotonic()-start<a.seconds:
                sequence=(decode_snapshot(page(26))['sequence']+1)&0xffffffff
                command(0x40,a.row);deadline=time.monotonic()+1
                while True:
                    h=decode_snapshot(int(read()))
                    if h['sequence']==sequence:break
                    if time.monotonic()>deadline:raise TimeoutError('Live Canny row pending')
                check_row(h,dict(source=0,row=a.row,sequence=sequence,mode=5))
                command(126,27);packed=read(192+width*24).tobytes(msby=True)
                check_row(decode_snapshot(int.from_bytes(packed[:24],'little')),h)
                rgb=rgb_bytes(packed[24:],0);visible=[v>0 for v in rgb[::3]]
                probe=page(16)
                if probe>>160!=0x56495331 or (probe>>128)&0xffffffff!=0x26100410:raise RuntimeError('Canny completion page mismatch')
                if (probe>>94)&1:raise RuntimeError('Canny plane is held; release the owning frame task first')
                rows.append(dict(t=time.monotonic(),display_source_frame=h['frame_id'],threshold=h['threshold'],canny_epoch=probe&0xffffffff,
                    visible_pixels=sum(visible),band_counts=[sum(visible[x0:x1]) for x0,x1 in bands]))
                time.sleep(.2)
        finally:command(126,0);ftdi.set_latency_timer(latency)
    missing=[sum(r['band_counts'][i]==0 for r in rows) for i in range(len(bands))]
    advancing=rows[-1]['display_source_frame']>rows[0]['display_source_frame'] and rows[-1]['canny_epoch']>rows[0]['canny_epoch']
    summary=dict(passed=advancing and not any(missing),samples=len(rows),seconds=rows[-1]['t']-rows[0]['t'],
        row=a.row,bands=bands,missing_samples=missing,minimum_band_pixels=[min(r['band_counts'][i] for r in rows) for i in range(len(bands))],
        first_display_source=rows[0]['display_source_frame'],last_display_source=rows[-1]['display_source_frame'],
        first_canny_epoch=rows[0]['canny_epoch'],last_canny_epoch=rows[-1]['canny_epoch'],
        scope='Sampled live display row, not every frame or the full image; source and Canny plane are not held')
    a.output.parent.mkdir(parents=True,exist_ok=True)
    a.output.write_text(json.dumps(dict(summary=summary,samples=rows),indent=2),encoding='utf-8')
    print(json.dumps(summary,indent=2));assert summary['passed'],'A sampled contour disappeared'

if __name__=='__main__':main()
