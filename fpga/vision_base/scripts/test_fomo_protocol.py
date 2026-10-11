"""Offline checks for the actual board tensor decoder and software-only headers."""
import struct
import tempfile
from pathlib import Path
from build_fomo_firmware import ROOT, LABELS, software_headers, EXAMPLE
from test_fomo_board import decode

with tempfile.TemporaryDirectory() as directory:
    p = Path(directory)
    model = ROOT / 'models/shape_fomo'
    expected = b''.join((model/'test_vectors'/(s+'_expected_output.bin')).read_bytes() for s in LABELS)
    status = [0x464f4d31,3,0,3,4,50000,100000,0,27648,576,25,24,0,0,0,100000000]
    results = b''
    for s in range(4):
        values = struct.unpack('<576b', expected[s*576:(s+1)*576])
        count = 0
        for i in range(144):
            c = max(range(4), key=lambda c: values[i*4+c])
            count += c != 0 and values[i*4+c] >= 0
        results += struct.pack('<Q4I', (1<<32)+100000,0,0,count,25)
    (p/'status.bin').write_bytes(struct.pack('<16I', *status))
    (p/'results.bin').write_bytes(results)
    (p/'outputs.bin').write_bytes(expected)
    (p/'layers.bin').write_bytes(struct.pack('<100Q', *([1000]*100)))
    r = decode(p, model)
    assert r['passed'] and r['exact_match'] and r['samples'][0]['invoke_cycles'] > 2**32
    assert [len(s['positive_cells']) for s in r['samples']] == [0,2,1,4]
    # One-LSB tolerance is reported separately from exact byte equality.
    changed = bytearray(expected)
    changed[0] -= 1
    (p/'outputs.bin').write_bytes(changed)
    (p/'results.bin').write_bytes(struct.pack('<Q4I', (1<<32)+100000,1,1,0,25)+results[24:])
    r = decode(p, model)
    assert r['passed'] and not r['exact_match']
    changed[0] -= 1
    (p/'outputs.bin').write_bytes(changed)
    (p/'results.bin').write_bytes(struct.pack('<Q4I', (1<<32)+100000,2,1,0,25)+results[24:])
    assert not decode(p, model)['passed']
    (p/'outputs.bin').write_bytes(expected[:-1])
    try: decode(p, model)
    except ValueError: pass
    else: raise AssertionError('Truncated tensor accepted')
    status[1] = 4
    (p/'status.bin').write_bytes(struct.pack('<16I', *status))
    try: decode(p, model)
    except ValueError: pass
    else: raise AssertionError('Firmware error accepted')
    overlay = p/'headers'
    software_headers(Path('F:/efinity-ci/deps/tinyml')/EXAMPLE, overlay)
    for file in overlay.rglob('*.h'):
        text = file.read_text()
        assert '_drv(' not in text and 'platform/tinyml/ops' not in text
        assert 'MultiplyByQuantizedMultiplier' in text
print('PASS software-only headers, 64-bit timing, signed tensors, exact/1-LSB/2-LSB, truncated/error records')
