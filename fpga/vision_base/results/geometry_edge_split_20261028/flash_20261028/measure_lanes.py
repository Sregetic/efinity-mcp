"""Two halted snapshots around a free-running interval; no program/reset/Flash writes."""
from pathlib import Path
import sys,subprocess,json,re,argparse
R=Path(__file__).resolve().parents[3];O=Path(__file__).parent;sys.path.insert(0,str(R/'scripts'))
from load_vision_ddr import validate_image,configuration,board_location,IDE
p=argparse.ArgumentParser();p.add_argument('--url',required=True);p.add_argument('--name',required=True);a=p.parse_args()
E=O/'firmware/vision.elf';_,_,s=validate_image(E,None)
commands=['halt','wait_halt 5000','echo "CPU [read_memory 0xf8100004 32 1]"','echo "ABI [read_memory 0xf8100500 32 1]"',f'echo "BEFORE [read_memory {s["geometry_m7_lane_record"]:#x} 32 16]"','adapter speed 1000','set start_tick [read_memory 0xf8100030 32 1]','resume','sleep 8000','halt','wait_halt 5000','set end_tick [read_memory 0xf8100030 32 1]','echo "RUN_TICKS $start_tick $end_tick"','adapter speed 5',f'echo "AFTER [read_memory {s["geometry_m7_lane_record"]:#x} 32 16]"',f'echo "RECORD [read_memory {s["geometry_m7_record"]:#x} 32 24]"','echo "NATIVE [read_memory 0xf8100504 32 1]"','echo "OWNER [read_memory 0xf8100528 32 1]"']
body='if {[catch {\n'+'\n'.join(commands)+'\n} failure]} {resume;echo "LANE_READ_ERROR $failure";shutdown error}\nresume\necho LANE_CPU_RESUMED\nshutdown\n'
cfg=O/(a.name+'.cfg');cfg.write_text(configuration(board_location(a.url),R/'artifacts/vision_soc/cpu0.yaml',s,5)+body,encoding='utf-8')
x=subprocess.run([str(IDE/'openocd/bin/openocd.exe'),'-f',str(cfg)],capture_output=True,text=True,timeout=180);log=x.stdout+x.stderr;(O/(a.name+'.log')).write_text(log,encoding='utf-8');x.check_returncode();assert 'LANE_CPU_RESUMED' in log
v={k:[int(n,0)for n in nums.split()]for k,nums in re.findall(r'^(CPU|ABI|BEFORE|AFTER|RUN_TICKS|RECORD|NATIVE|OWNER) ([0-9xabcdefABCDEF ]+)$',log,re.M)}
assert v['CPU']==[1] and v['ABI']==[0x26102871] and v['RECORD'][0]==0x4d374733,v
seconds=((v['RUN_TICKS'][1]-v['RUN_TICKS'][0])&0xffffffff)/1e8
assert 8<=seconds<10,seconds
v['free_run_seconds']=seconds;v['lanes']={}
for name,index in [('geometry',0),('face',8)]:
 before=v['BEFORE'][index:index+8];after=v['AFTER'][index:index+8]
 count=(after[0]-before[0])&0xffffffff
 assert before[0] and after[0] and 0<count<1000,(name,before,after)
 v['lanes'][name]=dict(completions=count,updates_per_second=count/seconds,latest_source_to_result_ms=after[4]/100000,source_frame=after[1],count=after[5]&7,more=bool(after[5]&8),complex=after[6])
assert v['OWNER']==[0],v
v.update(passed=True,cpu_resumed=True,scope='Current camera scene; independent completion counts, not accuracy or moving-object acceptance')
(O/(a.name+'.json')).write_text(json.dumps(v,indent=2),encoding='utf-8');print(json.dumps(v,indent=2))
