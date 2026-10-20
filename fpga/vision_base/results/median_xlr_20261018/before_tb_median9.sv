`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg[71:0]p=0;reg[15:0]m=0;wire[7:0]median;wire[15:0]om;
vision_median9 #(.META(16))dut(clk,p,m,median,om);
reg[7:0]expected[0:499],a[0:8],temp;integer i,j,k,errors=0;
initial begin
 for(i=0;i<509;i++)begin
 @(negedge clk);
 if(i<500)begin
  for(j=0;j<9;j++)begin a[j]=$urandom_range(0,255);p[j*8+:8]=a[j];end
  for(j=0;j<9;j++)for(k=j+1;k<9;k++)if(a[j]>a[k])begin temp=a[j];a[j]=a[k];a[k]=temp;end
  expected[i]=a[4];m=i;
 end else begin p=0;m=0;end
 @(posedge clk);#1;
 if(i>=8&&i-8<500)if(median!==expected[i-8]||om!==16'(i-8))errors++;
 end
 $display("MEDIAN9 500 windows errors=%d",errors);if(errors)$fatal;$finish;
end
endmodule
