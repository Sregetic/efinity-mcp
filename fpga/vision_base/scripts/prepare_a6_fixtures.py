"""Deterministic A6 offline fixtures, never a physical-card training dataset."""
import argparse,json,sys
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw,ImageOps
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'models'))
from shape_outline import classify

p=argparse.ArgumentParser();p.add_argument('--output-dir',required=True,type=Path);a=p.parse_args()
a.output_dir.mkdir(parents=True,exist_ok=True);cases=[]
def save(name,image,wanted):
    got=classify(np.asarray(image),[640,300,640,480])
    assert got['class_id']==wanted,(name,got)
    file=a.output_dir/(name+'.png');image.save(file)
    cases.append(dict(file=file.name,kind='synthetic',expected_class=wanted,**got))

for shape,box,kind in [('circle',(860,440,1060,640),1),('rect',(800,420,1120,660),2)]:
    for filled in [False,True]:
        image=Image.new('L',(1920,1080),240);draw=ImageDraw.Draw(image)
        draw_shape=draw.ellipse if shape=='circle' else draw.rectangle
        draw_shape(box,fill=24 if filled else None,outline=24,width=8)
        name=('filled_' if filled else 'hollow_')+shape;save(name,image,kind)
        if not filled:save(name+'_inverse',ImageOps.invert(image),kind)
save('blank',Image.new('L',(1920,1080),240),0)
image=Image.new('L',(1920,1080),240);draw=ImageDraw.Draw(image)
for x in range(680,1260,60):draw.rectangle((x,320,x+8,760),fill=24)
save('background_stripes',image,0)
image=Image.new('L',(1920,1080),240);ImageDraw.Draw(image).rectangle((620,420,900,660),outline=24,width=8)
save('clipped_rect',image,0)
(a.output_dir/'manifest.json').write_text(json.dumps(dict(scope='Offline A6 only; excludes real train/test accuracy',cases=cases),indent=2),encoding='utf-8')
print(f'Prepared {len(cases)} synthetic A6 fixtures')
