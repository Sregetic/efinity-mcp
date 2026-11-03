"""Precompute 4x contour coverage; the FPGA keeps its binary recognition graph."""
from pathlib import Path
import argparse
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
OUTPUT=ROOT/'board/ti60f225_v4/rtl/vision/canny_coverage_q5.mem'
FIT_OUTPUT=ROOT/'board/ti60f225_v4/rtl/vision/canny_fit_q4.mem'
INDEX_OUTPUT=OUTPUT.with_name('canny_coverage_index.mem')
PALETTE_OUTPUT=OUTPUT.with_name('canny_coverage_palette.mem')
SPURS={0b111010000,0b000010111,0b100110100,0b001011001}
OFFSETS=[(-1,-1),(0,-1),(1,-1),(-1,0),(0,0),(1,0),(-1,1),(0,1),(1,1)]

def paths(pattern):
    if pattern in SPURS:return []
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
    values=words(table)
    text=''.join(f'{word:020x}\n' for word in values)
    palette=list(dict.fromkeys(values))
    assert len(palette)<=64
    index_text=''.join(f'{palette.index(word):02x}\n' for word in values)
    levels=[(word>>(5*phase))&31 for word in palette for phase in range(16)]
    palette_text=''.join(f'{v:02x}\n' for v in levels+[0]*(1024-len(levels)))
    fit=[0]*1024
    for short in (0,1):
        for code in range(128):
            v=code if code<64 else code-128
            fit[(short<<7)|code]=(32+((v*51+2)>>2 if short else (v*57+4)>>3))&1023
        for code in range(256):
            v=code if code<128 else code-256
            fit[512|(short<<8)|code]=((v*13+4)>>3 if short else (v*17+32)>>6)&63
    fit_text=''.join(f'{v:03x}\n'for v in fit)
    if args.check:
        assert OUTPUT.read_text(encoding='ascii')==text,'Coverage ROM differs from generator'
        assert FIT_OUTPUT.read_text(encoding='ascii')==fit_text,'Fit ROM differs from generator'
        assert INDEX_OUTPUT.read_text(encoding='ascii')==index_text,'Coverage dictionary differs from generator'
        assert PALETTE_OUTPUT.read_text(encoding='ascii')==palette_text,'Coverage palette differs from generator'
    else:
        OUTPUT.write_text(text,encoding='ascii');FIT_OUTPUT.write_text(fit_text,encoding='ascii')
        INDEX_OUTPUT.write_text(index_text,encoding='ascii');PALETTE_OUTPUT.write_text(palette_text,encoding='ascii')
    print(f'PASS 512 contour neighborhoods, {len(palette)} lossless palette entries and exact Q4 fit reference; binary graph unchanged')

if __name__=='__main__':main()
