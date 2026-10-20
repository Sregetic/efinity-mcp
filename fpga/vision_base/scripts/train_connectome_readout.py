"""Train only a 320-weight readout of the fixed biological circuit, in DDR."""
import argparse
import json
import struct
import sys
from pathlib import Path
import numpy as np
from train_shape_cards import ROOT, samples, synthetic, multiplier

sys.path.insert(0, str(ROOT/'models'))
from connectome import fixed
from connectome_readout import MAGIC, GRAPH_VERSION, inputs, load, predict
from shape_cards import CLASSES, features


def fit(x, labels):
    design = np.column_stack([x.astype(np.float64)/128, np.ones(len(x))])
    penalty = np.diag([.01]*x.shape[1]+[0.])
    target = np.eye(4)[labels]
    return np.linalg.solve(design.T@design+penalty, design.T@target)


def main():
    p = argparse.ArgumentParser()
    g = p.add_mutually_exclusive_group(required=True)
    g.add_argument('--manifest', type=Path)
    g.add_argument('--synthetic-bringup', action='store_true')
    p.add_argument('--model-version', type=lambda s: int(s, 0), required=True)
    p.add_argument('--output-dir', type=Path, required=True)
    a = p.parse_args()
    if not 0 < a.model_version <= 0xffffffff:
        p.error('--model-version must be a nonzero uint32')
    data = samples(a.manifest) if a.manifest else {'train': synthetic(2210, 100), 'test': synthetic(107, 40)}
    arrays = {}
    for split, (gray, labels) in data.items():
        f = np.array([features(g) for g in gray])
        states = np.array([fixed(row) for row in f])
        arrays[split] = (f, states, np.array([inputs(s) for s in states]), labels)
    _, _, x, y = arrays['train']
    ftest, stest, xtest, yt = arrays['test']
    theta = fit(x, y)
    weight_scale = float(np.max(np.abs(theta[:-1]))/127)
    scores = np.column_stack([x.astype(np.float64)/128, np.ones(len(x))])@theta
    output_scale = float(np.max(np.abs(scores))/120)
    if not weight_scale or not output_scale:
        raise ValueError('Training data provides no learnable readout')
    weights = np.clip(np.rint(theta[:-1].T/weight_scale), -127, 127).astype(np.int8)
    bias = np.rint(theta[-1]/(weight_scale/128)).astype(np.int64)
    if np.any(np.abs(bias)+128*np.abs(weights.astype(np.int32)).sum(axis=1) >= 2**31):
        raise ValueError('Readout accumulator exceeds signed 32 bits')
    mult, shift = multiplier(weight_scale/128/output_scale)
    kind = 1 if a.synthetic_bringup else 2
    blob = struct.pack('<4I3i', MAGIC, a.model_version, GRAPH_VERSION, kind, 0, mult, shift)
    blob += bias.astype('<i4').tobytes()+weights.tobytes()
    a.output_dir.mkdir(parents=True, exist_ok=True)
    model_path = a.output_dir/'connectome_readout.bin'
    model_path.write_bytes(blob)
    model = load(model_path)
    actual = np.array([predict(s, model) for s in stest])
    predicted = np.argmax(actual, axis=1)
    confusion = np.zeros((4, 4), np.int32)
    np.add.at(confusion, (yt, predicted), 1)
    # Equal trained head and SAME eight-bin information, with no recurrent graph.
    from connectome import channels
    direct_train = np.array([channels(row)*2/2040-1 for row in arrays['train'][0]])*128
    direct_test = np.array([channels(row)*2/2040-1 for row in ftest])*128
    direct = fit(direct_train, y)
    direct_scores = np.column_stack([direct_test/128, np.ones(len(direct_test))])@direct
    report = dict(model='fixed MaleCNS 80-state circuit + trained linear INT8 readout',
                  model_version=a.model_version, graph_version=GRAPH_VERSION, classes=CLASSES,
                  training_kind='synthetic_bringup_only' if kind == 1 else 'real_camera',
                  real_accuracy_verified=False, train_samples=len(x), test_samples=len(xtest),
                  manifest=str(a.manifest.resolve()) if a.manifest else None,
                  train_seed=2210 if kind == 1 else None, test_seed=107 if kind == 1 else None,
                  readout_weights=320, readout_biases=4, model_bytes=len(blob),
                  int8_test_accuracy=float(np.mean(predicted == yt)), confusion_matrix=confusion.tolist(),
                  float_test_accuracy=float(np.mean(np.argmax(np.column_stack([xtest/128, np.ones(len(xtest))])@theta, axis=1) == yt)),
                  direct_same_bins_float_accuracy=float(np.mean(np.argmax(direct_scores, axis=1) == yt)),
                  topology_advantage_verified=False, score_kind='signed quantized logits, not probabilities',
                  quantization=dict(input_scale=1/128, input_zero=0, weight_scale=weight_scale,
                                    output_scale=output_scale, multiplier=mult, shift=shift),
                  source='Independent train/test card and session IDs are enforced by the existing collector loader',
                  note='The test split selects neither weights nor quantization; synthetic success is not real-camera acceptance')
    np.savez(a.output_dir/'heldout.npz', features=ftest, states=stest, scores=actual, labels=yt)
    (a.output_dir/'training.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
