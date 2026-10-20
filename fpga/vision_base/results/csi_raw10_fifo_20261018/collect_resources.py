from pathlib import Path
import difflib,json,re,shutil,xml.etree.ElementTree as ET
ROOT=Path('F:/Project/fpga/vision_base');P=Path(__file__).resolve().parent
old=json.loads((P/'before_manifest.json').read_text(encoding='utf-8-sig'));new=json.loads((ROOT/'artifacts/camera/manifest.json').read_text(encoding='utf-8-sig'))
changed=[k for k,v in new['source_sha256'].items() if old['source_sha256'].get(k)!=v]
assert changed==['board/ti60f225_v4/rtl/csi_rx_controller.sv'],changed
route=ET.parse(ROOT/'artifacts/camera/ti60f225_oob.route.rpt.xml').getroot()
fields={e.attrib['name']:e.attrib.get('value') for e in route.iter() if e.tag.endswith('group_data')}
xlr=int(fields['XLRs'].split('/')[0]);ram=int(fields['Memory Blocks'].split('/')[0]);dsp=int(fields['DSP Blocks'].split('/')[0])
assert new['wns_ns']>=0 and new['whs_ns']>=0 and fields['Unassigned Core Pins']=='0'
def csi(path):
    s=path.read_text(errors='replace');s=s[s.index('Module Resource Usage Distribution Estimates (begin)'):]
    line=next(x for x in s.splitlines() if '+inst_efx_csi2_rx:' in x)
    n=[int(x) for x in re.findall(r'(\d+)\(\d+\)',line)]
    return dict(ff=n[0],srl=n[1],add=n[2],lut=n[3],ram=n[5])
before=dict(xlr=57356,ram=244,dsp=62,wns_ns=old['wns_ns'],whs_ns=old['whs_ns'])
after=dict(xlr=xlr,ram=ram,dsp=dsp,free_xlr=60800-xlr,free_ram=256-ram,free_dsp=160-dsp,wns_ns=new['wns_ns'],whs_ns=new['whs_ns'],unassigned_core_pins=0)
result=dict(before=before,after=after,released={k:before[k]-after[k] for k in ['xlr','ram','dsp']},changed_build_inputs=changed,
            csi_before=csi(ROOT/'results/roi_render_perf_20261018/release/ti60f225_oob.map.rpt'),csi_after=csi(ROOT/'artifacts/camera/ti60f225_oob.map.rpt'),snapshot_ram=5,
            sensor_profile=new['sensor_profile'],flash_written=False)
(P/'resources.json').write_text(json.dumps(result,indent=2))
a=(P/'csi_rx_controller.before.sv').read_text().splitlines(True);b=(ROOT/changed[0]).read_text().splitlines(True)
(P/'source.diff').write_text(''.join(difflib.unified_diff(a,b,fromfile='before/'+changed[0],tofile='after/'+changed[0])))
release=P/'release';release.mkdir(exist_ok=True)
for f in (ROOT/'artifacts/camera').iterdir():
    if f.is_file():shutil.copyfile(f,release/f.name)
shutil.copyfile(ROOT/'results/board.compile.status.json',P/'compile.json')
program=ROOT/'results/programming/20261018_182044'
for name in ['program.json','program.log']:shutil.copyfile(program/name,P/name)
print(json.dumps(result,indent=2))
