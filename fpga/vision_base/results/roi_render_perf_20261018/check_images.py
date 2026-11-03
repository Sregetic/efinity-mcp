"""Check real exports against the existing display arithmetic and Canny model."""
import json,sys
from pathlib import Path
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'scripts'))
from test_canny_smooth import fitted,load_table
p=Path(__file__).resolve().parent
def read(name):return json.loads((p/name).read_text())
full=read('images/images.json');strips=read('mode_strips/images.json');before=read('edge_before.json');after=read('edge_after.json')
assert full['passed'] and strips['passed'] and before['words']==after['words']
frame=full['context']['roi_frame_id'];config=full['context']['applied_config_id']
assert all(i['frame_id']==frame and i['config_id']==config for m in [full,strips] for i in m['images'])
assert before['context']['held_source_frame_id']==after['context']['held_source_frame_id']==frame
def image(folder,n):return np.asarray(Image.open(p/folder/f'mode_{n}.png')).astype(np.int32)
bm=np.array([(w>>b)&1 for w in before['words'] for b in range(32)],dtype=bool).reshape(270,480)
expected=fitted(bm,load_table());expected[:8]=0;expected[-8:]=0;expected[:,:8]=0;expected[:,-8:]=0
expected=np.pad(expected,((2,0),(2,0)))[:1080,:1920]
np.save(p/'expected_canny.npy',expected)
mask=np.ones((1080,1920),dtype=bool);mask[:40,:432]=False
results={}
def check(name,actual,reference,selected):
    d=np.abs(actual-reference)[selected];r=dict(pixels=int(selected.sum()),different_channels=int(np.count_nonzero(d)),maximum_error=int(d.max()))
    results[name]=r;assert r['different_channels']==0,(name,r)
base=image('images',0);canny=image('images',5);overlay=image('images',6)
check('canny',canny,np.repeat(expected[:,:,None],3,axis=2),mask)
alpha=(canny[:,:,0]+4)//8
want=(base*(32-alpha[:,:,None])+np.array([255,48,48])*alpha[:,:,None]+16)//32
check('canny_overlay',overlay,want,mask)
gray=image('mode_strips',1);sobel=image('mode_strips',2);split=image('mode_strips',3)
want=gray.copy();want[:,962:]=sobel[:,962:];want[:,958:962]=[0,255,128]
stripmask=np.ones((24,1920),dtype=bool)
check('split_strip',split,want,stripmask)
want=base[500:524].copy();want[sobel[:,:,0]!=0]=[255,48,48]
check('sobel_overlay_strip',image('mode_strips',4),want,stripmask)
result=dict(passed=True,source_frame=frame,render_config=config,full_images=len(full['images']),full_size=[1920,1080],strip_images=len(strips['images']),strip_y=500,strip_height=24,canny_edges=int(bm.sum()),canny_plane_unchanged=True,comparisons=results,scope='Real same-frame exports vs unchanged display reference; not old/new bitstreams sharing one DDR frame')
(p/'image_verification.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
