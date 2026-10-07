"""Frozen FPGA Canny -> on-board occupancy/encoder, checked against the host.

The host plane is a reference/readback, not the production feature producer.
No trained labels or confidence are fabricated by this encoder check.
"""
import argparse
import json
import random
import subprocess
import sys
import time
from pathlib import Path
from capture_mode_images import write_png,check_frozen_source

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'models'))
from flyhash import edge_features,encode

def decode_status(v):
    tag=(v>>128)&0xffffffff
    if v>>160!=0x56495331 or tag not in (0x2610051d,0x2610071d,0x2610081d):
        raise RuntimeError(f'FlyHash firmware/header mismatch: {v:048x}')
    s=v&0xffffffff
    return dict(valid=(s>>31)&1,busy=(s>>30)&1,feature_ready=(s>>29)&1,fault=(s>>28)&1,
                context_valid=(s>>27)&1,loaded=(s>>20)&127,sequence=(s>>13)&127,
                backend={0x2610051d:'rtl',0x2610071d:'firmware',0x2610081d:'firmware_ddr'}[tag],
                cycles=None if tag!=0x2610051d else s&8191,cycle_low13=s&8191,
                frame_id=(v>>64)&0xffffffff,config_id=(v>>32)&0xffffffff,epoch=(v>>96)&0xffffffff)

def check_result(result,context,features):
    if not result['valid'] or result['busy'] or result['fault'] or result['loaded']!=64:
        raise RuntimeError(f'Incomplete hardware encoder result: {result}')
    for k in ['frame_id','config_id','epoch']:
        if result[k]!=context[k]:raise RuntimeError(f'FlyHash {k} binding mismatch')
    limit=2**32 if result['backend']!='rtl' else 8192
    if result['hash']!=f'{encode(features):064x}' or result['cycles'] is None or not 0<result['cycles']<limit:
        raise RuntimeError(f'FlyHash reference/cycle mismatch: {result}')
    if result['backend']!='rtl' and (result['firmware_state']!=1 or result['clock_hz']!=100000000):
        raise RuntimeError(f'FlyHash firmware boot/clock mismatch: {result}')

def decode_profile(v):
    if v>>160!=0x56495331 or (v>>128)&0xffffffff!=0x26100720:
        raise RuntimeError(f'FlyHash profile mismatch: {v:048x}')
    return dict(firmware_state=(v>>96)&0xffffffff,cycles=(v>>64)&0xffffffff,
                clock_hz=(v>>32)&0xffffffff,soc_enabled=v&1)

def run_ddr_job(url,directory,vector,source,binding,command,page):
    from efx_pgm.ftdi_program import acquire_jtag_engine
    from load_vision_ddr import board_location
    from flyhash_ddr import transfer,RESULT,INPUT
    location=board_location(url);directory=Path(directory)
    if source=='host':transfer(location,directory/'input',vector)
    started=time.monotonic()
    with acquire_jtag_engine(6e6,url) as e:
        e.reset();previous=decode_status(page(e,29))
        if not previous['context_valid'] or previous['busy']:raise RuntimeError(f'DDR task context not ready: {previous}')
        command(e,0x54 if source=='fpga' else 0x50)
        deadline=time.monotonic()+10
        while True:
            state=decode_status(page(e,29))
            if state['fault']:raise RuntimeError(f'DDR task fault: {state}')
            if state['valid'] and state['sequence']==(previous['sequence']+1)%128:break
            if time.monotonic()>deadline:raise TimeoutError('DDR FlyHash pending')
        descriptor=page(e,30,0x2610081e)
        if (descriptor>>96)&0xffffffff!=RESULT or (descriptor>>64)&0xffffffff!=INPUT:raise RuntimeError('FlyHash DDR ABI address mismatch')
        command(e,0x58);profile=decode_profile(page(e,30,0x26100720));command(e,0x57)
    elapsed=time.monotonic()-started
    record=transfer(location,directory/'result')
    for key in ['frame_id','config_id','epoch']:
        if record[key]!=state[key]:raise RuntimeError('FlyHash DDR '+key+' binding mismatch')
    if record['features']!=vector or record['cycles']!=profile['cycles']:raise RuntimeError('FlyHash DDR feature/cycle mismatch')
    with acquire_jtag_engine(6e6,url) as e:
        e.reset()
        if decode_status(page(e,29))!=state:raise RuntimeError('FlyHash task changed during DDR readout')
    state.update(profile);state.update(record);state.update(task_seconds=elapsed,host_seconds=time.monotonic()-started,feature_source=source)
    check_result(state,binding,vector);return state


def main():
    from efx_pgm.ftdi_program import acquire_jtag_engine
    from efx_pgm.device_utils import DeviceUtils
    from pyftdi.bits import BitSequence
    p=argparse.ArgumentParser();p.add_argument('--url',required=True)
    p.add_argument('--output-dir',type=Path,required=True)
    p.add_argument('--sensor',choices=['sc431hai','sc2210'],default='sc431hai')
    p.add_argument('--self-test',action='store_true',help='Also verify32 synthetic feature vectors on the board')
    p.add_argument('--feature-source',choices=['fpga','host'],default='fpga')
    p.add_argument('--compare-host',action='store_true',help='Also feed the reference features through the same encoder')
    a=p.parse_args()
    def control(args):
        r=subprocess.run([sys.executable,str(ROOT/'scripts/vision_control.py'),'--url',a.url,
                          '--sensor',a.sensor,'--roi-status',*args],check=True,capture_output=True,text=True)
        return json.loads(r.stdout)
    def command(e,op,value=0):
        e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2'])
        e.write_dr(BitSequence((0x56495331<<32)|(op<<24)|value,length=192));e.go_idle()
    def page(e,n,expected_tag=None):
        command(e,126,n);e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2'])
        v=int(e.read_dr(192));e.go_idle()
        tag=0x26100500+n if expected_tag is None else expected_tag
        valid_tag=((v>>128)&0xffffffff in (0x2610051d,0x2610071d,0x2610081d)) if n==29 and expected_tag is None else (v>>128)&0xffffffff==tag
        if v>>160!=0x56495331 or not valid_tag:
            raise RuntimeError(f'FlyHash page{n} mismatch: {v:048x}')
        return v
    with acquire_jtag_engine(6e6,a.url) as e:
        e.reset();initial=decode_status(page(e,29))
    before=control([]);a.output_dir.mkdir(parents=True,exist_ok=True)
    restore=['--roi',*map(str,before['roi']),'--output-size',*map(str,before['output_size']),
             '--position',*map(str,before['position']),'--roi-enable',str(before['roi_enabled']),
             '--memory',str(before['memory']),'--mode',str(before['mode'])]
    producer=initial['backend'] if a.feature_source=='fpga' else 'host'
    result=dict(method=f'FPGA frozen Canny / {producer}8x8 occupancy / {initial["backend"]} FlyHash',
                feature_extractor=producer,encoder=initial['backend'],trained_classifier=False,before=before)
    try:
        context=control(['--roi',*map(str,before['roi']),'--output-size',*map(str,before['output_size']),
                         '--position',*map(str,before['position']),'--roi-enable','1','--memory','1'])
        check_frozen_source(context)
        with acquire_jtag_engine(6e6,a.url) as e:
            e.reset();command(e,126,17);e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2'])
            v=int(e.read_dr(192));e.go_idle();baseline=(v>>64)&0xffffffff
            deadline=time.monotonic()+10
            # Two publications after the frozen render exclude an old/in-flight plane.
            while True:
                e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2']);v=int(e.read_dr(192));e.go_idle()
                if (v>>128)&0xffffffff!=0x26100411:raise RuntimeError('Canny status page mismatch')
                if ((v>>64)&0xffffffff)-baseline>=2 and (v>>125)&1:break
                if time.monotonic()>deadline:raise TimeoutError('Frozen Canny publications pending')
                time.sleep(.01)
        subprocess.run([sys.executable,str(ROOT/'scripts/capture_edge_probe.py'),'--url',a.url,
                        '--output',str(a.output_dir/'edge'),'--keep-held'],check=True,capture_output=True,text=True)
        plane=json.loads((a.output_dir/'edge.json').read_text(encoding='utf-8'))
        ctx=plane['context']
        if ctx['roi_frame_id']!=context['roi_frame_id'] or ctx['applied_config_id']!=context['applied_config_id'] or ctx['held_source_frame_id']!=context['held_source_frame_id']:
            raise RuntimeError('Canny plane/source task binding changed')
        pixels=bytes(255*((word>>bit)&1) for word in plane['words'] for bit in range(32))
        features=edge_features(pixels,480,270,(0,0,480,270))
        rgb=bytes(v for pixel in pixels for v in (pixel,pixel,pixel))
        write_png(a.output_dir/'edge.png',480,270,rgb)
        result.update(context=context,canny_epoch=plane['canny_epoch'],edge_pixels=sum(v!=0 for v in pixels),features=features)
        binding=dict(frame_id=context['roi_frame_id'],config_id=context['applied_config_id'],epoch=plane['canny_epoch'])
        if initial['backend']=='firmware_ddr':
            result['hardware']=run_ddr_job(a.url,a.output_dir/'task',features,a.feature_source,binding,command,page)
            result['fpga_features']=result['hardware']['features']
            if a.compare_host:result['host_comparison']=run_ddr_job(a.url,a.output_dir/'host',features,'host',binding,command,page)
            if a.self_test:
                rng=random.Random(2210)
                vectors=[[0]*64,[255]*64,list(range(64)),[255-i*4 for i in range(64)]]
                vectors += [[rng.randrange(256) for _ in range(64)] for _ in range(28)]
                result['synthetic_tests']=[dict(features=v,hardware=run_ddr_job(a.url,a.output_dir/f'vector{i}',v,'host',binding,command,page)) for i,v in enumerate(vectors)]
        else:
            with acquire_jtag_engine(6e6,a.url) as e:
                e.reset();ftdi=e._engine_provider._ctrl._ftdi
                old_latency=ftdi.get_latency_timer();ftdi.set_latency_timer(1)
                try:
                    def run(vector,source):
                        previous=decode_status(page(e,29))
                        if not previous['context_valid'] or previous['busy']:raise RuntimeError(f'Encoder task context not ready: {previous}')
                        started=time.monotonic();command(e,0x54 if source=='fpga' else 0x50)
                        if source=='host':
                            for i,value in enumerate(vector):
                                command(e,0x51,(i<<8)|value)
                                deadline=time.monotonic()+1
                                while True:
                                    s=decode_status(page(e,29))
                                    if s['fault']:raise RuntimeError(f'Encoder input rejected: {s}')
                                    if s['loaded']==i+1:break
                                    if time.monotonic()>deadline:raise TimeoutError(f'Feature{i} pending')
                        deadline=time.monotonic()+10
                        while True:
                            s=decode_status(page(e,29))
                            if s['fault']:raise RuntimeError(f'Encoder task fault: {s}')
                            if s['valid'] and s['sequence']==(previous['sequence']+1)%128:break
                            if time.monotonic()>deadline:raise TimeoutError('Hardware FlyHash pending')
                        task_seconds=time.monotonic()-started
                        if source=='fpga':
                            actual=[]
                            try:
                                for q in range(4):
                                    command(e,0x56,q);v=page(e,30,0x26100520+q)
                                    actual.extend((v>>(8*i))&255 for i in range(16))
                            finally:command(e,0x57)
                            if actual!=vector:raise RuntimeError(f'FPGA occupancy mismatch: {actual} != {vector}')
                            result['fpga_features']=actual
                        low=page(e,30)&((1<<128)-1);high=page(e,31)&((1<<128)-1)
                        if decode_status(page(e,29))!=s:raise RuntimeError('FlyHash result changed during readout')
                        if s['backend']=='firmware':
                            try:
                                command(e,0x58);s.update(decode_profile(page(e,30,0x26100720)))
                            finally:command(e,0x57)
                        s.update(hash=f'{(high<<128)|low:064x}',host_seconds=time.monotonic()-started,
                                 task_seconds=task_seconds,feature_source=source)
                        check_result(s,binding,vector);return s
                    result['hardware']=run(features,a.feature_source)
                    if a.compare_host:result['host_comparison']=run(features,'host')
                    if a.self_test:
                        rng=random.Random(2210)
                        vectors=[[0]*64,[255]*64,list(range(64)),[255-i*4 for i in range(64)]]
                        vectors += [[rng.randrange(256) for _ in range(64)] for _ in range(28)]
                        result['synthetic_tests']=[dict(features=vector,hardware=run(vector,'host')) for vector in vectors]
                finally:ftdi.set_latency_timer(old_latency)
        after=control([])
        if after['roi_frame_id']!=binding['frame_id'] or after['applied_config_id']!=binding['config_id'] or after['scan_bad_frames']!=context['scan_bad_frames'] or after['scan_error'] or after['render_error']:
            raise RuntimeError(f'Frame task changed/faulted: {after}')
        result['passed']=True
    finally:
        with acquire_jtag_engine(6e6,a.url) as e:
            e.reset()
            if decode_status(page(e,29))['busy']:command(e,0x52)
            command(e,0x26,0);command(e,126,0)
        result['restored']=control(restore)
        (a.output_dir/'result.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
    print(json.dumps(result,indent=2))

if __name__=='__main__':main()
