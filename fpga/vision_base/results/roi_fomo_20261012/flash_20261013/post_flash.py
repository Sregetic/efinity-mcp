"""Check the SPI-loaded application through existing keys, then restore live view."""
import json, struct, subprocess, sys, time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent
URL = 'ftdi://0x0403:0x6011:4:9/2'

def control(*args, ai=False):
    r = subprocess.run([sys.executable, str(ROOT/'scripts/vision_control.py'), '--url', URL,
                        *map(str, args), '--ai-status' if ai else '--roi-status'],
                       check=True, capture_output=True, text=True)
    return json.loads(r.stdout)

try:
    state = control('--ai-policy', 0, '--mode', 0, '--median', 1, '--memory', 0,
                    '--roi-enable', 0, '--menu', 10)
    assert state['menu_value'] == 0, state
    state = control('--key-event', 2)
    assert state['menu_value'] == 1, state
    state = control('--menu', 8, '--key-event', 2)
    assert state['menu_value'] == 1, state
    state = control('--memory', 1)
    deadline = time.monotonic() + 12
    while not (state['source_frozen'] and state['roi_frame_ok']):
        if time.monotonic() > deadline:
            raise TimeoutError(state)
        state = control()
    assert state['source_frozen'] and state['roi_frame_ok'], state
    frame = state['roi_frame_id']
    control('--key-event', 4)
    deadline = time.monotonic() + 20
    while True:
        done = control(ai=True)
        assert (done['ai_flags'] >> 11) & 3 != 3, done
        if (done['ai_flags'] >> 11) & 3 == 2 and done['ai_frame'] == frame:
            break
        if time.monotonic() > deadline:
            raise TimeoutError(done)
        time.sleep(.25)
    subprocess.run([sys.executable, str(ROOT/'scripts/read_fomo_camera.py'), '--url', URL,
                    '--elf', str(ROOT/'results/roi_fomo_20261012/camera_cooperative/vision.elf'),
                    '--output-dir', str(OUT/'fomo'), '--summary'], check=True)
    status = struct.unpack('<24I', (OUT/'fomo/status.bin').read_bytes())
    fusion = struct.unpack('<16I', (OUT/'fomo/fusion.bin').read_bytes())
    assert status[:2] == (0x464f4d32, 3) and status[17] == 0, status
    assert status[3] == frame and status[7] == 2 and fusion[6] == 2, (status, fusion)
    assert (fusion[2] >> 13) & 3 == 2, fusion
    result = dict(passed=True,source=frame,sequence=status[2],model=status[7],
                  invoke_ms=status[9]/100000,preprocess_ms=status[8]/100000,
                  postprocess_ms=status[10]/100000,objects=status[12],selftest_passed=True,
                  user1_program_download=False,scope='SPI-loaded camera task and key-event policy; not card accuracy or manual pressing')
finally:
    state = control('--ai-policy', 0, '--menu', 10)
    if state['menu_value'] == 1:
        control('--key-event', 2)
    first = control('--memory', 0, '--mode', 0, '--median', 1, '--menu', 0,
                    '--sobel-threshold', 128, '--canny-threshold', 80,
                    '--roi', 0, 0, 1920, 1080, '--output-size', 1920, 1080,
                    '--position', 0, 0, '--roi-enable', 0)
    time.sleep(2)
    last = control()
    assert last['roi_frame_id'] > first['roi_frame_id'] and last['rgb_capture_count'] > first['rgb_capture_count'], (first,last)
    assert last['roi_frame_ok'] and not any(last[k] for k in ['config_error','render_error','scan_error','canny_fault','capture_discarded','scan_bad_frames']), last
    (OUT/'final_live.json').write_text(json.dumps(dict(first=first,last=last,ai=control(ai=True)),indent=2))
(OUT/'post_flash_result.json').write_text(json.dumps(result,indent=2))
print(json.dumps(result,indent=2))
