"""Compare real M0 pixels with both ISP revisions on the exact captured source."""
import argparse, json
from pathlib import Path
import cv2
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]

def denoise(a, extended):
    l, c, r = a[:, :-2], a[:, 1:-1], a[:, 2:]
    def y(v): return (v[:,:,0] + 2*v[:,:,1] + v[:,:,2]) >> 2
    cy, ly, ry = y(c), y(l), y(r)
    mr = np.median(np.stack((l[:,:,0]-l[:,:,1], c[:,:,0]-c[:,:,1], r[:,:,0]-r[:,:,1])), axis=0).astype(np.int32)
    mb = np.median(np.stack((l[:,:,2]-l[:,:,1], c[:,:,2]-c[:,:,1], r[:,:,2]-r[:,:,1])), axis=0).astype(np.int32)
    near = (abs(ly-cy)<=8) & (abs(ry-cy)<=8)
    dark = near & (cy<=48) & (ly<=56) & (ry<=56) & ((mr!=c[:,:,0]-c[:,:,1]) | (mb!=c[:,:,2]-c[:,:,1]))
    rgb = np.stack(((4*cy+3*mr-mb)>>2, (4*cy-mr-mb)>>2, (4*cy+3*mb-mr)>>2), axis=2).clip(0,255)
    out = a.copy()
    out[:,1:-1] = np.where(dark[:,:,None], rgb, c)
    if extended:
        flat = near & (cy>48) & (abs(l-c).max(axis=2)<=16) & (abs(r-c).max(axis=2)<=16)
        out[:,1:-1] = np.where(flat[:,:,None], (l+2*c+r+2)>>2, out[:,1:-1])
    return out

def tone(a, shadow):
    name = 'chroma_shadow_gain_q8.mem' if shadow else 'chroma_tone_gain_q8.mem'
    rom = np.array([int(x,16) for x in (ROOT/'board/ti60f225_v4/rtl/gamma_conrrection'/name).read_text().split()], dtype=np.int32)
    return ((a*rom[a.max(axis=2)][:,:,None]+128)>>8).clip(0,255)

def metrics(a):
    y = cv2.cvtColor(a.astype(np.uint8), cv2.COLOR_RGB2GRAY).astype(float)
    return dict(mean=float(y.mean()), fine_std=float((y-cv2.GaussianBlur(y,(3,3),0)).std()))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('--shadow',type=int,choices=[0,1],required=True)
    p.add_argument('--revision',choices=['old','new'],required=True);p.add_argument('--roi',type=int,nargs=4,default=[900,450,200,200]);a=p.parse_args()
    meta=json.loads((a.capture/'images.json').read_text())
    assert meta['passed'] and meta['width']==1920 and meta['height']==1080
    assert all(i['median']==0 and i['tone']==3 for i in meta['images'])
    source=np.array(Image.open(a.capture/'source.png'),dtype=np.int32)
    actual=np.array(Image.open(a.capture/'mode_0.png'),dtype=np.int32)
    old=tone(denoise(source,False),a.shadow);new=tone(denoise(source,True),a.shadow)
    x,y,w,h=a.roi;region=np.s_[y:y+h,x:x+w]
    expected=new if a.revision=='new' else old
    # Ordinary-brightness ROI excludes clipped lights (separate highlight logic).
    assert np.array_equal(actual[region],expected[region]),'Actual ISP pixels differ from RTL-equivalent reference'
    m0,m1=metrics(old[region]),metrics(new[region])
    result=dict(passed=True,frame_id=meta['context']['roi_frame_id'],roi=a.roi,revision=a.revision,
        pixels_exact=w*h,old_reference=m0,new_reference=m1,actual=metrics(actual[region]),
        fine_reduction_percent=100*(1-m1['fine_std']/m0['fine_std']),
        comparison='Same captured source; old-path reference, not a second hardware photograph')
    (a.capture/'pixel_validation.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
    print(json.dumps(result,indent=2))
