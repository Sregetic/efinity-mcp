"""Actual CLI boundary checks without opening JTAG."""
import contextlib,io,json,runpy,sys,types
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'scripts'))
class Engine:
 def __init__(self,tag):self.page=0;self.tag=tag;self.writes=[]
 def __enter__(self):return self
 def __exit__(self,*args):pass
 def reset(self):pass
 def write_ir(self,v):pass
 def go_idle(self):pass
 def write_dr(self,v):
  op=(v>>24)&255;data=v&0xffffff;self.writes.append((op,data))
  if op==126:self.page=data
 def read_dr(self,n):
  tag=self.tag if self.page in (34,35,36) else 0x26091707
  flags=15|(2<<4)|(2<<6)|(4<<12)
  return (0x56495331<<160)|(tag<<128)|(flags<<64)|(123<<32)
def module(name,**attrs):
 m=types.ModuleType(name);m.__dict__.update(attrs);sys.modules[name]=m
module('efx_pgm');module('efx_pgm.ftdi_program',acquire_jtag_engine=lambda *a:engine)
module('efx_pgm.device_utils',DeviceUtils=types.SimpleNamespace(EFX_TI_INSTR={'USER2':4}))
module('pyftdi');module('pyftdi.bits',BitSequence=lambda v,**k:v)
import time
time.sleep=lambda _:None
for tag,args,code in [(0x26110134,['--sensor','hq12','--page','34'],0),(0x26110134,['--exposure','500'],2),(0x26110134,['--gain-r','256'],2),(0x26091707,['--exposure','500'],0),(0x26091707,['--sensor','hq12'],2),(0x26110135,['--page','35'],0),(0x26110136,['--page','36'],0)]:
 engine=Engine(tag);sys.argv=['vision_control.py',*args,'--samples','1'];out=io.StringIO();actual=0
 with contextlib.redirect_stdout(out),contextlib.redirect_stderr(io.StringIO()):
  try:runpy.run_path(str(ROOT/'scripts/vision_control.py'),run_name='__main__')
  except SystemExit as e:actual=e.code
 assert actual==code,(args,actual,code)
 if code:assert not any(op in (8,9,10,11,12)for op,_ in engine.writes),engine.writes
 elif tag==0x26110135:
  r=json.loads(out.getvalue())[0];assert r['scan_service_gap_cycles']==0x40af and r['ddr_read_burst_cycles']==123 and r['slow_read_address']=='0x00000000',r
 elif tag==0x26110136:
  r=json.loads(out.getvalue())[0];assert r['ddr_read_backpressure_cycles']==0x40af and r['scan_bad_frames']==123 and r['capture_discarded']==0,r
 elif '--page'in args:
  r=json.loads(out.getvalue())[0];assert r['source']=='hq12_hdmi' and r['source_frame']==123 and r['input_format']==2 and r['colorimetry']==2 and r['input_fifo_overflows']==0,r
 else:assert (12,500) in engine.writes
import re
cases=re.findall(r"6'd(\d+):",(ROOT/'board/ti60_hdmi/rtl/vision_hdmi_top.v').read_text().split('case(feature_diag_page)')[1])
assert len(cases)==len(set(cases))
print('PASS HQ12 diagnostic decode, unsupported camera writes blocked, original camera exposure retained, unique RTL page addresses')
