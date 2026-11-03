"""Bit-exact Canny noise checks plus positive geometry retention; no frame blanking shortcut."""
from pathlib import Path
import json
import cv2
import numpy as np


def denoise(a):
    windows=np.lib.stride_tricks.sliding_window_view(a,(3,3))
    median=np.median(windows,axis=(-2,-1)).astype(np.int32)
    centre=windows[:,:,1,1]
    same=np.abs(windows-centre[:,:,None,None])<=64
    continuation=(same[:,:,0,0]&same[:,:,2,2])|(same[:,:,0,1]&same[:,:,2,1])|\
                 (same[:,:,0,2]&same[:,:,2,0])|(same[:,:,1,0]&same[:,:,1,2])
    keep=continuation&(np.abs(centre-median)>64)
    out=np.zeros_like(a);out[2:,2:]=np.where((np.abs(centre-median)>64)&~continuation,median,centre)
    residual=int(np.where(keep,0,np.abs(centre-median)).sum())
    shift=((a.shape[0]-2)*(a.shape[1]-2)-1).bit_length()
    bound=min(255,(2*residual+(1<<shift)-1)>>shift)
    return out,bound


def classifications(a,enabled=True,threshold=16):
    a=np.asarray(a,dtype=np.int32);h,w=a.shape
    filtered,mean=denoise(a)
    src=filtered if enabled else a
    hi=max(16,threshold,min(2047,16+8*mean) if enabled else 16)
    g=np.zeros_like(a)
    k=np.array([[1,2,1],[2,4,2],[1,2,1]])
    win=np.lib.stride_tricks.sliding_window_view(src,(3,3))
    g[2:,2:]=((win*k).sum((-2,-1))+8)//16
    win=np.lib.stride_tricks.sliding_window_view(g,(3,3))
    gx=win[:,:,0,2]+2*win[:,:,1,2]+win[:,:,2,2]-win[:,:,0,0]-2*win[:,:,1,0]-win[:,:,2,0]
    gy=win[:,:,2,0]+2*win[:,:,2,1]+win[:,:,2,2]-win[:,:,0,0]-2*win[:,:,0,1]-win[:,:,0,2]
    mag=np.zeros_like(a);direction=np.zeros_like(a)
    ax,ay=np.abs(gx),np.abs(gy);mag[2:,2:]=ax+ay
    direction[2:,2:]=np.where(ay*256<ax*106,0,np.where(ax*256<ay*106,2,np.where((gx<0)!=(gy<0),3,1)))
    cl=np.zeros_like(a);shift=4 if enabled else 3
    for y in range(7 if enabled else 6,h):
        for x in range(7 if enabled else 6,w):
            p=mag[y-2:y+1,x-2:x+1];m=p[1,1];d=direction[y-1,x-1]
            n1,n2=[(p[1,0],p[1,2]),(p[0,0],p[2,2]),(p[0,1],p[2,1]),(p[0,2],p[2,0])][d]
            if m and m>=n1 and m>n2:cl[y-shift,x-shift]=2 if m>=hi else 1 if m>=hi//2 else 0
    return cl,mean,hi


def canny(a,enabled=True,threshold=16,min_component=32):
    cl,mean,hi=classifications(a,enabled,threshold)
    n,labels,stats,_=cv2.connectedComponentsWithStats((cl!=0).astype(np.uint8),8)
    keep=np.zeros(n,dtype=bool)
    for i in range(1,n):keep[i]=stats[i,4]>=min_component and bool(np.any(cl[labels==i]==2))
    return keep[labels].astype(np.uint8),mean,hi


def generate():
    out=Path(__file__).resolve().parents[1]/'results/noise_finish_20261004';out.mkdir(parents=True,exist_ok=True)
    rng=np.random.default_rng(2210);w,h=64,48;cases=[]
    for sigma in [4,8,16]:
        for salt in [0,.02]:
            a=np.clip(np.rint(70+rng.normal(0,sigma,(h,w))),0,255).astype(np.int32)
            mask=rng.random((h,w))<salt;a[mask]=rng.choice([0,255],int(mask.sum()))
            cases.append((f'flat_sigma{sigma}_salt{salt}',a,None))
    y,x=np.mgrid[:h,:w];clean=np.full((h,w),35,dtype=np.int32)
    clean[10:36,8:28]=210;clean[(x-46)**2+(y-24)**2<=9**2]=190
    for sigma in [0,8,16]:
        a=np.clip(np.rint(clean+rng.normal(0,sigma,(h,w))),0,255).astype(np.int32)
        mask=rng.random((h,w))<.015;a[mask]=rng.choice([0,255],int(mask.sum()))
        cases.append((f'geometry_sigma{sigma}',a,clean))
    # Thin vertical and diagonal structures must survive the impulse filter.
    thin=np.full((h,w),35,dtype=np.int32);thin[7:42,20]=220
    for yy in range(8,42):thin[yy,yy+12]=220
    cases.append(('thin_structures',thin,thin))
    frontend_input=[];frontend_expected=[];frontend_means=[]
    for enabled,a in [(True,cases[6][1]),(False,thin)]:
        filtered,mean=denoise(a)
        frontend_input.extend(a.ravel());frontend_expected.extend((filtered if enabled else a).ravel());frontend_means.append(mean)
    for file,values in [('denoise_input',frontend_input),('denoise_expected',frontend_expected),('denoise_means',frontend_means)]:
        (out/(file+'.mem')).write_text(''.join(f'{int(v):02x}\n' for v in values),encoding='utf-8')
    inputs=[];gold=[];means=[];highs=[];records=[]
    for name,a,truth in cases:
        edge,mean,hi=canny(a);before,_,_=canny(a,False,min_component=16)
        record=dict(name=name,noise_mean_bound=mean,effective_high=hi,before_pixels=int(before.sum()),after_pixels=int(edge.sum()))
        if truth is None:assert not edge.any(),record
        else:
            reference,_,_=canny(truth);band=cv2.dilate(reference,np.ones((5,5),np.uint8))!=0
            detected=cv2.dilate(edge,np.ones((5,5),np.uint8))!=0
            recall=float((reference.astype(bool)&detected).sum()/max(1,reference.sum()))
            false=int((edge.astype(bool)&~band).sum());record.update(false_pixels=false,contour_recall=recall)
            assert edge.sum()>32 and recall>=.85 and false==0,record
        inputs.extend(a.ravel());gold.extend(edge.ravel());means.append(mean);highs.append(hi);records.append(record)
    for file,values,digits in [('noise_input',inputs,2),('noise_expected',gold,1),('noise_mean',means,2),('noise_high',highs,3)]:
        (out/(file+'.mem')).write_text(''.join(f'{int(v):0{digits}x}\n' for v in values),encoding='utf-8')
    (out/'noise_reference.json').write_text(json.dumps(dict(width=w,height=h,cases=records),indent=2),encoding='utf-8')
    print(json.dumps(records,indent=2))


if __name__=='__main__':generate()
