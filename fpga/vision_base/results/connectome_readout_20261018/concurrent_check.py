"""This run's bounded real-video check; the production probe is reused unchanged."""
from pathlib import Path
import json,struct,subprocess,sys
root=Path('F:/Project/fpga/vision_base');out=Path(__file__).resolve().parent
url='ftdi://0x0403:0x6011:4:a/2'
def control(*args):
 r=subprocess.run([sys.executable,str(root/'scripts/vision_control.py'),'--url',url,'--roi-status',*map(str,args)],check=True,capture_output=True,text=True)
 return json.loads(r.stdout)
before=control();network=control('--menu',10)['menu_value']
try:
 if network!=1:control('--key-event',2)
 control('--menu',0,'--memory',0,'--roi',0,0,1920,1080,'--output-size',1920,1080,'--position',0,0,'--roi-enable',1,'--ai-policy',1)
 subprocess.run([sys.executable,str(root/'results/roi_render_perf_20261018/sample_runtime.py'),'--url',url,'--output',str(out/'concurrent_video.json'),'--seconds','20'],check=True)
 control('--ai-policy',0)
 subprocess.run([sys.executable,str(root/'scripts/read_fomo_camera.py'),'--url',url,'--elf',str(out/'firmware/vision.elf'),'--output-dir',str(out/'concurrent_task'),'--summary','--connectome-readout'],check=True)
 s=struct.unpack('<24I',(out/'concurrent_task/status.bin').read_bytes());h=struct.unpack('<14I',(out/'concurrent_task/readout_record.bin').read_bytes())
 assert s[1]==3 and not s[17] and not h[13] and h[1:6]==s[2:7]
finally:
 control('--ai-policy',0)
 current=control('--menu',10)
 if current['menu_value']!=network:control('--key-event',2)
 restored=control('--mode',5,'--median',1,'--memory',0,'--menu',0,'--roi',0,0,1920,1080,'--output-size',1920,1080,'--position',0,0,'--roi-enable',0)
 (out/'final_status.json').write_text(json.dumps(restored,indent=2))
