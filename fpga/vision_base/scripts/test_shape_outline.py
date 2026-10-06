"""Host acceptance of filled/outline topology, polarity and background rejection."""
import sys
from pathlib import Path
import numpy as np
sys.path.insert(0, str(Path(__file__).resolve().parents[1]/'models'))
from shape_outline import classify
y, x = np.indices((128, 128)); dx, dy = x-64, y-64
rect = (x>=36)&(x<=91)&(y>=54)&(y<=73)
outline = rect&((x<=38)|(x>=89)|(y<=56)|(y>=71))
circle = dx*dx+dy*dy<=484
ring = circle&(dx*dx+dy*dy>=324)
cases = [('blank', np.zeros_like(rect), 0), ('filled rectangle', rect, 2),
         ('outline rectangle', outline, 2), ('filled circle', circle, 1),
         ('outline circle', ring, 1), ('open rectangle', outline&~((y<=56)&(x>38)&(x<89)), 0),
         ('broken ring', ring&~((x>80)&(y>61)&(y<68)), 0)]
for name, mask, wanted in cases:
    for invert in [False, True]:
        gray = np.where(mask, 220 if invert else 20, 20 if invert else 220).astype(np.uint8)
        got = classify(gray, [16, 16, 96, 96], threshold=48, min_area=128)
        assert got['class_id'] == wanted, (name, invert, got)
        if wanted:
            noisy = gray.astype(np.int16)+(x*7+y*3)%7-3
            assert classify(noisy, [16, 16, 96, 96], threshold=48, min_area=128)['class_id'] == wanted
        print('PASS', name, 'inverted' if invert else 'normal', got['label'])
print('PASS host outline classifier14 cases, noisy positives and exact integer geometry')
