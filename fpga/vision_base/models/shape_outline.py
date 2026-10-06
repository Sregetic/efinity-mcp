"""Host reference for vision_shape_classifier's frozen-frame row-span contract."""
import argparse
import json
from pathlib import Path
import numpy as np
from PIL import Image


def classify(gray, roi, threshold=32, min_area=256, min_size=16, bg_spread=48):
    x, y, w, h = roi
    if gray.ndim != 2 or min(x, y) < 0 or min(w, h) < 32 or x+w > gray.shape[1] or y+h > gray.shape[0]:
        raise ValueError('Grayscale ROI must fit the image and contain four16x16 corner patches')
    if not 1 <= threshold <= 255:
        raise ValueError('Difference threshold1..255')
    a = gray[y:y+h, x:x+w].astype(np.int16)
    patches = [a[:16, :16], a[:16, -16:], a[-16:, :16], a[-16:, -16:]]
    means = [int(p.sum())//256 for p in patches]
    background = sum(int(p.sum()) for p in patches)//1024
    mask = np.abs(a-background) >= threshold
    mask[:16, :16] = mask[:16, -16:] = mask[-16:, :16] = mask[-16:, -16:] = False
    flags = 8 if max(means)-min(means) > bg_spread else 0
    yy, xx = np.nonzero(mask)
    if not len(xx):
        return dict(valid=False, class_id=0, label='NONE', reject_flags=flags|1,
                    background=background, corner_means=means, filled_area=0, bbox=None)
    xmin, xmax, ymin, ymax = int(xx.min()), int(xx.max()), int(yy.min()), int(yy.max())
    if xmin == 0 or xmax == w-1 or ymin == 0 or ymax == h-1:
        flags |= 2
    previous = []; previous_y = -1; area = 0
    def connected(a, b):
        return a[0] <= b[1]+1 and b[0] <= a[1]+1
    for row_y in range(h):
        padded = np.pad(mask[row_y].astype(np.int8), (1, 1))
        starts = np.flatnonzero(np.diff(padded) == 1)
        ends = np.flatnonzero(np.diff(padded) == -1)-1
        runs = list(zip(starts.tolist(), ends.tolist()))
        if not runs:
            continue
        area += runs[-1][1]-runs[0][0]+1
        if len(runs) > 2 or (not previous and len(runs) != 1):
            flags |= 4
        if previous and (row_y != previous_y+1 or
                not all(any(connected(a, b) for b in previous) for a in runs) or
                not all(any(connected(a, b) for a in runs) for b in previous)):
            flags |= 4
        previous, previous_y = runs, row_y
    if len(previous) != 1:
        flags |= 4
    bw, bh = xmax-xmin+1, ymax-ymin+1
    if area < min_area or min(bw, bh) < min_size:
        flags |= 1
    box_area = bw*bh
    kind = 0 if flags else 2 if area >= box_area-(box_area>>3) else 1 if (
        bw*8 >= bh*7 and bh*8 >= bw*7 and
        area >= (box_area>>1)+(box_area>>3)+(box_area>>4) and
        area <= (box_area>>1)+(box_area>>2)+(box_area>>4)+(box_area>>5)) else 3
    return dict(valid=not flags, class_id=kind, label=['NONE', 'CIRCLE', 'RECT', 'OTHER'][kind],
                reject_flags=flags, background=background, corner_means=means,
                filled_area=area, fill_ratio=area/box_area,
                bbox=[x+xmin, y+ymin, x+xmax, y+ymax])


if __name__ == '__main__':
    p = argparse.ArgumentParser(); p.add_argument('image', type=Path)
    p.add_argument('--roi', nargs=4, type=int, default=[640, 300, 640, 480])
    p.add_argument('--threshold', type=int, default=32); p.add_argument('--output', type=Path)
    a = p.parse_args()
    result = dict(image=a.image.resolve().as_posix(), roi=a.roi, threshold=a.threshold,
                  **classify(np.asarray(Image.open(a.image).convert('L')), a.roi, a.threshold))
    text = json.dumps(result, indent=2)
    if a.output:
        a.output.write_text(text, encoding='utf-8')
    print(text)
