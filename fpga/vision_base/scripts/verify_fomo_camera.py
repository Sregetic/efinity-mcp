"""Desktop reference of actual Ti60 RGB preprocessing/output/components and legacy AI."""
import argparse
import json
import struct
import sys
from pathlib import Path
import numpy as np
import tensorflow as tf
from PIL import Image
from load_vision_ddr import ROOT
sys.path.insert(0, str(ROOT/'models'))
from fomo_post import components
from shape_cards import features, dense
from flyhash import encode
from connectome import fixed


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--directory', type=Path, required=True)
    a = p.parse_args()
    out = a.directory
    s = struct.unpack('<24I', (out/'status.bin').read_bytes())
    f = struct.unpack('<16I', (out/'fusion.bin').read_bytes())
    legacy = struct.unpack('<24I', (out/'legacy.bin').read_bytes())
    assert s[:2] == (0x464f4d32, 3) and s[17] == 0 and s[7] == 2 and s[15] == 100000000, s
    assert (s[2], s[3], s[4], s[5], s[6]) == (legacy[1], legacy[2], legacy[3], legacy[20], legacy[21])
    assert not legacy[17] and not f[15] and (f[3], f[4], f[5], f[6], f[7]) == (s[3], s[4], s[5], 2, s[6])
    image_info=json.loads((out/'source/images.json').read_text())
    image,=image_info['images']
    assert image['mode']=='source' and image['frame_id']==s[3] and image['config_id']==s[5] and image['color_order']==0
    source=np.asarray(Image.open(out/'source/source.png').convert('RGB'))
    xy,wh=legacy[6:8];x,y,w,h=xy&65535,xy>>16,wh&65535,wh>>16
    yy=y-image['y']+np.arange(96)*h//96;xx=x+np.arange(96)*w//96
    rgb=source[yy[:,None],xx[None,:]]
    actual_input=(rgb.astype(np.int16)-128).astype(np.int8).reshape(1,96,96,3)
    if (out/'input.bin').exists():
        assert np.array_equal(np.frombuffer((out/'input.bin').read_bytes(),dtype=np.int8).reshape(1,96,96,3),actual_input)
        packed=np.frombuffer((out/'packed.bin').read_bytes(),dtype='<u2').reshape(96,96)
        values=np.stack([(packed>>10)&31,(packed>>5)&31,packed&31],axis=-1)
        assert np.array_equal(np.where((packed>>15)[...,None],values*8+values//4,values*2).astype(np.uint8),rgb)
    Image.fromarray(rgb).save(out/'camera_roi.png')
    gray = np.frombuffer((out/'gray.bin').read_bytes(), dtype=np.uint8).reshape(32, 32)
    sampled = rgb[::3, ::3].astype(np.uint32)
    expected_gray = ((sampled[..., 0]*77+sampled[..., 1]*150+sampled[..., 2]*29)>>8).astype(np.uint8)
    assert np.array_equal(gray, expected_gray), 'Legacy gray and FOMO RGB did not sample the same protected source'
    # Use the delivered model and exact scalar INT8 reference, not optimized desktop kernels.
    interpreter = tf.lite.Interpreter(model_path=str(ROOT/'models/shape_fomo/shape_fomo_int8.tflite'),
                                     experimental_op_resolver_type=tf.lite.experimental.OpResolverType.BUILTIN_REF)
    interpreter.allocate_tensors()
    inp, = interpreter.get_input_details()
    tensor, = interpreter.get_output_details()
    interpreter.set_tensor(inp['index'], actual_input)
    interpreter.invoke()
    expected = interpreter.get_tensor(tensor['index']).reshape(-1)
    actual = np.frombuffer((out/'output.bin').read_bytes(), dtype=np.int8)
    diff = np.abs(actual.astype(np.int16)-expected.astype(np.int16))
    assert not np.any(diff), 'Camera FOMO output differs from desktop integer reference'
    boxes, best = components(actual.tolist())
    keys = ['left', 'top', 'right', 'bottom', 'label', 'confidence', 'cells', 'peak_cell']
    cpu_boxes = [dict(zip(keys, struct.unpack_from('<4H2B2H', (out/'targets.bin').read_bytes(), i*14))) for i in range(s[12])]
    assert cpu_boxes == boxes and s[13] == best and s[14] == (boxes[best]['label'] if boxes else 0)
    assert ((f[2] >> 6) & 3) == s[14] and not (f[2] & 2), 'FOMO label/model must not inherit synthetic MLP TEST flag'
    layer_cycles = struct.unpack('<25Q', (out/'layers.bin').read_bytes())
    result = dict(passed=True, sequence=s[2], source_frame=s[3], source_config=s[4], render_config=s[5], context=s[6],
                  model=s[7], preprocessing_ms=s[8]/100000, invoke_ms=s[9]/100000, postprocessing_ms=s[10]/100000,
                  fomo_total_ms=s[11]/100000, arena_used_bytes=s[16], max_lsb_diff=int(diff.max()),
                  mismatched_output_bytes=int(np.count_nonzero(diff)), objects=boxes,
                  layer_ms=[n/100000 for n in layer_cycles], gray_same_source=True,
                  legacy_model=legacy[4], legacy_gray_sum=int(gray.sum()), fusion_record=list(f),
                  input_reference='Independent same-frame pre-Gamma RGB bulk snapshot sampled by the RV32I contract',
                  scope='Actual camera source/board output; optional full CPU input dump is separate; not real-card accuracy acceptance')
    assert legacy[15] == int(gray.sum())
    blob=(ROOT/'models/shape_cards_bringup/shape_cards_weights.bin').read_bytes()
    magic,iz,hz,oz,m0,s0,m1,s1=struct.unpack_from('<I7i',blob)
    assert magic==0x53434d31
    b0=np.frombuffer(blob,dtype='<i4',count=32,offset=32);b1=np.frombuffer(blob,dtype='<i4',count=4,offset=160)
    w0=np.frombuffer(blob,dtype=np.int8,count=4096,offset=176).reshape(32,128)
    w1=np.frombuffer(blob,dtype=np.int8,count=128,offset=4272).reshape(4,32)
    x=features(gray);h=dense(x,w0,b0,iz,hz,m0,s0,True);o=dense(h,w1,b1,hz,oz,m1,s1)
    for name,expected in [('features',x),('hidden',h),('logits',o)]:
        assert np.array_equal(expected,np.frombuffer((out/(name+'.bin')).read_bytes(),dtype=np.int8)),name
    assert int.from_bytes((out/'hash.bin').read_bytes(),'little')==encode((x[64:].astype(np.int16)+128).tolist())
    assert np.array_equal(fixed(x),np.frombuffer((out/'network.bin').read_bytes(),dtype='<i2'))
    n=struct.unpack('<10I',(out/'network_record.bin').read_bytes())
    assert n[9]==0 and n[1:6]==(s[2],s[3],s[4],s[5],s[6])
    result.update(legacy_int8_exact=True,flyhash_exact=True,connectome_states_exact=80)
    (out/'verification.json').write_text(json.dumps(result, indent=2))
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
