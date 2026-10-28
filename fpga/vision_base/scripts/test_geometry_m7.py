"""Run the M7 C backend on native Canny probe dumps and small geometry fixtures."""
import argparse
import json
import subprocess
from pathlib import Path
import cv2
import numpy as np

ROOT = Path(__file__).resolve().parents[1]


def wsl(path):
    path = path.resolve().as_posix()
    return '/mnt/' + path[0].lower() + path[2:]


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--native-dir', type=Path, required=True)
    p.add_argument('--output-dir', type=Path, required=True)
    a = p.parse_args()
    out = a.output_dir.resolve()
    out.mkdir(parents=True, exist_ok=True)
    native = a.native_dir.resolve()
    cases = []

    def add(name, mask, classes, gray=None, more=0):
        if gray is None:
            gray = (210 - (mask != 0).astype(np.uint8) * 180).astype(np.uint8)
        cases.append(dict(name=name, mask=mask, gray=gray, classes=classes, more=more))

    def blank():
        return np.zeros((270, 480), np.uint8)

    add('blank', blank(), [])
    m = blank(); cv2.rectangle(m, (40, 50), (180, 130), 255, 1)
    add('rectangle', m, [2])
    m = blank(); cv2.circle(m, (220, 130), 45, 255, 1)
    add('circle', m, [1])
    add('inverted_circle', m, [1], 255 - (210 - (m != 0).astype(np.uint8) * 180))
    m = blank(); cv2.polylines(m, [cv2.boxPoints(((220, 130), (120, 60), 31)).astype(np.int32)], True, 255, 1)
    add('rotated_rectangle', m, [2])
    m = blank(); cv2.rectangle(m, (20, 30), (100, 90), 255, 1); cv2.circle(m, (340, 190), 40, 255, 1)
    add('two_objects', m, [1, 2])
    m = blank(); cv2.rectangle(m, (70, 40), (410, 230), 255, 1); cv2.circle(m, (220, 130), 35, 255, 1)
    add('nested_distinct_objects', m, [1, 2])
    m = blank(); cv2.circle(m, (220, 130), 40, 255, 1); cv2.circle(m, (220, 130), 38, 255, 1)
    add('one_double_edge_circle', m, [1])
    m = blank(); cv2.rectangle(m, (4, 4), (30, 30), 255, 1); cv2.rectangle(m, (440, 5), (474, 28), 255, 1)
    cv2.circle(m, (22, 243), 15, 255, 1); cv2.rectangle(m, (445, 233), (473, 262), 255, 1)
    add('four_screen_corners', m, [1, 2, 2, 2])
    m = blank()
    for i in range(5): cv2.rectangle(m, (10 + i*90, 60), (70 + i*90, 110 + i*5), 255, 1)
    add('five_objects', m, [2, 2, 2, 2], more=1)
    m = blank(); cv2.line(m, (60, 60), (60, 150), 255); cv2.line(m, (60, 150), (200, 150), 255); cv2.line(m, (200, 150), (200, 60), 255)
    add('open_outline', m, [])

    def face_outline(cx, cy, rx=26, ry=36, eyes=True, mouth=True):
        m = blank()
        cv2.ellipse(m, (cx, cy), (rx, ry), 0, 0, 360, 255, 1)
        if eyes:
            for side in (-1, 1):
                cv2.ellipse(m, (cx+side*rx//3, cy-ry//5), (max(3,rx//6), max(1,ry//18)), 0, 0, 360, 255, 1)
        cv2.polylines(m, [np.array([[cx,cy-ry//8],[cx-2,cy+ry//5],[cx+2,cy+ry//5]])], False, 255, 1)
        if mouth:
            cv2.ellipse(m, (cx, cy+ry//2), (rx//3, max(2,ry//10)), 0, 0, 360, 255, 1)
        return m

    for name, cx, cy, rx, ry in [('edge_face_left_top',35,45,26,36), ('edge_face_right_top',443,45,26,36),
                                ('edge_face_left_bottom',35,224,26,36), ('edge_face_right_bottom',443,224,26,36),
                                ('edge_face_large',240,135,80,106)]:
        add(name, face_outline(cx,cy,rx,ry), None)
        cases[-1]['faces'] = 1
    m = face_outline(90,110) | face_outline(350,155)
    cv2.rectangle(m,(200,30),(260,70),255,1)
    add('two_edge_faces_and_rectangle',m,None);cases[-1]['faces']=2
    for name, eyes, mouth in [('head_without_eyes',False,True), ('head_without_mouth',True,False)]:
        add(name,face_outline(240,135,eyes=eyes,mouth=mouth),None);cases[-1]['faces']=0

    def gray480(im):
        g = (im[:, :, 2].astype(np.uint32)*77 + im[:, :, 1].astype(np.uint32)*150 + im[:, :, 0].astype(np.uint32)*29 + 128) >> 8
        return ((g.reshape(270, 4, 480, 4).sum((1, 3)) + 8) >> 4).astype(np.uint8)

    for name, source in [('photo_raw_v2', ROOT/'results/photo_edge_geometry_20261028/whole_photo_input.png'),
                         ('face_raw_v2', native/'face_input.png'), ('two_faces_raw', native/'two_faces_input.png')]:
        words = np.array([int(v, 16) for v in (native/(name+'_bitmap.mem')).read_text().split()], dtype='<u4')
        assert len(words) == 4050
        mask = np.unpackbits(words.view(np.uint8), bitorder='little').reshape(270, 480)*255
        image = cv2.imread(str(source))
        add(name, mask, None, gray480(image))
        rgb = image[2::4, 2::4, ::-1].astype(np.uint32)
        bright = rgb.max(2) >= 64
        q = np.where(bright[:, :, None], (rgb*31+127)//255, rgb >> 1)
        decoded = np.where(bright[:, :, None], (q << 3) | (q >> 2), q << 1)
        packed_gray = ((decoded[:, :, 0]*77 + decoded[:, :, 1]*150 + decoded[:, :, 2]*29 + 128) >> 8).astype(np.uint8)
        add(name+'_packed', mask, None, packed_gray)

    add('gray_face_without_edges', blank(), [], next(c['gray'] for c in cases if c['name']=='face_raw_v2'))

    with (out/'cases.bin').open('wb') as f:
        for c in cases:
            f.write(np.packbits(c['mask'].reshape(-1) != 0, bitorder='little').tobytes())
            f.write(c['gray'].tobytes())
    compiler = ['wsl.exe', '-d', 'Ubuntu-24.04', '--exec', 'gcc', '-O2', '-DVISION_MULHI_CFU', '-DINT8_TEST', '-g', '-fsanitize=address,undefined',
                '-std=c11', '-Wall', '-Wextra', '-Wno-misleading-indentation', '-o', wsl(out/'geometry_host')]
    compiler += [wsl(ROOT/s) for s in ['sim/test_geometry_m7.c', 'firmware/vision/geometry_m7.c',
                                     'firmware/vision/geometry_face.c','firmware/vision/geometry_letters.c']]
    r = subprocess.run(compiler, capture_output=True)
    (out/'compile.stdout').write_bytes(r.stdout); (out/'compile.stderr').write_bytes(r.stderr)
    r.check_returncode()
    r = subprocess.run(['wsl.exe', '-d', 'Ubuntu-24.04', '--exec', wsl(out/'geometry_host'),
                        wsl(out/'cases.bin')], capture_output=True)
    (out/'host.stdout').write_bytes(r.stdout); (out/'host.stderr').write_bytes(r.stderr)
    r.check_returncode()
    results = [json.loads(s) for s in r.stdout.decode('utf-8').splitlines()]
    assert len(results) == len(cases)
    for c, r in zip(cases, results):
        r['name'] = c['name']
        if c['classes'] is not None:
            assert sorted(b[0] for b in r['boxes']) == c['classes'], r
            assert r['more'] == c['more'], r
        else:
            nfaces = sum(b[0] == 3 for b in r['boxes'])
            wanted = c['faces'] if 'faces' in c else {'photo_raw_v2': 0, 'face_raw_v2': 1, 'two_faces_raw': 2}[c['name'].removesuffix('_packed')]
            assert nfaces == wanted, r
            if c['name'].startswith('photo_raw_v2'):
                assert any(b[0] == 2 and abs(b[1]-249) < 5 and abs(b[2]-113) < 5 and abs(b[3]-364) < 5 and abs(b[4]-162) < 5 for b in r['boxes']), r
        assert r['complex'] == 0, r
    # Require the actual face locations, not just a matching total count.
    targets = {'face_raw_v2': [(224,60)], 'two_faces_raw': [(110,125),(350,175)]}
    for r in results:
        base = r['name'].removesuffix('_packed')
        if base in targets:
            boxes = [b for b in r['boxes'] if b[0]==3]
            assert all(sum(b[1]<x<b[3] and b[2]<y<b[4] for b in boxes)==1 for x,y in targets[base]), r
            assert all(sum(b[1]<x<b[3] and b[2]<y<b[4] for x,y in targets[base])==1 for b in boxes), r
    by_name = {r['name']: r for r in results}
    for name in ('photo_raw_v2', 'face_raw_v2', 'two_faces_raw'):
        assert by_name[name]['boxes'] == by_name[name+'_packed']['boxes']
    (out/'result.json').write_text(json.dumps(results, indent=2), encoding='utf-8')
    print(f'PASS {len(results)} M7 shared edge-contour circle/rectangle/face cases; ASan/UBSan clean; {out}')


if __name__ == '__main__':
    main()
