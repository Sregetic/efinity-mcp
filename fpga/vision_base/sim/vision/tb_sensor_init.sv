`timescale 1ns/1ps
module tb;
reg clk=0;reg[7:0]addr=0;wire[24:0]word;
i2c_master_reg_rom dut(clk,addr,word);
always #5 clk=~clk;
integer i,dg=0,ag=0,geometry=0,start=0;
initial begin
 for(i=0;i<166;i=i+1)begin
  @(negedge clk);addr=i;@(posedge clk);#1;
  if(^word===1'bx)$fatal(1,"uninitialized sensor entry%0d",i);
  if(word[24:9]==16'h3e06&&word[8:1]==0)dg=dg|1;
  if(word[24:9]==16'h3e07&&word[8:1]==128)dg=dg|2;
  if(word[24:9]==16'h3e08&&word[8:1]==128)ag=ag|1;
  if(word[24:9]==16'h3e09&&word[8:1]==42)ag=ag|2;
  if(word[24:9]>=16'h3200&&word[24:9]<=16'h3213)geometry=geometry+1;
  if(word[24:9]==16'h0100&&word[8:1]==1)begin
   start=start+1;if(i!=165||dg!=3||ag!=3||geometry!=16)$fatal(1,"premature stream start");
  end
 end
 if(start!=1)$fatal(1,"stream start count%0d",start);
 $display("PASS SC431HAI166 writes: explicit unity digital gain, preserved analog gain, geometry before stream");$finish;
end
endmodule
