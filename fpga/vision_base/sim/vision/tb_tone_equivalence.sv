`timescale 1ns/1ps
`include "sim/vision/rgb_chroma_tone_reference.sv"
module tb;
localparam GAIN_FILE="board/ti60f225_v4/rtl/gamma_conrrection/chroma_tone_gain_q8.mem";
localparam SHADOW_FILE="board/ti60f225_v4/rtl/gamma_conrrection/chroma_shadow_gain_q8.mem";
localparam VALID_PAIRS=454*256,FULL_GAINS=65536;
reg clk=0,rst=0,de=0,hs=0,vs=0,shadow=0,freeze_tone=0;
reg[7:0]r=0,g=0,b=0;reg[15:0]gr=0,gg=0,gb=0;
wire od,oh,ov,hit,latched,ref_od,ref_oh,ref_ov,ref_hit,ref_latched;
wire[23:0]rgb,linear_rgb,plain_rgb,ref_rgb,ref_linear,ref_plain;
rgb_chroma_tone #(.SHADOW_FILE(SHADOW_FILE),.GAIN_FILE(GAIN_FILE))dut(
 clk,rst,de,hs,vs,r,g,b,od,oh,ov,rgb,linear_rgb,gr,gg,gb,plain_rgb,hit,shadow,freeze_tone,latched);
rgb_chroma_tone_reference #(.SHADOW_FILE(SHADOW_FILE),.GAIN_FILE(GAIN_FILE))original(
 clk,rst,de,hs,vs,r,g,b,ref_od,ref_oh,ref_ov,ref_rgb,ref_linear,gr,gg,gb,ref_plain,ref_hit,shadow,freeze_tone,ref_latched);
always #5 clk=~clk;
integer i,a,v,checks=0,pixels=0,resets=0;reg[1:0]curves=0;
initial begin
 for(i=0;i<VALID_PAIRS+FULL_GAINS+8;i=i+1)begin
  @(negedge clk);
  rst=i%32749<32745;de=i<VALID_PAIRS||(i%7!=0);hs=i%1650==0;vs=i%4096==0;
  shadow=(i/8192)%2;freeze_tone=(i/16384)%3==1;
  if(i<VALID_PAIRS)begin
   a=i/256;v=i%256;gr=a;gg=(a+151)%454;gb=453-a;
   r=v;g=v*37+53;b=255-v;
  end else begin
   a=i-VALID_PAIRS;gr=a;gg=65535-a;gb=a*40503+37;
   r=a*29;g=a*7+91;b=a*83+43;
  end
  @(posedge clk);#1;
  if({od,oh,ov,rgb,linear_rgb,plain_rgb,hit,latched} !==
     {ref_od,ref_oh,ref_ov,ref_rgb,ref_linear,ref_plain,ref_hit,ref_latched})
   $fatal(1,"tone output mismatch clock=%0d gains=%0d,%0d,%0d",i,gr,gg,gb);
  if({dut.cr,dut.cg,dut.cb,dut.lr,dut.lg,dut.lb,dut.alpha2,dut.alpha3} !==
     {original.cr,original.cg,original.cb,original.lr,original.lg,original.lb,original.alpha2,original.alpha3})
   $fatal(1,"tone config/pixel alignment mismatch clock=%0d",i);
  curves[latched]=1;checks=checks+1;
  if(od)pixels=pixels+1;
  if(!rst)resets=resets+1;
 end
 if(curves!=3||pixels==0||resets==0)$fatal(1,"missing tone coverage");
 $display("PASS tone cycle equivalence %0d clocks, %0d active pixels, %0d reset clocks, 116224 valid gain/pixel pairs per channel, 65536 full-range gains per channel, both curves/freeze/sync/config updates, zero differences",checks,pixels,resets);
 $finish;
end
endmodule
