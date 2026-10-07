"""Run the official model analyzer and its resource library, without opening a GUI."""
import argparse,importlib.util,json,re,subprocess
from pathlib import Path

def main():
    p=argparse.ArgumentParser();p.add_argument('--generator-dir',type=Path,required=True)
    p.add_argument('--model',type=Path,required=True);p.add_argument('--output-dir',type=Path,required=True)
    p.add_argument('--base-xlrs',type=int,default=56669);p.add_argument('--base-rams',type=int,default=238);a=p.parse_args()
    a.output_dir.mkdir(parents=True,exist_ok=True)
    r=subprocess.run([str(a.generator_dir/'bin/tflite.exe'),str(a.model.resolve()),'8','4','128'],capture_output=True,text=True)
    text=r.stdout+r.stderr;(a.output_dir/'official_analyzer.log').write_text(text,encoding='utf-8');r.check_returncode()
    settings={k:int(v) for k,v in re.findall(r'^([a-z0-9_]+):(\d+)\s*$',text,re.M)}
    if settings['fc_mode']!=1 or any(settings[k]!=0 for k in ['conv_depthw_mode','add_mode','mul_mode','lr_mode','min_max_mode']):
        raise ValueError('This application resource comparison requires an FC-only model')
    path=a.generator_dir/'lib/resource_lib.py';spec=importlib.util.spec_from_file_location('official_resources',path)
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);util=module.ResourceUtil()
    util.initialize_param({'AXI_DW':{'val':128},'FC_MAX_IN_NODE':{'val':settings['fc_max_in_node']}})
    rows={}
    for mode in ['LITE','STANDARD']:
        resources=util.evaluate_res('FC_MODE',mode);common=util.evaluate_common_module([mode])
        if common:resources=[a+b for a,b in zip(resources,common)]
        lut,ff,adds,ram,dsp=resources
        rows[mode]=dict(luts=lut,ffs=ff,adds=adds,ram_blocks=ram,dsp_blocks=dsp,
            conservative_logic_cell_upper=lut+ff+adds,
            estimator_fits_before_bus=(lut+ff+adds<=60800-a.base_xlrs and ram<=256-a.base_rams))
    revision=subprocess.check_output(['git','-C',str(a.generator_dir),'rev-parse','HEAD'],text=True).strip()
    record=dict(model=str(a.model.resolve()),generator_revision=revision,only_operator='FULLY_CONNECTED',cache_enabled=False,
        remaining=dict(xlrs=60800-a.base_xlrs,ram_blocks=256-a.base_rams),estimates=rows,
        units_note='Official columns are LUT/FF/ADD, not measured Efinity XLR. Their sum is a conservative cell budget, not P&R.',
        selected='existing signed dot4; implement and measure a signed32 multiply/high-shift CFU before adding a full accelerator',
        existing_video_features_removed=False,native_accelerator_build_verified=False)
    (a.output_dir/'resource_comparison.json').write_text(json.dumps(record,indent=2));print(json.dumps(record,indent=2))

if __name__=='__main__':main()
