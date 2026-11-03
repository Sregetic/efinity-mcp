from pathlib import Path
import json,subprocess
ROOT=Path('F:/Project/fpga/vision_base');OUT=Path(__file__).resolve().parent
source=r'''
`timescale 1ns/1ps
module tb;
 reg clk=0;always #5 clk=~clk;
 reg[8:0]pattern=0;reg[3:0]phase=0;wire[4:0]cb,cp;
 coverage_base c0(clk,pattern,phase,cb);coverage_packed c1(clk,pattern,phase,cp);
 reg short=0;reg[6:0]sum=0;reg[7:0]weight=0;wire[9:0]fb,fa;wire[5:0]sb,sa;
 fit_base f0(clk,short,sum,weight,fb,sb);fit_arithmetic f1(clk,short,sum,weight,fa,sa);
 reg[7:0]addr=0;wire[24:0]ib,ip;
 sensor_base i0(clk,addr,ib);sensor_packed i1(clk,addr,ip);
 reg we=0,re=0;reg[4:0]wa=0,ra=0;reg[22:0]wd=0;wire[22:0]tb,ts;
 tags_base t0(clk,we,re,wa,ra,wd,tb);tags_split t1(clk,we,re,wa,ra,wd,ts);
 reg[22:0]model[0:31],expected;reg[31:0]rng=32'hc0ffee11;
 reg[24:0]sensor_words[0:165];integer i,j,k,cases=0;
 initial begin
  $readmemh("@SENSOR@",sensor_words);
  for(i=0;i<512;i=i+1)for(j=0;j<16;j=j+1)begin
   @(negedge clk);pattern=i;phase=j;@(posedge clk);#1;
   if(cb!==cp)$fatal(1,"coverage p=%0d phase=%0d old=%0d new=%0d",i,j,cb,cp);cases=cases+1;
  end
  $display("PASS coverage8192 one-clock outputs, exact 5-bit levels");
  for(k=0;k<2;k=k+1)for(i=0;i<128;i=i+1)for(j=0;j<256;j=j+1)begin
   @(negedge clk);short=k;sum=i;weight=j;@(posedge clk);#1;
   if(fb!==fa||sb!==sa)$fatal(1,"fit short=%0d sum=%0d weight=%0d old=%h/%h new=%h/%h",k,i,j,fb,sb,fa,sa);cases=cases+1;
  end
  $display("PASS fit65536 signed input pairs, truncation and one-clock alignment");
  for(i=0;i<166;i=i+1)begin
   @(negedge clk);addr=i;@(posedge clk);#1;
   if(ib!==ip||ib!==sensor_words[i])$fatal(1,"sensor word%0d",i);cases=cases+1;
  end
  $display("PASS sensor166 boot words unchanged");
  for(i=0;i<32;i=i+1)begin
   @(negedge clk);we=1;wa=i;wd=23'h701234^(i*23'h10307);model[i]=wd;@(posedge clk);#1;
  end
  @(negedge clk);we=0;re=1;ra=0;expected=model[0];@(posedge clk);#1;
  if(tb!==expected||ts!==expected)$fatal(1,"tags initial read");
  for(i=0;i<10000;i=i+1)begin
   @(negedge clk);rng={rng[30:0],rng[31]^rng[21]^rng[1]^rng[0]};
   we=rng[0];re=rng[1];wa=rng[6:2];ra=i%5==0?wa:rng[11:7];wd=rng[31:9];
   if(re)expected=model[ra];
   @(posedge clk);#1;
   if(tb!==expected||ts!==expected)$fatal(1,"tags cycle%0d expected%h old%h new%h",i,expected,tb,ts);
   if(we)model[wa]=wd;cases=cases+1;
  end
  $display("PASS tags10000 random write/read/hold and same-address old-data checks");
  $display("PASS ram audit all cases=%0d",cases);$finish;
 end
 initial begin #2000000;$fatal(1,"timeout");end
endmodule
'''.replace('@SENSOR@',(ROOT/'board/ti60f225_v4/sensors/sc431hai_1080p30_center_4lane.mem').as_posix())
(OUT/'tb.sv').write_text(source)
cmd=['C:/iverilog/bin/iverilog.exe','-g2012','-s','tb','-o',str(OUT/'test.vvp'),str(OUT/'tb.sv'),str(OUT/'probes.sv'),str(ROOT/'rtl/sapphire_ram.sv'),str(ROOT/'board/ti60f225_v4/rtl/simple_dual_port_ram.v')]
subprocess.run(cmd,check=True)
r=subprocess.run(['C:/iverilog/bin/vvp.exe',str(OUT/'test.vvp')],capture_output=True,text=True,timeout=30)
(OUT/'equivalence.log').write_text(r.stdout+r.stderr);r.check_returncode();assert 'PASS ram audit all cases=83894' in r.stdout,r.stdout
print(r.stdout,flush=True)
readers={}
for name in ['reader_base','reader_srl']:
 exe=OUT/(name+'.vvp')
 subprocess.run(['C:/iverilog/bin/iverilog.exe','-g2012','-s','tb_axi_line_reader','-o',str(exe),str(ROOT/'sim/tb_axi_line_reader.sv'),str(OUT/(name+'.sv'))],check=True)
 r=subprocess.run(['C:/iverilog/bin/vvp.exe',str(exe)],capture_output=True,text=True,timeout=90)
 (OUT/(name+'.test.log')).write_text(r.stdout+r.stderr);r.check_returncode();assert 'PASS tb_axi_line_reader' in r.stdout
 readers[name]=r.stdout;print(name,r.stdout.splitlines()[-2:],flush=True)
assert readers['reader_base']==readers['reader_srl'],'RAM->SRL changed reader cycle/data behavior'
(OUT/'verification.json').write_text(json.dumps(dict(passed=True,coverage_pairs=8192,fit_signed_pairs=65536,sensor_boot_words=166,cache_tag_cycles=10000,reader_logs_cycle_identical=True,scope='Isolated producer/consumer contracts; not full-system P&R or hardware acceptance'),indent=2))
