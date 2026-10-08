"""Same held input, actual changed weights, atomic model/scores and restore."""
import json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'scripts'))
from validate_ai_result import verify
OUT=Path(__file__).parent/'model_versions'
def read(p):return json.loads((OUT/p).read_text())
before=read('repaired_before/result.json');rows=[]
assert (OUT/'before/gray.bin').read_bytes()==(OUT/'repaired_before/gray.bin').read_bytes(),'Held input changed during debug recovery'
for version in [2,1]:
    v=str(version);a=read(v+'/ai/result.json');f=read(v+'/fusion/result.json');m=read(v+'/match.json')
    assert a['frame_id']==f['frame_id']==before['frame_id']==93939
    assert a['render_config_id']==f['render_config_id']==16 and a['processing_context']==f['processing_context']==14
    assert a['model_id']==f['model_id']==version and a['logits']==f['scores'] and f['state']=='test'
    assert m['ai_match'] and m['ai_age_frames']==0
    assert (OUT/v/'ai/gray.bin').read_bytes()==(OUT/'repaired_before/gray.bin').read_bytes()
    rows.append(dict(version=version,frame_id=a['frame_id'],render=a['render_config_id'],scores=a['logits'],validation=verify(OUT/v/'ai',OUT/v/'weights.bin')))
assert rows[0]['scores']!=rows[1]['scores'] and rows[1]['scores']==before['logits']
result=dict(passed=True,scope='Synthetic weight version1->2->1; not a real-model accuracy benchmark',source_frame=93939,render_config=16,processing_context=14,input_bytes_identical=True,changed_scores=True,restored_original_scores=True,cases=rows)
(OUT/'validation.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
