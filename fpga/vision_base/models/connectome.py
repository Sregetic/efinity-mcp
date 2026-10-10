"""MaleCNS published subgraph, snapshot-reset recurrence; no trained readout."""
import json,math
from pathlib import Path
import numpy as np

DATA=Path(__file__).parent/'connectome_malecns'
GRAPH=json.loads((DATA/'graph.json').read_text())
Q=16384
assert len(GRAPH['nodes'])==80 and len(GRAPH['edges'])==1296
assert sum(e[2] for e in GRAPH['edges'])==26029
assert len({n['id'] for n in GRAPH['nodes']})==80
assert len({(a,b) for a,b,c in GRAPH['edges']})==1296
assert all(0<=a<80 and 0<=b<80 and c>0 for a,b,c in GRAPH['edges'])
assert all(n['sign'] in (-1,0,1) for n in GRAPH['nodes'])
assert len(GRAPH['inputs'])==32 and len(GRAPH['outputs'])==16

def qround(v):return int(math.copysign(math.floor(abs(v)*Q+0.5),v))
totals=np.zeros(80,np.int64)
for a,b,c in GRAPH['edges']:totals[b]+=c*abs(GRAPH['nodes'][a]['sign'])
EDGES=[(a,b,c*GRAPH['nodes'][a]['sign']/totals[b] if totals[b] else 0) for a,b,c in GRAPH['edges']]
WEIGHTS=[qround(w) for a,b,w in EDGES]
ORDER=sorted(range(1296),key=lambda e:(EDGES[e][1],EDGES[e][0]))
PRE=np.array([EDGES[e][0] for e in ORDER],np.uint8)
W=np.array([WEIGHTS[e] for e in ORDER],np.int16)
ROW=np.array([sum(b<i for a,b,w in EDGES) for i in range(81)],np.uint16)
INPUT=np.full(80,-1,np.int8)
for cell,channel in GRAPH['inputs']:INPUT[cell]=channel
LUT=np.array([qround(math.tanh(i/64)) for i in range(257)],np.int16)
assert max(sum(abs(int(w)) for w in W[ROW[i]:ROW[i+1]]) for i in range(80))<=Q+40

def channels(features):
 # Eight2x4 spatial bins of the SAME64 edge-density features used by FlyHash.
 p=np.asarray(features)[64:].reshape(8,8).astype(np.int32)+128
 return np.array([int(p[4*r:4*r+4,2*c:2*c+2].sum()) for r in range(2) for c in range(4)])

def floating(features):
 drive=np.zeros(80);u=2*channels(features)/2040-1
 for cell,channel in GRAPH['inputs']:drive[cell]=u[channel]
 h=np.zeros(80)
 for step in range(3):
  acc=drive.copy()
  for a,b,w in EDGES:acc[b]+=1.4*w*h[a]
  h=0.3*h+0.7*np.tanh(acc)
 return h

def rdiv(v,d):return (v+d//2)//d if v>=0 else -((-v+d//2)//d)
def r14(v):return rdiv(v,Q)
def tanh_q14(v):
 a=abs(v);i=a>>8;f=a&255
 y=(int(LUT[i])*(256-f)+int(LUT[i+1])*f+128)>>8
 return -y if v<0 else y

def fixed(features):
 u=[rdiv((2*int(v)-2040)*Q,2040) for v in channels(features)]
 h=[0]*80
 for step in range(3):
  nxt=[]
  for i in range(80):
   acc=sum(int(W[e])*h[int(PRE[e])] for e in range(int(ROW[i]),int(ROW[i+1])))
   drive=u[int(INPUT[i])] if INPUT[i]>=0 else 0
   nxt.append(r14(4915*h[i]+11469*tanh_q14(drive+r14(22938*r14(acc)))))
  h=nxt
 return np.array(h,np.int16)
