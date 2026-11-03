"""Validate executed ROI RTL pixels and C-produced global-to-view tracking packets."""
from pathlib import Path
import argparse,json
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[1];TASK=ROOT/'results/m7_follow_20261031'
OUT=TASK/'follow_render';cases=json.loads((OUT/'control/center_vectors.json').read_text())
p=argparse.ArgumentParser();p.add_argument('--overlay-dir',type=Path,default=OUT/'render');overlay=p.parse_args().overlay_dir
packets=json.loads((TASK/'service_follow/overlay_packets.json').read_text())
assert b'PASS tb_roi_axi_scaler' in(OUT/'render/test.log').read_bytes()
records=[]
for index,(case,packet)in enumerate(zip(cases,packets,strict=True)):
 x,y,w,h=case['target'];xy,wh,size,pos=case['roi'];sx,sy=xy>>12,xy&4095;sw,sh=wh>>12,wh&4095;dw,dh=size>>12,size&4095;dx,dy=pos>>12,pos&4095
 assert (sw,sh,dw,dh,dx,dy)==(480,270,1920,1080,0,0)
 source=np.full((1080,1920),0xef7b,np.uint16);source[y:y+h,x:x+w]=0x8842;source[y+3:y+h-3,x+3:x+w-3]=0xa25c
 actual=np.fromfile(OUT/f'render/center_{index}.raw',dtype='<u2').reshape(dh,dw)
 expected=source[np.ix_(sy+np.arange(dh)*sh//dh,sx+np.arange(dw)*sw//dw)]
 assert np.array_equal(actual,expected),case['name']
 center=[(x+w/2-sx)*dw/sw+dx,(y+h/2-sy)*dh/sh+dy]
 assert abs(center[0]-960)<=96 and abs(center[1]-540)<=54,center
 rows=packet['rows'];n=int(case['name'],16);count=rows[66]>>32
 assert rows[66]&0xffffffff==case['config'] and count==n//4+1
 assert [rows[0]&2047,(rows[0]>>11)&2047,rows[1]&2047,(rows[1]>>11)&2047]==[(x-sx)*4,(y-sy)*4,(x+w-1-sx)*4,(y+h-1-sy)*4]
 for i,line in enumerate(rows[18:18+count]):
  prior=max(0,i-1)
  assert [line&511,(line>>9)&511,(line>>18)&511,(line>>27)&511,line>>36]==[748+32*prior-sx,448+16*prior-sy,748+32*i-sx,448+16*i-sy,3]
 rgb=np.stack([(((actual>>s)&31)<<3)|(((actual>>s)&31)>>2)for s in(10,5,0)],axis=-1).astype(np.uint8)
 Image.fromarray(rgb).save(OUT/f'render/follow_{index}.png')
 records.append(dict(name=case['name'],pixels=actual.size,source_roi=[sx,sy,sw,sh],display_center=center,trail_points=count,source_frame=case['frame'],render=case['config']))
 if index==5:
  values=rgb[:,:,0].astype(np.uint32)<<16|rgb[:,:,1].astype(np.uint32)<<8|rgb[:,:,2].astype(np.uint32)
  (OUT/'render/backdrop.mem').write_text(''.join(f'{v:06x}\n'for v in values.flat))
(OUT/'result.json').write_text(json.dumps(dict(passed=True,rtl_pixels=sum(c['pixels']for c in records),cases=records,scope='RV32 follow descriptors -> unchanged production ROI reader/scaler; C track packets independently checked in global source coordinates'),indent=2))
print('PASS six follow ROI views, 12441600 actual RTL pixels and all real-observation packet transforms')

# The raster adds its existing two-pixel frontend phase to C display coordinates.
rows=packets[-1]['rows'];base=np.asarray(Image.open(OUT/'render/follow_5.png')).copy()
actual=np.asarray(Image.open(overlay/'follow_overlay.ppm'))
mask=np.fromfile(overlay/'follow_overlay.mask',dtype=np.uint8).reshape(1080,1920)
expected=base.copy();wanted=np.zeros((1080,1920),dtype=np.uint8)
x0,y0=rows[0]&2047,(rows[0]>>11)&2047;x1,y1=rows[1]&2047,(rows[1]>>11)&2047
for line in rows[18:18+(rows[66]>>32)]:
 xa,ya,xb,yb,shade=line&511,(line>>9)&511,(line>>18)&511,(line>>27)&511,line>>36
 if ya>yb:xa,ya,xb,yb=xb,yb,xa,ya
 delta=xb-xa;dy=yb-ya;inverse=(65536+dy//2)//dy if dy else 0
 color=(64,255,255)if shade==3 else(40,144,144)if shade==2 else(24,72,72)
 for gy in range(ya,yb+1):
  step=gy-ya
  a=xb if step==dy else xa+((delta*step*inverse+32768)>>16)
  b=xb if step+1>=dy else xa+((delta*(step+1)*inverse+32768)>>16)
  if not dy:a,b=xa,xb
  left,right=sorted((a,b));x=left*4+2;y=gy*4+2
  expected[y:y+4,x:right*4+6]=color;wanted[y:y+4,x:right*4+6]=1
for x,y,w,h in [(x0+2,y0+2,x1-x0+1,1),(x0+2,y1+2,x1-x0+1,1),(x0+2,y0+2,1,y1-y0+1),(x1+2,y0+2,1,y1-y0+1)]:
 expected[y:y+h,x:x+w]=(255,64,255);wanted[y:y+h,x:x+w]=1
label_x=min(x0,1888);label_y=y0-18 if y0>=18 else y0+2
if label_x<428 and label_y<40:label_y=40
for y,row in enumerate(rows[2:18]):
 for x in range(row>>32):
  expected[label_y+y+2,label_x+x+2]=(255,64,255)if row>>x&1 else(0,0,0)
  wanted[label_y+y+2,label_x+x+2]=1
assert np.array_equal(mask,wanted),'Actual RTL overlay mask differs from C source-point/box/label reference'
assert np.array_equal(actual,expected),'Actual RTL RGB differs from independent overlay reference'
Image.fromarray(actual).save(overlay/'follow_overlay.png')
Image.open(TASK/'rtl/track_overlay.ppm').save(TASK/'rtl/track_overlay.png')
(overlay/'overlay_result.json').write_text(json.dumps(dict(passed=True,pixels=int(mask.size),marks=int(mask.sum()),source_frame=cases[-1]['frame'],render=cases[-1]['config'],observations=rows[66]>>32,scope='Actual production tracking raster on actual production scaler pixels; synthetic packed16 moving source'),indent=2))
print('PASS actual ROI/overlay composite: 2073600 pixels, box/label and continuous segments between measured observations')
