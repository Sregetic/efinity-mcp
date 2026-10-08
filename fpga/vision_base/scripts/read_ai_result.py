"""Read a complete same-task CPU record/tensor through USER1; resume afterwards."""
import argparse,json,re,struct,subprocess,sys
from pathlib import Path
from load_vision_ddr import ROOT,IDE,board_location,configuration,symbols,validate_image,tcl_path
from capture_mode_images import write_png

def main():
    p=argparse.ArgumentParser();p.add_argument('--url',required=True);p.add_argument('--elf',type=Path,required=True)
    p.add_argument('--output-dir',type=Path,required=True)
    p.add_argument('--policy',choices=['view','geometry']);p.add_argument('--roi',nargs=4,type=int,metavar=('X','Y','W','H'))
    g=p.add_mutually_exclusive_group();g.add_argument('--frame',type=lambda x:int(x,0));g.add_argument('--latest',action='store_true')
    a=p.parse_args()
    if a.policy=='geometry' and (a.roi is not None or a.frame is not None or a.latest):p.error('Geometry policy owns ROI/frame selection; manual requests use view policy')
    if a.roi:
        x,y,w,h=a.roi
        if min(x,y)<0 or min(w,h)<1 or x+w>1920 or y+h>1080:p.error('ROI must fit1920x1080 source')
    if a.frame is not None and not 0<=a.frame<=0xffffffff:p.error('Frame ID is uint32')
    _,_,s=validate_image(a.elf,None);sym=symbols(a.elf);a.output_dir.mkdir(parents=True,exist_ok=True)
    location=board_location(a.url);address=sym['analysis_result']
    body='';condition=''
    if a.policy or a.roi or a.frame is not None or a.latest:
        ctrl=sym['analysis_control'];body=f'halt\nwait_halt 5000\nset previous [read_memory {address+4:#x} 32 1]\n'
        policy=2 if a.policy=='geometry' else 1
        subprocess.run([sys.executable,str(ROOT/'scripts/vision_control.py'),'--url',a.url,'--ai-policy',str(policy),'--samples','0'],check=True,capture_output=True,text=True)
        body+=f'set nonce [read_memory {ctrl+32:#x} 32 1]\nwrite_memory {ctrl+32:#x} 32 [list [expr {{($nonce+1)&0xffffffff}}]]\n'
        if a.policy=='view' and a.frame is None and not a.latest:body+=f'write_memory {ctrl:#x} 32 {{5}}\n'
        if a.roi:
            x,y,w,h=a.roi;body+=f'write_memory {ctrl+8:#x} 32 {{{x|(y<<16)} {w|(h<<16)}}}\n'
            condition+=f' && [lindex $record 6] == {x|(y<<16)} && [lindex $record 7] == {w|(h<<16)}'
        if a.frame is not None:
            body+=f'write_memory {ctrl:#x} 32 {{1 {a.frame}}}\n';condition+=f' && [lindex $record 2] == {a.frame}'
        elif a.latest:body+=f'write_memory {ctrl:#x} 32 {{3}}\n'
        condition+=' && [lindex $record 1] != $previous';body+='resume\n'
    body+=f'''set complete 0
for {{set n 0}} {{$n < 50}} {{incr n}} {{
 halt
 wait_halt 5000
 set record [read_memory {address:#x} 32 24]
 if {{[lindex $record 0] == 0x41494d31 && [lindex $record 1] != 0 && [lindex $record 17] == 0{condition}}} {{set complete 1;break}}
 resume
 sleep 10
}}
if {{!$complete}} {{resume;echo AI_RECORD_PENDING;shutdown error}}
echo "AI_RECORD $record"
'''
    arrays=[('gray','analysis_gray',1024),('features','analysis_features',128),('hidden','analysis_hidden',32),('logits','analysis_logits',4),('hash','analysis_hash',32)]
    for name,symbol,size in arrays:body+=f'dump_image {tcl_path(a.output_dir/(name+".bin"))} {sym[symbol]:#x} {size}\n'
    body+='resume\necho AI_RECORD_COMPLETE\nshutdown\n'
    cfg=configuration(location,ROOT/'artifacts/vision_soc/cpu0.yaml',s)+body;path=a.output_dir/'read.cfg';path.write_text(cfg)
    r=subprocess.run([str(IDE/'openocd/bin/openocd.exe'),'-f',str(path.resolve())],capture_output=True,text=True,timeout=60)
    log=r.stdout+r.stderr;(a.output_dir/'read.log').write_text(log);r.check_returncode()
    if 'AI_RECORD_COMPLETE' not in log:raise RuntimeError('CPU record read did not complete')
    record=[int(x,0) for x in re.search(r'^AI_RECORD (.*)$',log,re.M)[1].split()]
    gray=(a.output_dir/'gray.bin').read_bytes();rgb=bytes(v for x in gray for v in (x,x,x));write_png(a.output_dir/'roi.png',32,32,rgb)
    result=dict(sequence=record[1],frame_id=record[2],source_config_id=record[3],model_id=record[4],class_id=record[5],
        render_config_id=record[20],processing_context=record[21],roi=[record[6]&65535,record[6]>>16,record[7]&65535,record[7]>>16],input_base=record[8],
        dma_cycles=record[9],feature_cycles=record[10],layer0_cycles=record[11],layer1_cycles=record[12],flyhash_cycles=record[13],
        total_cpu_cycles=record[14],gray_sum=record[15],dma_errors=record[23],start_tick=record[18],end_tick=record[19],raw_record=record,
        features=list(struct.unpack('<128b',(a.output_dir/'features.bin').read_bytes())),
        hidden=list(struct.unpack('<32b',(a.output_dir/'hidden.bin').read_bytes())),
        logits=list(struct.unpack('<4b',(a.output_dir/'logits.bin').read_bytes())),
        hash=f'{int.from_bytes((a.output_dir/"hash.bin").read_bytes(),"little"):064x}',clock_hz=100000000)
    (a.output_dir/'result.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))

if __name__=='__main__':main()
