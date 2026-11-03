`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst=0,vs=0,hs=0,de=0;reg[15:0]d=0;
wire ov,oh,od,valid;wire[47:0]rgb;
debayer_top_2to1 dut(.in_pclk(clk),.in_rstn(rst),.raw_vs_i(vs),.raw_hs_i(hs),.raw_de_i(de),.raw_valid_i(de),.raw_datax4_i(d),.r_gain(16'd256),.g_gain(16'd256),.b_gain(16'd256),.rgb_vs_o(ov),.rgb_hs_o(oh),.rgb_de_o(od),.rgb_valid_o(valid),.rgb_datax2_o(rgb));
integer y,x,ox=0,oy=0,n=0,err=0;reg prev=0;integer a,b,c;
always @(posedge clk)begin
 #1;
 if(od)begin
  if(oy>4&&ox>5&&ox<25)begin
   a=rgb[23:16];b=rgb[15:8];c=rgb[7:0];
   if(a!=b||b!=c)begin err=err+1;if(err<12)$display("GRAY mismatch row%0d pair%0d BGR=%0d,%0d,%0d",oy,ox,a,b,c);end
   a=rgb[47:40];b=rgb[39:32];c=rgb[31:24];
   if(a!=b||b!=c)begin err=err+1;if(err<12)$display("GRAY mismatch high row%0d pair%0d BGR=%0d,%0d,%0d",oy,ox,a,b,c);end
   n=n+2;
  end
  ox=ox+1;
 end
 if(prev&&!od)begin oy=oy+1;ox=0;end
 prev=od;
end
initial begin
 repeat(4)@(negedge clk);rst=1;vs=1;repeat(4)@(negedge clk);vs=0;
 for(y=0;y<16;y=y+1)begin
  for(x=0;x<32;x=x+1)begin @(negedge clk);de=1;hs=1;d={8'(33+4*x+4*y),8'(31+4*x+4*y)};end
  @(negedge clk);de=0;hs=0;repeat(12)@(negedge clk);
 end
 repeat(20)@(negedge clk);
 $display("neutral ramp checked=%0d channel mismatches=%0d",n,err);
 if(n==0||err!=0)$fatal(1,"Neutral ramp channel alignment failed");$finish;
end
endmodule
