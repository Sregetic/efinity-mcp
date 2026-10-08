"""Read a complete CPU fusion record; publication identity is distinct from live view."""
import argparse,json,re,subprocess
from pathlib import Path
from load_vision_ddr import ROOT,IDE,board_location,configuration,symbols,validate_image,tcl_path
STATES=['none','wait','test','agree','conflict','unknown','error']
def decode(words):
    if len(words)!=16 or words[0]!=0x46555331 or not words[1] or words[15]:
        raise ValueError('Incomplete fusion producer record')
    flags=words[2];state=(flags>>8)&7
    if flags&~0x7ff:raise ValueError('Fusion flags contain bits outside ABI')
    if state>=len(STATES):raise ValueError('Fusion state outside ABI')
    def xy(v):return [v&65535,v>>16]
    return dict(sequence=words[1],flags=flags,state=STATES[state],inference_valid=bool(flags&1),
        synthetic_model=bool(flags&2),geometry_valid=bool(flags&4),automatic_roi=bool(flags&8),
        geometry_class=(flags>>4)&3,ai_class=(flags>>6)&3,frame_id=words[3],source_config_id=words[4],
        render_config_id=words[5],model_id=words[6],processing_context=words[7],
        display_box=[*xy(words[8]),*xy(words[9])],scores=[((words[10]>>(8*i))&255)-256 if (words[10]>>(8*i))&128 else (words[10]>>(8*i))&255 for i in range(4)],
        roi=[*xy(words[11]),*xy(words[12])],geometry_sequence=words[13])
def main():
    p=argparse.ArgumentParser();p.add_argument('--url',required=True);p.add_argument('--elf',type=Path,required=True);p.add_argument('--output-dir',type=Path,required=True);a=p.parse_args()
    _,_,s=validate_image(a.elf,None);sym=symbols(a.elf);address=sym['fusion_result'];a.output_dir.mkdir(parents=True,exist_ok=True)
    location=board_location(a.url)
    body=f'''set complete 0
for {{set n 0}} {{$n < 50}} {{incr n}} {{
 halt
 wait_halt 5000
 set record [read_memory {address:#x} 32 16]
 if {{[lindex $record 0] == 0x46555331 && [lindex $record 1] != 0 && [lindex $record 15] == 0}} {{set complete 1;break}}
 resume
 sleep 10
}}
if {{!$complete}} {{resume;echo FUSION_PENDING;shutdown error}}
echo "FUSION_RECORD $record"
resume
shutdown
'''
    cfg=configuration(location,ROOT/'artifacts/vision_soc/cpu0.yaml',s)+body;path=a.output_dir/'read.cfg';path.write_text(cfg)
    r=subprocess.run([str(IDE/'openocd/bin/openocd.exe'),'-f',str(path.resolve())],capture_output=True,text=True,timeout=60)
    log=r.stdout+r.stderr;(a.output_dir/'read.log').write_text(log);r.check_returncode()
    rows=re.search(r'^FUSION_RECORD (.*)$',log,re.M)
    if rows is None:raise RuntimeError('Fusion read did not publish a complete record')
    result=decode([int(v,0) for v in rows[1].split()]);(a.output_dir/'result.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
if __name__=='__main__':main()
