"""Compare one actual CPU/DMA record against the trained integer host reference."""
import argparse,json,struct,sys
from pathlib import Path
import numpy as np
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'models'))
from shape_cards import features,dense,CLASSES
from flyhash import encode

def verify(directory,weights):
    record=json.loads((directory/'result.json').read_text())
    blob=weights.read_bytes();magic,iz,hz,oz,m0,s0,m1,s1=struct.unpack_from('<I7i',blob)
    assert magic==0x53434d31 and len(blob)==4400,'Model blob contract'
    b0=np.frombuffer(blob,dtype='<i4',count=32,offset=32)
    b1=np.frombuffer(blob,dtype='<i4',count=4,offset=160)
    w0=np.frombuffer(blob,dtype=np.int8,count=4096,offset=176).reshape(32,128)
    w1=np.frombuffer(blob,dtype=np.int8,count=128,offset=4272).reshape(4,32)
    gray=np.frombuffer((directory/'gray.bin').read_bytes(),dtype=np.uint8).reshape(32,32)
    assert int(gray.sum())==record['gray_sum'],'CPU gray tensor/readback mismatch'
    x=features(gray);h=dense(x,w0,b0,iz,hz,m0,s0,True);o=dense(h,w1,b1,hz,oz,m1,s1)
    for name,value in [('features',x),('hidden',h),('logits',o)]:
        assert np.array_equal(value,record[name]),name+' mismatch against host reference'
    tag=encode((x[64:].astype(np.int16)+128).tolist())
    assert int(record['hash'],16)==tag,'FlyHash mismatch against host reference'
    assert record['class_id']==int(o.argmax()) and record['dma_errors']==0,'Label or DMA errors'
    result=dict(passed=True,sequence=record['sequence'],frame_id=record['frame_id'],
        source_config_id=record['source_config_id'],model_id=record['model_id'],roi=record['roi'],
        class_name=CLASSES[record['class_id']],gray_pixels=1024,features=128,hidden=32,logits=4,
        flyhash_bits=256,training_kind='synthetic_bringup_only',real_card_accuracy_verified=False,
        dma_microseconds=record['dma_cycles']*1e6/record['clock_hz'],
        network_microseconds=(record['layer0_cycles']+record['layer1_cycles'])*1e6/record['clock_hz'],
        total_cpu_microseconds=record['total_cpu_cycles']*1e6/record['clock_hz'])
    (directory/'validation.json').write_text(json.dumps(result,indent=2));return result

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--directory',type=Path,required=True)
    p.add_argument('--weights',type=Path,required=True);a=p.parse_args()
    print(json.dumps(verify(a.directory,a.weights),indent=2))
