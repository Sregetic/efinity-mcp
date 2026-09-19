from pathlib import Path
p=Path('board/ti60f225_v4/rtl/ti60f225_oob_top.v');s=p.read_text(encoding='utf-8')
s=s.replace('= link_reset;',"= 1'b0;").replace('i_arstn && !link_reset','i_arstn').replace('w_mipi_rx_pclk_arstn && !link_reset','w_mipi_rx_pclk_arstn')
a=s.index('reg[2:0]link_cmd_sync=0;');b=s.index('wire [31:0] mipi_debug_out;',a)
s=s[:a]+'''// Optional observational CSI diagnostics. Opcode20 soft reset was withdrawn:
// it reproducibly destroys the valid baseline until full FPGA reconfiguration.
reg[2:0]probe_cmd_sync=0;reg probe_cmd_seen=0,probe_csi_view=0;
always @(posedge core_clk)begin
 probe_cmd_sync<={probe_cmd_sync[1:0],feature_command_toggle};probe_cmd_seen<=probe_cmd_sync[2];
 if(probe_cmd_sync[2]!=probe_cmd_seen&&feature_command[31:24]==21)probe_csi_view<=feature_command[0];
end
'''+s[b:]
a=s.index('reg out_vs_q=0,out_de_q=0;')
s=s[:a]+'''// Count DE and HS independently; geometry requires their intersection.
reg[31:0]probe_de_count=0,probe_hs_count=0;
reg[15:0]probe_error_seen=0;
always @(posedge i_mipi_rx_pclk)begin
 if(w_mipi_rx_de)probe_de_count<=probe_de_count+1'b1;
 if(w_mipi_rx_hs&&!rx_hs_q)probe_hs_count<=probe_hs_count+1'b1;
 probe_error_seen<=probe_error_seen|mipi_debug_out[15:0];
end
'''+s[a:]
s=s.replace("if(feature_diag_page==15)diag_shift", "if(feature_diag_page==15&&probe_csi_view)diag_shift<={32'h56495331,32'h2609192f,feature_status,probe_de_count,probe_hs_count,probe_error_seen,mipi_debug_out[15:0]};\n  else if(feature_diag_page==15)diag_shift")
p.write_text(s,encoding='utf-8')
p=Path('board/ti60f225_v4/rtl/cam_i2c_ctrl/i2c/i2c_master_reg_rom.v');s=p.read_text(encoding='utf-8');assert s.count("16'h36eb,8'h0d")==1 and s.count("16'h36ec,8'h65")==1
s=s.replace("16'h36eb,8'h0d","16'h36eb,8'h0c").replace("16'h36ec,8'h65","16'h36ec,8'h55");p.write_text(s,encoding='utf-8')

