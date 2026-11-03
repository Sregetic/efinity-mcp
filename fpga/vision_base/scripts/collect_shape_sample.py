"""One labelled FPGA source image; train/test are separate physical sessions/cards."""
import argparse,json,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
VENDOR=Path('F:/Efinity/2026.1/python311/bin/python.exe')

def check_groups(records,split,session,card):
    if not session or not card:raise ValueError('Capture session and physical card IDs are required')
    for r in records:
        if r['split']!=split and (r['session_id']==session or r['card_id']==card):
            raise ValueError('Train/test must use independently collected sessions and physical cards')

def main():
    p=argparse.ArgumentParser();p.add_argument('--url',required=True);p.add_argument('--dataset',type=Path,required=True)
    p.add_argument('--split',choices=['train','test'],required=True);p.add_argument('--label',choices=['blank','circle','rectangle','triangle'],required=True)
    p.add_argument('--session-id',required=True);p.add_argument('--card-id',required=True)
    p.add_argument('--roi',nargs=4,type=int,default=[640,300,640,480]);a=p.parse_args();x,y,w,h=a.roi
    if x<0 or y<0 or w<1 or h<1 or x+w>1920 or y+h>1080:raise ValueError('ROI must fit1920x1080 source')
    a.dataset.mkdir(parents=True,exist_ok=True);manifest=a.dataset/'manifest.jsonl'
    records=[json.loads(line) for line in manifest.read_text(encoding='utf-8').splitlines() if line.strip()] if manifest.exists() else []
    check_groups(records,a.split,a.session_id,a.card_id)
    directory=a.dataset/'captures'/str(time.time_ns())
    subprocess.run([str(VENDOR),str(ROOT/'scripts/capture_mode_images.py'),'--url',a.url,'--output-dir',str(directory),
        '--modes','source','--source-native-order','--rows',str(y),str(h)],check=True)
    captured=json.loads((directory/'images.json').read_text(encoding='utf-8'))
    if not captured['passed']:raise RuntimeError('Capture did not complete')
    image=captured['images'][0]
    record=dict(kind='real_camera',split=a.split,label=a.label,session_id=a.session_id,card_id=a.card_id,
        image=str((directory/image['file']).resolve()),roi=[x,0,w,h],source_roi=a.roi,source_frame_id=image['frame_id'],config_id=image['config_id'],preprocessing='packed_frame_native_channels_before_gamma')
    with manifest.open('a',encoding='utf-8') as f:f.write(json.dumps(record,ensure_ascii=False)+'\n')
    print(json.dumps(record,ensure_ascii=False,indent=2))

if __name__=='__main__':main()
