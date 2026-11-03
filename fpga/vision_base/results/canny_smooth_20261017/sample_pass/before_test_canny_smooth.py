"""Geometry checks on quantized slopes and an optional real accepted Canny plane."""
import argparse,json
from pathlib import Path
import numpy as np
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]

def neighborhoods(bitmap):
    h,w=bitmap.shape;p=np.pad(bitmap,1);index=np.zeros((h,w),dtype=np.uint16)
    for y in range(3):
        for x in range(3):index|=p[y:y+h,x:x+w].astype(np.uint16)<<(8-y*3-x)
    return index

def expand(table,bitmap):
    h,w=bitmap.shape
    return table[neighborhoods(bitmap)].reshape(h,w,4,4).transpose(0,2,1,3).reshape(h*4,w*4)

def old_table():
    table=np.zeros((512,16),dtype=np.uint8)
    for bits in range(512):
        nw,n,ne,w,c,e,sw,s,se=[bool(bits&(1<<(8-i)))for i in range(9)]
        for y in range(4):
            for x in range(4):
                core=c and (x==y==2 or y==2 and(w and x<=2 or e and x>=2)
                    or x==2 and(n and y<=2 or s and y>=2)
                    or x==y and(nw and x<=2 or se and x>=2)
                    or x+y==4 and(ne and x>=2 or sw and x<=2)) or n and w and x==y==0
                halo=c and (abs(x-y)==1 and(nw and x<=2 and y<=2 or se and x>=2 and y>=2)
                    or x+y in(3,5)and(ne and x>=2 and y<=2 or sw and x<=2 and y>=2))or n and w and x+y==1
                table[bits,y*4+x]=255 if core else 64 if halo else 0
    return table

def load_table():
    data=[int(v,16)for v in(ROOT/'board/ti60f225_v4/rtl/vision/canny_coverage_q5.mem').read_text().split()]
    levels=np.array([[(word>>(i*5))&31 for i in range(16)]for word in data],dtype=np.uint8)
    return (levels<<3)|(levels>>2)

def model(bitmap,x,y,horizontal,origin,radius=4):
    minor=[origin,origin];total=origin;weighted=0
    for k in range(1,radius+1):
        for side,direction in enumerate((-1,1)):
            found=False
            for candidate in(minor[side],minor[side]-1,minor[side]+1,minor[side]-2,minor[side]+2):
                if abs(candidate)>5:continue
                xx,yy=(x+direction*k,y+candidate)if horizontal else(x+candidate,y+direction*k)
                if 0<=yy<bitmap.shape[0]and 0<=xx<bitmap.shape[1]and bitmap[yy,xx]:minor[side]=candidate;found=True;break
            if not found:return None
        total+=sum(minor);weighted+=k*(minor[1]-minor[0])
    if abs(total-(2*radius+1)*origin)>(9 if radius==4 else 5):return None
    if radius==2 and abs(weighted)>18:return None
    slope=(weighted*17+32)>>6 if radius==4 else (weighted*13+4)>>3
    center=32+((total*57+4)>>3)if radius==4 else 32+((total*51+2)>>2)
    return center-2*slope,slope,abs(weighted)

def fitted(bitmap,table):
    image=expand(table,bitmap);indices=neighborhoods(bitmap);h,w=bitmap.shape
    for y in range(2,h-2):
        for x in range(2,w-2):
            bits=int(indices[y,x]);nw,n,ne,left,c,right,sw,s,se=[bool(bits&(1<<(8-i)))for i in range(9)]
            short_n=n and not(nw or ne or bitmap[y-2,x-1:x+2].any())
            short_s=s and not(sw or se or bitmap[y+2,x-1:x+2].any())
            short_w=left and not(nw or sw or bitmap[y-1:y+2,x-2].any())
            short_e=right and not(ne or se or bitmap[y-1:y+2,x+2].any())
            junction=c and(n and s and(left and not short_w and not(nw and sw)or right and not short_e and not(ne and se))
                or left and right and(n and not short_n and not(nw and ne)or s and not short_s and not(sw and se)))
            if junction or bits in (0b111010000,0b000010111,0b100110100,0b001011001):continue
            for radius in (4,2):
                candidates=[]
                for horizontal,origin in [(True,0 if c else -1 if n else 1),
                                          (False,0 if c else -1 if left else 1)]:
                    eligible=(c or(horizontal and(n or s))or(not horizontal and(left or right)))and not(
                        c and(n and s and not(left or right)if horizontal else left and right and not(n or s)))
                    if eligible:
                        fit=model(bitmap,x,y,horizontal,origin,radius)
                        if fit is not None:candidates.append((*fit,horizontal))
                if candidates:break
            if not candidates:continue
            start,slope,_,horizontal=min(candidates,key=lambda fit:fit[2])
            yy,xx=np.indices((4,4));major,small=(xx,yy)if horizontal else(yy,xx)
            distance=np.abs((small<<4)-(start+major*slope))
            image[y*4:y*4+4,x*4:x*4+4]=np.where(distance<16,255-distance*16,0)
    return image

def line_metrics(image,slope,transpose=False):
    a=image.T if transpose else image;y=np.arange(a.shape[0])[:,None]
    centers=(a*y).sum(axis=0)/np.maximum(a.sum(axis=0),1)
    u=np.arange(a.shape[1]);inside=(u>=56)&(u<a.shape[1]-24)&(centers>=56)&(centers<a.shape[0]-24)
    first,last=np.flatnonzero(inside)[[0,-1]];u=u[first:last+1];centers=centers[first:last+1]
    error=centers-(slope*(u-(32*4+2))+24*4+2)
    return float(np.sqrt(np.mean(np.diff(centers,2)**2))),float(np.max(np.abs(error-error.mean())))

def components(image):
    points=set(zip(*np.where(image>0)));count=0
    while points:
        count+=1;queue=[points.pop()]
        for y,x in queue:
            for dy in(-1,0,1):
                for dx in(-1,0,1):
                    q=(y+dy,x+dx)
                    if q in points:points.remove(q);queue.append(q)
    return count

def main():
    p=argparse.ArgumentParser();p.add_argument('--output-dir',type=Path,default=ROOT/'results/canny_raster_geometry')
    p.add_argument('--bitmap',type=Path);a=p.parse_args();a.output_dir.mkdir(parents=True,exist_ok=True)
    old,new=old_table(),load_table();report={'slopes':[]}
    for slope in(1/6,1/3,1/2,2/3,1.,-1/6,-1/3,-1/2,-2/3,-1.):
        for transpose in(False,True):
            yy,xx=np.indices((48,64));line=yy==np.floor(slope*(xx-32)+24+.5)
            before,after=expand(old,line),fitted(line,new)
            if transpose:before,after=before.T,after.T
            r0,e0=line_metrics(before,slope,transpose);r1,e1=line_metrics(after,slope,transpose)
            report['slopes'].append({'slope':slope,'transposed':transpose,'old_roughness':r0,'new_roughness':r1,
                'old_peak_deviation_pixels':e0,'new_peak_deviation_pixels':e1})
            if slope in(1/3,1/2)and not transpose:
                Image.fromarray(before).save(a.output_dir/f'slope_{slope:.3f}_before.png')
                Image.fromarray(after).save(a.output_dir/f'slope_{slope:.3f}_after.png')
            assert components(after)==1,(slope,transpose,'disconnected contour')
            assert e1<.75,(slope,'coarse-grid displacement',e1)
            assert r1<r0*.8 if r0>.01 else r1<.01,(slope,r0,r1)
    yy,xx=np.indices((24,24))
    for name,line in [('cross',(xx==12)|(yy==12)),('corner',(xx==12)&(yy<=12)|(yy==12)&(xx>=12)),('empty',np.zeros((24,24),dtype=bool))]:
        rendered=fitted(line,new);assert components(rendered)==(name!='empty'),name
    yy,xx=np.indices((64,96));finite=0
    for slope in(1/6,1/3,.5,2/3,-1/6,-1/3,-.5,-2/3):
        for phase in range(6):
            line=(yy==np.floor(slope*(xx-48)+32+phase/6+.5))&(xx>=23)&(xx<73)
            assert components(fitted(line,new))==1,(slope,phase,'endpoint transition split');finite+=1
    shapes={'rectangle':(((xx==28)|(xx==68))&(yy>=20)&(yy<=48))|(((yy==20)|(yy==48))&(xx>=28)&(xx<=68)),
        'circle':abs(np.sqrt((xx-48)**2+(yy-32)**2)-18)<.6,
        'T':((xx==48)&(yy>=12)&(yy<=52))|((yy==32)&(xx>=48)&(xx<78))}
    for name,line in shapes.items():assert components(fitted(line,new))==1,name
    report.update(finite_endpoint_cases=finite,closed_and_junction_shapes=list(shapes))
    # Camera-derived turn: the former13-pixel flat and one-cell spur must stay gone.
    corner=['...............#.....','..............##.....','..............#......',
        '.............##.....#','.............#......#','##..........##.....##',
        '.###........#......#.','...###.....##.....##.','.....###...#......#..',
        '.......#####.....##..','..........#......#...','#...............##...',
        '.##.............#....','...#...........##....','....##.........#.....',
        '......##......##.....','........##....#......','..........#..........',
        '.......#...##........']
    line=np.zeros((64,96),dtype=bool)
    line[20:39,30:51]=[[v=='#'for v in row]for row in corner]
    rendered=fitted(line,new);longest=0
    for row in rendered[108:128,148:172]:
        xs=np.flatnonzero(row==255)
        longest=max(longest,max([0]+[len(g)for g in np.split(xs,np.where(np.diff(xs)>1)[0]+1)]))
    spur=int(rendered[120:124,160:164].sum())
    assert longest<=2 and spur==0,('coarse corner step/spur',longest,spur)
    report.update(corner_maximum_full_white_flat=longest,corner_spur_sum=spur)
    Image.fromarray(rendered).save(a.output_dir/'corner_fixture.png')
    if a.bitmap:
        bitmap=np.asarray(Image.open(a.bitmap))!=0
        Image.fromarray(expand(old,bitmap)).save(a.output_dir/'real_before.png')
        Image.fromarray(fitted(bitmap,new)).save(a.output_dir/'real_after.png')
    report['passed']=True
    (a.output_dir/'geometry.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
    print(json.dumps(report,indent=2))

if __name__=='__main__':main()
