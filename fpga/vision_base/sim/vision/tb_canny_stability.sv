`timescale 1ns/1ps
module tb;
localparam W=32,H=32;
reg clk=0,rst=0,valid=0;reg[8:0]x=0,y=0;reg[10:0]mag=0;reg[1:0]dir=0;
reg history=0;wire nv,kept;wire[8:0]nx,ny;wire[10:0]nm;
reg old_map[0:W*H-1],next_map[0:W*H-1];
vision_canny_nms #(.W(W)) dut(clk,rst,valid,x,y,mag,dir,history,11'd128,1'b0,1'b0,nv,nx,ny,nm,kept);
always #5 clk=~clk;
// Same synchronous history read as the production front plane.
always @(posedge clk)history<=x>=2&&y>=2?old_map[(y-2)*W+x-2]:0;
integer f,xx,yy,i,count0,count1;
always @(posedge clk)if(nv&&nx>=4&&ny>=4)
 next_map[(ny-4)*W+nx-4]<=kept&&nm>=64;
initial begin
 for(i=0;i<W*H;i=i+1)begin old_map[i]=0;next_map[i]=0;end
 repeat(4)@(negedge clk);rst=1;
 for(f=0;f<6;f=f+1)begin
  for(i=0;i<W*H;i=i+1)next_map[i]=0;
  for(yy=0;yy<H;yy=yy+1)for(xx=0;xx<W;xx=xx+1)begin
   @(negedge clk);valid=1;x=xx;y=yy;mag=0;
   if(yy>=8&&yy<=25)begin
    if(f==0||f==1||f==2)mag=xx==16?(f==1?198:200):(xx==17?(f==1?200:198):0);
    if(f==3)mag=xx==20?200:(xx==21?198:0);
    if(f==5)mag=xx==20?30:0;
   end
   // Exercise sparse gaps, including consecutive pixels at each peak.
   @(negedge clk);valid=0;repeat(xx%3)@(negedge clk);
  end
  @(negedge clk);valid=0;repeat(8)@(negedge clk);
  count0=0;count1=0;
  for(yy=8;yy<22;yy=yy+1)begin
   if(f<3)begin count0=count0+next_map[yy*W+14];count1=count1+next_map[yy*W+15];end
   if(f==3)begin count0=count0+next_map[yy*W+18];count1=count1+next_map[yy*W+14];end
  end
  if(f<=3&&(count0!=14||count1!=0))$fatal(1,"peak stability/motion frame%0d kept%0d competitor%0d",f,count0,count1);
  if(f>=4)for(i=0;i<W*H;i=i+1)if(next_map[i])$fatal(1,"ghost/weak edge frame%0d address%0d",f,i);
  for(i=0;i<W*H;i=i+1)old_map[i]=next_map[i];
 end
 $display("PASS stable NMS: first frame, +/-2 near-peak noise, immediate motion, flat/weak rejection and sparse gaps");$finish;
end
endmodule
