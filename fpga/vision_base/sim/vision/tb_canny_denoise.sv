`timescale 1ns/1ps
module tb;
localparam W=64,H=48,N=W*H;
reg clk=0,rst=0,valid=0,median_en=1;always #5 clk=~clk;
reg[8:0]x=0,y=0;reg[7:0]gray=0;wire oval,noise_valid,calibrated;
wire[8:0]ox,oy;wire[7:0]pixel,mean;wire[10:0]floor;
vision_canny_denoise #(.W(W),.H(H))dut(clk,rst,valid,x,y,gray,median_en,oval,ox,oy,pixel,mean,floor,noise_valid,calibrated);
reg[7:0]input_pixels[0:2*N-1],expected[0:2*N-1];reg[7:0]means[0:1];
integer f,i,seen=0,errors=0,oframe=0;
always @(negedge clk)if(oval)begin
 if(ox==0&&oy==0&&seen!=0)oframe=oframe+1;
 if(pixel!==expected[oframe*N+oy*W+ox])begin errors=errors+1;if(errors<8)$display("DEN BAD frame%0d x%0d y%0d pixel%0d expected%0d",oframe,ox,oy,pixel,expected[oframe*N+oy*W+ox]);end
 seen=seen+1;
end
initial begin
 $readmemh("results/noise_finish_20261004/denoise_input.mem",input_pixels);
 $readmemh("results/noise_finish_20261004/denoise_expected.mem",expected);
 $readmemh("results/noise_finish_20261004/denoise_means.mem",means);
 repeat(4)@(negedge clk);rst=1;
 for(f=0;f<2;f=f+1)begin
  median_en=f==0;
  for(i=0;i<N;i=i+1)begin valid=1;x=i%W;y=i/W;gray=input_pixels[f*N+i];@(negedge clk);valid=0;repeat(15)@(negedge clk);end
  repeat(20)@(negedge clk);
  if(mean!==means[f]||!noise_valid||floor!=16+8*means[f])$fatal(1,"noise statistic frame%0d mean%0d expected%0d floor%0d",f,mean,means[f],floor);
  if(calibrated!=(f!=0))$fatal(1,"frame calibration state");
 end
 if(errors||seen!=2*N)$fatal(1,"denoise pixels errors%0d seen%0d",errors,seen);
 $display("PASS Canny denoise median/bypass %0d pixels, metadata, noise bound, bootstrap calibration",seen);$finish;
end
endmodule
