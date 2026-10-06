"""Dump a stable480x270 Canny front plane over JTAG, no USB capture card needed."""
import argparse
import json
import time
from pathlib import Path
from efx_pgm.ftdi_program import acquire_jtag_engine
from efx_pgm.device_utils import DeviceUtils
from pyftdi.bits import BitSequence

p=argparse.ArgumentParser();p.add_argument('--url',required=True);p.add_argument('--output',type=Path,required=True)
p.add_argument('--frequency',type=int,default=6000000)
p.add_argument('--keep-held',action='store_true',help='Transfer the successful front-plane hold to the calling frame task')
a=p.parse_args()
with acquire_jtag_engine(a.frequency,a.url) as e:
    e.reset();e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2'])
    def command(op,value=0):
        e.write_dr(BitSequence((0x56495331<<32)|(op<<24)|value,length=192));e.go_idle()
    def read(tag=0x26100410):
        v=int(e.read_dr(192));e.go_idle()
        if v>>160!=0x56495331 or (v>>128)&0xffffffff!=tag:
            raise RuntimeError(f'Edge probe build/page mismatch: {v:048x}')
        return v
    command(126,16);time.sleep(.03);read()
    read();status=(read()>>96)&0xffffffff
    if not (status>>29)&1:raise RuntimeError('Canny output not ready')
    command(0x26,1);words=[];started=time.monotonic();complete=False
    ftdi=e._engine_provider._ctrl._ftdi
    old_latency=ftdi.get_latency_timer();ftdi.set_latency_timer(1)
    try:
        time.sleep(.03);read();epoch=read()&0xffffffff
        command(126,17);time.sleep(.03);read(0x26100411);snapshot=read(0x26100411)
        status=(snapshot>>96)&0xffffffff;stats=(snapshot>>32)&0xffffffff
        context=dict(mode=(status>>21)&7,median=(status>>20)&1,memory=(status>>18)&3,
            requested_threshold=(status>>4)&2047,noise_mean_bound=(stats>>24)&255,
            noise_valid=(stats>>23)&1,effective_threshold=stats&2047,display_id_at_hold=snapshot&0xffffffff)
        command(126,18);time.sleep(.03);read(0x26100412);roi=read(0x26100412)
        command(126,22);time.sleep(.03);read(0x26100416);source=read(0x26100416)
        context.update(roi_frame_id=(roi>>64)&0xffffffff,applied_config_id=(roi>>32)&0xffffffff,
            held_source_frame_id=(source>>64)&0xffffffff,held_raw_id_sample=(source>>32)&0xffffffff)
        command(126,16);time.sleep(.03);read()
        for address in range(4050):
            command(0x27,address)
            deadline=time.monotonic()+1
            while True:
                v=read();meta=(v>>64)&0xffffffff
                if v&0xffffffff!=epoch:raise RuntimeError('Front plane changed during hold')
                if (meta>>30)&1 and not(meta>>31)&1 and (meta>>29)&1==(meta>>28)&1 and meta&4095==address:break
                if time.monotonic()>deadline:raise TimeoutError(f'Edge word {address}')
            words.append((v>>32)&0xffffffff)
            if address%500==499:print(f'EDGE words{address+1}/4050',flush=True)
        complete=True
    finally:
        # Freeze is owned by this dump and must be released even on transfer failure.
        if not(a.keep_held and complete):command(0x26,0)
        command(126,0);ftdi.set_latency_timer(old_latency)
    pixels=bytes(255*((word>>bit)&1) for word in words for bit in range(32))
    a.output.parent.mkdir(parents=True,exist_ok=True)
    a.output.with_suffix('.pgm').write_bytes(b'P5\n480 270\n255\n'+pixels)
    a.output.with_suffix('.json').write_text(json.dumps(dict(width=480,height=270,canny_epoch=epoch,
        seconds=time.monotonic()-started,packing='bit0=lowest row-major coordinate',context=context,
        usb_latency_ms=dict(before=old_latency,during=1),words=words)),encoding='utf-8')
    print(f'Saved {a.output}, epoch{epoch}, edge_pixels{sum(v!=0 for v in pixels)}')
