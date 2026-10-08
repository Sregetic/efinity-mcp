"""RGB888 line snapshots from a frozen FPGA source; no HDMI capture device."""
import argparse
import json
import struct
import subprocess
import sys
import time
import zlib
from pathlib import Path

NAMES = {'source':'Source before Gamma', '0':'Camera color', '1':'Grayscale',
         '2':'Sobel', '3':'Gray / Sobel', '4':'Sobel overlay', '5':'Canny',
         '6':'Canny overlay', '7':'Recognition'}
ORDERS = [(0,1,2),(0,2,1),(2,1,0),(1,0,2),(1,2,0),(2,0,1)]

def check_frozen_source(context):
    # vision_control's ROI commit already observed a valid field. frame_ok
    # clears at every VS and can be0 in the subsequent multi-page status read.
    if not context['source_held'] or not context['source_frozen']:
        raise RuntimeError(f'Frozen RGB source was not acquired: {context}')
    if context['roi_frame_id']!=context['held_source_frame_id']:
        raise RuntimeError('Display/source lease mismatch')

def decode_snapshot(v):
    if v >> 160 != 0x56495331 or (v >> 128) & 0xffffffff not in [0x2610051a,0x2610051b]:
        raise RuntimeError(f'RGB snapshot firmware/header mismatch: {v:048x}')
    s=v & 0xffffffff
    return dict(ready=(s>>31)&1,busy=(s>>30)&1,error=(s>>29)&1,source=(s>>28)&1,
                mode=(s>>25)&7,threshold=(s>>14)&2047,median=(s>>13)&1,tone=(s>>11)&3,
                row=s&2047,sequence=(v>>32)&0xffffffff,config_id=(v>>64)&0xffffffff,
                frame_id=(v>>96)&0xffffffff)

def decode_caps(v):
    geometry=((v>>64)&0xffffffff,(v>>32)&0xffffffff,v&0xffffffff)
    if v>>160!=0x56495331 or (v>>128)&0xffffffff!=0x2610051c or geometry[:2]!=(1920,1080) or geometry[2] not in [0,24]:
        raise RuntimeError(f'RGB snapshot capability mismatch: {v:048x}')
    return geometry

def check_row(h,expected):
    if not h['ready'] or h['busy'] or h['error']:
        raise RuntimeError(f'Incomplete RGB line: {h}')
    for k,v in expected.items():
        if h[k]!=v:raise RuntimeError(f'RGB line {k} changed: {h[k]} != {v}')

def rgb_bytes(bgr,order):
    c=[bgr[2::3],bgr[1::3],bgr[0::3]]
    out=bytearray(len(bgr))
    for i,k in enumerate(ORDERS[order]):out[i::3]=c[k]
    return out

def write_png(path,width,height,rgb):
    if len(rgb)!=width*height*3:raise ValueError('RGB pixel extent mismatch')
    def chunk(kind,data):
        return struct.pack('>I',len(data))+kind+data+struct.pack('>I',zlib.crc32(kind+data))
    stride=width*3
    scan=b''.join(b'\0'+rgb[y*stride:(y+1)*stride] for y in range(height))
    path.write_bytes(b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',width,height,8,2,0,0,0))+
                     chunk(b'IDAT',zlib.compress(scan))+chunk(b'IEND',b''))

def main():
    # Vendor imports stay inside the hardware entry point; codecs test independently.
    from efx_pgm.ftdi_program import acquire_jtag_engine
    from efx_pgm.device_utils import DeviceUtils
    from pyftdi.bits import BitSequence
    p=argparse.ArgumentParser();p.add_argument('--url',required=True)
    p.add_argument('--output-dir',type=Path,required=True)
    p.add_argument('--sensor',choices=['sc431hai','sc2210'],default='sc431hai')
    p.add_argument('--modes',nargs='+',choices=list(NAMES),default=list(NAMES))
    p.add_argument('--frequency',type=int,default=6000000)
    p.add_argument('--source-native-order',action='store_true',help='Keep packed-frame channels for analysis DMA training; display exports stay unchanged')
    p.add_argument('--current-view',action='store_true',help='Capture an already frozen view without changing its render configuration')
    p.add_argument('--rows',nargs=2,type=int,default=[0,1080],metavar=('Y','HEIGHT'))
    a=p.parse_args();y0,height=a.rows
    if y0<0 or height<1 or y0+height>1080:raise ValueError('Rows must fit1080-line canvas')
    if len(set(a.modes))!=len(a.modes):raise ValueError('Each mode is captured once')
    control_path=Path(__file__).with_name('vision_control.py')
    def control(args):
        r=subprocess.run([sys.executable,str(control_path),'--url',a.url,'--sensor',a.sensor,
                          '--roi-status',*args],check=True,capture_output=True,text=True)
        return json.loads(r.stdout)
    def command(e,op,value=0):
        e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2'])
        e.write_dr(BitSequence((0x56495331<<32)|(op<<24)|value,length=192));e.go_idle()
    def read(e,length=192):
        e.write_ir(DeviceUtils.EFX_TI_INSTR['USER2'])
        # Vendor read() splits its512-byte pipe while staying in SHIFT_DR.
        # read_dr() sends one packet and is limited to the pipe size.
        e.change_state('shift_dr');v=e.read(length,first=True,last=True)
        e.change_state('update_dr');e.go_idle();return v
    def page(e,n):
        command(e,126,n);return int(read(e))
    with acquire_jtag_engine(a.frequency,a.url) as e:
        e.reset();width,canvas_height,bits=decode_caps(page(e,28))
        if bits==0:raise RuntimeError('RGB snapshots disabled in this build')
    before=control([]);a.output_dir.mkdir(parents=True,exist_ok=True)
    (a.output_dir/'before.json').write_text(json.dumps(before,indent=2),encoding='utf-8')
    result=dict(width=width,height=height,canvas_height=canvas_height,y=y0,format='RGB888',
                method='FPGA line RAM / bulk USER2; no HDMI capture card',images=[])
    restore=['--roi',*map(str,before['roi']),'--output-size',*map(str,before['output_size']),
             '--position',*map(str,before['position']),'--roi-enable',str(before['roi_enabled']),
             '--memory',str(before['memory']),'--mode',str(before['mode'])]
    try:
        context=before if a.current_view else control(['--roi','0','0','1920','1080','--output-size','1920','1080',
                         '--position','0','0','--roi-enable','1','--memory','1'])
        check_frozen_source(context)
        frame=context['roi_frame_id'];config=context['applied_config_id']
        result['context']=context
        with acquire_jtag_engine(a.frequency,a.url) as e:
            e.reset()
            # Local PyFTDI endpoint: avoid16ms waits on the tail of each512-byte packet.
            ftdi=e._engine_provider._ctrl._ftdi
            old_latency=ftdi.get_latency_timer();ftdi.set_latency_timer(1)
            result['usb_latency_ms']=dict(before=old_latency,during=1)
            try:
                command(e,0x26,0)
                if any(m in a.modes for m in ['5','6']):
                    deadline=time.monotonic()+10
                    while not (page(e,17)>>125)&1:
                        if time.monotonic()>deadline:raise TimeoutError('Canny result pending')
                        time.sleep(.01)
                command(e,0x26,1);time.sleep(.03)
                result['canny_epoch']=page(e,16)&0xffffffff
                color_order=(page(e,3)>>76)&7
                tone=page(e,8)&3
                current_mode=context['mode']
                for m in a.modes:
                    if m!='source':
                        command(e,1,int(m));deadline=time.monotonic()+1
                        while (page(e,0)>>117)&7!=int(m):
                            if time.monotonic()>deadline:raise TimeoutError('Display mode commit pending')
                            time.sleep(.001)
                        current_mode=int(m)
                    selected_threshold=(page(e,0)>>100)&2047
                    # Classifier/OSD settle on this fixed source before the first row.
                    time.sleep(.08);start=time.monotonic();rgb=bytearray();first_sequence=None
                    for y in range(y0,y0+height):
                        previous=decode_snapshot(page(e,26))['sequence']
                        sequence=(previous+1)&0xffffffff
                        command(e,0x40,((m=='source')<<11)|y)
                        deadline=time.monotonic()+1
                        while True:
                            h=decode_snapshot(int(read(e)))
                            if h['sequence']==sequence:break
                            if time.monotonic()>deadline:raise TimeoutError(f'RGB row{y} pending: {h}')
                            time.sleep(.001)
                        expected=dict(source=int(m=='source'),row=y,sequence=sequence,mode=current_mode,
                                      threshold=selected_threshold,median=context['median'],tone=tone,
                                      frame_id=frame,config_id=config)
                        check_row(h,expected)
                        command(e,126,27)
                        packed=read(e,192+width*24).tobytes(msby=True)
                        check_row(decode_snapshot(int.from_bytes(packed[:24],'little')),expected)
                        rgb.extend(rgb_bytes(packed[24:],color_order if m=='source' and not a.source_native_order else 0))
                        if first_sequence is None:first_sequence=sequence
                        if (y-y0+1)%90==0:print(f'{NAMES[m]} rows{y-y0+1}/{height}',flush=True)
                    filename='source.png' if m=='source' else f'mode_{m}.png'
                    write_png(a.output_dir/filename,width,height,rgb)
                    info=dict(mode=m,name=NAMES[m],file=filename,frame_id=frame,config_id=config,
                              canny_epoch=result['canny_epoch'],threshold=selected_threshold,median=context['median'],
                              tone=tone,color_order=0 if m=='source' and a.source_native_order else color_order,sequence_first=first_sequence,sequence_last=sequence,
                              seconds=time.monotonic()-start,width=width,height=height,y=y0)
                    result['images'].append(info)
                    (a.output_dir/'images.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
                    print(f'Saved {filename}: {width}x{height}, source{frame}, {info["seconds"]:.2f}s',flush=True)
                if page(e,16)&0xffffffff!=result['canny_epoch']:raise RuntimeError('Held Canny plane changed')
            finally:
                command(e,0x26,0);command(e,126,0);ftdi.set_latency_timer(old_latency)
        after=control([])
        if after['roi_frame_id']!=frame or after['applied_config_id']!=config:
            raise RuntimeError('Frozen source/config changed during image export')
        # Persistent scanout counters expose even an underrun that has recovered.
        if after['scan_bad_frames']!=context['scan_bad_frames'] or after['scan_error'] or after['render_error']:
            raise RuntimeError(f'ROI scan/render fault during image export: {after}')
        result['passed']=True
        (a.output_dir/'images.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
    finally:
        result['restored']=control(['--mode',str(before['mode'])] if a.current_view else restore)
        (a.output_dir/'restore.json').write_text(json.dumps(result['restored'],indent=2),encoding='utf-8')

if __name__=='__main__':main()
