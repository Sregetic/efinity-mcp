"""Production A/B and mapped-DSP checks; reference RTL remains independent."""
from pathlib import Path
import json
import re
import subprocess

ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
V=ROOT/'board/ti60f225_v4/rtl/vision'

def run(name,bench,sources,cwd=ROOT,parameters=()):
    exe=OUT/(name+'.vvp')
    cmd=['C:/iverilog/bin/iverilog.exe','-g2012','-s','tb',*parameters,'-o',str(exe),str(bench),*[str(p) for p in sources]]
    for stage,args in [('compile',cmd),('run',['C:/iverilog/bin/vvp.exe',str(exe)])]:
        with (OUT/(name+'.'+stage+'.log')).open('wb') as stream:
            subprocess.run(args,cwd=cwd,stdout=stream,stderr=subprocess.STDOUT,check=True,timeout=600)
    exe.unlink()
    print('PASS',name,flush=True)

old=(OUT/'before/board/ti60f225_v4/rtl/vision/vision_local_motion_core.sv').read_text()
(OUT/'motion_reference.sv').write_text(old.replace('module vision_local_motion_core #(', 'module vision_local_motion_core_reference #(',1))
tb=(ROOT/'sim/motion_direction/tb_local_motion_core.sv').read_text()
insert='''
wire old_ir,old_ov,old_tv,old_rv,old_fault;wire[2:0]old_direction;
wire signed[31:0]old_hx,old_vy;wire[15:0]old_active;wire[3:0]old_x0,old_y0,old_x1,old_y1;
vision_local_motion_core_reference ref_dut(clk,rst,abort_frame,iv,old_ir,first,last,clear_history,gray,
 old_ov,oready,old_tv,old_direction,old_hx,old_vy,old_active,old_rv,old_x0,old_x1,old_y0,old_y1,old_fault);
integer cycle_pairs=0;
always @(posedge clk)begin
 #1;
 if({ir,ov,tv,rv,fault,direction,hx,vy,active,x0,y0,x1,y1}!==
    {old_ir,old_ov,old_tv,old_rv,old_fault,old_direction,old_hx,old_vy,old_active,old_x0,old_y0,old_x1,old_y1})
  $fatal(1,"Motion public port/cycle mismatch %0d",cycle_pairs);
 cycle_pairs=cycle_pairs+1;
end
'''
tb=tb.replace('reg[7:0]words[',insert+'reg[7:0]words[',1)
tb=tb.replace('$display("PASS local motion core', '$display("PASS motion A/B %0d identical port cycles",cycle_pairs);\n $display("PASS local motion core',1)
(OUT/'tb_motion_ab.sv').write_text(tb)
frames=json.loads((OUT/'motion/verification.json').read_text())['fixture']['core_frames']
run('motion_ab',OUT/'tb_motion_ab.sv',[V/'vision_local_motion_core.sv',OUT/'motion_reference.sv'],cwd=OUT/'motion',parameters=['-Ptb.FRAMES='+str(frames)])

# All valid signed contrasts are differences of two 8bit gray values.
pairs=0
for a in range(-255,256):
 for b in range(-255,256):
  old_score=max(a,0)*max(b,0)+max(-a,0)*max(-b,0)
  folded=abs(a)*abs(b) if (a<0)==(b<0) else 0
  assert old_score==folded
  pairs+=1
(OUT/'motion_identity.json').write_text(json.dumps({'signed_pairs':pairs,'passed':True}))

# The earlier frozen raster is the original249RAM implementation, before either optimization.
ref=ROOT/'results/ram_pack_20261022/canny_reference.sv'
tb=(ROOT/'results/ram_pack_20261022/tb_canny_ab.sv').read_text().replace('results/ram_pack_20261022/','results/xlr_recover_20261022/')
(OUT/'tb_canny_ab.sv').write_text(tb)
run('canny_ab',OUT/'tb_canny_ab.sv',[ref,V/'vision_canny_raster.sv',V/'vision_sparse_window.sv'])

# Verify the DSP primitive netlist too: no hidden pipeline or signed-format drift.
bench='''`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg short=0;reg[6:0]sum=0;reg[7:0]weight=0;wire[9:0]c;wire[5:0]s;
reg[9:0]gold[0:1023];integer mode,a,b,n=0;
fit_mac dut(clk,short,sum,weight,c,s);
initial begin
 $readmemh("@GOLD@",gold);
 for(mode=0;mode<2;mode=mode+1)for(a=0;a<128;a=a+1)for(b=0;b<256;b=b+1)begin
  @(negedge clk);short=mode;sum=a;weight=b;@(posedge clk);#1;
  if(c!==gold[(mode<<7)|a]||s!==gold[512|(mode<<8)|b][5:0])$fatal(1,"Mapped DSP signed/latency mismatch %0d %0d %0d",mode,a,b);
  n=n+1;
 end
 $display("PASS mapped Efinity DSP primitives %0d exact cycle pairs",n);$finish;
end
endmodule
'''.replace('@GOLD@',(V/'canny_fit_q4.mem').as_posix())
(OUT/'tb_mapped_fit.sv').write_text(bench)
mapped=OUT/'fit_mac/outflow/fit_mac.map.v'
types=set(re.findall(r'^\s*(EFX_\w+)\s',mapped.read_text(),re.M))
models=Path('F:/Efinity/2026.1/sim_models/verilog')
run('mapped_fit',OUT/'tb_mapped_fit.sv',[mapped,*[models/(name.lower()+'.v') for name in sorted(types)]])

# Full23bit cache-tag bank wiring uses the official primitive models as well.
mapped=OUT/'tag_banks/outflow/tag_banks.map.v'
types=set(re.findall(r'^\s*(EFX_\w+)\s',mapped.read_text(),re.M))
run('mapped_tags',OUT/'tb_mapped_tags.sv',[mapped,*[models/(name.lower()+'.v') for name in sorted(types)]])

# Icarus12 leaves an input-static LUT at0 despite LUTMASK[0]=1 in this netlist;
# ModelSim executes the untouched vendor models and all62 original core frames.
mapped=OUT/'motion_shared/outflow/motion_shared.map.v'
types=set(re.findall(r'^\s*(EFX_\w+)\s',mapped.read_text(),re.M))
bench=(ROOT/'sim/motion_direction/tb_local_motion_core.sv').read_text().replace('#100000000;','#2000000;')
(OUT/'tb_mapped_motion.sv').write_text(bench)
tool=Path('E:/modeltech64_2020.4/win64')
with (OUT/'modelsim_motion.compile.log').open('wb') as stream:
 subprocess.run([str(tool/'vlib.exe'),(OUT/'modelsim_work').as_posix()],cwd=OUT,stdout=stream,stderr=subprocess.STDOUT,check=True,timeout=60)
 subprocess.run([str(tool/'vlog.exe'),'-work',(OUT/'modelsim_work').as_posix(),'-sv',(OUT/'tb_mapped_motion.sv').as_posix(),mapped.as_posix(),*[str(models/(name.lower()+'.v')) for name in sorted(types)]],cwd=OUT,stdout=stream,stderr=subprocess.STDOUT,check=True,timeout=120)
with (OUT/'modelsim_library.log').open('wb') as stream:
 subprocess.run([str(tool/'vmap.exe'),'-c'],cwd=OUT,stdout=stream,stderr=subprocess.STDOUT,check=True,timeout=30)
 subprocess.run([str(tool/'vmap.exe'),'-modelsimini',(OUT/'modelsim.ini').as_posix(),'xlr_motion_work',(OUT/'modelsim_work').as_posix()],cwd=OUT,stdout=stream,stderr=subprocess.STDOUT,check=True,timeout=30)
with (OUT/'modelsim_motion.run.log').open('wb') as stream:
 subprocess.run([str(tool/'vsim.exe'),'-c','-modelsimini',(OUT/'modelsim.ini').as_posix(),'-lib','xlr_motion_work','-gFRAMES='+str(frames),'tb','-do','run -all; quit -f'],cwd=OUT/'motion',stdout=stream,stderr=subprocess.STDOUT,check=True,timeout=300)
assert 'PASS local motion core frames='+str(frames) in (OUT/'modelsim_motion.run.log').read_text()
print('PASS mapped_motion ModelSim',flush=True)
