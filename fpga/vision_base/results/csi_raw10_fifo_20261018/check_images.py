"""Validate actual nine-mode exports against unchanged display arithmetic."""
import json,sys
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw,ImageFont
ROOT=Path('F:/Project/fpga/vision_base');sys.path.insert(0,str(ROOT/'scripts'))
from test_canny_smooth import fitted,load_table
P=Path(__file__).resolve().parent
meta=json.loads((P/'images/images.json').read_text());before=json.loads((P/'edge_before.json').read_text());after=json.loads((P/'edge_after.json').read_text())
assert meta['passed'] and len(meta['images'])==9 and before['words']==after['words']
frame=meta['context']['roi_frame_id'];config=meta['context']['applied_config_id']
assert all(i['frame_id']==frame and i['config_id']==config for i in meta['images'])
assert before['context']['held_source_frame_id']==after['context']['held_source_frame_id']==frame
def image(n):return np.asarray(Image.open(P/'images'/f'mode_{n}.png')).astype(np.int32)
bm=np.array([(w>>b)&1 for w in before['words'] for b in range(32)],dtype=bool).reshape(270,480)
expected=fitted(bm,load_table());expected[:8]=0;expected[-8:]=0;expected[:,:8]=0;expected[:,-8:]=0;expected=np.pad(expected,((2,0),(2,0)))[:1080,:1920]
mask=np.ones((1080,1920),dtype=bool);mask[:40,:432]=False
results={}
def check(name,actual,ref):
    d=np.abs(actual-ref)[mask];r=dict(pixels=int(mask.sum()),different_channels=int(np.count_nonzero(d)),maximum_error=int(d.max()))
    results[name]=r;assert not r['different_channels'],(name,r)
base=image(0);canny=image(5);gray=image(1);sobel=image(2)
check('canny',canny,np.repeat(expected[:,:,None],3,axis=2))
alpha=(canny[:,:,0]+4)//8
check('canny_overlay',image(6),(base*(32-alpha[:,:,None])+np.array([255,48,48])*alpha[:,:,None]+16)//32)
want=gray.copy();want[:,962:]=sobel[:,962:];want[:,958:962]=[0,255,128];check('split',image(3),want)
want=base.copy();want[sobel[:,:,0]!=0]=[255,48,48];check('sobel_overlay',image(4),want)
assert np.array_equal(gray[mask,0],gray[mask,1]) and np.array_equal(gray[mask,1],gray[mask,2])
assert np.array_equal(sobel[mask,0],sobel[mask,1]) and np.array_equal(sobel[mask,1],sobel[mask,2])
sobel_threshold=next(i['threshold'] for i in meta['images'] if i['mode']=='2')
assert np.all((sobel[mask]==0)|(sobel[mask]>=sobel_threshold//2))
stats=dict(mean_rgb=base.mean(axis=(0,1)).tolist(),std_rgb=base.std(axis=(0,1)).tolist(),minimum=int(base.min()),maximum=int(base.max()))
old=np.asarray(Image.open(P/'before_strips/mode_0.png')).astype(np.int32);now=base[500:524]
stats['different_time_strip_comparison']=dict(before_mean_rgb=old.mean(axis=(0,1)).tolist(),after_mean_rgb=now.mean(axis=(0,1)).tolist(),scope='Different capture times, not identical-frame equivalence')
canvas=Image.new('RGB',(1920,3*388),(20,20,20));draw=ImageDraw.Draw(canvas);font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',20)
labels=[('source','Source before Gamma'),('0','M0 Camera'),('1','M1 Grayscale'),('2','M2 Sobel'),('3','M3 Split'),('4','M4 Sobel overlay'),('5','M5 Canny'),('6','M6 Canny overlay'),('7','M7 Recognition')]
for i,(key,label) in enumerate(labels):
    path=P/'images'/('source.png' if key=='source' else f'mode_{key}.png');x=(i%3)*640;y=(i//3)*388
    canvas.paste(Image.open(path).resize((640,360)),(x,y+28));draw.text((x+8,y+3),label,fill='white',font=font)
canvas.save(P/'all_modes.png')
r=dict(passed=True,source_frame=frame,render_config=config,images=9,size=[1920,1080],canny_edges=int(bm.sum()),canny_plane_unchanged=True,comparisons=results,camera_statistics=stats,scope='Actual same-frame images vs unchanged reference, not old/new sensors sharing a frame')
(P/'image_verification.json').write_text(json.dumps(r,indent=2));print(json.dumps(r,indent=2))
