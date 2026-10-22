"""Same-device isolated candidates; no production-source replacement or hardware access."""
from pathlib import Path
import json
import re
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
sv=r'''
module tag_base(input clk,we,re,input[4:0]wa,ra,input[22:0]wd,output[22:0]rd);
 Ram_1w_1rs #(.wordCount(32),.wordWidth(23),.wrAddressWidth(5),.rdAddressWidth(5),.wrDataWidth(23),.rdDataWidth(23))
 r(clk,we,1'b1,wa,wd,clk,re,ra,rd);
endmodule
module tag_bits(input clk,we,re,input[4:0]wa,ra,input[22:0]wd,output[22:0]rd);
 @LOW@
 reg[31:0]h0,h1,h2;reg[2:0]q;
 always @(posedge clk)if(we)begin h0[wa]<=wd[20];h1[wa]<=wd[21];h2[wa]<=wd[22];end
 always @(posedge clk)if(re)q<={h2[ra],h1[ra],h0[ra]};
 assign rd[22:20]=q;
endmodule
module tag_mask(input clk,we,re,input[4:0]wa,ra,input[22:0]wd,output[22:0]rd);
 @LOW@
 reg[31:0]h0,h1,h2;reg[2:0]q;
 wire[31:0]mask=we?(32'b1<<wa):32'b0;
 always @(posedge clk)begin
  h0<=(h0&~mask)|({32{wd[20]}}&mask);
  h1<=(h1&~mask)|({32{wd[21]}}&mask);
  h2<=(h2&~mask)|({32{wd[22]}}&mask);
  if(re)q<={h2[ra],h1[ra],h0[ra]};
 end
 assign rd[22:20]=q;
endmodule
module tag_banks(input clk,we,re,input[4:0]wa,ra,input[22:0]wd,output[22:0]rd);
 @LOW@
 wire[11:0]q;reg[1:0]bank;
 genvar b;generate for(b=0;b<4;b=b+1)begin:g
  (* syn_ramstyle="registers" *)reg[2:0]memory[0:7];reg[2:0]r;
  always @(posedge clk)begin
   if(we&&wa[4:3]==b)memory[wa[2:0]]<=wd[22:20];
   if(re)r<=memory[ra[2:0]];
  end
  assign q[b*3+:3]=r;
 end endgenerate
 always @(posedge clk)if(re)bank<=ra[4:3];
 assign rd[22:20]=q[bank*3+:3];
endmodule
module tag_onehot(input clk,we,re,input[4:0]wa,ra,input[22:0]wd,output[22:0]rd);
 @LOW@
 wire[31:0]ws=we?(32'b1<<wa):32'b0,rs=32'b1<<ra;
 wire[95:0]bits;reg[2:0]value,q;integer j;
 genvar i;generate for(i=0;i<32;i=i+1)begin:g
  reg[2:0]r;always @(posedge clk)if(ws[i])r<=wd[22:20];assign bits[i*3+:3]=r;
 end endgenerate
 always @*begin value=0;for(j=0;j<32;j=j+1)value=value|(bits[j*3+:3]&{3{rs[j]}});end
 always @(posedge clk)if(re)q<=value;
 assign rd[22:20]=q;
endmodule
module tag_toggle(input clk,we,re,input[4:0]wa,ra,input[22:0]wd,output[22:0]rd);
 @LOW@
 reg phase=0;wire[2:0]encoded=wd[22:20]^{3{!phase}};
 wire[95:0]bits;reg[2:0]q;
 always @(posedge clk)phase<=!phase;
 genvar i;generate for(i=0;i<32;i=i+1)begin:g
  reg[2:0]value;
  always @(posedge clk)value<=we&&wa==i?encoded:~value;
  assign bits[i*3+:3]=value;
 end endgenerate
 always @(posedge clk)if(re)q<=bits[ra*3+:3]^{3{phase}};
 assign rd[22:20]=q;
endmodule
module tag_toggle_banks(input clk,we,re,input[4:0]wa,ra,input[22:0]wd,output[22:0]rd);
 @LOW@
 reg phase=0;wire[2:0]encoded=wd[22:20]^{3{!phase}};
 reg[1:0]bank;wire[11:0]q;
 always @(posedge clk)phase<=!phase;
 genvar b,i;generate for(b=0;b<4;b=b+1)begin:g
  wire[23:0]bits;reg[2:0]r;
  for(i=0;i<8;i=i+1)begin:word
   reg[2:0]value;
   always @(posedge clk)value<=we&&wa==b*8+i?encoded:~value;
   assign bits[i*3+:3]=value;
  end
  always @(posedge clk)if(re)r<=bits[ra[2:0]*3+:3]^{3{phase}};
  assign q[b*3+:3]=r;
 end endgenerate
 always @(posedge clk)if(re)bank<=ra[4:3];
 assign rd[22:20]=q[bank*3+:3];
endmodule
module fit_base(input clk,short,input[6:0]sum,input[7:0]weight,output reg[9:0]center=0,output reg[5:0]slope=0);
 wire signed[13:0]v={{7{sum[6]}},sum},w={{6{weight[7]}},weight};
 wire signed[13:0]c51=(v<<<5)+(v<<<4)+(v<<<1)+v+14'sd2;
 wire signed[13:0]c57=(v<<<6)-(v<<<3)+v+14'sd4;
 wire signed[13:0]s13=(w<<<3)+(w<<<2)+w+14'sd4;
 wire signed[13:0]s17=(w<<<4)+w+14'sd32;
 wire signed[13:0]c=14'sd32+(short?(c51>>>2):(c57>>>3));
 wire signed[13:0]s=short?(s13>>>3):(s17>>>6);
 always @(posedge clk)begin center<=c[9:0];slope<=s[5:0];end
endmodule
module fit_dsp(input clk,short,input[6:0]sum,input[7:0]weight,output reg[9:0]center=0,output reg[5:0]slope=0);
 wire signed[6:0]cv=short?7'sd51:7'sd57;
 wire signed[5:0]sv=short?6'sd13:6'sd17;
 (* syn_use_dsp="yes" *)wire signed[13:0]cp=$signed(sum)*cv,sp=$signed(weight)*sv;
 wire signed[13:0]cr=cp+(short?14'sd2:14'sd4),sr=sp+(short?14'sd4:14'sd32);
 wire signed[13:0]c=14'sd32+(short?(cr>>>2):(cr>>>3));
 wire signed[13:0]s=short?(sr>>>3):(sr>>>6);
 always @(posedge clk)begin center<=c[9:0];slope<=s[5:0];end
endmodule
module fit_factored(input clk,short,input[6:0]sum,input[7:0]weight,output reg[9:0]center=0,output reg[5:0]slope=0);
 wire signed[13:0]v={{7{sum[6]}},sum},w={{6{weight[7]}},weight};
 wire signed[13:0]common=(v<<<5)+(v<<<4)+v;
 wire signed[13:0]cp=common+(short?(v<<<1):(v<<<3))+(short?14'sd2:14'sd4);
 wire signed[13:0]sp=(w<<<4)+w-(short?(w<<<2):14'sd0)+(short?14'sd4:14'sd32);
 wire signed[13:0]c=14'sd32+(short?(cp>>>2):(cp>>>3));
 wire signed[13:0]s=short?(sp>>>3):(sp>>>6);
 always @(posedge clk)begin center<=c[9:0];slope<=s[5:0];end
endmodule
module fit_mac(input clk,short,input[6:0]sum,input[7:0]weight,output reg[9:0]center=0,output reg[5:0]slope=0);
 wire signed[6:0]cv=short?7'sd51:7'sd57;
 wire signed[5:0]sv=short?6'sd13:6'sd17;
 (* syn_use_dsp="yes" *)wire signed[13:0]cr=($signed(sum)*cv)+(short?14'sd130:14'sd260);
 (* syn_use_dsp="yes" *)wire signed[13:0]sr=($signed(weight)*sv)+(short?14'sd4:14'sd32);
 wire signed[13:0]c=short?(cr>>>2):(cr>>>3),s=short?(sr>>>3):(sr>>>6);
 always @(posedge clk)begin center<=c[9:0];slope<=s[5:0];end
endmodule
'''
low='simple_dual_port_ram #(.DATA_WIDTH(20),.ADDR_WIDTH(5),.OUTPUT_REG("FALSE")) low(.wclk(clk),.we(we),.waddr(wa),.wdata(wd[19:0]),.rclk(clk),.re(re),.raddr(ra),.rdata(rd[19:0]));'
sv=sv.replace('@LOW@',low)
banked=sv[sv.index('module tag_banks('):sv.index('module tag_onehot(')]
sv+=banked.replace('module tag_banks(', 'module tag_banks2(').replace('[11:0]q;reg[1:0]bank','[5:0]q;reg bank').replace('b<4','b<2').replace('[0:7]','[0:15]').replace('[4:3]','[4]').replace('[2:0]]','[3:0]]')
sv+=banked.replace('module tag_banks(', 'module tag_banks8(').replace('[11:0]q;reg[1:0]bank','[23:0]q;reg[2:0]bank').replace('b<4','b<8').replace('[0:7]','[0:3]').replace('[4:3]','[4:2]').replace('[2:0]]','[1:0]]')
(OUT/'tag_fit_probes.sv').write_text(sv)

# Preserve the eight multiply beats: each equivalent signed pair has one load and one accumulate beat.
core=(OUT/'before/board/ti60f225_v4/rtl/vision/vision_local_motion_core.sv').read_text()
fold=core.replace('gray_latched,current_on,current_off','gray_latched').replace('reg packet_open,history_valid,warm;reg[7:0]gray_latched;','reg packet_open,history_valid,warm;reg[7:0]gray_latched;reg signed[8:0]current_delta;')
fold=fold.replace('wire signed[31:0]signed_product={16\'d0,product};',"wire signed[SUM_W-1:0]signed_product={{(SUM_W-16){1'b0}},product};")
fold=fold.replace('reg signed[SUM_W-1:0]hx,vy;reg[15:0]count_active;','reg signed[SUM_W-1:0]hx,vy;reg[$clog2(N+1)-1:0]count_active;')
a=fold.index('wire[8:0]negative_delta=');b=fold.index('wire[8:0]stored_delta=',a)
fold=fold[:a]+'''wire signed[8:0]old_delta=cell_q[8:0],old_left=left[17:9],now_left=left[8:0],old_above=above[17:9],now_above=above[8:0];
reg signed[8:0]pair_a,pair_b;
always @*case(term[2:1])
 0:begin pair_a=old_left;pair_b=current_delta;end
 1:begin pair_a=old_delta;pair_b=now_left;end
 2:begin pair_a=old_above;pair_b=current_delta;end
 3:begin pair_a=old_delta;pair_b=now_above;end
endcase
wire[8:0]magnitude_a=pair_a[8]?-pair_a:pair_a,magnitude_b=pair_b[8]?-pair_b:pair_b;
wire[8:0]current_magnitude=current_delta[8]?-current_delta:current_delta;
'''+fold[b:]
fold=fold.replace('wire[31:0]abs_h=', 'wire[SUM_W-1:0]abs_h=').replace('wire[31:0]major=', 'wire[SUM_W-1:0]major=')
a=fold.index('always @*begin\n mul_a=0;');b=fold.index('always @(posedge clk)begin',a)
fold=fold[:a]+fold[b:]
fold=fold.replace('current_on<=0;current_off<=0;term<=0;gray_latched<=0;', 'current_delta<=0;mul_a<=0;mul_b<=0;term<=0;gray_latched<=0;')
fold=fold.replace("current_on<=(warm&&delta>0)?delta[7:0]:8'd0;\n    current_off<=(warm&&delta<0)?negative_delta[7:0]:8'd0;", "current_delta<=warm?delta:9'sd0;")
a=fold.index('    if(term<4)begin');b=fold.index('    if(term==7)',a)
fold=fold[:a]+'''    if(!term[0])begin
     mul_a<=0;mul_b<=0;
     if(warm&&(term[2]?row!=0:col!=0)&&pair_a[8]==pair_b[8])begin
      mul_a<=magnitude_a[7:0];mul_b<=magnitude_b[7:0];
     end
    end else if(!term[2])begin
     if(term[1])hx<=hx-signed_product;else hx<=hx+signed_product;
    end else begin
     if(term[1])vy<=vy-signed_product;else vy<=vy+signed_product;
    end
'''+fold[b:]
fold=fold.replace('(current_on>8||current_off>8)','current_magnitude>8')
fold=fold.replace('(major<<1)>=minor+(minor<<1)',"({1'b0,major}<<1)>={1'b0,minor}+({1'b0,minor}<<1)")
assert 'current_on' not in fold and 'negative_delta' not in fold
(OUT/'motion_fold.sv').write_text(fold)
step=fold.replace("wire signed[SUM_W-1:0]signed_product={{(SUM_W-16){1'b0}},product};", "wire signed[16:0]signed_increment=term[1]?-$signed({1'b0,product}):$signed({1'b0,product});")
step=step.replace('if(term[1])hx<=hx-signed_product;else hx<=hx+signed_product;','hx<=hx+signed_increment;')
step=step.replace('if(term[1])vy<=vy-signed_product;else vy<=vy+signed_product;','vy<=vy+signed_increment;')
(OUT/'motion_step.sv').write_text(step)
shared=step.replace('assign in_ready=', 'wire signed[SUM_W-1:0]updated_sum=(term[2]?vy:hx)+signed_increment;\nassign in_ready=')
shared=shared.replace('hx<=hx+signed_increment;','hx<=updated_sum;').replace('vy<=vy+signed_increment;','vy<=updated_sum;')
(OUT/'motion_shared.sv').write_text(shared)
acc=fold.replace("reg[2:0]term;reg[7:0]mul_a,mul_b;wire[15:0]product=mul_a*mul_b;\nwire signed[SUM_W-1:0]signed_product={{(SUM_W-16){1'b0}},product};",'''reg[2:0]term;reg[7:0]mul_a,mul_b;
wire signed[8:0]factor_a=term[1]?-$signed({1'b0,mul_a}):$signed({1'b0,mul_a});
wire signed[8:0]factor_b=$signed({1'b0,mul_b});
(* syn_use_dsp="yes" *)wire signed[SUM_W-1:0]next_h=hx+(factor_a*factor_b);
(* syn_use_dsp="yes" *)wire signed[SUM_W-1:0]next_v=vy+(factor_a*factor_b);''')
acc=acc.replace('if(term[1])hx<=hx-signed_product;else hx<=hx+signed_product;','hx<=next_h;').replace('if(term[1])vy<=vy-signed_product;else vy<=vy+signed_product;','vy<=next_v;')
(OUT/'motion_acc.sv').write_text(acc)

font=(ROOT/'board/ti60f225_v4/rtl/vision/vision_osd.sv').read_text()
glyphs=[int(w,16) for w in re.findall(r"chinese_glyph=256'h([0-9a-f]+)",font)]
for bank,shift in enumerate((11,6,1)):
 vals=[((g>>(16*(15-row)))>>shift)&31 for g in glyphs for row in range(16)]
 (OUT/f'font_bank{bank}.mem').write_text(''.join(f'{v:02x}\n' for v in vals))
font_sv='''module font_banks(input clk,input[6:0]glyph,input[3:0]row,col,output ink);
 (* syn_ramdecomp="area" *)reg[4:0]b0[0:1935],b1[0:1935],b2[0:1935];
 reg[14:0]q;reg[3:0]position;
 initial begin @FILES@ end
 always @(posedge clk)begin q<={b0[{glyph,row}],b1[{glyph,row}],b2[{glyph,row}]};position<=col;end
 assign ink=position!=15&&q[14-position];
endmodule
'''.replace('@FILES@',''.join(f'$readmemh("{(OUT/f"font_bank{i}.mem").as_posix()}",b{i});' for i in range(3)))
(OUT/'font_banks.sv').write_text(font_sv)

ns='http://www.efinixinc.com/enf_proj';ET.register_namespace('efx',ns)
names=sys.argv[1:] or ['tag_base','tag_bits','tag_mask','tag_banks','tag_banks2','tag_banks8','tag_onehot','tag_toggle','tag_toggle_banks','fit_base','fit_dsp','fit_factored','fit_mac','font_banks','motion_base','motion_fold','motion_step','motion_shared','motion_acc']
records=json.loads((OUT/'probe_results.json').read_text()) if sys.argv[1:] else {}
for name in names:
 d=OUT/name;d.mkdir(exist_ok=True)
 tree=ET.parse(ROOT/'results/ram_audit_20261018/coverage_packed/coverage_packed.xml');proj=tree.getroot();proj.set('name',name)
 info=proj.find(f'{{{ns}}}design_info');info.find(f'{{{ns}}}top_module').set('name',name if not name.startswith('motion_') else 'vision_local_motion_core')
 for f in list(info.findall(f'{{{ns}}}design_file')):info.remove(f)
 source=OUT/'tag_fit_probes.sv' if name.startswith(('tag_','fit_')) else OUT/'font_banks.sv' if name=='font_banks' else OUT/(name+'.sv') if name in ['motion_fold','motion_step','motion_shared','motion_acc'] else OUT/'before/board/ti60f225_v4/rtl/vision/vision_local_motion_core.sv'
 for p in [source,ROOT/'rtl/sapphire_ram.sv',ROOT/'board/ti60f225_v4/rtl/simple_dual_port_ram.v']:
  ET.SubElement(info,f'{{{ns}}}design_file',name=p.as_posix(),version='default',library='default')
 tree.write(d/(name+'.xml'),encoding='unicode');(d/'probe.sdc').write_text('create_clock -name clk -period 6.734 [get_ports clk]\n')
 with (d/'console.log').open('w') as log:
  subprocess.run(['F:/Efinity/2026.1/python311/bin/python.exe','F:/Efinity/2026.1/scripts/efx_run.py',name+'.xml','--flow','map','--timeout','180'],cwd=d,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=240)
 s=(d/'outflow'/(name+'.map.rpt')).read_text().split('Resource Summary (begin)',1)[1].split('Resource Summary (end)',1)[0]
 c={k:int(v) for k,v in re.findall(r'(EFX_\w+)\s*:\s*(\d+)',s)}
 c['RAM']=c.get('EFX_RAM10',0)+c.get('EFX_DPRAM10',0);records[name]=c
 (OUT/'probe_results.json').write_text(json.dumps(records,indent=2))
 print(name,json.dumps(c),flush=True)
