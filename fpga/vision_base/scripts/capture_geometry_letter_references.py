"""Calibrate reference outlines through the unchanged production RTL Canny pipeline."""
import json
import argparse
import subprocess
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFont
from generate_geometry_letters import FONTS, CHARS
from test_geometry_letters_native import wsl

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'results/geometry_letters_20261028/native_references'
BINARY=ROOT/'results/geometry_letters_20261028/native/obj/Vtb'


def crop(mask, x, y, w, h):
    sx,sy=x//4,y//4
    local=mask[sy:(y+h+3)//4,sx:(x+w+3)//4]
    yy,xx=np.where(local)
    assert len(xx), 'Reference glyph disappeared in accepted Canny bits'
    return local[yy.min():yy.max()+1,xx.min():xx.max()+1],int(sy+yy.max()),[int(sx+xx.min()),int(sy+yy.min()),int(sx+xx.max()),int(sy+yy.max())]


def main():
    global OUT
    p=argparse.ArgumentParser();p.add_argument('--kind',choices=['reference','large','validation'],default='reference');args=p.parse_args()
    sizes={'reference':(192,256,320),'large':(384,512),'validation':(400,480)}[args.kind]
    if args.kind!='reference':OUT=ROOT/('results/geometry_letters_20261028/native_'+args.kind)
    OUT.mkdir(exist_ok=True)
    refs=[]
    for fi,font in enumerate(FONTS):
        for size in sizes:
            f=ImageFont.truetype('C:/Windows/Fonts/'+font,size)
            bounds=[f.getbbox(c) for c in CHARS]
            top=min(b[1] for b in bounds)
            cw=max(b[2]-min(0,b[0]) for b in bounds)+24
            ch=max(b[3] for b in bounds)-top+24
            cols=(1920-96)//cw;rows=(1080-96)//ch
            per=(cols-1)*rows
            for page,start in enumerate(range(0,52,per)):
                name=f'f{fi}_{size}_{page}';prefix=OUT/name
                im=Image.new('L',(1920,1080),255);draw=ImageDraw.Draw(im);items=[]
                for n,c in enumerate(CHARS[start:start+per]):
                    row,col=divmod(n,cols-1);col+=1
                    xy=(48+col*cw+12-min(0,f.getbbox(c)[0]),48+row*ch+12-top)
                    bounds=draw.textbbox(xy,c,font=f);assert bounds[0]>=0 and bounds[1]>=0 and bounds[2]<1920 and bounds[3]<1080,bounds
                    draw.text(xy,c,font=f,fill=0)
                    items.append((c,row,col))
                for row in range(rows):draw.text((60,48+row*ch+12-top),'H',font=f,fill=0)
                im.save(prefix.with_suffix('.png'))
                mem=prefix.with_suffix('.mem');mem.write_text('\n'.join(f'{v:02x}' for v in im.tobytes())+'\n')
                r=subprocess.run(['wsl.exe','-d','Ubuntu-24.04','--cd',wsl(ROOT/'board/ti60f225_v4'),'--exec',wsl(BINARY),
                                  '+image='+wsl(mem),'+output='+wsl(prefix)],capture_output=True,timeout=180)
                prefix.with_suffix('.log').write_bytes(r.stdout+r.stderr);r.check_returncode()
                assert b'PASS native Canny' in r.stdout
                words=np.array([int(v,16) for v in Path(str(prefix)+'_bitmap.mem').read_text().split()],dtype='<u4')
                mask=np.unpackbits(words.view(np.uint8),bitorder='little').reshape(270,480)
                Image.fromarray((mask*255).astype(np.uint8)).save(Path(str(prefix)+'_edges.png'))
                for c,row,col in items:
                    e,bottom,box=crop(mask,48+col*cw,48+row*ch,cw,ch)
                    anchor,base,_=crop(mask,48,48+row*ch,cw,ch)
                    refs.append(dict(font=font,size=size,char=c,width=e.shape[1],height=e.shape[0],
                                     cap_height=e.shape[0]*100//anchor.shape[0],baseline=(bottom-base)*100//anchor.shape[0],
                                     box=box,packed=np.packbits(e,bitorder='little').tobytes().hex(),source=name))
                mem.unlink()
                print(name,'references',len(refs),flush=True)
    assert len(refs)==52*len(FONTS)*len(sizes)
    (OUT/'references.json').write_text(json.dumps(refs,indent=2),encoding='utf-8')
    print(f'PASS {len(refs)} actual RTL accepted-edge captures; no Canny source changes.')


if __name__=='__main__':main()
