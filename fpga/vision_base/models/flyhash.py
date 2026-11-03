"""Initial fixed-point FlyHash-inspired encoder, not a trained vision classifier.

64 uint8 features -> 256 sparse binary projections (6 inputs/KC) -> top13.
Equal fan-in makes common mean/scale normalization irrelevant to WTA ranks;
no divider or multiplier is needed in the FPGA encoder.
"""
import argparse
import json
import random
from pathlib import Path


def projection():
    state = 0x2210
    rows = []
    for _ in range(256):
        row = []
        while len(row) < 6:
            state = (state >> 1) ^ (0xB400 if state & 1 else 0)
            index = state & 63
            if index not in row:
                row.append(index)
        rows.append(row)
    return rows


PROJECTION = projection()


def encode(features):
    if len(features) != 64 or any(type(v) is not int or not 0 <= v <= 255 for v in features):
        raise ValueError('features: exactly64 uint8 integers')
    scores = [sum(features[i] for i in row) for row in PROJECTION]
    winners = sorted(range(256), key=lambda i: (-scores[i], i))[:13]
    return sum(1 << i for i in winners)


def edge_features(pixels, width, height, roi):
    """8x8 average edge occupancy, with the same ROI used by the frame task."""
    x, y, w, h = roi
    if len(pixels) != width * height or w < 8 or h < 8 or min(x, y) < 0 or x+w > width or y+h > height:
        raise ValueError('edge plane size and ROI mismatch')
    values = []
    for by in range(8):
        ya, yb = y + by*h//8, y + (by+1)*h//8
        for bx in range(8):
            xa, xb = x + bx*w//8, x + (bx+1)*w//8
            count = sum(pixels[py*width+px] != 0 for py in range(ya, yb) for px in range(xa, xb))
            area = (xb-xa)*(yb-ya)
            values.append((count*255 + area//2)//area)
    return values


def nearest(query, labeled_hashes):
    """Prototype matching only; confidence/unknown cutoff needs real samples."""
    return min(((label, (query ^ tag).bit_count()) for label, tag in labeled_hashes), key=lambda pair: pair[1])


def fixtures(directory):
    directory.mkdir(parents=True, exist_ok=True)
    assert [int(word, 16) for word in Path(__file__).with_name('flyhash_projection.mem').read_text().split()] == [i for row in PROJECTION for i in row]
    rng = random.Random(2210)
    vectors = [[0]*64, [255]*64, list(range(64)), [255-i*4 for i in range(64)]]
    vectors += [[rng.randrange(256) for _ in range(64)] for _ in range(28)]
    assert encode(vectors[0]) == encode(vectors[1]) == (1 << 13)-1
    assert edge_features(bytes(64), 8, 8, (0, 0, 8, 8)) == [0]*64
    assert edge_features(bytes([255]*64), 8, 8, (0, 0, 8, 8)) == [255]*64
    for vector in vectors:
        # Independent streaming insertion matches the full-sort reference.
        top = []
        for i, row in enumerate(PROJECTION):
            score = sum(vector[j] for j in row)
            pos = next((p for p, (v, _) in enumerate(top) if score > v), len(top))
            top.insert(pos, (score, i))
            del top[13:]
        assert encode(vector) == sum(1 << i for _, i in top)
        assert encode(vector).bit_count() == 13
    assert nearest(encode(vectors[2]), [('ramp', encode(vectors[2])), ('other', encode(vectors[3]))]) == ('ramp', 0)
    (directory/'features.mem').write_text(''.join(f'{v:02x}\n' for vector in vectors for v in vector))
    (directory/'expected.mem').write_text(''.join(f'{encode(vector):064x}\n' for vector in vectors))
    print('PASS FlyHash reference32 vectors, top13, ties, edge occupancy and prototype matching')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--fixtures', type=Path)
    parser.add_argument('--input', type=Path)
    args = parser.parse_args()
    if args.fixtures:
        fixtures(args.fixtures)
    if args.input:
        request = json.loads(args.input.read_text(encoding='utf-8-sig'))
        if any(type(request[k]) is not int or not 0 <= request[k] < 2**32 for k in ['frame_id', 'config_id']):
            raise ValueError('frame_id/config_id: uint32 integers')
        print(json.dumps(dict(frame_id=request['frame_id'], config_id=request['config_id'],
                              hash=f"{encode(request['features']):064x}", winners=13)))
