"""Export a completed camera task at the proven5kHz USER1 read speed; resume CPU."""
import argparse
import struct
import subprocess
from pathlib import Path
from load_vision_ddr import ROOT, IDE, board_location, configuration, validate_image, tcl_path


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--url', required=True)
    p.add_argument('--elf', type=Path, required=True)
    p.add_argument('--output-dir', type=Path, required=True)
    p.add_argument('--summary', action='store_true', help='Read task identities only; keep large RGB arrays for the first numeric comparison')
    p.add_argument('--full-input', action='store_true', help='Slow USER1 export of all preserved RGB/packed samples; source image normally uses existing bulk USER2')
    p.add_argument('--connectome-readout', action='store_true', help='Read the CRD1 companion head from an ELF built with --connectome-readout')
    a = p.parse_args()
    _, _, sym = validate_image(a.elf, None)
    out = a.output_dir.resolve()
    out.mkdir(parents=True, exist_ok=True)
    body = 'halt\nwait_halt 5000\n'
    fields = [('status', 'fomo_camera_status', 96), ('fusion', 'fusion_result', 64), ('legacy', 'analysis_result', 96),
              ('control', '__control_state', 120)]
    if a.connectome_readout:
        fields += [('readout_record', 'connectome_readout_result', 56),
                   ('readout_scores', 'analysis_connectome_scores', 4)]
    if not a.summary:
        fields += [('output', 'fomo_camera_output', 576),
              ('targets', 'fomo_detections', 144*14), ('layers', 'fomo_camera_layer_cycles', 200),
              ('gray', 'analysis_gray', 1024), ('features', 'analysis_features', 128),
              ('hidden', 'analysis_hidden', 32), ('logits', 'analysis_logits', 4),
              ('hash', 'analysis_hash', 32), ('network', 'analysis_connectome', 160),
              ('network_record', 'connectome_result', 40)]
        if a.full_input:
            fields += [('packed', 'fomo_packed_input', 18432), ('input', 'fomo_rgb_input', 27648), ('log', 'fomo_camera_log', 2048)]
    for name, symbol, size in fields:
        body += f'dump_image {tcl_path(out/(name+".bin"))} {sym[symbol]:#x} {size}\n'
    body += 'resume\necho FOMO_CAMERA_READ_COMPLETE\nshutdown\n'
    cfg = out/'read.cfg'
    cfg.write_text(configuration(board_location(a.url), ROOT/'artifacts/vision_soc/cpu0.yaml', sym) + body)
    r = subprocess.run([str(IDE/'openocd/bin/openocd.exe'), '-f', str(cfg)], capture_output=True, text=True, timeout=2400 if a.full_input else 300)
    (out/'read.log').write_text(r.stdout+r.stderr)
    r.check_returncode()
    if 'FOMO_CAMERA_READ_COMPLETE' not in r.stdout+r.stderr:
        raise RuntimeError('Camera task export did not finish')
    status = struct.unpack('<24I', (out/'status.bin').read_bytes())
    if status[:2] != (0x464f4d32, 3) or status[17] != 0:
        raise RuntimeError('Expected completed camera FOMO task: '+str(status))
    print('READ completed camera FOMO sequence', status[2], 'source', status[3], 'objects', status[12])


if __name__ == '__main__':
    main()
