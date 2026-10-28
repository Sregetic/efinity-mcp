"""Small halted USER1 snapshot; resume on both successful and failed reads."""
from pathlib import Path
import sys,subprocess,re,json,argparse
R=Path(__file__).resolve().parents[2];sys.path.insert(0,str(R/'scripts'))
from load_vision_ddr import configuration,validate_image,board_location,IDE
p=argparse.ArgumentParser();p.add_argument('--url',required=True);p.add_argument('--name',required=True);p.add_argument('--elf',type=Path,default=R/'results/geometry_m7_20261028/release/vision.elf');a=p.parse_args()
E=a.elf;_,_,s=validate_image(E,None)
O=R/'results/geometry_m7_20261028/board_runtime';O.mkdir(exist_ok=True)
base=configuration(board_location(a.url),R/'artifacts/vision_soc/cpu0.yaml',s,5)
commands=['halt','wait_halt 5000',f'echo "M7_RECORD [read_memory {s["geometry_m7_record"]:#x} 32 24]"',f'echo "AI_RUNTIME [read_memory {s["ai_runtime"]:#x} 32 8]"']
for off in [0,4,8,0x18,0x1c,0x20,0x28,0x2c,0x34]:
 commands.append(f'echo "GEO_{off:02x} [read_memory {0xf8100500+off:#x} 32 1]"')
commands.append('echo "DMA_STATE [read_memory 0xf8100104 32 1]"')
body='if {[catch {\n'+'\n'.join(commands)+'\n} failure]} {resume;echo "M7_READ_ERROR: $failure";shutdown error}\nresume\necho M7_CPU_RESUMED\nshutdown\n'
cfg=O/(a.name+'.cfg');cfg.write_text(base+body,encoding='utf-8')
x=subprocess.run([str(IDE/'openocd/bin/openocd.exe'),'-f',str(cfg)],capture_output=True,text=True,timeout=120)
log=x.stdout+x.stderr;(O/(a.name+'.log')).write_text(log,encoding='utf-8');x.check_returncode();assert 'M7_CPU_RESUMED' in log
result={}
for name,values in re.findall(r'^(M7_RECORD|AI_RUNTIME|GEO_[0-9a-f]+|DMA_STATE) ([0-9xabcdefABCDEF ]+)$',log,re.M):result[name]=[int(v,0)for v in values.split()]
assert len(result['M7_RECORD'])==24 and result['GEO_00']==[0x26102871],result
result['cpu_resumed']=True;result['record_complete']=result['M7_RECORD'][0]==0x4d374732 and result['M7_RECORD'][1]!=0
(O/(a.name+'.json')).write_text(json.dumps(result,indent=2),encoding='utf-8');print(json.dumps(result,indent=2))
