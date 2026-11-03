`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg short=0;reg[6:0]sum=0;reg[7:0]weight=0;wire[9:0]c;wire[5:0]s;
reg[9:0]gold[0:1023];integer mode,a,b,n=0;
fit_mac dut(clk,short,sum,weight,c,s);
initial begin
 $readmemh("F:/Project/fpga/vision_base/board/ti60f225_v4/rtl/vision/canny_fit_q4.mem",gold);
 for(mode=0;mode<2;mode=mode+1)for(a=0;a<128;a=a+1)for(b=0;b<256;b=b+1)begin
  @(negedge clk);short=mode;sum=a;weight=b;@(posedge clk);#1;
  if(c!==gold[(mode<<7)|a]||s!==gold[512|(mode<<8)|b][5:0])$fatal(1,"Mapped DSP signed/latency mismatch %0d %0d %0d",mode,a,b);
  n=n+1;
 end
 $display("PASS mapped Efinity DSP primitives %0d exact cycle pairs",n);$finish;
end
endmodule
