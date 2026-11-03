`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg[11:0]x=0,y=0;reg[2:0]mode=0;reg[14:0]ui=0;reg[10:0]threshold=0,request=0;
reg fusion=0,match=1;reg[351:0]packet=0;reg[15:0]age=0;wire a0,a1,i0,i1;
vision_osd n(x,y,mode,threshold,1'b1,2'd1,3'd5,1'b1,2'd2,1'b1,1'b1,a0,i0,request,fusion,packet,match,age,clk,ui);
osd_reference o(x,y,mode,threshold,1'b1,2'd1,3'd5,1'b1,2'd2,1'b1,1'b1,a1,i1,request,fusion,packet,match,age,clk,ui);
integer p,xx,yy,count=0;
initial begin
 for(p=0;p<20;p=p+1)begin
  mode=p%8;ui=((p%10)<<11)|(p*101%2048);threshold=p*103%2048;request=2047-threshold;fusion=p&1;match=p&2;age=$random;
  packet={$random,$random,$random,$random,$random,$random,$random,$random,$random,$random,$random};
  for(yy=0;yy<100;yy=yy+1)for(xx=0;xx<440;xx=xx+1)begin
   @(negedge clk);x=xx;y=yy;@(posedge clk);#1;
   if(a0!==a1||i0!==i1||(a0&&n.ch_q!==o.ch_q))$fatal(1,"OSD mismatch p=%0d x=%0d y=%0d",p,xx,yy);count=count+1;
  end
  for(xx=440;xx<1920;xx=xx+1)begin
   @(negedge clk);x=xx;y=4;@(posedge clk);#1;if(a0!==a1||i0!==i1)$fatal(1,"outside HUD alias");
  end
 end
 $display("PASS OSD compact selectors %0d pixels, all10 menus and outside-HUD aliases",count);$finish;
end
endmodule
