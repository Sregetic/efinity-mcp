from pathlib import Path
import sys,subprocess,json,re
R=Path(__file__).resolve().parents[2];O=Path(sys.argv[1]);O.mkdir(parents=True,exist_ok=True);sys.path.insert(0,str(R/'scripts'))
from load_vision_ddr import configuration,board_location,validate_image,IDE
_,_,sym=validate_image(R/'results/geometry_m7_20261028/release/vision.elf',None)
body='''if {[catch {
halt
wait_halt 5000
echo "BOOT_STATUS [read_memory 0x07621000 32 5]"
echo "CPU_STATE [read_memory 0xf8100004 32 1]"
echo "M7_ABI [read_memory 0xf8100500 32 1]"
echo "CONTROL_MAGIC [read_memory 0x07620200 32 1]"
echo "SIDEBAR [read_memory 0x07620278 32 3]"
} failure]} {resume;echo "MENU_READ_ERROR $failure";shutdown error}
resume
echo MENU_CPU_RESUMED
shutdown
'''
p=O/'read.cfg';p.write_text(configuration(board_location('ftdi://0x0403:0x6011:4:b/2'),R/'artifacts/vision_soc/cpu0.yaml',sym,5)+body,encoding='utf-8')
x=subprocess.run([str(IDE/'openocd/bin/openocd.exe'),'-f',str(p)],capture_output=True,text=True,timeout=120);log=x.stdout+x.stderr;(O/'read.log').write_text(log,encoding='utf-8');x.check_returncode();assert 'MENU_CPU_RESUMED' in log
v={k:[int(n,0)for n in a.split()]for k,a in re.findall(r'^(BOOT_STATUS|CPU_STATE|M7_ABI|CONTROL_MAGIC|SIDEBAR) ([0-9xabcdefABCDEF ]+)$',log,re.M)};v['cpu_resumed']=True;(O/'read.json').write_text(json.dumps(v,indent=2),encoding='utf-8');print(json.dumps(v,indent=2))
