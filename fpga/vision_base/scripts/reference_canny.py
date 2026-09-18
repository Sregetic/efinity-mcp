from pathlib import Path
from collections import deque
import numpy as np,json
D=Path('sim/vision');W,H=480,270
s=np.full((H,W),20,dtype=np.int64);s[28:100,40:165]=180;s[45:82,60:145]=40
for y in range(10,125):
 x=200-y//2;s[y,max(0,x-2):x+2]=230
# Isolated low-contrast object plus a weak contour attached to a strong contour.
# This exercises both promotion and rejection in the complete RTL pipeline.
s[5:22,10:30]=50
for y in range(103,126):s[y,20:100]=140-5*(y-103)
s=np.repeat(np.repeat(s[:135,:240],2,axis=0),2,axis=1)
G=np.zeros_like(s);M=np.zeros_like(s);Dr=np.zeros_like(s)
k=np.array([[1,2,1],[2,4,2],[1,2,1]])
for y in range(2,H):
 for x in range(2,W):G[y,x]=(int((s[y-2:y+1,x-2:x+1]*k).sum())+8)//16
for y in range(2,H):
 for x in range(2,W):
  p=G[y-2:y+1,x-2:x+1];gx=int(p[0,2]+2*p[1,2]+p[2,2]-p[0,0]-2*p[1,0]-p[2,0]);gy=int(p[2,0]+2*p[2,1]+p[2,2]-p[0,0]-2*p[0,1]-p[0,2]);a,b=abs(gx),abs(gy);M[y,x]=a+b
  Dr[y,x]=0 if b*256<a*106 else 2 if a*256<b*106 else 3 if (gx<0)!=(gy<0) else 1
cl=np.zeros_like(s)
for y in range(6,H):
 for x in range(6,W):
  p=M[y-2:y+1,x-2:x+1];m=p[1,1];di=Dr[y-1,x-1];n1,n2=[(p[1,0],p[1,2]),(p[0,0],p[2,2]),(p[0,1],p[2,1]),(p[0,2],p[2,0])][di]
  if m>0 and m>=n1 and m>n2:cl[y-3,x-3]=2 if m>=128 else 1 if m>=64 else 0
q=deque(zip(*np.where(cl==2)));edge=cl==2
while q:
 y,x=q.popleft()
 for dy in [-1,0,1]:
  for dx in [-1,0,1]:
   yy,xx=y+dy,x+dx
   if 0<=yy<H and 0<=xx<W and cl[yy,xx]==1 and not edge[yy,xx]:edge[yy,xx]=1;q.append((yy,xx))
(D/'canny_input.mem').write_text(''.join(f'{n:02x}\n' for n in s.ravel()))
(D/'canny_expected.mem').write_text(''.join(f'{int(n):x}\n' for n in edge.ravel()))
promoted=int(((cl==1)&edge).sum());rejected=int(((cl==1)&~edge).sum())
assert promoted>0 and rejected>0, f'Fixture coverage promoted={promoted} rejected={rejected}'
(D/'canny_reference.json').write_text(json.dumps({'width':W,'height':H,'strong':int((cl==2).sum()),'weak':int((cl==1).sum()),'promoted_weak':promoted,'rejected_weak':rejected,'edges':int(edge.sum())},indent=2))
print('reference edges',edge.sum())
