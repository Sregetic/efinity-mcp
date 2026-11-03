from pathlib import Path
import json,re,subprocess
import xml.etree.ElementTree as ET
ROOT=Path('F:/Project/fpga/vision_base');OUT=Path(__file__).resolve().parent
coverage=ROOT/'board/ti60f225_v4/rtl/vision/canny_coverage_q5.mem'
fit=ROOT/'board/ti60f225_v4/rtl/vision/canny_fit_q4.mem'
sensor=ROOT/'board/ti60f225_v4/sensors/sc431hai_1080p30_center_4lane.mem'
words=[int(v,16) for v in coverage.read_text().split()];palette=sorted(set(words));indices=[palette.index(w) for w in words]
(OUT/'coverage_index.mem').write_text(''.join(f'{v:02x}\n' for v in indices))
levels=[(w>>(5*p))&31 for w in palette for p in range(16)]+[0]*((64-len(palette))*16)
(OUT/'coverage_palette.mem').write_text(''.join(f'{v:02x}\n' for v in levels))
sensor_words=[int(v,16) for v in sensor.read_text().split()];assert not any(v&1 for v in sensor_words)
prefix=sorted(set(v>>17 for v in sensor_words));assert len(prefix)<=16
packed=[(prefix.index(v>>17)<<16)|((v>>1)&65535) for v in sensor_words]
(OUT/'sensor_packed.mem').write_text(''.join(f'{v:05x}\n' for v in packed))
sv=r'''
module coverage_base(input clk,input[8:0]pattern,input[3:0]phase,output[4:0]level);
 reg[79:0]rom[0:511],q;reg[3:0]phase_q;
 initial $readmemh("@COVERAGE@",rom);
 always @(posedge clk)begin q<=rom[pattern];phase_q<=phase;end
 assign level=q[5*phase_q+:5];
endmodule
module coverage_packed(input clk,input[8:0]pattern,input[3:0]phase,output reg[4:0]level);
 (* syn_ramstyle="logic" *)reg[5:0]index_rom[0:511];reg[4:0]palette[0:1023];
 initial begin $readmemh("@INDEX@",index_rom);$readmemh("@PALETTE@",palette);end
 always @(posedge clk)level<=palette[{index_rom[pattern],phase}];
endmodule
module fit_base(input clk,short,input[6:0]sum,input[7:0]weight,output reg[9:0]center=0,output reg[5:0]slope=0);
 reg[9:0]rom[0:1023];initial $readmemh("@FIT@",rom);
 always @(posedge clk)begin center<=rom[{2'b0,short,sum}];slope<=rom[{1'b1,short,weight}];end
endmodule
module fit_arithmetic(input clk,short,input[6:0]sum,input[7:0]weight,output reg[9:0]center=0,output reg[5:0]slope=0);
 wire signed[13:0]v={{7{sum[6]}},sum},w={{6{weight[7]}},weight};
 wire signed[13:0]c51=(v<<<5)+(v<<<4)+(v<<<1)+v+14'sd2;
 wire signed[13:0]c57=(v<<<6)-(v<<<3)+v+14'sd4;
 wire signed[13:0]s13=(w<<<3)+(w<<<2)+w+14'sd4;
 wire signed[13:0]s17=(w<<<4)+w+14'sd32;
 wire signed[13:0]c=14'sd32+(short?(c51>>>2):(c57>>>3));
 wire signed[13:0]s=short?(s13>>>3):(s17>>>6);
 always @(posedge clk)begin center<=c[9:0];slope<=s[5:0];end
endmodule
module tags_base(input clk,we,re,input[4:0]wa,ra,input[22:0]wd,output[22:0]rd);
 Ram_1w_1rs #(.wordCount(32),.wordWidth(23),.wrAddressWidth(5),.wrDataWidth(23),.wrMaskWidth(1),.wrMaskEnable(0),.rdAddressWidth(5),.rdDataWidth(23))
  memory(clk,we,1'b1,wa,wd,clk,re,ra,rd);
endmodule
module tags_split(input clk,we,re,input[4:0]wa,ra,input[22:0]wd,output[22:0]rd);
 simple_dual_port_ram #(.DATA_WIDTH(20),.ADDR_WIDTH(5),.OUTPUT_REG("FALSE")) low(.wclk(clk),.we(we),.waddr(wa),.wdata(wd[19:0]),.rclk(clk),.re(re),.raddr(ra),.rdata(rd[19:0]));
 (* syn_ramstyle="registers" *)reg[2:0]high[0:31];reg[2:0]q;
 always @(posedge clk)begin if(we)high[wa]<=wd[22:20];if(re)q<=high[ra];end
 assign rd[22:20]=q;
endmodule
module sensor_base(input clk,input[7:0]addr,output reg[24:0]value);
 reg[24:0]rom[0:255];initial $readmemh("@SENSOR@",rom);
 always @(posedge clk)value<=rom[addr];
endmodule
module sensor_packed(input clk,input[7:0]addr,output[24:0]value);
 reg[19:0]rom[0:255],q;reg[7:0]prefix;
 initial $readmemh("@PACKED@",rom);
 always @(posedge clk)q<=rom[addr];
 always @*begin prefix=8'hxx;case(q[19:16])
 @PREFIX_CASES@
 endcase end
 assign value={prefix,q[15:0],1'b0};
endmodule
'''
for k,v in {'COVERAGE':coverage,'FIT':fit,'SENSOR':sensor,'INDEX':OUT/'coverage_index.mem','PALETTE':OUT/'coverage_palette.mem','PACKED':OUT/'sensor_packed.mem'}.items():sv=sv.replace('@'+k+'@',v.as_posix())
sv=sv.replace('@PREFIX_CASES@','\n'.join(f"4'd{i}:prefix=8'h{v:02x};" for i,v in enumerate(prefix)))
(OUT/'probes.sv').write_text(sv)
reader=(ROOT/'rtl/axi_line_reader.sv').read_text().replace('MAX_BURST_BEATS = 16','MAX_BURST_BEATS = 64')
assert reader!=(ROOT/'rtl/axi_line_reader.sv').read_text()
(OUT/'reader_base.sv').write_text(reader)
(OUT/'reader_srl.sv').write_text(reader.replace('if (FIFO_BEATS <= 32)','if (FIFO_BEATS <= 64)'))
ns='http://www.efinixinc.com/enf_proj';ET.register_namespace('efx',ns)
cases=['coverage_base','coverage_packed','fit_base','fit_arithmetic','tags_base','tags_split','sensor_base','sensor_packed','reader_base','reader_srl']
records={}
for name in cases:
 directory=OUT/name;directory.mkdir(exist_ok=True)
 project=ET.Element('{'+ns+'}project',name=name,sw_version='2026.1.132.3.9')
 info=ET.SubElement(project,'{'+ns+'}device_info')
 for tag,val in [('family','Titanium'),('device','Ti60F225'),('timing_model','I3')]:ET.SubElement(info,'{'+ns+'}'+tag,name=val)
 info=ET.SubElement(project,'{'+ns+'}design_info',def_veri_version='sv_09',def_vhdl_version='vhdl_2008',unified_flow='false')
 ET.SubElement(info,'{'+ns+'}top_module',name='axi_line_reader' if name.startswith('reader') else name)
 files=[OUT/(name+'.sv')] if name.startswith('reader') else [OUT/'probes.sv',ROOT/'rtl/sapphire_ram.sv',ROOT/'board/ti60f225_v4/rtl/simple_dual_port_ram.v']
 for path in files:ET.SubElement(info,'{'+ns+'}design_file',name=path.as_posix(),version='default',library='default')
 info=ET.SubElement(project,'{'+ns+'}constraint_info');ET.SubElement(info,'{'+ns+'}sdc_file',name='probe.sdc')
 (directory/'probe.sdc').write_text('create_clock -name clk -period 10 [get_ports clk]\n')
 info=ET.SubElement(project,'{'+ns+'}synthesis',tool_name='efx_map')
 ET.SubElement(info,'{'+ns+'}param',name='mode',value='speed',value_type='e_option')
 ET.SubElement(info,'{'+ns+'}param',name='work_dir',value='work_syn',value_type='e_string')
 project_file=directory/(name+'.xml');ET.ElementTree(project).write(project_file,encoding='unicode')
 cmd=['F:/Efinity/2026.1/python311/bin/python.exe','F:/Efinity/2026.1/scripts/efx_run.py',project_file.name,'--flow','map','--timeout','180']
 with (directory/'console.log').open('w') as log:r=subprocess.run(cmd,cwd=directory,stdout=log,stderr=subprocess.STDOUT,timeout=240)
 r.check_returncode()
 report=(directory/'outflow'/(name+'.map.rpt')).read_text();section=report.split('Resource Summary (begin)',1)[1].split('Resource Summary (end)',1)[0]
 counts=dict.fromkeys(['EFX_FF','EFX_SRL8','EFX_ADD','EFX_LUT4','EFX_RAM10','EFX_DPRAM10','EFX_DSP24','EFX_DSP48'],0)
 for k,v in re.findall(r'(EFX_\w+)\s*:\s*(\d+)',section):counts[k]=int(v)
 counts['RAM']=counts['EFX_RAM10']+counts['EFX_DPRAM10'];records[name]=counts
 (OUT/'map_results.json').write_text(json.dumps(records,indent=2));print(name,json.dumps(counts),flush=True)
(OUT/'table_analysis.json').write_text(json.dumps(dict(coverage_words=len(words),coverage_unique=len(palette),sensor_words=len(sensor_words),sensor_high_bytes=prefix,scope='Isolated same-device map, not whole-system P&R or deployment'),indent=2))
