`timescale 1ns/1ps
module tb;
reg clk=0;always #2.272727 clk=~clk;
reg[71:0]w=0;reg[15:0]meta=0;reg[10:0]threshold=0;
wire[10:0]mag;wire[1:0]dir;wire[15:0]out_meta;wire edge_pixel;
vision_sobel #(.META(16)) dut(clk,w,meta,mag,dir,out_meta,threshold,edge_pixel);
integer em[0:10003],ed[0:10003],ee[0:10003];
integer i,j,gx,gy,ax,ay,p[0:8],checked=0;
initial begin
 for(i=0;i<10004;i=i+1)begin
  @(negedge clk);
  for(j=0;j<9;j=j+1)begin
   if(i<512)p[j]=((i>>j)&1)?255:0;
   else p[j]=$urandom_range(0,255);
   w[71-j*8-:8]=p[j];
  end
  meta=i;threshold=$urandom_range(0,2047);
  gx=p[2]+2*p[5]+p[8]-p[0]-2*p[3]-p[6];
  gy=p[6]+2*p[7]+p[8]-p[0]-2*p[1]-p[2];
  ax=(gx<0)?-gx:gx;ay=(gy<0)?-gy:gy;
  em[i]=ax+ay;ee[i]=(em[i]>=threshold);
  ed[i]=(ay*256<ax*106)?0:((ax*256<ay*106)?2:(((gx<0)^(gy<0))?3:1));
  @(posedge clk);#0.1;
  if(i>=3)begin
   if(out_meta!==16'(i-3)||mag!==11'(em[i-3])||dir!==2'(ed[i-3])||edge_pixel!==1'(ee[i-3]))
    $fatal(1,"Sobel mismatch cycle=%0d meta=%0d magnitude=%0d expected=%0d",i,out_meta,mag,em[i-3]);
   checked=checked+1;
  end
 end
 $display("SOBEL PASS %0d windows, 512 binary extremes, four stages, II=1, varying threshold + metadata",checked);$finish;
end
endmodule
