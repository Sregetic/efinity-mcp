"""Train/quantize the fixed card MLP; synthetic bring-up never counts as real accuracy."""
import argparse,json,math,struct,sys
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'models'))
from shape_cards import CLASSES,gray_roi,features,dense

def synthetic(seed,count):
    rng=np.random.default_rng(seed);images=[];labels=[]
    for label in range(4):
        for _ in range(count):
            bg=int(rng.integers(190,255));fg=int(rng.integers(5,90));img=Image.new('L',(32,32),bg);d=ImageDraw.Draw(img)
            x,y=int(rng.integers(4,8)),int(rng.integers(4,8));r=int(rng.integers(19,27));bottom=int(rng.integers(20,28))
            if label==1:d.ellipse((x,y,r,bottom),outline=fg,width=int(rng.integers(2,4)))
            elif label==2:d.rectangle((x,y,r,bottom),outline=fg,width=int(rng.integers(2,4)))
            elif label==3:d.polygon(((16,y),(r,bottom),(x,bottom)),outline=fg,width=int(rng.integers(2,4)))
            g=np.clip(np.asarray(img,dtype=np.int16)+rng.integers(-3,4,(32,32)),0,255).astype(np.uint8)
            images.append(g);labels.append(label)
    return np.array(images),np.array(labels)

def samples(manifest):
    records=[json.loads(s) for s in manifest.read_text(encoding='utf-8').splitlines() if s.strip()]
    groups={};images={s:[] for s in ['train','test']};labels={s:[] for s in images}
    for r in records:
        split=r['split'];label=CLASSES.index(r['label']);card=r['card_id'];session=r['session_id']
        if split not in images or r['kind']!='real_camera':raise ValueError('Real training requires explicitly collected train/test camera records')
        for group in ['card:'+card,'session:'+session]:
            if group in groups and groups[group]!=split:raise ValueError('Train/test card or capture session leakage: '+group)
            groups[group]=split
        with Image.open(r['image']) as img:images[split].append(gray_roi(img,r['roi']))
        labels[split].append(label)
    if any(set(labels[s])!=set(range(4)) for s in images):raise ValueError('Both independently collected splits need all four classes')
    return {s:(np.array(images[s]),np.array(labels[s])) for s in images}

def multiplier(scale):
    fraction,shift=math.frexp(float(scale));q=int(np.floor(fraction*(1<<31)+.5))
    if q==(1<<31):q>>=1;shift+=1
    return q,shift

def array(name,dtype,data):
    a=np.asarray(data)
    dims=''.join(f'[{d}]' for d in a.shape)
    def init(v):return '{'+','.join(init(x) if np.ndim(x) else str(int(x)) for x in v)+'}'
    return f'static const {dtype} {name}{dims}={init(a)};\n'

def main():
    p=argparse.ArgumentParser();g=p.add_mutually_exclusive_group(required=True)
    g.add_argument('--manifest',type=Path);g.add_argument('--synthetic-bringup',action='store_true')
    p.add_argument('--output-dir',type=Path,required=True);p.add_argument('--epochs',type=int,default=100);a=p.parse_args()
    import tensorflow as tf
    tf.config.threading.set_intra_op_parallelism_threads(2);tf.config.threading.set_inter_op_parallelism_threads(2)
    tf.keras.utils.set_random_seed(2210);a.output_dir.mkdir(parents=True,exist_ok=True)
    dataset=samples(a.manifest) if a.manifest else {'train':synthetic(2210,100),'test':synthetic(107,40)}
    train_gray,y=dataset['train'];test_gray,yt=dataset['test']
    qtrain=np.array([features(g) for g in train_gray]);qtest=np.array([features(g) for g in test_gray])
    x=qtrain.astype(np.float32)/128.;xt=qtest.astype(np.float32)/128.
    model=tf.keras.Sequential([tf.keras.Input(shape=(128,)),tf.keras.layers.Dense(32,activation='relu'),tf.keras.layers.Dense(4)])
    model.compile(optimizer=tf.keras.optimizers.Adam(.01),loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True))
    rng=np.random.default_rng(2210)
    for epoch in range(a.epochs):
        for indices in np.array_split(rng.permutation(len(x)),math.ceil(len(x)/64)):model.train_on_batch(x[indices],y[indices])
        if (epoch+1)%25==0:print('trained epochs',epoch+1,flush=True)
    converter=tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations=[tf.lite.Optimize.DEFAULT]
    def representative():
        for row in x:yield [row.reshape(1,128)]
        # Known feature-domain endpoints, calibration only, not labelled examples.
        yield [np.full((1,128),-1.,np.float32)];yield [np.full((1,128),127/128,np.float32)]
    converter.representative_dataset=representative
    converter.target_spec.supported_ops=[tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
    converter.inference_input_type=tf.int8;converter.inference_output_type=tf.int8
    converter._experimental_disable_per_channel_quantization_for_dense_layers=True
    binary=converter.convert();path=a.output_dir/'shape_cards.tflite';path.write_bytes(binary)
    interpreter=tf.lite.Interpreter(model_content=binary,experimental_preserve_all_tensors=True,
        experimental_op_resolver_type=tf.lite.experimental.OpResolverType.BUILTIN_REF)
    interpreter.allocate_tensors();details={d['index']:d for d in interpreter.get_tensor_details()}
    ops=interpreter._get_ops_details();assert [o['op_name'] for o in ops]==['FULLY_CONNECTED','FULLY_CONNECTED'],ops
    input_id=interpreter.get_input_details()[0]['index'];output_id=interpreter.get_output_details()[0]['index']
    assert details[input_id]['quantization']==(1/128.,0),details[input_id]
    layers=[]
    for op in ops:
        inp,w,b=map(int,op['inputs']);out=int(op['outputs'][0]);di,dw,do=details[inp],details[w],details[out]
        assert len(dw['quantization_parameters']['scales'])==1,'The firmware contract is per-tensor FC quantization'
        m,s=multiplier(di['quantization'][0]*dw['quantization'][0]/do['quantization'][0])
        layers.append(dict(weights=interpreter.get_tensor(w),bias=interpreter.get_tensor(b),input_zero=di['quantization'][1],output_zero=do['quantization'][1],multiplier=m,shift=s,output_id=out))
    assert layers[0]['weights'].shape==(32,128) and layers[1]['weights'].shape==(4,32)
    fixture_indices=np.concatenate([np.flatnonzero(yt==label)[:4] for label in range(4)])
    fixture=np.vstack([qtest[fixture_indices],np.random.default_rng(39).integers(-128,128,(16,128),dtype=np.int8)])
    hidden=[];outputs=[]
    for row in np.vstack([qtest,fixture]):
        interpreter.set_tensor(input_id,row.reshape(1,128));interpreter.invoke()
        h=dense(row,layers[0]['weights'],layers[0]['bias'],layers[0]['input_zero'],layers[0]['output_zero'],layers[0]['multiplier'],layers[0]['shift'],True)
        o=dense(h,layers[1]['weights'],layers[1]['bias'],layers[1]['input_zero'],layers[1]['output_zero'],layers[1]['multiplier'],layers[1]['shift'])
        assert np.array_equal(h,interpreter.get_tensor(layers[0]['output_id'])[0]),'First layer fixed-point mismatch'
        assert np.array_equal(o,interpreter.get_tensor(output_id)[0]),'Second layer fixed-point mismatch'
        hidden.append(h);outputs.append(o)
    quant_score=float(np.mean(np.argmax(outputs[:len(qtest)],axis=1)==yt))
    l0,l1=layers
    header=struct.pack('<I7i',0x53434d31,l0['input_zero'],l0['output_zero'],l1['output_zero'],l0['multiplier'],l0['shift'],l1['multiplier'],l1['shift'])
    blob=header+l0['bias'].astype('<i4').tobytes()+l1['bias'].astype('<i4').tobytes()+l0['weights'].tobytes()+l1['weights'].tobytes()
    (a.output_dir/'shape_cards_weights.bin').write_bytes(blob)
    fixture_gray=np.array([test_gray[np.flatnonzero(yt==label)[0]] for label in range(4)])
    fixture_features=np.array([features(g) for g in fixture_gray])
    from flyhash import encode
    hashes=np.array([[(encode((f[64:].astype(np.int16)+128).tolist())>>(32*i))&0xffffffff for i in range(8)] for f in fixture_features],dtype=np.uint32)
    source='#include "shape_model.h"\n#include "flyhash.h"\n#define REG(off) (*(volatile uint32_t *)(0xf8100000u+(off)))\nextern const uint8_t __weights_start[];\n'
    source+=array('inputs','int8_t',fixture)+array('expected_hidden','int8_t',hidden[-32:])+array('expected_outputs','int8_t',outputs[-32:])
    source+=array('gray_inputs','uint8_t',fixture_gray.reshape(4,1024))+array('gray_features','int8_t',fixture_features)
    source+=array('expected_hashes','uint32_t',hashes)
    source+='''volatile uint32_t inference_result[12];
void main(void){
 const struct shape_model *m=(const struct shape_model *)__weights_start;
 int8_t h[32],o[4],f[128];uint32_t start=REG(0x30),l0=0,l1=0,hash_ticks=0;
 if(m->magic!=0x53434d31u){inference_result[0]=0xbad00001;for(;;);}
#ifdef VISION_MULHI_CFU
 if(REG(0x12c)!=3){inference_result[0]=0xbad00007;for(;;);}
 if(m->s0>-2||m->s1>-2||m->s0<-30||m->s1<-30){inference_result[0]=0xbad00006;for(;;);}
#endif
 for(unsigned n=0;n<4;n++){
  shape_features(gray_inputs[n],f);for(unsigned j=0;j<128;j++)if(f[j]!=gray_features[n][j]){inference_result[0]=0xbad00002;inference_result[1]=n;inference_result[2]=j;for(;;);}
  uint8_t occupancy[64];uint32_t hash[8];for(unsigned j=0;j<64;j++)occupancy[j]=f[64+j]+128;
  uint32_t t=REG(0x30);flyhash_encode(occupancy,hash);hash_ticks+=REG(0x30)-t;
  for(unsigned j=0;j<8;j++)if(hash[j]!=expected_hashes[n][j]){inference_result[0]=0xbad00005;inference_result[1]=n;inference_result[2]=j;for(;;);}
 }
 for(unsigned n=0;n<32;n++){
  uint32_t a=REG(0x30);shape_dense(inputs[n],128,m->w0,m->b0,32,m->input_zero,m->hidden_zero,m->m0,m->s0,1,h);uint32_t b=REG(0x30);
  shape_dense(h,32,m->w1,m->b1,4,m->hidden_zero,m->output_zero,m->m1,m->s1,0,o);uint32_t c=REG(0x30);l0+=b-a;l1+=c-b;
  for(unsigned j=0;j<32;j++)if(h[j]!=expected_hidden[n][j]){inference_result[0]=0xbad00003;inference_result[1]=n;inference_result[2]=j;inference_result[3]=h[j];inference_result[4]=expected_hidden[n][j];for(;;);}
  for(unsigned j=0;j<4;j++)if(o[j]!=expected_outputs[n][j]){inference_result[0]=0xbad00004;inference_result[1]=n;inference_result[2]=j;inference_result[3]=o[j];inference_result[4]=expected_outputs[n][j];for(;;);}
 }
 inference_result[1]=32;inference_result[2]=REG(0x30)-start;inference_result[3]=l0;inference_result[4]=l1;inference_result[5]=4;inference_result[6]=hash_ticks;inference_result[0]=0x53434d31;REG(4)=5;for(;;);
}
void trap(void){REG(4)=3;for(;;);}
'''
    (a.output_dir/'model_selftest.c').write_text(source)
    summary=dict(application='four-class shape cards',classes=CLASSES,dims=[128,32,4],weight_parameters=4224,macs=4224,
        training_kind='synthetic_bringup_only' if a.synthetic_bringup else 'real_camera',real_accuracy_verified=not a.synthetic_bringup,
        train_samples=len(x),test_samples=len(xt),float_test_accuracy=float(np.mean(np.argmax(model(xt).numpy(),axis=1)==yt)),int8_test_accuracy=quant_score,
        tflite_bytes=len(binary),weights_bytes=len(blob),operators=[o['op_name'] for o in ops],fixed_point_vectors=len(outputs),tensorflow=tf.__version__,
        rounding='TFLITE_SINGLE_ROUNDING',quantization=[{k:int(l[k]) for k in ['input_zero','output_zero','multiplier','shift']} for l in layers])
    (a.output_dir/'training.json').write_text(json.dumps(summary,indent=2));print(json.dumps(summary,indent=2))

if __name__=='__main__':main()
