"""Read a frozen sparse 80x45 Bayer-tile snapshot over USER2 JTAG."""
import argparse
import json
import time
from pathlib import Path
from efx_pgm.ftdi_program import acquire_jtag_engine
from efx_pgm.device_utils import DeviceUtils
from pyftdi.bits import BitSequence

p = argparse.ArgumentParser()
p.add_argument('--url', default='ftdi://0x0403:0x6011:4:3/2')
p.add_argument('--output', required=True)
p.add_argument('--color-order', type=int, choices=range(6))
p.add_argument('--region', type=int, nargs=4, default=None, metavar=('X','Y','W','H'))
p.add_argument('--step', type=int, default=1)
a = p.parse_args()
if a.step < 1:
    raise ValueError('step must be positive')
with acquire_jtag_engine(1e6, a.url) as e:
    e.reset()
    def command(op, value=0):
        e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2'])
        e.write_dr(BitSequence((0x56495331 << 32) | (op << 24) | value, length=192))
        e.go_idle()
    def read():
        e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2'])
        v = int(e.read_dr(192))
        e.go_idle()
        if v >> 160 != 0x56495331 or ((v >> 128) & 0xffffffff) not in [0x26091638,0x26091639,0x2609163a,0x2609163b,0x2609163c,0x2609163d,0x2609163e,0x26091730,0x26091731,0x26091732,0x26091733]:
            raise RuntimeError('RAW probe build/page mismatch: %048x' % v)
        return v
    command(126, 3)
    if a.color_order is not None:
        command(6, a.color_order)
    command(0x20)
    time.sleep(.15)
    read()
    initial = read()
    seq = initial & 0xffffffff
    if not seq or (initial >> 95) & 1:
        raise RuntimeError('RAW snapshot not complete')
    small=((initial>>128)&0xffffffff) in [0x26091732,0x26091733]
    cols,rows,spacing=(40,23,48) if small else (80,45,24)
    x0,y0,width,height=a.region or [0,0,cols,rows]
    if min(x0,y0)<0 or min(width,height)<1 or x0+width>cols or y0+height>rows:raise ValueError('Region outside probe grid')
    values = []
    started = time.time()
    xs=list(range(x0,x0+width,a.step));ys=list(range(y0,y0+height,a.step))
    addresses=[y*cols+x for y in ys for x in xs]
    for i,address in enumerate(addresses):
        command(0x21, address)
        read()  # Synchronous RAM read-port priming after address update.
        v = read()
        if (v & 0xffffffff) != seq or ((v >> 64) & 4095) != address or (v >> 95) & 1:
            raise RuntimeError('Snapshot changed or address mismatch at %d' % i)
        values.append((v >> 32) & 0xffffffff)
        if i % 600 == 599:
            print('RAW tiles %d/%d' % (i + 1,len(addresses)), flush=True)
    record = dict(sequence=seq, width=len(xs), height=len(ys), origin_tile=[x0,y0],source_width=1920, source_height=1080,
                  tile_spacing=spacing*a.step, packing='bits31:24=p01 23:16=p00 15:8=p11 7:0=p10',
                  color_order=(initial >> 76) & 7, seconds=time.time()-started, words=values)
    Path(a.output).write_text(json.dumps(record), encoding='utf-8')
    print('Saved %s, %.2fs, sequence %d' % (a.output, record['seconds'], seq))
