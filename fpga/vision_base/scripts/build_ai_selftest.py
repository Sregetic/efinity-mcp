"""Weight-free references for shared features, FlyHash and the fixed connectome circuit."""
import argparse,sys
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'models'))
from shape_cards import features
from connectome import fixed
from flyhash import encode

def generate(output):
    x=np.arange(1024).reshape(32,32)
    gray=[np.zeros((32,32),np.uint8),(x%256).astype(np.uint8),(((x//32+x%32)%2)*255).astype(np.uint8)]
    f=[features(g) for g in gray]
    hashes=[[encode((v[64:].astype(np.int16)+128).tolist())>>(32*i)&0xffffffff for i in range(8)] for v in f]
    def array(name,kind,rows):
        return f'static const {kind} {name}[3][{len(rows[0])}]={{'+','.join('{'+','.join(str(int(v)) for v in row)+'}' for row in rows)+'};\n'
    text='#pragma once\n/* Generated from fixed shared-feature and circuit inputs; no classifier weights. */\n'
    for name,kind,rows in [('selftest_features','int8_t',f),('selftest_hash','uint32_t',hashes),('selftest_neurons','int16_t',[fixed(v) for v in f])]:
        text+=array(name,kind,rows)
    output.write_text(text)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
