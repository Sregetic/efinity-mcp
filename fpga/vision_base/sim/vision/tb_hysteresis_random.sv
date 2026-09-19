`timescale 1ns/1ps
module tb;
localparam W=16,H=12,N=W*H;
reg clk=0;always #5 clk=~clk;
reg rst=0,vblank=0,cv=0,last=0;reg[7:0]x=0,y=0,dx=0,dy=0;reg[1:0]c=0;
wire cap,ready,busy,pixel,fault;wire[31:0]frames;wire[3:0]state;wire[8:0]queued;
vision_hysteresis_sweep #(.W(W),.H(H),.CW(8),.REUSE_CAPTURE_MAP(1)) dut(clk,rst,vblank,cv,x,y,c,last,dx,dy,cap,ready,busy,pixel,frames,fault,state,queued);
integer cls[0:N-1],refmap[0:N-1];integer f,i,j,xx,yy,nx,ny,changed,cycles=0;
always @(posedge clk)if(state>=3&&state<=7)cycles<=cycles+1;
initial begin
 #21;rst=1;
 for(f=0;f<100;f=f+1)begin
  for(i=0;i<N;i=i+1)begin
   cls[i]=$urandom_range(0,9);cls[i]=(cls[i]<5)?0:((cls[i]<9)?1:2);
   if(f==0)cls[i]=1;
   if(f==1)cls[i]=(i==N-1)?2:1;
   if(f==2)cls[i]=(i==0)?2:1;
   if(f==3)cls[i]=2;
   refmap[i]=(cls[i]==2);
  end
  changed=1;
  while(changed)begin
   changed=0;
   for(i=0;i<N;i=i+1)if(cls[i]==1&&!refmap[i])begin
    xx=i%W;yy=i/W;
    for(ny=yy-1;ny<=yy+1;ny=ny+1)for(nx=xx-1;nx<=xx+1;nx=nx+1)
     if(nx>=0&&nx<W&&ny>=0&&ny<H)if(refmap[ny*W+nx])begin refmap[i]=1;changed=1;end
   end
  end
  if(f==0)begin wait(state==1);@(negedge clk);vblank=1;@(negedge clk);vblank=0;end
  wait(cap);
  for(i=0;i<N;i=i+1)begin @(negedge clk);x=i%W;y=i/W;c=cls[i];cv=1;last=(i==N-1);end
  @(negedge clk);cv=0;last=0;wait(state==8);
  @(negedge clk);vblank=1;@(negedge clk);vblank=0;
  for(i=0;i<N;i=i+1)begin
   @(negedge clk);dx=i%W;dy=i/W;@(posedge clk);#1;
   if(pixel!==1'(refmap[i]))$fatal(1,"frame%0d pixel%0d got%0b expected%0d",f,i,pixel,refmap[i]);
  end
  if(fault||frames!=f+1)$fatal(1,"status");
 end
 $display("HYSTERESIS RANDOM PASS 100 maps, 19200 pixels, exact flood reference, scan cycles=%0d",cycles);$finish;
end
initial begin #100000000;$fatal(1,"timeout");end
endmodule
