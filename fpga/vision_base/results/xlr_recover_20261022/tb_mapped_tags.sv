`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg we=0,re=0;reg[4:0]wa=0,ra=0;reg[22:0]wd=0;wire[22:0]rd;
tag_banks dut(clk,we,re,wa,ra,wd,rd);
reg[22:0]gold[0:31],expected;integer i;
initial begin
 for(i=0;i<32;i=i+1)begin @(negedge clk);we=1;wa=i;wd=$urandom;gold[i]=wd;end
 @(negedge clk);we=0;re=1;ra=0;
 @(posedge clk);#1;expected=gold[0];if(rd!==expected)$fatal(1,"Mapped tags initial read");
 for(i=0;i<10000;i=i+1)begin
  @(negedge clk);we=$urandom;re=$urandom;wa=$urandom;ra=i%3==0?wa:$urandom;wd=$urandom;
  if(re)expected=gold[ra];
  @(posedge clk);#1;
  if(rd!==expected)$fatal(1,"Mapped23bit tag mismatch cycle%0d got%h want%h",i,rd,expected);
  if(we)gold[wa]=wd;
 end
 $display("PASS mapped Efinity RAM/FF primitives10000 full23bit tag cycles and read-hold/old-word cases");$finish;
end
endmodule
