`timescale 1ns/1ps
module tb;
localparam W=32,H=24,N=W*H,MIN=32;
reg clk=0,rst=0,vblank=0,cv=0,last=0;reg[7:0]x=0,y=0,dx=0,dy=0;reg[1:0]c=0;
wire cap,ready,busy,pixel,fault;wire[31:0]frames;wire[3:0]state;
vision_hysteresis_sweep #(.W(W),.H(H),.CW(8),.REUSE_CAPTURE_MAP(1),.MIN_COMPONENT(MIN))
 dut(clk,rst,vblank,cv,x,y,c,last,dx,dy,cap,ready,busy,pixel,frames,fault,state,,1'b0,1'b0,12'd0,,,,,1'b0,,,,8'd0,8'd0,);
always #5 clk=~clk;
reg[1:0]input_map[0:N-1];reg gold[0:N-1],seen[0:N-1];integer queue[0:N-1];
integer testno,i,j,xx,yy,a,b,head,tail,idx,ni,nx,ny,kept=0,removed=0,cycles=0,checks=0;
reg has_seed;
always @(posedge clk)cycles=cycles+1;
task reference;
 begin
  for(i=0;i<N;i=i+1)begin seen[i]=0;gold[i]=0;end
  for(i=0;i<N;i=i+1)if(input_map[i]!=0&&!seen[i])begin
   queue[0]=i;seen[i]=1;head=0;tail=1;has_seed=0;
   while(head<tail)begin
    idx=queue[head];head=head+1;has_seed=has_seed||input_map[idx]==2;
    for(b=-1;b<=1;b=b+1)for(a=-1;a<=1;a=a+1)begin
     nx=idx%W+a;ny=idx/W+b;ni=ny*W+nx;
     if(nx>=0&&nx<W&&ny>=0&&ny<H&&input_map[ni]!=0&&!seen[ni])begin seen[ni]=1;queue[tail]=ni;tail=tail+1;end
    end
   end
   if(has_seed&&tail>=MIN)begin for(j=0;j<tail;j=j+1)gold[queue[j]]=1;kept=kept+tail;end
   else removed=removed+tail;
  end
 end
endtask
task run_frame;
 integer start_cycles;
 begin
  reference;
  if(!cap)begin wait(state==1);@(negedge clk);vblank=1;@(negedge clk);vblank=0;wait(cap);end
  for(yy=0;yy<H;yy=yy+1)for(xx=0;xx<W;xx=xx+1)begin
   @(negedge clk);cv=1;x=xx;y=yy;c=input_map[yy*W+xx];last=xx==W-1&&yy==H-1;
  end
  @(negedge clk);cv=0;last=0;start_cycles=cycles;
  wait(state==8);if(fault)$fatal(1,"filter fault");
  @(negedge clk);vblank=1;@(negedge clk);vblank=0;
  for(yy=0;yy<H;yy=yy+1)for(xx=0;xx<W;xx=xx+1)begin
   @(negedge clk);dx=xx;dy=yy;@(posedge clk);#1;
   if(pixel!==gold[yy*W+xx])$fatal(1,"CC mismatch test=%0d x=%0d y=%0d",testno,xx,yy);
   checks=checks+1;
  end
  $display("PASS CC frame=%0d process_cycles=%0d",testno,cycles-start_cycles);
 end
endtask
initial begin
 repeat(4)@(negedge clk);rst=1;
 for(testno=0;testno<54;testno=testno+1)begin
  for(i=0;i<N;i=i+1)input_map[i]=0;
  case(testno)
   0:for(yy=1;yy<H;yy=yy+3)for(xx=1;xx<W;xx=xx+3)input_map[yy*W+xx]=2;
   1:for(xx=0;xx<MIN-1;xx=xx+1)input_map[2*W+xx]=2; // Threshold minus one removed.
   2:for(xx=0;xx<MIN;xx=xx+1)input_map[2*W+xx]=2; // Exact threshold retained.
   3:begin
    for(yy=0;yy<H;yy=yy+1)input_map[yy*W+yy]=yy==0?2:1;
    for(yy=1;yy<21;yy=yy+1)input_map[yy*W+12]=2;
    for(xx=12;xx<29;xx=xx+1)input_map[9*W+xx]=2; // Large component with tails.
   end
   default:if(testno!=53)for(i=0;i<N;i=i+1)begin
    a=$urandom_range(0,99);input_map[i]=a<6?2:(a<25?1:0);
   end
  endcase
  run_frame;
 end
 if(frames!=54||fault||kept==0||removed==0)$fatal(1,"coverage/frames failure");
 $display("PASS CC %0d pixels, 54 maps, all components<%0d removed, exact boundary/thin/diagonal/tail kept, weak hysteresis exact, next-frame overwrite",checks,MIN);$finish;
end
initial begin #100000000;$fatal(1,"timeout state=%0d",state);end
endmodule
