"""Run delivered vectors on Ti60, read real outputs/timing, restore full AI firmware."""
import argparse
import json
import struct
import subprocess
import sys
import time
from pathlib import Path
from build_fomo_firmware import LABELS
from load_vision_ddr import ROOT, IDE, board_location, configuration, symbols, validate_image, tcl_path


def decode(directory, model_dir):
    status = struct.unpack('<16I', (directory / 'status.bin').read_bytes())
    if status[0:3] != (0x464f4d31, 3, 0) or status[4] != 4 or status[15] != 100000000:
        raise ValueError('FOMO test did not complete: ' + str(status))
    data = (directory / 'outputs.bin').read_bytes()
    stats = (directory / 'results.bin').read_bytes()
    if len(data) != 2304 or len(stats) != 96:
        raise ValueError('Truncated FOMO DDR record')
    layers = struct.unpack('<100Q', (directory / 'layers.bin').read_bytes())
    rows = []
    for s, name in enumerate(LABELS):
        cycles, maximum, mismatches, positive, operators = struct.unpack_from('<Q4I', stats, s * 24)
        actual = data[s*576:(s+1)*576]
        expected = (model_dir / 'test_vectors' / (name + '_expected_output.bin')).read_bytes()
        a = struct.unpack('<576b', actual)
        e = struct.unpack('<576b', expected)
        diff = [abs(x-y) for x, y in zip(a, e)]
        if (maximum, mismatches) != (max(diff), sum(d != 0 for d in diff)):
            raise ValueError('CPU comparison and actual DDR output disagree: ' + name)
        cells = []
        for i in range(144):
            c = max(range(4), key=lambda c: a[i*4+c])
            if c and a[i*4+c] >= 0:
                cells.append(dict(label=['background','circle','rectangle','triangle'][c],
                                  grid_x=i%12, grid_y=i//12, score=(a[i*4+c]+128)/256))
        if positive != len(cells) or operators != 25 or cycles == 0:
            raise ValueError('Invalid CPU statistics: ' + name)
        rows.append(dict(sample=name, invoke_cycles=cycles, invoke_ms=cycles/100000,
                         max_lsb_diff=maximum, mismatched_bytes=mismatches, exact_match=mismatches==0,
                         within_1_lsb=maximum<=1, positive_cells=cells,
                         layer_cycles=list(layers[s*25:(s+1)*25]),
                         layer_ms=[v/100000 for v in layers[s*25:(s+1)*25]]))
    return dict(passed=all(r['within_1_lsb'] for r in rows), exact_match=all(r['exact_match'] for r in rows),
                clock_hz=status[15], arena_used_bytes=status[5], arena_reserved_bytes=262144,
                allocation_ms=((status[7]<<32)|status[6])/100000, status=list(status), samples=rows,
                measurement='64-bit CLINT; no CPU halt during Invoke; includes layer-boundary control service',
                source='physical Ti60 Sapphire RV32I firmware kernels, USER1 DDR tensor readback')


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--url', required=True)
    p.add_argument('--elf', type=Path, required=True)
    p.add_argument('--restore-elf', type=Path, required=True)
    p.add_argument('--restore-weights', type=Path, required=True)
    p.add_argument('--model-dir', type=Path, default=ROOT / 'models/shape_fomo')
    p.add_argument('--output-dir', type=Path, required=True)
    p.add_argument('--load-jtag-khz', type=int, default=25, help='Static ELF loading only; tensor readback remains at 5kHz')
    a = p.parse_args()
    out = a.output_dir.resolve()
    out.mkdir(parents=True, exist_ok=True)
    _, _, sym = validate_image(a.elf, None)
    validate_image(a.restore_elf, a.restore_weights)
    location = board_location(a.url)
    def control(*args):
        r = subprocess.run([sys.executable, str(ROOT/'scripts/vision_control.py'), '--url', a.url, *map(str, args)],
                           capture_output=True, text=True, check=True)
        return json.loads(r.stdout)
    before = control('--roi-status', '--samples', 1)
    (out/'before.json').write_text(json.dumps(before, indent=2))
    def load(elf, directory, weights=None):
        args = [sys.executable, str(ROOT/'scripts/load_vision_ddr.py'), '--url', a.url,
                '--elf', str(elf), '--output-dir', str(directory), '--timeout-seconds', '1800']
        if not weights: args += ['--jtag-khz', str(a.load_jtag_khz)]
        if weights: args += ['--weights', str(weights)]
        print('LOAD', elf, flush=True)
        subprocess.run(args, check=True)
    try:
        # Loading a test app leaves the old weights and shared control state intact.
        load(a.elf, out/'load')
        deadline = time.monotonic() + 900
        previous = None
        while True:
            page, = control('--page', 30, '--samples', 1)
            state = page['flyhash_firmware_state']
            if state != previous:
                print('FOMO_STATE', hex(state), flush=True)
                previous = state
            if state in (2, 3): break
            if time.monotonic() > deadline: raise TimeoutError('FOMO inference did not finish in 900s')
            time.sleep(5)
        body = 'halt\nwait_halt 5000\n'
        for name, symbol, length in [('status','fomo_status',64), ('results','fomo_results',96),
                                      ('outputs','fomo_outputs',2304), ('layers','fomo_layer_cycles',800), ('log','fomo_log',2048)]:
            body += f'dump_image {tcl_path(out/(name+".bin"))} {sym[symbol]:#x} {length}\n'
        body += 'resume\necho FOMO_RECORD_COMPLETE\nshutdown\n'
        cfg = out/'read.cfg'
        cfg.write_text(configuration(location, ROOT/'artifacts/vision_soc/cpu0.yaml', sym) + body)
        r = subprocess.run([str(IDE/'openocd/bin/openocd.exe'), '-f', str(cfg)], capture_output=True, text=True, timeout=180)
        (out/'read.log').write_text(r.stdout+r.stderr)
        r.check_returncode()
        if 'FOMO_RECORD_COMPLETE' not in r.stdout+r.stderr: raise RuntimeError('FOMO DDR dump incomplete')
        (out/'runtime.log').write_text((out/'log.bin').read_bytes().split(b'\0',1)[0].decode())
        result = decode(out, a.model_dir)
        result['firmware_elf'] = str(a.elf.resolve())
        (out/'result.json').write_text(json.dumps(result, indent=2))
        print(json.dumps(result, indent=2), flush=True)
        if not result['passed']: raise AssertionError('Board output exceeds the supplied one-LSB acceptance')
    finally:
        load(a.restore_elf, out/'restore', a.restore_weights)
        restored = control('--mode', before['mode'], '--median', before['median'], '--memory', before['memory'],
                           '--sobel-threshold', before['sobel_threshold'], '--canny-threshold', before['canny_threshold'],
                           '--menu', before['menu'], '--roi-status', '--samples', 1)
        (out/'restore.json').write_text(json.dumps(restored, indent=2))


if __name__ == '__main__':
    main()
