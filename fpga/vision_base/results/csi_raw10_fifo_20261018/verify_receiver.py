"""Map both actual IP5.15 configurations and check their retained pack paths."""
from pathlib import Path
import json, re, subprocess, xml.etree.ElementTree as ET

ROOT=Path('F:/Project/fpga/vision_base'); OUT=Path(__file__).resolve().parent
HOME=Path('F:/Efinity/2026.1'); MODELSIM=Path('E:/modeltech64_2020.4/win64')
source=ROOT/'board/ti60f225_v4/rtl/csi_rx_controller.sv'
s=source.read_text(); start=s.index('module `IP_MODULE_NAME(efx_csi2_rx_top)')
header=s[start:s.index(');',start)+2]
parameters=['HS_DATA_WIDTH','tINIT_NS','CLOCK_FREQ_MHZ','NUM_DATA_LANE','PACK_TYPE','AREGISTER','ENABLE_VCX','FRAME_MODE','ASYNC_STAGE','PIXEL_FIFO_DEPTH']
NS='http://www.efinixinc.com/enf_proj'; ET.register_namespace('efx',NS)
counts={}
for name,pack,depth in [('csi_base',15,1024),('csi_new',1,512)]:
    d=OUT/name;d.mkdir(exist_ok=True)
    h=header.replace('`IP_MODULE_NAME(efx_csi2_rx_top)',name).replace('HS_DATA_WIDTH = 16','HS_DATA_WIDTH = 8').replace('tINIT_NS = 400000','tINIT_NS = 100')
    h=h.replace("PACK_TYPE = 4'b1111",f'PACK_TYPE = {pack}').replace('PIXEL_FIFO_DEPTH = 1024',f'PIXEL_FIFO_DEPTH = {depth}')
    wrapper='`define MIPI_CSI2_RX_DEBUG\n'+h+'\nefx_csi2_rx_top_816397a398bd4f6e8213b75d000bd820 #(\n'+',\n'.join(f'.{p}({p})' for p in parameters)+') core(.*);\nendmodule\n'
    (d/'wrapper.sv').write_text(wrapper)
    prj=ET.Element('{'+NS+'}project',name=name,sw_version='2026.1.132.3.9')
    info=ET.SubElement(prj,'{'+NS+'}device_info')
    for tag,value in [('family','Titanium'),('device','Ti60F225'),('timing_model','I3')]:ET.SubElement(info,'{'+NS+'}'+tag,name=value)
    info=ET.SubElement(prj,'{'+NS+'}design_info',def_veri_version='sv_09',def_vhdl_version='vhdl_2008',unified_flow='false')
    ET.SubElement(info,'{'+NS+'}top_module',name=name)
    for f in [source,d/'wrapper.sv']:ET.SubElement(info,'{'+NS+'}design_file',name=f.as_posix(),version='default',library='default')
    info=ET.SubElement(prj,'{'+NS+'}constraint_info');ET.SubElement(info,'{'+NS+'}sdc_file',name='probe.sdc')
    (d/'probe.sdc').write_text('create_clock -name clk -period 10 [get_ports clk]\ncreate_clock -name byte -period 14.286 [get_ports clk_byte_HS]\ncreate_clock -name pixel -period 13.468 [get_ports clk_pixel]\n')
    info=ET.SubElement(prj,'{'+NS+'}synthesis',tool_name='efx_map')
    for key,value,typ in [('mode','speed','e_option'),('work_dir','work_syn','e_string'),('write_efx_verilog','on','e_bool')]:ET.SubElement(info,'{'+NS+'}param',name=key,value=value,value_type=typ)
    ET.ElementTree(prj).write(d/(name+'.xml'),encoding='unicode')
    cmd=[str(HOME/'python311/bin/python.exe'),str(HOME/'scripts/efx_run.py'),name+'.xml','--flow','map','--timeout','180']
    with (d/'map.log').open('w') as log:subprocess.run(cmd,cwd=d,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=240)
    net=d/'outflow'/(name+'.map.v');assert net.exists()
    text=net.read_text();assert 'depack40bit_inst' in text
    if name=='csi_new':assert not any(f'depack{n}bit_inst' in text for n in [48,56,64])
    report=(d/'outflow'/(name+'.map.rpt')).read_text()
    section=report.split('Resource Summary (begin)',1)[1].split('Resource Summary (end)',1)[0]
    counts[name]=dict(re.findall(r'(EFX_\w+)\s*:\s*(\d+)',section))
    print('PASS actual IP5.15 map',name,flush=True)
(OUT/'receiver_map_verification.json').write_text(json.dumps(dict(passed=True,scope='Actual synthesis structure only; not pixel simulation',ip_version='5.15',raw10_path_retained=True,other_pack_paths_removed=True,counts=counts),indent=2))
