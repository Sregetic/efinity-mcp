"""Run ordinary-motion RTL tests in isolated output folders; never touches hardware."""
import argparse,hashlib,json,os,subprocess,tempfile
from pathlib import Path
from motion_reference import fixtures

def main():
 p=argparse.ArgumentParser();p.add_argument('--iverilog',default='iverilog');p.add_argument('--vvp',default='vvp');p.add_argument('--ivl-lib');p.add_argument('--output',type=Path);a=p.parse_args();base=Path(__file__).resolve().parents[1];rtl=base/'board/ti60f225_v4/rtl/vision';bench=base/'sim/motion_direction';out=a.output.resolve() if a.output else Path(tempfile.mkdtemp(prefix='ordinary-motion-tests-'));out.mkdir(parents=True,exist_ok=True)
 if (out/'verification.json').exists():raise SystemExit('Existing evidence found: choose a new output directory.')
 env=os.environ.copy()
 if Path(a.iverilog).is_absolute():env['PATH']=str(Path(a.iverilog).parent)+os.pathsep+env.get('PATH','')
 mods=['vision_window3','vision_median9','vision_sobel','vision_frontend','vision_osd','vision_motion_osd','vision_motion_readout','vision_display','vision_local_motion_core','vision_local_motion_tap','vision_motion_policy'];rows=[];hashes={};seen=[]
 tests=[('core','tb_local_motion_core.sv',['vision_local_motion_core']),('tap','tb_local_motion_tap.sv',['vision_local_motion_core','vision_local_motion_tap','vision_motion_policy']),('policy','tb_motion_policy.sv',['vision_motion_policy']),('snapshot','tb_motion_snapshot.sv',['vision_motion_snapshot_cdc']),('readout','tb_motion_readout.sv',['vision_motion_readout']),('hud_snapshot','tb_motion_hud_snapshot.sv',mods),('hud','tb_motion_hud.sv',['vision_motion_osd']),('display','tb_motion_display.sv',mods)]
 for name,test,names in tests:
  work=out/name;work.mkdir(exist_ok=False);fixture=fixtures(work/'vectors');sources=[bench/test]+[rtl/(n+'.sv') for n in names];seen.extend(sources)
  for f in sources:hashes[str(f.relative_to(base)).replace('\\','/')]=hashlib.sha256(f.read_bytes()).hexdigest()
  exe=work/(name+'.vvp');cmd=[a.iverilog]+(['-B',a.ivl_lib] if a.ivl_lib else [])+['-g2012','-Wall','-s','tb']+(['-Ptb.FRAMES='+str(fixture['core_frames'])] if name=='core' else [])+['-o',str(exe)]+[str(f) for f in sources];row=dict(test=name,fixture=fixture)
  for stage,args in [('compile',cmd),('simulation',[a.vvp]+(['-M',a.ivl_lib] if a.ivl_lib else [])+[str(exe)])]:
   result=subprocess.run(args,cwd=work,env=env,capture_output=True,timeout=180);(work/(stage+'.log')).write_bytes(result.stdout+result.stderr);row[stage+'_exit']=result.returncode
   if result.returncode:print((result.stdout+result.stderr).decode('utf-8',errors='replace'));raise SystemExit(f'FAIL {name} {stage}')
  rows.append(row);print('PASS',name,flush=True)
 assert all(hashlib.sha256(f.read_bytes()).hexdigest()==hashes[str(f.relative_to(base)).replace('\\','/')] for f in seen)
 report=dict(passed=True,tests=rows,sources=hashes,scope='Actual Icarus event simulation with generated synthetic fixtures only; not board compile or camera accuracy',hardware_programmed=False);(out/'verification.json').write_text(json.dumps(report,indent=2),encoding='utf-8');print('PASS all8 RTL tests; report:',out/'verification.json')
if __name__=='__main__':main()
