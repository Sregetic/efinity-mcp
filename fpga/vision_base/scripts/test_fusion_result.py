from read_fusion_result import decode
w=[0x46555331,7,0x22f,100,900,4,3,21,640|(300<<16),800|(500<<16),0x7f0180ff,600|(250<<16),240|(300<<16),17,0,0]
r=decode(w)
assert r['frame_id']==100 and r['source_config_id']==900 and r['render_config_id']==4
assert r['scores']==[-1,-128,1,127] and r['roi']==[600,250,240,300]
assert r['state']=='test' and r['automatic_roi'] and r['synthetic_model']
for v in [w[:-1],w[:15]+[1],[0,*w[1:]],w[:2]+[0xa107a107]+w[3:]]:
 try:decode(v)
 except ValueError:pass
 else:raise AssertionError('Partial or wrong-version record accepted')
print('PASS fusion record source/render/model/context, signed scores and incomplete record rejection')
