
module coverage_base(input clk,input[8:0]pattern,input[3:0]phase,output[4:0]level);
 reg[79:0]rom[0:511],q;reg[3:0]phase_q;
 initial $readmemh("F:/Project/fpga/vision_base/board/ti60f225_v4/rtl/vision/canny_coverage_q5.mem",rom);
 always @(posedge clk)begin q<=rom[pattern];phase_q<=phase;end
 assign level=q[5*phase_q+:5];
endmodule
module coverage_packed(input clk,input[8:0]pattern,input[3:0]phase,output reg[4:0]level);
 (* syn_ramstyle="logic" *)reg[5:0]index_rom[0:511];reg[4:0]palette[0:1023];
 initial begin $readmemh("F:/Project/fpga/vision_base/results/ram_audit_20261018/coverage_index.mem",index_rom);$readmemh("F:/Project/fpga/vision_base/results/ram_audit_20261018/coverage_palette.mem",palette);end
 always @(posedge clk)level<=palette[{index_rom[pattern],phase}];
endmodule
module fit_base(input clk,short,input[6:0]sum,input[7:0]weight,output reg[9:0]center=0,output reg[5:0]slope=0);
 reg[9:0]rom[0:1023];initial $readmemh("F:/Project/fpga/vision_base/board/ti60f225_v4/rtl/vision/canny_fit_q4.mem",rom);
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
 reg[24:0]rom[0:255];initial $readmemh("F:/Project/fpga/vision_base/board/ti60f225_v4/sensors/sc431hai_1080p30_center_4lane.mem",rom);
 always @(posedge clk)value<=rom[addr];
endmodule
module sensor_packed(input clk,input[7:0]addr,output[24:0]value);
 reg[19:0]rom[0:255],q;reg[7:0]prefix;
 initial $readmemh("F:/Project/fpga/vision_base/results/ram_audit_20261018/sensor_packed.mem",rom);
 always @(posedge clk)q<=rom[addr];
 always @*begin prefix=8'hxx;case(q[19:16])
 4'd0:prefix=8'h01;
4'd1:prefix=8'h30;
4'd2:prefix=8'h32;
4'd3:prefix=8'h33;
4'd4:prefix=8'h34;
4'd5:prefix=8'h36;
4'd6:prefix=8'h37;
4'd7:prefix=8'h39;
4'd8:prefix=8'h3e;
4'd9:prefix=8'h45;
4'd10:prefix=8'h57;
 endcase end
 assign value={prefix,q[15:0],1'b0};
endmodule
