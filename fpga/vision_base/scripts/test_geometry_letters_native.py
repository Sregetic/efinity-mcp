"""Run actual C code against held-out production RTL Canny bitmaps."""
import argparse
import json
import subprocess
from pathlib import Path
import numpy as np

ROOT=Path(__file__).resolve().parents[1]


def wsl(p):
    p=p.resolve().as_posix()
    return '/mnt/'+p[0].lower()+p[2:]


def main():
    p=argparse.ArgumentParser()
    p.add_argument('--cases-dir',type=Path,default=ROOT/'sim/fixtures/geometry_letters')
    p.add_argument('--output-dir',type=Path,default=ROOT/'results/geometry_letters_20261028/native_host')
    a=p.parse_args();out=a.output_dir.resolve();out.mkdir(parents=True,exist_ok=True)
    cases=json.loads((a.cases_dir/'cases.json').read_text())
    names=list(dict.fromkeys(c['source'] for c in cases))
    for name in names:
        words=np.array([int(v,16) for v in (a.cases_dir/(name+'.mem')).read_text().split()],dtype='<u4')
        assert len(words)==4050
        (out/(name+'.bin')).write_bytes(words.tobytes())
    command=['wsl.exe','-d','Ubuntu-24.04','--exec','gcc','-O2','-g','-fsanitize=address,undefined',
             '-std=c11','-I'+wsl(ROOT/'firmware/vision'),wsl(ROOT/'sim/test_geometry_letters.c'),
             wsl(ROOT/'firmware/vision/geometry_m7.c'),'-o',wsl(out/'letters')]
    r=subprocess.run(command,capture_output=True);(out/'compile.log').write_bytes(r.stdout+r.stderr);r.check_returncode()
    r=subprocess.run(['wsl.exe','-d','Ubuntu-24.04','--exec',wsl(out/'letters'),*[wsl(out/(n+'.bin')) for n in names]],capture_output=True)
    (out/'host.stdout').write_bytes(r.stdout);(out/'host.stderr').write_bytes(r.stderr);r.check_returncode()
    frames=dict(zip(names,[json.loads(line) for line in r.stdout.splitlines()],strict=True));results=[]
    for t in cases:
        frame=frames[t['source']];x0,y0,x1,y1=t['box'];cx=(x0+x1)/2;cy=(y0+y1)/2
        candidates=[c for c in frame['candidates'] if c[3] and c[2]>=4 and max(abs(c[0]-x0),abs(c[1]-y0),abs(c[7]-x1),abs(c[8]-y1))<=3]
        c=max(candidates,key=lambda c:(c[7]-c[0]+1)*(c[8]-c[1]+1)) if candidates else None
        expected=4+'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.index(t['char'])
        exact=c is not None and c[2]==expected
        ambiguous=c is not None and c[2]==82 and t['char'] in 'Il'
        results.append(dict(**t,expected=expected,candidate=c,exact=exact,ambiguous=ambiguous,ok=exact or ambiguous))
    anchors=json.loads((a.cases_dir/'anchors.json').read_text())
    display_failures=[]
    for name,frame in frames.items():
        targets=[(4+'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.index(c['char']),c['box']) for c in cases if c['source']==name]
        targets += [(11,b) for b in anchors[name]]
        good=len(frame['boxes'])==min(4,len(targets)) and frame['more']==int(len(targets)>4)
        for b in frame['boxes']:
            good &= any((b[0]==k or (b[0]==82 and k in (12,41))) and max(abs(v-w) for v,w in zip(b[1:],box))<=3 for k,box in targets)
        if not good:display_failures.append(dict(source=name,boxes=frame['boxes'],more=frame['more'],expected_count=min(4,len(targets))))
    failures=[r for r in results if not r['ok']]
    summary=dict(total=len(results),exact=sum(r['exact'] for r in results),ambiguous=sum(r['ambiguous'] for r in results),failures=len(failures),display_failures=len(display_failures),frames=len(frames))
    (out/'result.json').write_text(json.dumps(dict(summary=summary,cases=results,frames=frames,display_failures=display_failures),indent=2),encoding='utf-8')
    print(json.dumps(summary))
    for r in failures[:30]:print(r['font'],r['size'],r['char'],r['candidate'])
    for r in display_failures[:10]:print(r)
    assert not failures and not display_failures, 'Native glyph/display failures: see result.json'


if __name__=='__main__':main()
