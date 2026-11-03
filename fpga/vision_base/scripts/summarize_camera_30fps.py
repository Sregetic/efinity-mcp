import json,time,hashlib
from pathlib import Path
from sensor_register_control import command,raw,transaction
from efx_pgm.ftdi_program import acquire_jtag_engine
root=Path('results/camera_60fps_20260919')
def read(name):return json.loads((root/name).read_text(encoding='utf-8-sig'))
def rate(a,key,t='time_s'):return ((a[-1][key]-a[0][key])&0xffffffff)/(a[-1][t]-a[0][t])
a=read('final30_capture.json');b=read('final30_raw.json');c=read('final30_fov.json');d=read('final30_errors.json');g=json.loads(Path('results/board.compile.status.json').read_text(encoding='utf-8-sig'))
r=dict(decision='User chose to retain full-resolution30fps;60fps trial stopped',capture_fps=rate(a,'capture_id','sample_time_s'),raw_fps=rate(b,'sensor_frames'),raw_geometry_ok=all(x['words_per_line']==640 and x['lines']==1440 and x['words']==921600 and x['data_type']==43 for x in b),fov_geometry_ok=all(x['words_per_line']==480 and x['lines']==1080 and x['words']==518400 and x['late']==0 for x in c),overruns=[c[0]['overruns'],c[-1]['overruns']],write_errors=[d[0]['write_errors'],d[-1]['write_errors']],canny_fault=any(x['canny_fault'] for x in a),mode=a[-1]['mode'],bit_sha256=hashlib.sha256(Path('artifacts/camera/ti60f225_oob.bit').read_bytes()).hexdigest(),wns_ns=g['wns_ns'],whs_ns=g['whs_ns'],unassigned_pins=g['unassigned_core_pins'],visual_acceptance='pending user',flash_modified=False)
with acquire_jtag_engine(1e6,'ftdi://0x0403:0x6011:4:3/2') as e:
 e.reset();command(e,126,9);time.sleep(.05)
 r['clock_registers']={hex(k):transaction(e,k)['value'] for k in (0x36eb,0x36ec)}
 command(e,21,1);command(e,126,15);time.sleep(.05);r['csi_debug']=[]
 for _ in range(5):
  v=raw(e);r['csi_debug'].append(dict(marker=f'{(v>>128)&0xffffffff:08x}',de=(v>>64)&0xffffffff,hs=(v>>32)&0xffffffff,seen=f'{(v>>16)&65535:04x}',live=f'{v&65535:04x}'));time.sleep(.2)
 command(e,21,0);command(e,126,0)
assert r['raw_geometry_ok'] and r['fov_geometry_ok'] and 29<r['capture_fps']<31 and 29<r['raw_fps']<31
assert r['overruns'][0]==r['overruns'][1] and r['write_errors'][0]==r['write_errors'][1] and not r['canny_fault']
assert r['clock_registers']=={'0x36eb':13,'0x36ec':101}
(root/'final30_summary.json').write_text(json.dumps(r,indent=2),encoding='utf-8');print(json.dumps(r,indent=2))
