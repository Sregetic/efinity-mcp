"""USER1 DDR payload access for the tagged FlyHash mailbox ABI2."""
import struct,subprocess
from pathlib import Path
from load_vision_ddr import ROOT,IDE,configuration,tcl_path
RESULT=0x07620000;INPUT=0x07620100

def transfer(location,directory,features=None):
 directory=Path(directory);directory.mkdir(parents=True,exist_ok=True)
 body='halt\nwait_halt 5000\n'
 if features is not None:
  if len(features)!=64 or any(not 0<=v<=255 for v in features):raise ValueError('FlyHash requires64 uint8 features')
  src=directory/'input.bin';src.write_bytes(bytes(features))
  body+=f'load_image {tcl_path(src)} {INPUT:#x} bin\ndump_image {tcl_path(directory/"input_read.bin")} {INPUT:#x} 64\n'
 else:body+=f'dump_image {tcl_path(directory/"record.bin")} {RESULT:#x} 128\n'
 body+='resume\necho FLY_DDR_COMPLETE\nshutdown\n'
 sym=dict(__debug_work_start=0x07ff0000,__debug_work_limit=0x07ff1000)
 cfg=configuration(location,ROOT/'artifacts/vision_soc/cpu0.yaml',sym)+body
 path=directory/'memory.cfg';path.write_text(cfg,encoding='utf-8')
 r=subprocess.run([str(IDE/'openocd/bin/openocd.exe'),'-f',str(path.resolve())],capture_output=True,text=True,timeout=60)
 log=r.stdout+r.stderr;(directory/'memory.log').write_text(log,encoding='utf-8');r.check_returncode()
 if 'FLY_DDR_COMPLETE' not in log:raise RuntimeError('FlyHash DDR transfer did not complete')
 if features is not None:
  if (directory/'input_read.bin').read_bytes()!=bytes(features):raise RuntimeError('FlyHash DDR input mismatch')
  return None
 return decode_record((directory/'record.bin').read_bytes())

def decode_record(data):
 if len(data)!=128:raise ValueError('FlyHash record must contain128 bytes')
 magic,sequence,nonce,frame,config,epoch,errors,cycles=struct.unpack_from('<8I',data)
 if magic!=0x464c5932 or not sequence:raise RuntimeError('Incomplete FlyHash DDR record')
 return dict(record_sequence=sequence,nonce=nonce,frame_id=frame,config_id=config,epoch=epoch,
             stream_errors=errors,cycles=cycles,features=list(data[32:96]),hash=f'{int.from_bytes(data[96:128],"little"):064x}')
