"""Feed saved FPGA grayscale readbacks into production A6 RTL, compare host math."""
import argparse, json, subprocess, sys
from pathlib import Path
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'models'))
from shape_outline import classify
p=argparse.ArgumentParser();p.add_argument('images',nargs='+',type=Path);p.add_argument('--output-dir',required=True,type=Path)
p.add_argument('--threshold',type=int,choices=range(1,256),default=32)
p.add_argument('--input-kind',choices=['camera_readback','synthetic'],default='camera_readback');a=p.parse_args()
a.output_dir.mkdir(parents=True,exist_ok=True);exe=a.output_dir/'shape_readback.vvp'
subprocess.run(['C:/iverilog/bin/iverilog.exe','-g2012','-s','tb','-o',str(exe),str(ROOT/'sim/vision/tb_shape_readback.sv'),str(ROOT/'board/ti60f225_v4/rtl/vision/vision_shape_classifier.sv')],check=True)
rows=[]
try:
    for i,path in enumerate(a.images):
        gray=np.asarray(Image.open(path).convert('L'));expected=classify(gray,[640,300,640,480],threshold=a.threshold)
        mem=a.output_dir/f'readback_{i}.mem'
        mem.write_text(''.join(f'{v:02x}\n' for v in gray[300:780,640:1280].ravel()),encoding='ascii')
        try:
            r=subprocess.run(['C:/iverilog/bin/vvp.exe',str(exe),f'+image={mem.resolve().as_posix()}',f'+kind={expected["class_id"]}',f'+flags={expected["reject_flags"]}',f'+background={expected["background"]}',f'+threshold={a.threshold}'],check=True,capture_output=True,text=True)
            (a.output_dir/f'readback_{i}.log').write_text(r.stdout+r.stderr,encoding='utf-8');print(r.stdout.strip())
            rows.append(dict(image=path.resolve().as_posix(),input_kind=a.input_kind,threshold=a.threshold,host_rtl_equal=True,**expected))
        finally:
            mem.unlink()
finally:
    exe.unlink()
(a.output_dir/'result.json').write_text(json.dumps(dict(passed=True,scope='Production A6 host/RTL parity; input kind explicit; physical card acceptance remains separate',cases=rows),indent=2),encoding='utf-8')
