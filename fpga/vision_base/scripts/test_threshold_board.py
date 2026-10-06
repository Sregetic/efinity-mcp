"""Actual USER2 threshold isolation and clamping; physical events covered by RTL TB."""
import argparse, json, time
from pathlib import Path
from efx_pgm.ftdi_program import acquire_jtag_engine
from efx_pgm.device_utils import DeviceUtils
from pyftdi.bits import BitSequence
p=argparse.ArgumentParser();p.add_argument('--url',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
with acquire_jtag_engine(3e6,a.url) as e:
    e.reset()
    def command(op,value):
        e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);e.write_dr(BitSequence((0x56495331<<32)|(op<<24)|value,length=192));e.go_idle();time.sleep(.035)
    def page(n):
        command(126,n)
        for _ in range(2):
            e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);v=int(e.read_dr(192));e.go_idle()
        assert v>>160==0x56495331
        return v
    def state():
        v=page(0);q=(v>>96)&0xffffffff;c=page(8)
        return dict(mode=(q>>21)&7,threshold=(q>>4)&2047,sobel=(c>>24)&2047,canny=(c>>13)&2047,effective=(c>>2)&2047)
    before=state();rows=[]
    def check(mode,sobel,canny):
        s=state();rows.append(s);assert (s['mode'],s['sobel'],s['canny'],s['threshold'])==(mode,sobel,canny,canny if mode in [5,6] else sobel),s
    try:
        command(1,2);command(0x28,96);command(0x29,144);check(2,96,144)
        command(2,0);check(2,16,144)
        command(2,2047);check(2,2047,144)
        command(1,5);check(5,2047,144)
        command(2,0);check(5,2047,16)
        command(0x28,80);command(0x29,160);check(5,80,160)
        command(1,2);check(2,80,160)
        command(1,6);check(6,80,160)
    finally:
        command(0x28,before['sobel']);command(0x29,before['canny']);command(1,before['mode']);page(0)
    restored=state();page(0)
result=dict(passed=True,scope='Actual board USER2 commands, not physical button presses',before=before,cases=rows,restored=restored)
a.output.write_text(json.dumps(result,indent=2),encoding='utf-8');print(json.dumps(result,indent=2))
