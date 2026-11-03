from pathlib import Path
import importlib.util,json,numpy as np
from PIL import Image
O=Path(__file__).resolve().parent/'board_release';R=O.parents[2]
spec=importlib.util.spec_from_file_location('oracle',R/'scripts/test_canny_smooth.py');oracle=importlib.util.module_from_spec(spec);spec.loader.exec_module(oracle)
b=np.asarray(Image.open(O/'edge.pgm'))!=0;ref=oracle.fitted(b,oracle.load_table());pred=np.zeros_like(ref);pred[2:,2:]=ref[:-2,:-2]
actual=np.asarray(Image.open(O/'canny/mode_5.png'));mask=np.ones(ref.shape,bool);mask[:4,:]=False;mask[:,:4]=False;mask[:40,:432]=False
different=int((np.any(actual!=pred[:,:,None],axis=2)&mask).sum());Image.fromarray(pred).save(O/'canny/reference.png')
i=json.loads((O/'canny/images.json').read_text());e=json.loads((O/'edge.json').read_text())
r=dict(passed=different==0,compared_pixels=int(mask.sum()),different_pixels=different,frame_id=i['context']['roi_frame_id'],canny_epoch=e['canny_epoch'],held_binary_identical=True,active_requested_threshold=96)
(O/'canny_numeric.json').write_text(json.dumps(r,indent=2),encoding='utf-8');print(json.dumps(r,indent=2));assert different==0,r
