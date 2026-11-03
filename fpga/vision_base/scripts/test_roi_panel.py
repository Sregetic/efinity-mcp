"""Run directly: saved galleries survive reload and board work cannot block images."""
import json
import threading
from pathlib import Path
from tempfile import TemporaryDirectory
from types import SimpleNamespace
from urllib.error import HTTPError
from urllib.request import Request,urlopen
import roi_panel as panel
from capture_mode_images import NAMES,write_png

with TemporaryDirectory() as temporary:
    panel.out=Path(temporary)
    panel.a=SimpleNamespace(url='TEST',sensor='sc431hai')
    directory=panel.out/'mode_frames_1';directory.mkdir()
    modes=list(NAMES)
    images=[dict(mode=m,file='source.png' if m=='source' else f'mode_{m}.png',frame_id=42,config_id=7) for m in modes]
    metadata=dict(passed=True,context=dict(held_source_frame_id=42,applied_config_id=7),images=images,canny_epoch=9)
    def save_capture(target,data):
        for item in data['images']:write_png(target/item['file'],2,1,bytes([10,20,30,40,50,60]))
        (target/'images.json').write_text(json.dumps(data),encoding='utf-8')
        (target/'restore.json').write_text('{}',encoding='utf-8')
    save_capture(directory,metadata)
    published=panel.publish_images(directory)
    incomplete=panel.out/'mode_frames_2';incomplete.mkdir()
    (incomplete/'images.json').write_text('{"images":[]}',encoding='utf-8')
    try:panel.publish_images(incomplete)
    except ValueError:pass
    else:raise AssertionError('Partial capture replaced the completed gallery')

    server=panel.ThreadingHTTPServer(('127.0.0.1',0),panel.Handler)
    thread=threading.Thread(target=server.serve_forever);thread.start()
    base=f'http://127.0.0.1:{server.server_port}'
    def get(path):
        with urlopen(base+path,timeout=3) as response:return response.read()
    entered=threading.Event();requested=threading.Event();finished=threading.Event()
    errors=[]
    calls=[]
    def fake_run(command,**kwargs):
        calls.append(command)
        entered.set()
        if '--output-dir' in command:
            target=Path(command[-1]);target.mkdir()
            save_capture(target,dict(metadata,context=dict(held_source_frame_id=43,applied_config_id=8),
                                     images=[dict(i,frame_id=43,config_id=8) for i in images]))
        return SimpleNamespace(stdout='{"mode":0}')
    panel.subprocess.run=fake_run
    def board_request():
        requested.set()
        try:assert json.loads(get('/state'))==dict(mode=0)
        except Exception as error:errors.append(error)
        finally:finished.set()
    try:
        with panel.board_lock:
            worker=threading.Thread(target=board_request);worker.start();assert requested.wait(1)
            for _ in range(2):assert json.loads(get('/mode-gallery'))==published
            for item in images:assert get(published['image_base']+item['file']).startswith(b'\x89PNG\r\n\x1a\n')
            assert not entered.is_set() and not finished.is_set(), 'Board request bypassed serialization'
        worker.join(3);assert finished.is_set() and not errors,errors
        request=Request(base+'/modes',data=b'{}',headers={'Content-Type':'application/json','Origin':base})
        with urlopen(request,timeout=3) as response:new=json.load(response)
        assert new['context']['held_source_frame_id']==43 and new['image_base']!=published['image_base']
        assert json.loads(get('/mode-gallery'))==new
        assert get(published['image_base']+'source.png')==get(new['image_base']+'source.png')
        for policy in [0,1,2]:
            request=Request(base+'/ai-policy',data=json.dumps(dict(policy=policy)).encode(),headers={'Content-Type':'application/json','Origin':base})
            with urlopen(request,timeout=3) as response:assert json.load(response)==dict(mode=0)
            assert calls[-1][-2:]==['--ai-policy',str(policy)]
        for policy in [3,True,'1']:
            request=Request(base+'/ai-policy',data=json.dumps(dict(policy=policy)).encode(),headers={'Content-Type':'application/json','Origin':base})
            before=len(calls)
            try:urlopen(request,timeout=3)
            except HTTPError as error:assert error.code==400
            else:raise AssertionError('Invalid policy reached hardware')
            assert len(calls)==before
        for model in [1,2]:
            request=Request(base+'/ai-policy',data=json.dumps(dict(policy=2,model=model)).encode(),headers={'Content-Type':'application/json','Origin':base})
            with urlopen(request,timeout=3) as response:assert json.load(response)==dict(mode=0)
            assert calls[-1][-4:]==['--ai-policy','2','--recognition-model',{1:'fomo',2:'m7'}[model]]
        for model in [0,3,True,'m7']:
            request=Request(base+'/ai-policy',data=json.dumps(dict(policy=2,model=model)).encode(),headers={'Content-Type':'application/json','Origin':base})
            before=len(calls)
            try:urlopen(request,timeout=3)
            except HTTPError as error:assert error.code==400
            else:raise AssertionError('Invalid model reached hardware')
            assert len(calls)==before
        for path in ['/mode_frames_1/../mode_gallery.json','/mode_frames_1/mode_8.png','/mode_frames_99/source.png']:
            try:get(path)
            except HTTPError as error:assert error.code==404
            else:raise AssertionError(f'Unexpected image path served: {path}')
        request=Request(base+'/apply',data=b'{}',headers={'Content-Type':'application/json','Origin':'http://other-origin'})
        try:urlopen(request,timeout=3)
        except HTTPError as error:assert error.code==400
        else:raise AssertionError('Cross-origin board operation accepted')
        html=get('/').decode('utf-8')
        assert html.index('id="gallery"')<html.index('id="state"')
        assert 'loadImages();refresh();' in html and 'button:not([data-view])' in html
        display=html.split('id="mode"')[1].split('</select>')[0]
        assert '<option value="7">' not in display and 'id="recognitionModel"' in html
        model_select=html.split('id="recognitionModel"')[1].split('</select>')[0]
        assert 'value="0"' not in model_select and 'value="1"' in model_select and 'value="2" selected' in model_select
    finally:server.shutdown();server.server_close();thread.join()
print('PASS: eight-image gallery, historical image routes, FOMO/M7 and rejected retired BASE model, legacy policy caller, static reads, serialization and origin boundaries')
