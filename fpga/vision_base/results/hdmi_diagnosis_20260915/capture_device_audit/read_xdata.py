# Read-only MacroSilicon ROM protocol. Reference: BertoldVdb/ms-tools mshal/hal_rom.go and hal_region.go.
# Only opcode B5 (XDATA read) is implemented. No register/EEPROM/firmware write commands.
import ctypes as c,json,sys
from ctypes import wintypes as w
from pathlib import Path
k=c.WinDLL('kernel32',use_last_error=True);h=c.WinDLL('hid',use_last_error=True)
k.CreateFileW.argtypes=[w.LPCWSTR,w.DWORD,w.DWORD,c.c_void_p,w.DWORD,w.DWORD,w.HANDLE];k.CreateFileW.restype=w.HANDLE;k.CloseHandle.argtypes=[w.HANDLE]
for name in ['HidD_SetFeature','HidD_GetFeature']:
 fn=getattr(h,name);fn.argtypes=[w.HANDLE,c.c_void_p,w.ULONG];fn.restype=w.BOOLEAN
path=r'\\?\HID#VID_2B89&PID_5854&MI_04#9&208f6724&0&0000#{4d1e55b2-f16f-11cf-88cb-001111000030}'
f=k.CreateFileW(path,0,3,None,3,0,None);assert f!=c.c_void_p(-1).value,c.get_last_error()
records=[]
try:
 for addr in ([int(a,0) for a in sys.argv[1:]] or [0xf800]):
  assert 0<=addr<=65535
  request=bytes([0,0xb5,addr>>8,addr&255,0,0,0,0,0]);buf=(c.c_ubyte*9).from_buffer_copy(request)
  assert h.HidD_SetFeature(f,buf,9),('read-request',c.get_last_error())
  reply=(c.c_ubyte*9)();assert h.HidD_GetFeature(f,reply,9),('read-response',c.get_last_error())
  raw=bytes(reply);assert raw[:4]==request[:4],(request.hex(),raw.hex())
  records.append({'addr':hex(addr),'value':raw[4],'request':request.hex(),'response':raw.hex()})
finally:k.CloseHandle(f)
print(json.dumps(records,indent=2))
