`timescale 1ns/1ps
module tb;
localparam W=16,H=12,PW=W*4,PH=H*4;
reg clk=0,rst=0,vblank=0,de=0,ready=1,bitmap=0;reg[11:0]x=0,y=0;
wire[8:0]fx,fy;wire[7:0]coverage;wire pixel;wire[31:0]coarse,shown;
vision_canny_raster #(.W(W),.H(H),.COVERAGE_FILE("board/ti60f225_v4/rtl/vision/canny_coverage_q5.mem"),.FIT_FILE("board/ti60f225_v4/rtl/vision/canny_fit_q4.mem")) dut(clk,rst,vblank,de,x,y,bitmap,ready,fx,fy,pixel,coarse,shown,coverage);
always #5 clk=~clk;
reg map[0:W*H-1],gold[0:PW*PH-1];
always @(posedge clk)bitmap<=fx<W&&fy<H?map[fy*W+fx]:0;
reg[79:0]lut[0:511];reg[4:0]level;reg[7:0]expected_coverage;
integer f,i,xx,yy,a,b,k,nx,ny,gx,gy,pattern,checks=0,lit=0,halos=0;
initial begin
 force dut.fit_enable=0;
 $readmemh("board/ti60f225_v4/rtl/vision/canny_coverage_q5.mem",lut);
 repeat(4)@(negedge clk);rst=1;
 for(f=0;f<5;f=f+1)begin
  for(i=0;i<W*H;i=i+1)map[i]=0;
  for(yy=3;yy<H-3;yy=yy+1)for(xx=3;xx<W-3;xx=xx+1)
   map[yy*W+xx]=f==0?(xx==yy||xx+yy==12):(f==1?(xx==7||yy==6):(f==2?1:(f==3?$urandom_range(0,1):0)));
  for(i=0;i<PW*PH;i=i+1)gold[i]=0;
  for(yy=0;yy<H;yy=yy+1)for(xx=0;xx<W;xx=xx+1)if(map[yy*W+xx])begin
   gold[(yy*4+2)*PW+xx*4+2]=1;
   for(b=-1;b<=1;b=b+1)for(a=-1;a<=1;a=a+1)if(a!=0||b!=0)begin
    nx=xx+a;ny=yy+b;
    if(nx>=0&&nx<W&&ny>=0&&ny<H&&map[ny*W+nx])
     for(k=0;k<=4;k=k+1)begin gx=xx*4+2+a*k;gy=yy*4+2+b*k;gold[gy*PW+gx]=1;end
   end
  end
  @(negedge clk);vblank=1;de=0;repeat(8)@(negedge clk);vblank=0;
  wait(!dut.prefill);repeat(16)@(negedge clk);
  for(yy=0;yy<PH;yy=yy+1)begin
   for(xx=0;xx<PW;xx=xx+1)begin
    @(negedge clk);de=1;x=xx;y=yy;@(posedge clk);#1;
    if(pixel!==gold[yy*PW+xx])$fatal(1,"raster mismatch frame%0d x%0d y%0d got%b want%b tile%b",f,xx,yy,pixel,gold[yy*PW+xx],dut.tile);
    pattern=0;
    for(b=-1;b<=1;b=b+1)for(a=-1;a<=1;a=a+1)begin
     nx=xx/4+a;ny=yy/4+b;
     if(nx>=0&&nx<W&&ny>=0&&ny<H&&map[ny*W+nx])pattern=pattern|(1<<(8-(b+1)*3-a-1));
    end
    level=lut[pattern][5*((yy%4)*4+xx%4)+:5];expected_coverage={level,level[4:2]};
    if(xx/4<2||xx/4>=W-2||yy/4<2||yy/4>=H-2)expected_coverage=0;
    if(coverage!==expected_coverage)$fatal(1,"coverage mismatch frame%0d x%0d y%0d got%0d want%0d tile%b word%h",f,xx,yy,coverage,expected_coverage,dut.tile,dut.coverage_word);
    if(f==4&&coverage!==0)$fatal(1,"halo ghost on flat frame");
    if(coverage!=0&&coverage!=255)halos=halos+1;
    checks=checks+1;if(pixel)lit=lit+1;
   end
   @(negedge clk);de=0;x=0;repeat(12)@(negedge clk);
  end
 end
 if(halos==0)$fatal(1,"no diagonal antialias coverage");
 $display("PASS contour raster %0d pixels, %0d white pixels, diagonal/corner/horizontal/vertical/dense/random/zero next frame, sync bitmap RAM",checks,lit);$finish;
end
endmodule
