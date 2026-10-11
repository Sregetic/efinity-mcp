"""Recompute the four delivered golden tensors with installed desktop TFLite."""
import json
from pathlib import Path
import numpy as np
import tensorflow as tf
from PIL import Image
from build_fomo_firmware import ROOT, LABELS

model = ROOT / 'models/shape_fomo'
interpreter = tf.lite.Interpreter(model_path=str(model / 'shape_fomo_int8.tflite'),
                                 experimental_op_resolver_type=tf.lite.experimental.OpResolverType.BUILTIN_REF)
interpreter.allocate_tensors()
input_info, = interpreter.get_input_details()
output_info, = interpreter.get_output_details()
assert input_info['shape'].tolist() == [1, 96, 96, 3] and input_info['dtype'] == np.int8
assert output_info['shape'].tolist() == [1, 12, 12, 4] and output_info['dtype'] == np.int8
assert input_info['quantization'][1] == -128 and output_info['quantization'] == (1/256, -128)
rows = []
for name in LABELS:
    data = np.frombuffer((model / 'test_vectors' / (name + '_input.bin')).read_bytes(), dtype=np.int8).reshape(1, 96, 96, 3)
    png = np.asarray(Image.open(model / 'test_vectors' / (name + '_96.png')).convert('RGB'))
    assert np.array_equal(data[0].astype(np.int16) + 128, png), name + ' PNG/input mismatch'
    interpreter.set_tensor(input_info['index'], data)
    interpreter.invoke()
    actual = interpreter.get_tensor(output_info['index']).reshape(-1)
    expected = np.frombuffer((model / 'test_vectors' / (name + '_expected_output.bin')).read_bytes(), dtype=np.int8)
    difference = np.abs(actual.astype(np.int16) - expected.astype(np.int16))
    row = dict(sample=name, max_lsb_diff=int(difference.max()), mismatched_bytes=int(np.count_nonzero(difference)))
    rows.append(row)
    print(row)
    assert row['max_lsb_diff'] == 0, name + ' delivered golden differs from current BUILTIN_REF'
out = ROOT / 'results/fomo_fixed_20261011/host_reference.json'
out.write_text(json.dumps(dict(passed=True, tensorflow=tf.__version__, reference='BUILTIN_REF', samples=rows), indent=2))
print('PASS four PNG/int8 inputs and 2304 golden output bytes')
