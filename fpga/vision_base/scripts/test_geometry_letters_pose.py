"""Exercise camera-like poses of held-out accepted Canny bitmaps, not a new edge detector."""
import argparse,json,subprocess
from pathlib import Path
import cv2,numpy as np
from test_geometry_letters_native import ROOT,wsl

def main():
 p=argparse.ArgumentParser();p.add_argument('--backend',type=Path,required=True);p.add_argument('--output-dir',type=Path,required=True);p.add_argument('--angles',type=int,nargs='+',default=[-18,18]);a=p.parse_args()
 out=a.output_dir.resolve();out.mkdir(parents=True,exist_ok=True)
 cases=[c for c in json.loads((ROOT/'sim/fixtures/geometry_letters/cases.json').read_text())if c['font']=='arial.ttf'and c['size']==400];frames=list(dict.fromkeys(c['source']for c in cases));inputs=[]
 for name in frames:
  words=np.array([int(v,16)for v in (ROOT/'sim/fixtures/geometry_letters'/(name+'.mem')).read_text().split()],dtype='<u4');mask=np.unpackbits(words.view(np.uint8),bitorder='little').reshape(270,480)
  image=cv2.imread(str(ROOT/'results/geometry_letters_20261028/native_validation'/(name+'.png')),0)
  if image is None:raise FileNotFoundError(name)
  for angle in a.angles:
   matrix=cv2.getRotationMatrix2D((240,135),angle,.70)
   tag=f'{name}_{angle:+d}';path=out/(tag+'.bin');targets=[]
   prefix=out/tag
   if not Path(str(prefix)+'_bitmap.mem').exists():
    full=cv2.warpAffine(image,cv2.getRotationMatrix2D((960,540),angle,.70),(1920,1080),flags=cv2.INTER_LINEAR,borderValue=255)
    cv2.imwrite(str(prefix.with_suffix('.png')),full);mem=prefix.with_suffix('.mem');mem.write_text('\n'.join(f'{v:02x}'for v in full.flat)+'\n')
    binary=ROOT/'results/geometry_letters_20261028/native/obj/Vtb'
    run=subprocess.run(['wsl.exe','-d','Ubuntu-24.04','--cd',wsl(ROOT/'board/ti60f225_v4'),'--exec',wsl(binary),'+image='+wsl(mem),'+output='+wsl(prefix)],capture_output=True,timeout=180)
    prefix.with_suffix('.log').write_bytes(run.stdout+run.stderr);run.check_returncode();assert b'PASS native Canny'in run.stdout;mem.unlink()
   accepted=np.array([int(v,16)for v in Path(str(prefix)+'_bitmap.mem').read_text().split()],dtype='<u4');assert len(accepted)==4050;path.write_bytes(accepted.tobytes())
   for c in cases:
    if c['source']!=name:continue
    x,y,x1,y1=c['box'];single=np.zeros_like(mask);single[y:y1+1,x:x1+1]=mask[y:y1+1,x:x1+1]
    single=cv2.warpAffine(single,matrix,(480,270),flags=cv2.INTER_NEAREST);yy,xx=np.where(single)
    projected=[int(xx.min()),int(yy.min()),int(xx.max()),int(yy.max())]
    actual=np.unpackbits(accepted.view(np.uint8),bitorder='little').reshape(270,480)
    owned=actual&cv2.dilate(single,np.ones((3,3),np.uint8));yy,xx=np.where(owned)
    assert len(xx),(tag,c['char'],'no accepted edges')
    targets.append(dict(char=c['char'],box=[int(xx.min()),int(yy.min()),int(xx.max()),int(yy.max())],projected_box=projected,accepted_pixels=int(owned.sum())))
   inputs.append(dict(name=tag,path=str(path),targets=targets));print('Canny pose',tag,flush=True)
 rows=[]
 for i in range(0,len(inputs),24):
  group=inputs[i:i+24];r=subprocess.run(['wsl.exe','-d','Ubuntu-24.04','--exec',wsl(a.backend),*[wsl(Path(t['path']))for t in group]],capture_output=True)
  (out/f'run_{i:03d}.stderr').write_bytes(r.stderr);r.check_returncode();rows.extend(json.loads(v)for v in r.stdout.splitlines())
 assert len(rows)==len(inputs)
 results=[];alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
 for item,row in zip(inputs,rows,strict=True):
  for target in item['targets']:
   k=4+alphabet.index(target['char']);matches=[c for c in row['candidates']if c[3]and max(abs(v-w)for v,w in zip([c[0],c[1],c[7],c[8]],target['box']))<=3]
   exact=any(c[2]==k for c in matches);ambiguous=target['char']in'Il'and any(c[2]==82 for c in matches)
   results.append(dict(scene=item['name'],**target,expected=k,exact=exact,ambiguous=ambiguous,candidates=matches,ok=exact or ambiguous))
 summary=dict(frames=len(inputs),glyphs=len(results),exact=sum(t['exact']for t in results),ambiguous=sum(t['ambiguous']for t in results),failures=sum(not t['ok']for t in results))
 (out/'result.json').write_text(json.dumps(dict(summary=summary,cases=results,frames=rows),indent=2))
 print(json.dumps(summary));print(json.dumps([t for t in results if not t['ok']][:12]));assert not summary['failures']
if __name__=='__main__':main()
