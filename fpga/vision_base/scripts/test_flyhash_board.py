"""Runnable host check; no hardware or vendor Python modules required."""
from flyhash_board import decode_status,decode_profile,check_result,encode,edge_features
from capture_mode_images import check_frozen_source

if __name__=='__main__':
    # Real board incident: a committed frozen field, sampled during the next VS.
    source=dict(source_held=1,source_frozen=1,roi_frame_id=7941,held_source_frame_id=7941,roi_frame_ok=0)
    check_frozen_source(source)
    for key,value in [('source_held',0),('source_frozen',0),('held_source_frame_id',7942)]:
        bad=dict(source);bad[key]=value
        try:check_frozen_source(bad)
        except RuntimeError:pass
        else:raise AssertionError(key)
    features=edge_features(bytes([255]*129600),480,270,(0,0,480,270))
    assert features==[255]*64
    context=dict(frame_id=28,config_id=8,epoch=24)
    status=(1<<31)|(1<<27)|(64<<20)|(1<<13)|4877
    v=(0x56495331<<160)|(0x2610051d<<128)|(24<<96)|(28<<64)|(8<<32)|status
    result=decode_status(v);result['hash']=f'{encode(features):064x}'
    check_result(result,context,features)
    fw=decode_status((v&~(0xffffffff<<128))|(0x2610071d<<128))
    assert fw['cycles'] is None and fw['cycle_low13']==4877 and fw['backend']=='firmware'
    profile=(0x56495331<<160)|(0x26100720<<128)|(1<<96)|(25000<<64)|(100000000<<32)|1
    fw.update(decode_profile(profile));fw['hash']=result['hash'];check_result(fw,context,features)
    for key,value in [('firmware_state',0),('clock_hz',148500000),('cycles',None)]:
        bad=dict(fw);bad[key]=value
        try:check_result(bad,context,features)
        except RuntimeError:pass
        else:raise AssertionError(key)
    for key,value in [('frame_id',29),('config_id',9),('epoch',25),('loaded',63),('valid',0),('busy',1),('fault',1),('hash','0'*64),('cycles',8192)]:
        bad=dict(result);bad[key]=value
        try:check_result(bad,context,features)
        except RuntimeError:pass
        else:raise AssertionError(key)
    assert edge_features(bytes(129600),480,270,(0,0,480,270))==[0]*64
    print('PASS FlyHash host codec,480x270 occupancy,frame/config/epoch binding,hardware result checks')
