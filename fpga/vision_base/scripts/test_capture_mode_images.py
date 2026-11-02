from pathlib import Path
from tempfile import TemporaryDirectory
from PIL import Image
from capture_mode_images import NAMES,decode_snapshot,decode_caps,check_row,rgb_bytes,write_png,check_frozen_source

assert list(NAMES)==['source',*map(str,range(7))]

# Full-screen F1 has no ROI lease; RGB line headers still bind every row to its frame.
source=dict(roi_enabled=0,source_held=0,source_frozen=1,roi_frame_id=13334,held_source_frame_id=0)
check_frozen_source(source)
for bad in [dict(source,source_frozen=0),dict(source,roi_enabled=1),
            dict(source,roi_enabled=1,source_held=1,held_source_frame_id=13335)]:
    try:check_frozen_source(bad)
    except RuntimeError:pass
    else:raise AssertionError('Unfrozen or mismatched ROI source accepted')
check_frozen_source(dict(source,roi_enabled=1,source_held=1,held_source_frame_id=13334))

status=(1<<31)|(1<<28)|(5<<25)|(128<<14)|(1<<13)|(3<<11)|1079
v=(0x56495331<<160)|(0x2610051b<<128)|(123<<96)|(7<<64)|(1080<<32)|status
h=decode_snapshot(v)
for bits in [0,24]:
    caps=(0x56495331<<160)|(0x2610051c<<128)|(1920<<64)|(1080<<32)|bits
    assert decode_caps(caps)==(1920,1080,bits)
for caps in [(0x2610051c<<128)|(1920<<64)|(1080<<32)|24,(0x56495331<<160)|(0x2610051c<<128)|(1920<<64)|(1080<<32)|12]:
    try:decode_caps(caps)
    except RuntimeError:pass
    else:raise AssertionError('Invalid snapshot capabilities accepted')
try:decode_snapshot((0x56495331<<160)|(0x2610061a<<128))
except RuntimeError:pass
else:raise AssertionError('Disabled snapshot page accepted as an image')
check_row(h,dict(row=1079,mode=5,source=1,sequence=1080,frame_id=123,config_id=7,threshold=128,median=1,tone=3))
for changed in [dict(h,error=1),dict(h,frame_id=124),dict(h,threshold=129)]:
    try:check_row(changed,dict(frame_id=123,threshold=128))
    except RuntimeError:pass
    else:raise AssertionError('Mixed/incomplete line was accepted')
rgb=rgb_bytes(bytes([3,2,1,6,5,4]),0);assert rgb==bytes([1,2,3,4,5,6])
assert rgb_bytes(bytes([3,2,1]),2)==bytes([3,2,1])
# RAW readback is disabled in the snapshot-only build, but source color order remains.
for order,expected in [(0,bytes([1,2,3])),(2,bytes([3,2,1]))]:
    disabled_raw=(0x56495331<<160)|(0x26100603<<128)|(order<<76)
    assert rgb_bytes(bytes([3,2,1]),(disabled_raw>>76)&7)==expected
with TemporaryDirectory() as d:
    p=Path(d)/'frame.png';write_png(p,2,1,rgb)
    image=Image.open(p);assert image.size==(2,1) and image.getpixel((0,0))==(1,2,3) and image.getpixel((1,0))==(4,5,6)
print('PASS snapshot RGB888/header/source binding, changed line rejection, RGB/BGR order and lossless PNG')
