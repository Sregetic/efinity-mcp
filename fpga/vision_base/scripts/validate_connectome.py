"""Validate same-ROI board Q14 states and report float error, not recognition accuracy."""
import argparse,json,sys
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'models'))
from connectome import fixed,floating,GRAPH,Q

def verify(directory):
 r=json.loads((directory/'result.json').read_text());c=r['connectome_record']
 assert c[6:8]==[0x10001,3] and c[9]==0,'Network version/iteration/publication contract'
 expected=fixed(r['features']);actual=np.array(r['connectome_states'],np.int16)
 assert np.array_equal(expected,actual),'Board/C Q14 states differ from host'
 err=float(np.max(np.abs(floating(r['features'])-actual.astype(float)/Q)))
 result=dict(passed=True,sequence=r['sequence'],frame_id=r['frame_id'],source_config_id=r['source_config_id'],render_config_id=r['render_config_id'],processing_context=r['processing_context'],roi=r['roi'],states=80,edges=1296,max_float_q14_state_error=err,cycles=c[8],microseconds=c[8]/100,
  output_body_ids=[GRAPH['nodes'][i]['id'] for i in GRAPH['outputs']],readout_features_q14=[int(actual[i])*4 for i in GRAPH['outputs']],trained_readout=False,real_accuracy_verified=False)
 (directory/'connectome_validation.json').write_text(json.dumps(result,indent=2));return result
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--directory',type=Path,required=True);a=p.parse_args();print(json.dumps(verify(a.directory),indent=2))
