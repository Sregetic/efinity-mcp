`timescale 1ns/1ps
module tb;
reg clk=0; always #3.367 clk=~clk;
reg rst=1;reg [7:0] din=0;reg de=0;wire[9:0] out;
dvi_encode_pure dut(clk,rst,din,1'b0,1'b0,de,out);
integer i;
initial begin
 repeat(5)@(negedge clk);rst=0;
 for(i=0;i<280;i=i+1)begin
 @(negedge clk);de=(i<256);din=i;
 @(posedge clk);#1;$display("S %0d %0d %0d %03x",i,din,de,out);
 end
 $finish;
end
endmodule
