
module tag_base(input clk,we,re,input[4:0]wa,ra,input[22:0]wd,output[22:0]rd);
 Ram_1w_1rs #(.wordCount(32),.wordWidth(23),.wrAddressWidth(5),.rdAddressWidth(5),.wrDataWidth(23),.rdDataWidth(23))
 r(clk,we,1'b1,wa,wd,clk,re,ra,rd);
endmodule
module tag_bits(input clk,we,re,input[4:0]wa,ra,input[22:0]wd,output[22:0]rd);
 simple_dual_port_ram #(.DATA_WIDTH(20),.ADDR_WIDTH(5),.OUTPUT_REG("FALSE")) low(.wclk(clk),.we(we),.waddr(wa),.wdata(wd[19:0]),.rclk(clk),.re(re),.raddr(ra),.rdata(rd[19:0]));
 reg[31:0]h0,h1,h2;reg[2:0]q;
 always @(posedge clk)if(we)begin h0[wa]<=wd[20];h1[wa]<=wd[21];h2[wa]<=wd[22];end
 always @(posedge clk)if(re)q<={h2[ra],h1[ra],h0[ra]};
 assign rd[22:20]=q;
endmodule
module tag_mask(input clk,we,re,input[4:0]wa,ra,input[22:0]wd,output[22:0]rd);
 simple_dual_port_ram #(.DATA_WIDTH(20),.ADDR_WIDTH(5),.OUTPUT_REG("FALSE")) low(.wclk(clk),.we(we),.waddr(wa),.wdata(wd[19:0]),.rclk(clk),.re(re),.raddr(ra),.rdata(rd[19:0]));
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
 simple_dual_port_ram #(.DATA_WIDTH(20),.ADDR_WIDTH(5),.OUTPUT_REG("FALSE")) low(.wclk(clk),.we(we),.waddr(wa),.wdata(wd[19:0]),.rclk(clk),.re(re),.raddr(ra),.rdata(rd[19:0]));
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
 simple_dual_port_ram #(.DATA_WIDTH(20),.ADDR_WIDTH(5),.OUTPUT_REG("FALSE")) low(.wclk(clk),.we(we),.waddr(wa),.wdata(wd[19:0]),.rclk(clk),.re(re),.raddr(ra),.rdata(rd[19:0]));
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
 simple_dual_port_ram #(.DATA_WIDTH(20),.ADDR_WIDTH(5),.OUTPUT_REG("FALSE")) low(.wclk(clk),.we(we),.waddr(wa),.wdata(wd[19:0]),.rclk(clk),.re(re),.raddr(ra),.rdata(rd[19:0]));
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
 simple_dual_port_ram #(.DATA_WIDTH(20),.ADDR_WIDTH(5),.OUTPUT_REG("FALSE")) low(.wclk(clk),.we(we),.waddr(wa),.wdata(wd[19:0]),.rclk(clk),.re(re),.raddr(ra),.rdata(rd[19:0]));
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
module tag_banks2(input clk,we,re,input[4:0]wa,ra,input[22:0]wd,output[22:0]rd);
 simple_dual_port_ram #(.DATA_WIDTH(20),.ADDR_WIDTH(5),.OUTPUT_REG("FALSE")) low(.wclk(clk),.we(we),.waddr(wa),.wdata(wd[19:0]),.rclk(clk),.re(re),.raddr(ra),.rdata(rd[19:0]));
 wire[5:0]q;reg bank;
 genvar b;generate for(b=0;b<2;b=b+1)begin:g
  (* syn_ramstyle="registers" *)reg[2:0]memory[0:15];reg[2:0]r;
  always @(posedge clk)begin
   if(we&&wa[4]==b)memory[wa[3:0]]<=wd[22:20];
   if(re)r<=memory[ra[3:0]];
  end
  assign q[b*3+:3]=r;
 end endgenerate
 always @(posedge clk)if(re)bank<=ra[4];
 assign rd[22:20]=q[bank*3+:3];
endmodule
module tag_banks8(input clk,we,re,input[4:0]wa,ra,input[22:0]wd,output[22:0]rd);
 simple_dual_port_ram #(.DATA_WIDTH(20),.ADDR_WIDTH(5),.OUTPUT_REG("FALSE")) low(.wclk(clk),.we(we),.waddr(wa),.wdata(wd[19:0]),.rclk(clk),.re(re),.raddr(ra),.rdata(rd[19:0]));
 wire[23:0]q;reg[2:0]bank;
 genvar b;generate for(b=0;b<8;b=b+1)begin:g
  (* syn_ramstyle="registers" *)reg[2:0]memory[0:3];reg[2:0]r;
  always @(posedge clk)begin
   if(we&&wa[4:2]==b)memory[wa[1:0]]<=wd[22:20];
   if(re)r<=memory[ra[1:0]];
  end
  assign q[b*3+:3]=r;
 end endgenerate
 always @(posedge clk)if(re)bank<=ra[4:2];
 assign rd[22:20]=q[bank*3+:3];
endmodule
