"""80 Q14 circuit states -> signed INT8 linear readout, not probabilities."""
import struct
import numpy as np
from shape_cards import dense

MAGIC = 0x43524431
GRAPH_VERSION = 0x00010001
MODEL_BYTES = 364


def inputs(states):
    q = np.asarray(states)
    if q.shape != (80,) or q.dtype != np.int16:
        raise ValueError('Expected int16[80] Q14 circuit state')
    return np.clip((q.astype(np.int32) + 64) >> 7, -128, 127).astype(np.int8)


def load(path):
    blob = path.read_bytes()
    if len(blob) != MODEL_BYTES:
        raise ValueError('CRD1 readout must contain exactly 364 bytes')
    magic, version, graph, kind, zero, mult, shift = struct.unpack_from('<4I3i', blob)
    if magic != MAGIC or not version or graph != GRAPH_VERSION or kind not in (1, 2):
        raise ValueError('Readout magic/version/graph/training kind mismatch')
    if not -128 <= zero <= 127 or not 0 < mult < 2**31 or not -30 <= shift <= -2:
        raise ValueError('Readout quantization exceeds the installed MulHi contract')
    bias = np.frombuffer(blob, '<i4', 4, 28)
    weights = np.frombuffer(blob, np.int8, 320, 44).reshape(4, 80)
    if np.any(np.abs(bias.astype(np.int64))+128*np.abs(weights.astype(np.int32)).sum(axis=1) >= 2**31):
        raise ValueError('Readout accumulator exceeds signed 32 bits')
    return dict(version=version, graph=graph, kind=kind, zero=zero, multiplier=mult, shift=shift,
                bias=bias, weights=weights)


def predict(states, model):
    return dense(inputs(states), model['weights'], model['bias'], 0, model['zero'],
                 model['multiplier'], model['shift'])
