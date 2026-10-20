`timescale 1ns/1ps
module tb;
localparam W=48,H=36,PW=W*4,PH=H*4;
reg clk=0,rst=0,vblank=0,de=0,ready=1,bitmap=0;reg[11:0]x=0,y=0;
wire[8:0]fx,fy;wire[7:0]coverage;wire pixel;wire[31:0]coarse,shown;
vision_canny_raster #(.W(W),.H(H),.COVERAGE_FILE("board/ti60f225_v4/rtl/vision/canny_coverage_q5.mem"),.FIT_FILE("board/ti60f225_v4/rtl/vision/canny_fit_q4.mem"))
 dut(clk,rst,vblank,de,x,y,bitmap,ready,fx,fy,pixel,coarse,shown,coverage);
always #5 clk=~clk;
reg map[0:W*H-1];reg[79:0]lut[0:511];reg[4:0]level;reg[7:0]expected;
always @(posedge clk)bitmap<=fx<W&&fy<H?map[fy*W+fx]:0;
integer f,i,xx,yy,a,b,nx,ny,pattern,cx,cy,k,minor,total,weight,slope,start,distance,major,minor_axis;
integer checks=0,fit_checks=0,radius,walk_pattern,previous,candidate,q,golden;reg[4:0]actual_walk;
initial begin
 $readmemh("board/ti60f225_v4/rtl/vision/canny_coverage_q5.mem",lut);
 repeat(4)@(negedge clk);rst=1;
 for(walk_pattern=0;walk_pattern<2048;walk_pattern=walk_pattern+1)for(previous=-5;previous<=5;previous=previous+1)begin
  golden=0;
  for(q=4;q>=0;q=q-1)begin
   candidate=previous+(q==1?-1:q==2?1:q==3?-2:q==4?2:0);
   if(candidate>=-5&&candidate<=5&&(walk_pattern&(1<<(candidate+5))))golden=16|(candidate&15);
  end
  actual_walk=dut.line_fit.walk(11'(walk_pattern),4'(previous));
  if(actual_walk!==5'(golden))$fatal(1,"walk pattern%h previous%0d got%h expected%h",walk_pattern,previous,actual_walk,golden);
 end
 for(f=0;f<5;f=f+1)begin
  for(yy=0;yy<H;yy=yy+1)for(xx=0;xx<W;xx=xx+1)
   case(f)
    0:map[yy*W+xx]=yy==8+xx/3;
    1:map[yy*W+xx]=yy==27-xx/3;
    2:map[yy*W+xx]=xx==8+yy/3;
    3:map[yy*W+xx]=xx==28-yy/3;
    default:map[yy*W+xx]=0;
   endcase
  for(yy=0;yy<H;yy=yy+1)for(xx=0;xx<W;xx=xx+1)
   if(xx<2||xx>=W-2||yy<2||yy>=H-2)map[yy*W+xx]=0;
  @(negedge clk);vblank=1;de=0;repeat(8)@(negedge clk);vblank=0;
  wait(!dut.prefill);repeat(16)@(negedge clk);
  for(yy=0;yy<PH;yy=yy+1)begin
   for(xx=0;xx<PW;xx=xx+1)begin
    @(negedge clk);de=1;x=xx;y=yy;@(posedge clk);#1;
    cx=xx/4;cy=yy/4;pattern=0;
    for(b=-1;b<=1;b=b+1)for(a=-1;a<=1;a=a+1)begin
     nx=cx+a;ny=cy+b;
     if(nx>=0&&nx<W&&ny>=0&&ny<H&&map[ny*W+nx])pattern=pattern|(1<<(8-(b+1)*3-a-1));
    end
    level=lut[pattern][5*((yy%4)*4+xx%4)+:5];expected={level,level[4:2]};
    minor=f==0?8+cx/3:f==1?27-cx/3:f==2?8+cy/3:28-cy/3;
    minor_axis=f<2?cy:cx;
    major=f<2?cx:cy;
    radius=(major>=6&&major<(f<2?W:H)-6)?4:(major>=4&&major<(f<2?W:H)-4)?2:0;
    if(f<4&&cx>=2&&cx<W-2&&cy>=2&&cy<H-2&&radius!=0&&minor-minor_axis>=-1&&minor-minor_axis<=1)begin
     total=0;weight=0;
     for(k=-radius;k<=radius;k=k+1)begin
      minor=(f==0?8+(cx+k)/3:f==1?27-(cx+k)/3:f==2?8+(cy+k)/3:28-(cy+k)/3)-minor_axis;
      total=total+minor;weight=weight+k*minor;
     end
     slope=radius==4?(weight*17+32)>>>6:(weight*13+4)>>>3;
     start=32+(radius==4?((total*57+4)>>>3):((total*51+2)>>>2))-2*slope;
     major=f<2?xx%4:yy%4;minor_axis=f<2?yy%4:xx%4;
     distance=minor_axis*16-(start+major*slope);if(distance<0)distance=-distance;
     expected=distance<16?255-distance*16:0;fit_checks=fit_checks+1;
    end
    if(cx<2||cx>=W-2||cy<2||cy>=H-2)expected=0;
    if(coverage!==expected)$fatal(1,"fit frame%0d x%0d y%0d got%0d expected%0d enable%b active%h",f,xx,yy,coverage,expected,dut.fit_enable,dut.line_fit.active);
    checks=checks+1;
   end
   @(negedge clk);de=0;x=0;repeat(12)@(negedge clk);
  end
 end
 if(fit_checks<3000)$fatal(1,"straight-fit interior not exercised");
 $display("PASS9-point fit %0d raster pixels, %0d fitted pixels, +/- shallow/steep slopes and empty next frame",checks,fit_checks);$finish;
end
endmodule
