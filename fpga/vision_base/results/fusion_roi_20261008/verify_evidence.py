"""Recheck stored board pixels, CPU values, frozen identities and ROI boxes."""
import json,sys
from pathlib import Path
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[2];sys.path[:0]=[str(ROOT/'models'),str(ROOT/'scripts')]
from shape_cards import gray_roi
from validate_ai_result import verify
OUT=Path(__file__).parent
def read(path):return json.loads((OUT/path).read_text())
frame=read('frozen.json')['roi_frame_id'];rows=[]
for name,ai,fusion,match,box_image,source_dir in [
    ('full','frozen_ai','frozen_fusion','ai_frozen.json','frozen_images/mode_6.png','frozen_images'),
    ('automatic','automatic_ai_final','automatic_fusion_after_images','automatic_match_final.json','automatic_images/mode_6.png','frozen_images'),
    ('verified_full','verified_full_ai','verified_full_fusion','verified_full_match.json','verified_full_box/mode_6.png','verified_source'),
    ('verified_zoom','verified_zoom_ai','verified_zoom_fusion','verified_zoom_match.json','verified_zoom_box/mode_6.png','verified_source')]:
    source=Image.open(OUT/source_dir/'source.png');source_frame=read(source_dir+'/images.json')['images'][0]['frame_id']
    a=read(ai+'/result.json');f=read(fusion+'/result.json');m=read(match)
    tensor=np.frombuffer((OUT/ai/'gray.bin').read_bytes(),dtype=np.uint8).reshape(32,32)
    assert a['frame_id']==f['frame_id']==m['ai_frame']==source_frame
    assert a['render_config_id']==f['render_config_id']==m['ai_render_config']
    assert a['processing_context']==f['processing_context']==m['ai_context']
    assert f['state']=='test' and f['synthetic_model'] and m['ai_match'] and m['ai_age_frames']==0
    assert a['roi']==f['roi'] and a['logits']==f['scores']
    assert np.array_equal(tensor,gray_roi(source,a['roi'])),name+' source/DMA pixels'
    verified=verify(OUT/ai,ROOT/'models/shape_cards_bringup/shape_cards_weights.bin')
    x0,y0,x1,y1=f['display_box'];image=np.asarray(Image.open(OUT/box_image))
    line=image[0 if image.shape[0]==1 else y0]
    assert np.all(line[x0:x1+1]==[0,255,255]),name+' projected box pixels'
    rows.append(dict(case=name,frame=source_frame,render=f['render_config_id'],context=f['processing_context'],roi=f['roi'],scores=f['scores'],automatic=f['automatic_roi'],geometry_class=f['geometry_class'],**{'cpu_validation':verified}))
assert (OUT/'verified_full_ai/gray.bin').read_bytes()==(OUT/'verified_zoom_ai/gray.bin').read_bytes()
assert read('frozen_fusion/result.json')==read('frozen_fusion_after_images/result.json')
old=read('scheduler_none/result.json');fresh=read('scheduler_recovered/result.json')
assert old['state']=='none' and fresh['inference_valid'] and fresh['automatic_roi'] and fresh['geometry_class']==1
assert old['frame_id']==fresh['frame_id']==frame and old['render_config_id']==fresh['render_config_id']==6
stale=read('stale/match.json');assert stale['ai_enabled'] and not stale['ai_match'] and stale['ai_age_frames']>0
assert not np.any(np.all(np.asarray(Image.open(OUT/'stale/box_line/mode_6.png'))==[0,255,255],axis=2))
result=dict(passed=True,scope='Actual board I1/I3 data/pixel checks; calibrated camera background spot is not a physical shape-card accuracy test',cases=rows,same_source_rerenders=True,automatic_recalibration_retriggered=True,stale_roi_hidden=True)
(OUT/'board_validation.json').write_text(json.dumps(result,indent=2));print('PASS source/DMA1024 pixels, CPU layers/FlyHash, I3 identities/box pixels, frozen rerender, geometry retry and stale box suppression')
