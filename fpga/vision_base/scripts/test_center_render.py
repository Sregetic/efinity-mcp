"""Check actual RTL pixel dumps against the RV32I-produced center descriptors."""
import argparse,json
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw,ImageFont

ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--output-dir',type=Path,default=ROOT/'results/center_symmetric_20261022')
out=p.parse_args().output_dir
cases=json.loads((out/'control/center_vectors.json').read_text())
assert 'PASS tb_roi_axi_scaler six firmware center descriptors' in (out/'render/test.log').read_text()

def rgb(pixels):
    channels=[(pixels>>shift)&31 for shift in (10,5,0)]
    return np.stack([(c<<3)|(c>>2) for c in channels],axis=-1).astype(np.uint8)

font=ImageFont.truetype('C:/Windows/Fonts/Noto Sans SC Medium (TrueType).otf',24)
sheet=Image.new('RGB',(1312,1248),'#20262c');draw=ImageDraw.Draw(sheet)
selected={'geometry':0,'top_left':1,'bottom_right':2}
titles={'geometry':'几何结果 → 自动构图','top_left':'左上目标 → 左右对称留边','bottom_right':'右下目标 → 四边对称留边'}
records=[];total=0
for index,case in enumerate(cases):
    x,y,w,h=case['target']
    xy,wh,size,pos=case['roi']
    sx,sy=xy>>12,xy&4095;sw,sh=wh>>12,wh&4095
    dw,dh=size>>12,size&4095;dx,dy=pos>>12,pos&4095
    source=np.full((1080,1920),0xef7b,dtype=np.uint16)
    source[y:y+h,x:x+w]=0x8842
    source[y+3:y+h-3,x+3:x+w-3]=0xa25c
    actual=np.fromfile(out/f'render/center_{index}.raw',dtype='<u2')
    assert actual.size==dw*dh,(case['name'],actual.size,dw*dh)
    actual=actual.reshape(dh,dw)
    xs=sx+np.arange(dw,dtype=np.int64)*sw//dw
    ys=sy+np.arange(dh,dtype=np.int64)*sh//dh
    expected=source[np.ix_(ys,xs)]
    assert np.array_equal(actual,expected),case['name']
    scale=dw//sw
    assert dw==sw*scale and dh==sh*scale and not(dw&7)
    assert dx==1920-dx-dw and dy==1080-dy-dh
    error_x=dx+(x+w/2-sx)*scale-960;error_y=dy+(y+h/2-sy)*scale-540
    assert abs(error_x)<=4 and abs(error_y)<=4
    assert sx<=x and sy<=y and x+w<=sx+sw and y+h<=sy+sh
    canvas=np.zeros((1080,1920),dtype=np.uint16)
    canvas[dy:dy+dh,dx:dx+dw]=actual
    before=Image.fromarray(rgb(source));after=Image.fromarray(rgb(canvas))
    before.save(out/f"render/{case['name']}_before.png")
    after.save(out/f"render/{case['name']}_after.png")
    if case['name'] in selected:
        row=selected[case['name']];oy=row*416
        marked=before.copy();ImageDraw.Draw(marked).rectangle((sx,sy,sx+sw-1,sy+sh-1),outline='#ff9830',width=5)
        draw.text((12,oy+4),titles[case['name']]+'：左为源图与裁剪框，右为RTL缩放后定位',font=font,fill='#ffff80')
        sheet.paste(marked.resize((640,360)),(0,oy+48))
        sheet.paste(after.resize((640,360)),(672,oy+48))
    total+=actual.size
    records.append(dict(name=case['name'],pixels=int(actual.size),scale=scale,
                        source=[sx,sy,sw,sh],destination=[dx,dy,dw,dh],
                        center_error=[error_x,error_y],margins=[dx,1920-dx-dw,dy,1080-dy-dh],exact_pixels=True,
                        source_frame=case['frame'],render_config=case['config']))
sheet.save(out/'center_preview.png')
result=dict(passed=True,rtl_pixels=total,cases=records,
            scope='RV32I descriptor -> production AXI reader/scaler pixel replay; host canvas placement, synthetic targets, not camera recognition or HDMI acceptance')
(out/'render/result.json').write_text(json.dumps(result,indent=2))
print(f'PASS {len(cases)} production RV32I center descriptors, {total} actual RTL pixels, aspect ratio/center/whole target/symmetric margins')
