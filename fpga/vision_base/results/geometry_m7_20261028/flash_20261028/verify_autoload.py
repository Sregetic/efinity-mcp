"""Verify SPI-autoloaded static bytes; USER1 only halts/reads/resumes, never downloads."""
from pathlib import Path
import sys,json,subprocess,re,time
R=Path(__file__).resolve().parents[3];O=Path(__file__).resolve().parent/'autoboot';O.mkdir(exist_ok=True)
sys.path.insert(0,str(R/'scripts'))
from load_vision_ddr import validate_image,configuration,board_location,tcl_path,IDE
E=R/'results/geometry_m7_20261028/release/vision.elf';W=E.with_name('shape_cards_weights.bin');URL='ftdi://0x0403:0x6011:4:b/2'
entry,segments,sym=validate_image(E,W);data=E.read_bytes();expected=[]
commands=['halt','wait_halt 5000','set boot [read_memory 0x07621000 32 5]','set state [read_memory 0xf8100004 32 1]','echo "BOOT_STATUS $boot"','echo "CPU_STATE $state"','if {[lindex $boot 1] != 7 || $state != 1} {error "SPI boot not complete"}','adapter speed 1000']
for i,s in enumerate(segments):
 if s['size']:expected.append((f'segment{i}',s['address'],data[s['offset']:s['offset']+s['size']]))
expected.append(('weights',sym['__weights_start'],W.read_bytes()))
for name,address,payload in expected:
 for off in range(0,len(payload),1024):
  part=payload[off:off+1024];p=O/f'{name}_{off:06x}.bin';commands.append(f'dump_image {tcl_path(p)} {address+off:#x} {len(part)}')
body='if {[catch {\n'+'\n'.join(commands)+'\n} failure]} {resume;echo "AUTOBOOT_READ_ERROR $failure";shutdown error}\nresume\necho AUTOBOOT_READ_COMPLETE\nshutdown\n'
p=O/'read.cfg';p.write_text(configuration(board_location(URL),R/'artifacts/vision_soc/cpu0.yaml',sym,25)+body,encoding='utf-8')
start=time.monotonic();x=subprocess.run([str(IDE/'openocd/bin/openocd.exe'),'-f',str(p.resolve())],capture_output=True,text=True,timeout=1500);log=x.stdout+x.stderr;(O/'read.log').write_text(log,encoding='utf-8');x.check_returncode();assert 'AUTOBOOT_READ_COMPLETE' in log
boot=[int(v,0)for v in re.search(r'^BOOT_STATUS (.*)$',log,re.M)[1].split()];state=int(re.search(r'^CPU_STATE (.*)$',log,re.M)[1],0)
assert boot==[0x56424f31,7,0xef6017,447344,4400] and state==1,(boot,state)
for name,address,payload in expected:
 actual=b''.join((O/f'{name}_{off:06x}.bin').read_bytes()for off in range(0,len(payload),1024))
 assert actual==payload,'Actual SPI-autoloaded byte mismatch: '+name
 (O/(name+'.bin')).write_bytes(actual)
 for off in range(0,len(payload),1024):(O/f'{name}_{off:06x}.bin').unlink()
v=dict(passed=True,boot_status=boot,cpu_state=state,program_bytes=boot[3],weights_bytes=boot[4],actual_ddr_bytes_verified=True,user1_program_download=False,cpu_resumed=True,physical_power_cycle_verified=False,configuration_source='matched final SRAM restart after configuration Flash write',static_read_khz=1000,chunk_bytes=1024,seconds=time.monotonic()-start)
(O/'result.json').write_text(json.dumps(v,indent=2),encoding='utf-8');print(json.dumps(v,indent=2))
