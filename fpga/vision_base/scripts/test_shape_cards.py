"""Minimal preprocessing, split-leakage and single-rounding regressions."""
import json,random,sys
from pathlib import Path
from tempfile import TemporaryDirectory
import numpy as np
from PIL import Image
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'models'))
from shape_cards import features,gray_roi,requantize
from collect_shape_sample import check_groups
from train_shape_cards import samples

black=np.zeros((32,32),dtype=np.uint8);white=np.full_like(black,255)
assert np.array_equal(features(black),np.full(128,-128,np.int8))
assert np.array_equal(features(white)[:64],np.full(64,127,np.int8)) and np.all(features(white)[64:]==-128)
assert gray_roi(Image.new('RGB',(32,32),(255,0,0)),[0,0,32,32])[0,0]==76
pattern=np.arange(60*80,dtype=np.uint32).reshape(60,80)%256
sampled=gray_roi(Image.fromarray(pattern.astype(np.uint8)),[3,5,37,45])
assert np.array_equal(sampled,pattern[5+(np.arange(32)*45)//32][:,3+(np.arange(32)*37)//32])
r=random.Random(9);cases=[(1410,1754168599,-8)]+[(r.randint(-4000000,4000000),r.randint(1,2147483647),r.randint(-30,-2)) for _ in range(4096)]
for x,m,s in cases:assert requantize(x,m,s)==(((x*m)>>32)+(1<<(-2-s)))>>(-1-s)
with TemporaryDirectory() as temporary:
    root=Path(temporary);image=root/'source.png';Image.fromarray(white).save(image)
    rows=[dict(kind='real_camera',split=split,label=label,session_id=split,card_id=split+label,image=str(image),roi=[0,0,32,32]) for split in ['train','test'] for label in ['blank','circle','rectangle','triangle']]
    manifest=root/'manifest.jsonl';manifest.write_text('\n'.join(map(json.dumps,rows)))
    got=samples(manifest);assert len(got['train'][0])==len(got['test'][0])==4
    for field in ['session_id','card_id']:
        bad=[dict(r) for r in rows];bad[4][field]=bad[0][field];manifest.write_text('\n'.join(map(json.dumps,bad)))
        try:samples(manifest)
        except ValueError:pass
        else:raise AssertionError('Split leakage accepted: '+field)
    try:check_groups(rows,'test','train','newcard')
    except ValueError:pass
    else:raise AssertionError('Capture crossed a training session')
print('PASS card features, independent train/test cards/sessions and4097 single-rounding MulHi cases')
