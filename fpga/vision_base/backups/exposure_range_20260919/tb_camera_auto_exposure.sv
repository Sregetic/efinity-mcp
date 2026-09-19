`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0,vs=0,de=0,ack=0,fault=0,en=1;reg[15:0]pix=0,manual=444;reg[31:0]frame=0;
wire req,boost;wire[15:0]ex,nc,nt,nh;wire[31:0]sum;wire[1:0]decision;
camera_auto_exposure #(.CX0(0),.CX1(16),.CY0(0),.CY1(16),.SAMPLE_BITS(1),.SETTLE(2))d(clk,rst,vs,de,pix,frame,en,manual,ack,fault,req,ex,sum,nc,nt,nh,decision,boost);
always @(posedge clk)if(rst)ack<=req;
task automatic image(input[7:0]v,input fresh);
 integer x,y;begin
 @(negedge clk);vs=1;de=0;if(fresh)frame=frame+1;repeat(4)@(negedge clk);vs=0;
 for(y=0;y<16;y=y+1)begin
  for(x=0;x<16;x=x+1)begin de=1;pix={v,v};@(negedge clk);end
  de=0;repeat(2)@(negedge clk);
 end
 repeat(8)@(negedge clk);
 end
endtask
integer i;reg[15:0]old;
initial begin
 #21;rst=1;for(i=0;i<12;i=i+1)image(24,1);
 if(ex<=444||!boost)$fatal(1,"dark scene did not increase exposure");
 old=ex;for(i=0;i<12;i=i+1)image(255,1);
 if(ex>=old||nh!=nt||nc!=64||nt!=64)$fatal(1,"clipped scene/metering failed");
 for(i=0;i<8;i=i+1)image(60,1);old=ex;
 for(i=0;i<10;i=i+1)image(24,0);
 if(ex!=old)$fatal(1,"frozen source changed exposure");
 fault=1;for(i=0;i<10;i=i+1)image(255,1);if(ex!=old)$fatal(1,"fault changed exposure");
 fault=0;en=0;manual=600;for(i=0;i<12;i=i+1)image(24,1);if(ex!=600)$fatal(1,"manual override failed");
 $display("AE PASS: dark/bright direction, 64 samples, deadband, freeze, fault and manual");$finish;
end
endmodule
