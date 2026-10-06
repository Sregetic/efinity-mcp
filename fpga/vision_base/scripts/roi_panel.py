"""Local control panel; hardware is serialized, saved images load independently."""
import argparse,json,re,subprocess,sys,time
from datetime import datetime
from http.server import BaseHTTPRequestHandler,ThreadingHTTPServer
from pathlib import Path
from threading import RLock

root=Path(__file__).resolve().parents[1]
out=root/'results/roi_live_20261004'
# ponytail: one board lock; split by device only if this panel serves multiple boards.
board_lock=RLock()

def control(args):
    with board_lock:
        result=subprocess.run([sys.executable,str(root/'scripts/vision_control.py'),'--url',a.url,'--sensor',a.sensor,'--roi-status',*args],capture_output=True,text=True,check=True)
    return json.loads(result.stdout)

def publish_images(directory):
    result=json.loads((directory/'images.json').read_text(encoding='utf-8'))
    if not result.get('passed'):raise ValueError('Image capture has not completed')
    result['restored']=json.loads((directory/'restore.json').read_text(encoding='utf-8'))
    result['image_base']=f'/{directory.name}/'
    result['captured_at']=datetime.fromtimestamp((directory/'images.json').stat().st_mtime).isoformat(timespec='seconds')
    pending=out/'mode_gallery.tmp'
    pending.write_text(json.dumps(result,ensure_ascii=False),encoding='utf-8')
    pending.replace(out/'mode_gallery.json')
    return result

class Handler(BaseHTTPRequestHandler):
    def response(self,code,data,kind='application/json; charset=utf-8'):
        blob=data if isinstance(data,bytes) else json.dumps(data,ensure_ascii=False).encode('utf-8')
        self.send_response(code);self.send_header('Content-Type',kind);self.send_header('Content-Length',str(len(blob)))
        if not kind.startswith('image/'):self.send_header('Cache-Control','no-store')
        self.end_headers();self.wfile.write(blob)
    def do_GET(self):
        if self.path=='/':self.response(200,(root/'scripts/roi_panel.html').read_bytes(),'text/html; charset=utf-8')
        elif self.path=='/state':
            try:self.response(200,control([]))
            except subprocess.CalledProcessError as e:self.response(502,dict(error=e.stderr))
        elif self.path=='/mode-gallery':
            manifest=out/'mode_gallery.json'
            if manifest.is_file():self.response(200,manifest.read_bytes())
            else:self.response(404,dict(error='尚未保存完整图像组，请读取原图与全部模式'))
        elif re.fullmatch(r'/mode_frames(?:_\d+)?/(source|mode_[0-7])\.png',self.path.split('?')[0]):
            path=out/self.path.split('?')[0].lstrip('/')
            if path.is_file():self.response(200,path.read_bytes(),'image/png')
            else:self.response(404,dict(error='Snapshot image not found'))
        elif self.path.split('?')[0]=='/preview.png':self.response(200,(out/'panel_preview.png').read_bytes(),'image/png')
        elif self.path.split('?')[0]=='/flyhash/edge.png':self.response(200,(out/'flyhash'/'edge.png').read_bytes(),'image/png')
        else:self.response(404,dict(error='Unknown panel path'))
    def do_POST(self):
        with board_lock:self.hardware_POST()
    def hardware_POST(self):
        try:
            origin='http://'+self.headers['Host']
            if self.headers.get('Origin')!=origin or self.headers.get('Content-Type')!='application/json':raise ValueError('Use this local panel origin and JSON input')
            data=json.loads(self.rfile.read(int(self.headers['Content-Length'])))
            if self.path=='/apply':
                values=[*data['roi'],*data['size'],*data['position'],data['mode'],data['threshold']]
                if any(type(v) is not int for v in values):raise ValueError('Coordinates, dimensions, mode and threshold are integers')
                if any(type(data[k]) is not bool for k in ['enabled','frozen','median']):raise ValueError('Enable/freeze/median are boolean controls')
                args=['--roi',*map(str,data['roi']),'--output-size',*map(str,data['size']),'--position',*map(str,data['position']),'--roi-enable',str(int(data['enabled'])),'--memory',str(int(data['frozen'])),'--mode',str(data['mode']),'--threshold',str(data['threshold']),'--median',str(int(data['median']))]
                result=control(args)
            elif self.path=='/modes':
                directory=out/f'mode_frames_{time.time_ns()}'
                subprocess.run([sys.executable,str(root/'scripts/capture_mode_images.py'),'--url',a.url,'--sensor',a.sensor,
                                '--output-dir',str(directory)],check=True,capture_output=True,text=True)
                result=publish_images(directory)
            elif self.path=='/flyhash':
                subprocess.run([sys.executable,str(root/'scripts/flyhash_board.py'),'--url',a.url,'--sensor',a.sensor,
                                '--output-dir',str(out/'flyhash')],check=True,capture_output=True,text=True)
                result=json.loads((out/'flyhash'/'result.json').read_text(encoding='utf-8'))
            elif self.path=='/preview':
                deadline=time.monotonic()+10
                while not control([])['canny_ready']:
                    if time.monotonic()>deadline:raise ValueError('Canny analysis is still pending; inspect the board status')
                subprocess.run([sys.executable,str(root/'scripts/capture_edge_probe.py'),'--url',a.url,'--output',str(out/'panel_preview')],check=True,capture_output=True,text=True)
                python=Path.home()/'.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
                subprocess.run([str(python),'-E','-c','from PIL import Image; import sys; Image.open(sys.argv[1]).save(sys.argv[2])',str(out/'panel_preview.pgm'),str(out/'panel_preview.png')],check=True,capture_output=True,text=True)
                probe=json.loads((out/'panel_preview.json').read_text(encoding='utf-8'))
                result=dict(captured=True,canny_epoch=probe['canny_epoch'],context=probe['context'])
            else:raise ValueError('Unknown operation')
            self.response(200,result)
        except (ValueError,KeyError,json.JSONDecodeError) as e:self.response(400,dict(error=str(e)))
        except subprocess.CalledProcessError as e:self.response(502,dict(error=e.stderr))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--url',required=True);p.add_argument('--port',type=int,default=0);p.add_argument('--sensor',choices=['sc431hai','sc2210'],default='sc431hai');a=p.parse_args()
    out.mkdir(parents=True,exist_ok=True)
    server=ThreadingHTTPServer(('127.0.0.1',a.port),Handler)
    url=f'http://127.0.0.1:{server.server_port}'
    (out/'panel_server.json').write_text(json.dumps(dict(url=url,pid=__import__('os').getpid(),jtag_url=a.url)),encoding='utf-8')
    print(url,flush=True);server.serve_forever()
