from pathlib import Path
import struct,json
import numpy as np
import tensorflow as tf
root=Path('F:/Project/fpga/vision_base');out=root/'results/connectome_readout_20261018'
s=struct.unpack('<24I',(out/'board/frozen/status.bin').read_bytes());cycles=struct.unpack('<25Q',(out/'board/frozen/layers.bin').read_bytes())
model=tf.lite.Interpreter(model_path=str(root/'models/shape_fomo/shape_fomo_int8.tflite'),experimental_op_resolver_type=tf.lite.experimental.OpResolverType.BUILTIN_REF)
model.allocate_tensors();details={d['index']:d for d in model.get_tensor_details()};ops=model._get_ops_details()
assert len(ops)==len(cycles)==25
rows=[]
for i,(op,ticks) in enumerate(zip(ops,cycles)):
 shape=details[int(op['outputs'][0])]['shape'].tolist();inputs=[details[int(j)]['shape'].tolist() for j in op['inputs'] if j>=0]
 macs=0
 if op['op_name']=='CONV_2D':macs=int(np.prod(shape))*int(np.prod(inputs[1][1:]))
 if op['op_name']=='DEPTHWISE_CONV_2D':macs=int(np.prod(shape))*inputs[1][1]*inputs[1][2]
 rows.append(dict(layer=i,operator=op['op_name'],input_shapes=inputs,output_shape=shape,macs=macs,ms=ticks/100000,invoke_fraction=ticks/s[9]))
by={}
for r in rows:by[r['operator']]=by.get(r['operator'],0)+r['ms']
report=dict(source_frame=s[3],sequence=s[2],invoke_ms=s[9]/100000,layer_ms=sum(cycles)/100000,
            operator_ms=by,top_layers=sorted(rows,key=lambda r:r['ms'],reverse=True)[:5],layers=rows,
            scope='Measured fixed-shape camera inference; no new accelerator or speedup claim')
(out/'fomo_hotspots.json').write_text(json.dumps(report,indent=2));print(json.dumps({k:v for k,v in report.items() if k!='layers'},indent=2))
