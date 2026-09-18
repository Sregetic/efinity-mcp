`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0;
wire[15:0]x,y;wire hs,vs,de;wire[47:0]data;
lcd_ref_color_bar #(.DYN_EN(1'b0),.HS_POLORY(1'b1),.VS_POLORY(1'b1),
 .SYMBOL_WIDTH(8),.SYMBOL_NUM(3),.PAR_PIXEL_NUM(2),
 .HFP(4),.HST(4),.HACT(16),.HBP(4),.VFP(2),.VST(2),.VACT(4),.VBP(2),.TEST_MODE(2)) d(
 .clk(clk),.rst_n(rst),.i_cfg_vid(48'd0),.h_cnt(x),.v_cnt(y),.hs(hs),.vs(vs),.de(de),.o_vid_data(data));
integer active=0,lines=0,pairs=0,frames=0,cycles=0;
reg dq=0,vq=0;
always @(posedge clk)begin
 dq<=de;vq<=vs;cycles<=cycles+1;
 if(vs&&!vq)frames<=frames+1;
 if(de)begin
  active<=active+1;pairs<=pairs+1;
  if(data[47:24]!==data[23:0])$fatal(1,"two pixels differ");
 end
 if(dq&&!de)begin
  if(pairs!=8)$fatal(1,"active pairs/line %0d",pairs);
  lines<=lines+1;pairs<=0;
 end
end
initial begin
 #21;rst=1;
 wait(frames==2);repeat(4)@(posedge clk);
 if(lines<4||active<32)$fatal(1,"frame geometry lines%0d active%0d",lines,active);
 $display("LCD NATIVE 2PPC PASS: 8 pairs/16 pixels per active line, stable paired RGB");
 $finish;
end
initial begin #100000;$fatal(1,"timeout");end
endmodule
