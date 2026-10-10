`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst=0,vs=0,de=0,en=1,fault=0,ack0=0,ack1=0;reg[15:0]pix=0,manual=444;reg[31:0]frame=0;
wire r0,r1,b0,b1;wire[15:0]v0,v1,n0,n1,t0,t1,h0,h1;wire[31:0]s0,s1;wire[1:0]d0,d1;
ae_reference #(.CX0(0),.CX1(16),.CY0(0),.CY1(16),.SAMPLE_BITS(1),.SETTLE(2))o(clk,rst,vs,de,pix,frame,en,manual,ack0,fault,r0,v0,s0,n0,t0,h0,d0,b0);
camera_auto_exposure #(.CX0(0),.CX1(16),.CY0(0),.CY1(16),.SAMPLE_BITS(1),.SETTLE(2))n(clk,rst,vs,de,pix,frame,en,manual,ack1,fault,r1,v1,s1,n1,t1,h1,d1,b1);
always @(posedge clk)if(rst)begin ack0<=r0;ack1<=r1;end
integer f,x,y;reg[31:0]random=32'h12345678;
initial begin
 repeat(4)@(negedge clk);rst=1;
 for(f=0;f<300;f=f+1)begin
  @(negedge clk);vs=1;de=0;if(f%7!=0)frame=frame+1;en=f%13!=0;fault=f%19==0;manual=112+(f*37)%2839;
  repeat(5)@(negedge clk);
  if({r0,v0,s0,n0,t0,h0,d0,b0}!={r1,v1,s1,n1,t1,h1,d1,b1})$fatal(1,"AE frame decision mismatch %0d",f);
  vs=0;
  for(y=0;y<16;y=y+1)begin
   for(x=0;x<16;x=x+1)begin de=1;random=(random>>1)^((random&1)?32'hd0000001:0);pix=f%3==0?16'h1818:f%3==1?16'hffff:random[15:0];@(negedge clk);end
   de=0;repeat(2)@(negedge clk);
  end
  repeat(8)@(negedge clk);
 end
 $display("PASS AE300 frame-equivalent decisions/statistics, mixed samples/fresh/fault/manual, two-clock delayed request");$finish;
end
endmodule
