"""Reference edge geometry for upright printed Latin glyphs; no learned model."""
from pathlib import Path
import cv2
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
FONTS = ['arial.ttf', 'times.ttf', 'Noto Sans SC Medium (TrueType).otf']
CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'


def features(e):
    y, x = np.where(e)
    out = np.zeros((32,32), np.uint8)
    out[y*32//max(e.shape), x*32//max(e.shape)] = 1
    envelope = np.zeros_like(out)
    for y in range(32):
        xs = np.flatnonzero(out[y])
        if len(xs): envelope[y,xs[0]]=envelope[y,xs[-1]]=1
    for x in range(32):
        ys = np.flatnonzero(out[:,x])
        if len(ys): envelope[ys[0],x]=envelope[ys[-1],x]=1
    return envelope


def generate():
    import json
    records = json.loads((ROOT/'models/geometry_letters/reference_edges.json').read_text())
    lines = ['/* Production RTL Canny edge geometry; captured by scripts/capture_geometry_letter_references.py. */',
             '#pragma once', '#include <stdint.h>',
             'struct m7_letter_template {uint16_t letter,aspect,cap_height,count;int16_t baseline;uint32_t edge[32],near[32];};',
             f'enum {{M7_LETTER_TEMPLATES={len(records)}}};',
             'static const struct m7_letter_template m7_letter_templates[M7_LETTER_TEMPLATES]={']
    for r in records:
        e = np.unpackbits(np.frombuffer(bytes.fromhex(r['packed']),np.uint8),bitorder='little')[:r['width']*r['height']].reshape(r['height'],r['width'])
        f = features(e); d = cv2.dilate(f,np.ones((3,3),np.uint8))
        row = lambda a: [sum(int(a[y,x]) << x for x in range(32)) for y in range(32)]
        packed = lambda a: '{' + ','.join(f'0x{x:08x}u' for x in row(a)) + '}'
        lines.append(f" {{{CHARS.index(r['char'])},{r['width']*100//r['height']},{r['cap_height']},{int(f.sum())},{r['baseline']},{packed(f)},{packed(d)}}},")
    return '\n'.join(lines+['};',''])


if __name__ == '__main__':
    (ROOT/'firmware/vision/geometry_letter_templates.h').write_text(generate(), encoding='utf-8')
    print('468 production Canny references, 52 classes, three print fonts, three scales.')
