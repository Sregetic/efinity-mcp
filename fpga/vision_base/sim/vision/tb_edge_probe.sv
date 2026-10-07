`timescale 1ns/1ps
module tb;
localparam W=48,H=32,N=W*H;
reg clk=0,rst=0,vblank=0,cv=0,last=0,de=0,req=0;reg[7:0]x=0,y=0,dx=0,dy=0;
reg[1:0]c=0;reg[11:0]address=0;wire cap,ready,busy,pixel,fault,pbusy,ack,hpixel;reg[7:0]hx=0,hy=0;
wire[31:0]frames,data;wire[11:0]read_address;
vision_hysteresis_sweep #(.W(W),.H(H),.CW(8),.REUSE_CAPTURE_MAP(1),.PROBE(1),.HISTORY(1))dut(
 clk,rst,vblank,cv,x,y,c,last,dx,dy,cap,ready,busy,pixel,frames,fault,,,de,req,address,ack,data,read_address,pbusy,1'b0,,,,hx,hy,hpixel);
always #5 clk=~clk;
function automatic gold(input integer a);gold=(a%W>=9&&a%W<=33&&a/W>=7&&a/W<=24)||a%73==0;endfunction
integer i,j,frame_checks=0,probe_checks=0;reg[31:0]wanted;
initial begin
 repeat(4)@(negedge clk);rst=1;wait(dut.state==1);@(negedge clk);vblank=1;
 @(negedge clk);vblank=0;
 for(i=0;i<N;i=i+1)begin cv=1;x=i%W;y=i/W;c=gold(i)?2:0;last=i==N-1;@(negedge clk);end
 cv=0;last=0;wait(dut.state==8);@(negedge clk);vblank=1;@(negedge clk);vblank=0;wait(ready);
 for(i=0;i<N/32;i=i+1)begin
  // Request during active video, then give a34+clock horizontal blank.
  address=i;req=~req;de=1;
  for(j=0;j<48;j=j+1)begin
   dx=j;dy=i%H;hx=(j+13)%W;hy=(i+5)%H;cv=1;x=j;y=i%H;c=0;@(posedge clk);#1;
   if(pixel!==gold((i%H)*W+j))$fatal(1,"active video corrupted at%0d",j);
   if(hpixel!==gold(hy*W+hx))$fatal(1,"history port corrupted by display/back write");
   frame_checks=frame_checks+1;@(negedge clk);
  end
  de=0;cv=0;repeat(40)@(negedge clk);
  wanted=0;for(j=0;j<32;j=j+1)wanted[j]=gold(i*32+j);
  if(ack!==req||pbusy||data!==wanted||read_address!=i)$fatal(1,"probe address%0d got%h expected%h",i,data,wanted);
  probe_checks=probe_checks+32;
 end
 if(fault||frames!=1)$fatal(1,"front plane changed while publication held");
 $display("PASS edge probe %0d bits, %0d active pixels unaffected, crossed rows, front frame stable",probe_checks,frame_checks);$finish;
end
initial begin #10000000;$fatal(1,"probe watchdog");end
endmodule
