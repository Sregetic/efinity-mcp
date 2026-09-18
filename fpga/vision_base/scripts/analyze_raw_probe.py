"""Numerical and thumbnail inspection of measured Bayer tiles, no white balance."""
import argparse
import json
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw

p = argparse.ArgumentParser()
p.add_argument('snapshot')
a = p.parse_args()
src = Path(a.snapshot)
d = json.loads(src.read_text(encoding='utf-8'))
w = np.array(d['words'], dtype=np.uint32).reshape(d['height'], d['width'])
raw = np.stack([(w >> 16) & 255, (w >> 24) & 255, w & 255, (w >> 8) & 255], -1).astype(float)
valid = (raw.max(-1) < 240) & (raw.mean(-1) > 24)
stats = dict(sequence=d['sequence'], sample_tiles=int(w.size), usable_tiles=int(valid.sum()),
             mean=raw.mean((0, 1)).tolist(), maximum=raw.max((0, 1)).tolist(),
             near_saturated_fraction=(raw >= 250).mean((0, 1)).tolist(),
             pair_00_11_median_abs_difference=float(np.median(np.abs(raw[..., 0]-raw[..., 3])[valid])),
             pair_01_10_median_abs_difference=float(np.median(np.abs(raw[..., 1]-raw[..., 2])[valid])))
patterns = {'RGGB':(0,1,2,3), 'BGGR':(3,1,2,0), 'GRBG':(1,0,3,2), 'GBRG':(2,0,3,1)}
canvas = Image.new('RGB', (800, 500), (30, 30, 30))
draw = ImageDraw.Draw(canvas)
for i,(name,(r,g1,g2,b)) in enumerate(patterns.items()):
    rgb = np.stack([raw[...,r], (raw[...,g1]+raw[...,g2])/2, raw[...,b]], -1)
    rgb = np.clip((rgb-16)/255, 0, 1)**(1/2.2)
    im = Image.fromarray(np.uint8(np.rint(rgb*255))).resize((400,225), Image.Resampling.NEAREST)
    x,y=(i%2)*400,(i//2)*250
    canvas.paste(im,(x,y+25))
    draw.text((x+8,y+6),name+'  RAW tiles / no WB',(255,255,255))
canvas.save(src.with_name(src.stem+'_patterns.png'))
src.with_name(src.stem+'_stats.json').write_text(json.dumps(stats,indent=2),encoding='utf-8')
np.save(src.with_name(src.stem+'_tiles.npy'),raw)
print(json.dumps(stats,indent=2))
