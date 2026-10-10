"""Final native bit: frozen ROI reanalysis, HUD pixels, then restore live view."""
import json,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
URL='ftdi://0x0403:0x6011:4:9/2'
HOST='C:/Users/Sregetic/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
def run(script,*args,host=False):
    executable=[HOST,'-E','-X','utf8'] if host else [sys.executable]
    return subprocess.run([*executable,str(ROOT/'scripts'/script),*map(str,args)],capture_output=True,text=True,check=True).stdout
def control(*args):
    return json.loads(run('vision_control.py','--url',URL,*args,'--roi-status'))
def record(name):
    d=OUT/name
    run('read_ai_result.py','--url',URL,'--elf',ROOT/'artifacts/vision_soc/ddr_firmware/vision.elf','--output-dir',d)
    run('validate_ai_result.py','--directory',d,'--weights',ROOT/'models/shape_cards_bringup/shape_cards_weights.bin',host=True)
    run('validate_connectome.py','--directory',d,host=True)
    return json.loads((d/'result.json').read_text())
try:
    control('--mode',0,'--median',1,'--memory',1,'--ai-policy',0,'--menu',8,
            '--roi',736,302,960,540,'--output-size',960,540,'--position',320,240,'--roi-enable',1,
            '--sobel-threshold',128,'--canny-threshold',80,'--gain-r',336,'--gain-g',256,'--gain-b',504,'--tone',3,'--color-order',2)
    time.sleep(2)
    control('--key-event',2);control('--key-event',4);time.sleep(1)
    a=record('roi_release')
    control('--menu',3,'--key-event',2);time.sleep(2)
    control('--menu',8,'--key-event',4);time.sleep(1)
    b=record('roi_release_rerender')
    assert a['frame_id']==b['frame_id'] and b['sequence']==a['sequence']+1
    assert a['render_config_id']!=b['render_config_id'] and a['processing_context']==b['processing_context']
    assert a['roi']==[736,302,960,540] and b['roi']==[768,302,960,540]
    control('--menu',9,'--key-event',2);time.sleep(1)
    c=record('selftest_release')
    assert c['runtime'][1]==2 and c['sequence']==b['sequence']
    assert c['fusion_record'][3:14]==b['fusion_record'][3:14]
    run('capture_mode_images.py','--url',URL,'--current-view','--modes',0,'--rows',0,100,'--output-dir',OUT/'osd_release')
    result=dict(passed=True,frame_id=a['frame_id'],sequences=[a['sequence'],b['sequence']],render_configs=[a['render_config_id'],b['render_config_id']],contexts=[a['processing_context'],b['processing_context']],rois=[a['roi'],b['roi']],selftest=c['runtime'][1],image='osd_release/mode_0.png',scope='Actual CPU/DMA/DDR and internal display pixels, not physical HDMI or recognition accuracy')
    (OUT/'final_view_validation.json').write_text(json.dumps(result,indent=2))
finally:
    control('--mode',0,'--median',1,'--memory',0,'--menu',8,'--ai-policy',2,
            '--roi',736,302,960,540,'--output-size',960,540,'--position',320,240,'--roi-enable',1,
            '--sobel-threshold',128,'--canny-threshold',80)
    first=control();time.sleep(3);last=control()
    assert last['roi_frame_id']!=first['roi_frame_id'] and last['memory']==0
    for key in ['config_error','render_error','scan_error','capture_discarded','scan_bad_frames','render_deadline_misses']:
        assert last[key]==0,(key,last[key])
    (OUT/'live_release.json').write_text(json.dumps(last,indent=2))
print(json.dumps(result,indent=2))
