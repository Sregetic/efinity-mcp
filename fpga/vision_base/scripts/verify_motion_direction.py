"""Offline ordinary-motion and Chinese menu integration; no board access."""
import argparse
import json
import subprocess
from pathlib import Path
from motion_reference import fixtures

ROOT = Path(__file__).resolve().parents[1]


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--output', type=Path, default=ROOT/'results/motion_sidebar_20261022/rtl')
    p.add_argument('--tests', nargs='+', choices=['core', 'tap', 'policy', 'readout', 'motion_display', 'motion_sidebar'])
    a = p.parse_args()
    out = a.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    fixture = fixtures(out/'vectors')
    rtl = ROOT/'board/ti60f225_v4/rtl/vision'
    display = ['vision_display', 'vision_frontend', 'vision_window3', 'vision_median9',
               'vision_sobel', 'vision_osd', 'vision_local_motion_core',
               'vision_local_motion_tap', 'vision_motion_policy', 'vision_motion_readout']
    tests = [
        ('core', 'sim/motion_direction/tb_local_motion_core.sv', ['vision_local_motion_core']),
        ('tap', 'sim/motion_direction/tb_local_motion_tap.sv', ['vision_local_motion_core', 'vision_local_motion_tap', 'vision_motion_policy']),
        ('policy', 'sim/motion_direction/tb_motion_policy.sv', ['vision_motion_policy']),
        ('readout', 'sim/motion_direction/tb_motion_readout.sv', ['vision_motion_readout']),
        ('motion_display', 'sim/vision/tb_motion_display.sv', display),
        ('motion_sidebar', 'sim/vision/tb_motion_sidebar.sv', ['vision_sidebar_overlay', 'vision_osd']),
    ]
    rows = []
    for name, bench, sources in tests:
        if a.tests and name not in a.tests:
            continue
        exe = out/(name+'.vvp')
        cmd = ['C:/iverilog/bin/iverilog.exe', '-g2012', '-s', 'tb', '-o', str(exe)]
        if name == 'core':
            cmd += ['-Ptb.FRAMES='+str(fixture['core_frames'])]
        cmd += [str(ROOT/bench)] + [str(rtl/(n+'.sv')) for n in sources]
        for stage, args in [('compile', cmd), ('run', ['C:/iverilog/bin/vvp.exe', str(exe),
                '+vectors='+str(out.parent/'control/ui_vectors.mem'), '+output='+str(out)])]:
            log = out/(name+'.'+stage+'.log')
            with log.open('wb') as stream:
                result = subprocess.run(args, cwd=out, stdout=stream, stderr=subprocess.STDOUT, timeout=600)
            if result.returncode:
                print(log.read_text(encoding='utf-8', errors='replace'))
                result.check_returncode()
        rows.append(dict(test=name, passed=True))
        exe.unlink()
        print('PASS', name, flush=True)
    (out/'verification.json').write_text(json.dumps(dict(passed=True, tests=rows, fixture=fixture,
        scope='Synthetic RTL and actual RV32I menu words; not physical keys or camera accuracy',
        hardware_programmed=False), indent=2), encoding='utf-8')


if __name__ == '__main__':
    main()
