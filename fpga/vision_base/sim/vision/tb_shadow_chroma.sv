`timescale 1ns/1ps
module tb;
reg clk=0,rst=0,de=0,hs=1,vs=0;reg[7:0]r=0,g=0,b=0;
wire od,oh,ov;wire[7:0]rr,gg,bb;
rgb_shadow_denoise dut(clk,rst,de,hs,vs,r,g,b,od,oh,ov,rr,gg,bb);
always #5 clk=~clk;
task trip(input[23:0]a,c,z,input[23:0]expected);begin
 @(negedge clk);de=0;repeat(3)@(negedge clk);
 de=1;{r,g,b}=a;@(negedge clk);{r,g,b}=c;@(negedge clk);{r,g,b}=z;
 @(posedge clk);#1;
 if(!od||{rr,gg,bb}!==expected)$fatal(1,"chroma got=%h expected=%h center=%h",{rr,gg,bb},expected,c);
end endtask
integer i,y,noise;reg[23:0]center;integer after_y;
initial begin
 repeat(3)@(negedge clk);rst=1;
 trip(24'h141414,24'h280028,24'h141414,24'h141414); // magenta -> neutral at same Y20
 trip(24'h141414,24'h002800,24'h141414,24'h141414); // green -> neutral at same Y20
 trip(24'h102030,24'h102030,24'h102030,24'h102030); // stable dark color exact
 trip(24'h808080,24'hff00ff,24'h808080,24'hff00ff); // bright detail exact
 trip(24'h000000,24'h303030,24'h303030,24'h303030); // luma boundary exact
 trip(24'h141414,24'h282828,24'h141414,24'h282828); // fine luma feature exact
 trip(24'h000000,24'h000000,24'h000000,24'h000000); // black not raised
 for(i=0;i<30;i=i+1)begin
  y=8+i;noise=y/2;center={(8'(y+noise)),(8'(y-noise)),(8'(y+noise))};
  trip({8'(y),8'(y),8'(y)},center,{8'(y),8'(y),8'(y)},{8'(y),8'(y),8'(y)});
 end
 // First pixel after blanking must bypass even if previous line was dark.
 @(negedge clk);de=0;repeat(3)@(negedge clk);de=1;{r,g,b}=24'h280028;
 @(negedge clk);{r,g,b}=24'h141414;@(posedge clk);#1;
 if({rr,gg,bb}!==24'h280028)$fatal(1,"line boundary smear");
 $display("PASS dark chroma37 triplets + first-pixel bypass; luma, black, bright edges preserved");$finish;
end
endmodule
