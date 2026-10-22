"""Independent integer reference. All fixtures are generated synthetic data."""
from pathlib import Path
import random
class Reference:
 def __init__(self):self.previous=self.on=self.off=None
 def step(self,g,reset=False):
  valid=self.previous is not None and not reset
  delta=[[g[y][x]-self.previous[y][x] if valid else 0 for x in range(12)] for y in range(12)]
  on=[[max(v,0) for v in row] for row in delta];off=[[max(-v,0) for v in row] for row in delta];hx=vy=0
  if valid:
   for delayed,current in [(self.on,on),(self.off,off)]:
    hx+=sum(delayed[y][x]*current[y][x+1]-delayed[y][x+1]*current[y][x] for y in range(12) for x in range(11))
    vy+=sum(delayed[y][x]*current[y+1][x]-delayed[y+1][x]*current[y][x] for y in range(11) for x in range(12))
  points=[(x,y) for y in range(12) for x in range(12) if abs(delta[y][x])>8];n=len(points);box=[min(x for x,y in points),min(y for x,y in points),max(x for x,y in points)+1,max(y for x,y in points)+1] if n else [0]*4;code=0
  if valid and not n:code=1
  elif valid and max(abs(hx),abs(vy))>=256 and 2*max(abs(hx),abs(vy))>=3*min(abs(hx),abs(vy)):code=(3 if hx>0 else 2) if abs(hx)>=abs(vy) else (5 if vy>0 else 4)
  self.previous=[row[:] for row in g];self.on=on;self.off=off;value=int(valid)
  for v,bits in [(code,3),(int(bool(n)),1),(n,16),(hx&0xffffffff,32),(vy&0xffffffff,32)]+[(v,4) for v in box]:value=(value<<bits)|v
  return value

def fixtures(folder):
 folder=Path(folder);folder.mkdir(parents=True,exist_ok=True);grids=[];resets=[]
 for direction in ['right','left','up','down']:
  for i in range(6):
   g=[[180]*12 for _ in range(12)];p=2+i if direction in ['right','down'] else 8-i
   for y in range(12):
    for x in range(12):
     if ((4<=y<7 and p<=x<p+2) if direction in ['right','left'] else (p<=y<p+2 and 4<=x<7)):g[y][x]=20
   grids.append(g);resets.append(i==0)
 for i in range(8):grids.append([[128]*12 for _ in range(12)]);resets.append(i==0)
 for i in range(8):grids.append([[32 if i%2 else 224]*12 for _ in range(12)]);resets.append(i==0)
 rng=random.Random(2214)
 for i in range(16):grids.append([[rng.choice([0,255]) for _ in range(12)] for _ in range(12)]);resets.append(i==0)
 for i in range(6):
  g=[[180]*12 for _ in range(12)]
  for y in range(2+i,4+i):
   for x in range(2+i,4+i):g[y][x]=20
  grids.append(g);resets.append(i==0)
 ref=Reference();expected=[ref.step(g,r) for g,r in zip(grids,resets)]
 (folder/'grid_words.mem').write_text(''.join(f'{v:02x}\n' for g in grids for row in g for v in row),encoding='ascii');(folder/'reset_history.mem').write_text(''.join(f'{int(v):x}\n' for v in resets),encoding='ascii');(folder/'core_expected.mem').write_text(''.join(f'{v:026x}\n' for v in expected),encoding='ascii')
 pixels=[];means=[]
 for i in range(6):
  frame=[[20 if 32<=y<56 and 32+16*i<=x<64+16*i else 180 for x in range(192)] for y in range(96)];pixels.extend(v for row in frame for v in row)
  for gy in range(12):
   for gx in range(12):means.append(sum(frame[gy*8+sy][gx*16+2*sx+1] for sy in range(8) for sx in range(8))>>6)
 (folder/'pixel_frames.mem').write_text(''.join(f'{v:02x}\n' for v in pixels),encoding='ascii');(folder/'pixel_grid_expected.mem').write_text(''.join(f'{v:02x}\n' for v in means),encoding='ascii')
 return dict(core_frames=len(grids),pixel_frames=6,kind='generated_synthetic_only',seed=2214)
