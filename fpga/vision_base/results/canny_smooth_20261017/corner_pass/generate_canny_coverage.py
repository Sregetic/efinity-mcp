"""Precompute 4x contour coverage; the FPGA keeps its binary recognition graph."""
from pathlib import Path
import argparse
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
OUTPUT=ROOT/'board/ti60f225_v4/rtl/vision/canny_coverage_q5.mem'
OFFSETS=[(-1,-1),(0,-1),(1,-1),(-1,0),(0,0),(1,0),(-1,1),(0,1),(1,1)]

def paths(pattern):
    bits=[bool(pattern&(1<<(8-i))) for i in range(9)]
    nw,n,ne,w,center,e,sw,s,se=bits
    curves=[]
    if center:
        connected=[nw and not(n or w),n,ne and not(n or e),w,False,e,
                   sw and not(s or w),s,se and not(s or e)]
        directions=[np.array(OFFSETS[i],dtype=float) for i,on in enumerate(connected) if on]
        origin=np.array([2.,2.])
        if len(directions)==2:
            a,b=[origin+2*d for d in directions]
            t=np.linspace(0,1,33)[:,None]
            curve=(1-t)**2*a+2*(1-t)*t*origin+t*t*b
            # Extend the shared tangent across the half-pixel sampling boundary.
            curves.append(np.vstack([a+.75*directions[0]/np.linalg.norm(directions[0]),
                                     curve,b+.75*directions[1]/np.linalg.norm(directions[1])]))
        else:
            for d in directions:
                curves.append(np.array([origin,origin+2*d+.75*d/np.linalg.norm(d)]))
            if not directions:
                curves.append(np.array([origin,origin]))
    else:
        # Diagonal neighbors meet at cell corners only when no orthogonal route exists.
        for on,a,b in [(n and w and not nw,(2,-2),(-2,2)),
                       (n and e and not ne,(2,-2),(6,2)),
                       (s and w and not sw,(2,6),(-2,2)),
                       (s and e and not se,(2,6),(6,2))]:
            if on:curves.append(np.array([a,b],dtype=float))
    return curves

def make_table():
    sub=(np.arange(8)+.5)/8-.5
    yy,xx=np.meshgrid(np.arange(4),np.arange(4),indexing='ij')
    sy,sx=np.meshgrid(sub,sub,indexing='ij')
    samples=np.stack([xx[:,:,None,None]+sx,yy[:,:,None,None]+sy],axis=-1).reshape(-1,2)
    table=np.zeros((512,16),dtype=np.uint8)
    for pattern in range(512):
        distance=np.full(len(samples),np.inf)
        for curve in paths(pattern):
            for a,b in zip(curve,curve[1:]):
                delta=b-a;length=float(delta@delta)
                if length:
                    t=np.clip((samples-a)@delta/length,0,1)
                    d=samples-(a+t[:,None]*delta)
                else:d=samples-a
                distance=np.minimum(distance,(d*d).sum(axis=1))
        covered=(distance<=.25).reshape(16,64).sum(axis=1)
        table[pattern]=(covered*31+32)//64
        if pattern==16:table[pattern,10]=31
    return table

def words(table):
    return [sum(int(level)<<(5*i) for i,level in enumerate(cell)) for cell in table]

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--check',action='store_true');args=parser.parse_args()
    table=make_table()
    assert not table[0].any() and table[16,10]==31
    assert np.all(table[16+128+2].reshape(4,4)[:,2]==31)
    assert np.all(table[16+32+8].reshape(4,4)[2,:]==31)
    text=''.join(f'{word:020x}\n' for word in words(table))
    if args.check:assert OUTPUT.read_text(encoding='ascii')==text,'Coverage ROM differs from generator'
    else:OUTPUT.write_text(text,encoding='ascii')
    print('PASS 512 contour neighborhoods, 16 pixels x5bit coverage; 512x80 existing-clock ROM')

if __name__=='__main__':main()
