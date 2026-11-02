"""Reference edge geometry for upright printed Latin glyphs; no learned model."""
from pathlib import Path
import cv2
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
FONTS = ['arial.ttf', 'times.ttf', 'Noto Sans SC Medium (TrueType).otf']
CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'


def features(e, size=16):
    y, x = np.where(e)
    out = np.zeros((size,size), np.uint8)
    # Keep inner strokes and holes; independent axes tolerate camera foreshortening.
    out[y*(size-1)//(e.shape[0]-1), x*(size-1)//(e.shape[1]-1)] = 1
    return out


def generate():
    import json
    records = json.loads((ROOT/'models/geometry_letters/reference_edges.json').read_text())
    lines = ['/* Production RTL Canny edge geometry; captured by scripts/capture_geometry_letter_references.py. */',
             '#pragma once', '#include <stdint.h>',
             'enum {M7_LETTER_SIZE=16,M7_LETTER_WORDS=8,M7_LETTER_MAX_DENSITY=MAX_DENSITY_VALUE};',
             'struct m7_letter_template {uint16_t letter,aspect,cap_height,count,fine_count;int16_t baseline;uint32_t edge[8],near[8],fine[32];};',
             f'enum {{M7_LETTER_TEMPLATES={len(records)}}};',
             'static const struct m7_letter_template m7_letter_templates[M7_LETTER_TEMPLATES]={']
    max_fine=0
    assert all(CHARS.index(r['char'])==i%52 for i,r in enumerate(records))
    for r in records:
        e = np.unpackbits(np.frombuffer(bytes.fromhex(r['packed']),np.uint8),bitorder='little')[:r['width']*r['height']].reshape(r['height'],r['width'])
        f = features(e); d = cv2.dilate(f,np.ones((3,3),np.uint8))
        row = lambda a: [sum(int(a[y*2+j,x]) << (x+j*16) for j in range(2) for x in range(16)) for y in range(8)]
        packed = lambda a: '{' + ','.join(f'0x{x:08x}u' for x in row(a)) + '}'
        fine = features(e,32)
        max_fine=max(max_fine,int(fine.sum()))
        fine_rows = '{'+','.join(f'0x{sum(int(fine[y,x])<<x for x in range(32)):08x}u' for y in range(32))+'}'
        lines.append(f" {{{CHARS.index(r['char'])},{r['width']*100//r['height']},{r['cap_height']},{int(f.sum())},{int(fine.sum())},{r['baseline']},{packed(f)},{packed(d)},{fine_rows}}},")
    coarse=[i for i,r in enumerate(records)if r['size']==384]
    lines+=['};',f'enum {{M7_COARSE_TEMPLATES={len(coarse)}}};',
            'static const uint16_t m7_coarse_templates[]={'+','.join(map(str,coarse))+'};','']
    return '\n'.join(lines).replace('MAX_DENSITY_VALUE',str(max_fine*3//2))


if __name__ == '__main__':
    (ROOT/'firmware/vision/geometry_letter_templates.h').write_text(generate(), encoding='utf-8')
    print('468 production Canny references, 52 classes, three print fonts/scales; packed full16 edge geometry.')
