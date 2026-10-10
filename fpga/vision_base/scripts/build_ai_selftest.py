"""Reference fixtures for the installed weights and the fixed connectome circuit."""
import argparse,struct,sys
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'models'))
from shape_cards import features,dense
from connectome import fixed
from flyhash import encode

def generate(weights,output):
    data=weights.read_bytes()
    magic,iz,hz,oz,m0,s0,m1,s1=struct.unpack_from('<I7i',data)
    assert magic==0x53434d31 and len(data)==4400
    b0=np.frombuffer(data,'<i4',32,32);b1=np.frombuffer(data,'<i4',4,160)
    w0=np.frombuffer(data,np.int8,4096,176).reshape(32,128)
    w1=np.frombuffer(data,np.int8,128,4272).reshape(4,32)
    x=np.arange(1024).reshape(32,32)
    gray=[np.zeros((32,32),np.uint8),(x%256).astype(np.uint8),(((x//32+x%32)%2)*255).astype(np.uint8)]
    f=[features(g) for g in gray]
    hidden=[dense(v,w0,b0,iz,hz,m0,s0,True) for v in f]
    logits=[dense(h,w1,b1,hz,oz,m1,s1) for h in hidden]
    hashes=[[encode((v[64:].astype(np.int16)+128).tolist())>>(32*i)&0xffffffff for i in range(8)] for v in f]
    def array(name,kind,rows):
        return f'static const {kind} {name}[3][{len(rows[0])}]={{'+','.join('{'+','.join(str(int(v)) for v in row)+'}' for row in rows)+'};\n'
    text='#pragma once\n/* Generated from the deployed weight bytes; regenerate when weights change. */\n'
    for name,kind,rows in [('selftest_features','int8_t',f),('selftest_hidden','int8_t',hidden),('selftest_logits','int8_t',logits),('selftest_hash','uint32_t',hashes),('selftest_neurons','int16_t',[fixed(v) for v in f])]:
        text+=array(name,kind,rows)
    output.write_text(text)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--weights',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.weights,a.output)
