`timescale 1ns/1ps
module tb;
localparam W=480,H=270;
reg clk=0;always #5 clk=~clk;
reg rst=0,vblank=0,de=0,ready=0,bitmap=0;reg[11:0]x=0,y=0;
wire[8:0]fx,fy,old_fx,old_fy;wire pixel,old_pixel;wire[7:0]coverage,old_coverage;
wire[31:0]coarse,shown,old_coarse,old_shown;
vision_canny_raster #(.W(W),.H(H),
 .INDEX_FILE("board/ti60f225_v4/rtl/vision/canny_coverage_index.mem"),
 .PALETTE_FILE("board/ti60f225_v4/rtl/vision/canny_coverage_palette.mem")) dut(
 clk,rst,vblank,de,x,y,bitmap,ready,fx,fy,pixel,coarse,shown,coverage);
vision_canny_raster_reference #(.W(W),.H(H),
 .COVERAGE_FILE("board/ti60f225_v4/rtl/vision/canny_coverage_q5.mem"),
 .FIT_FILE("board/ti60f225_v4/rtl/vision/canny_fit_q4.mem")) before_dut(
 clk,rst,vblank,de,x,y,bitmap,ready,old_fx,old_fy,old_pixel,old_coarse,old_shown,old_coverage);
reg map[0:W*H-1];integer f,xx,yy,i,checks=0,pixels=0,lit=0,before_image,after_image;
always @(posedge clk)bitmap<=fx<W&&fy<H?map[fy*W+fx]:0;
always @(posedge clk)begin
 #1;
 if(rst)begin
  if({fx,fy,pixel,coverage,coarse,shown}!=={old_fx,old_fy,old_pixel,old_coverage,old_coarse,old_shown})
   $fatal(1,"Canny A/B frame%0d x%0d y%0d coverage%0d/%0d",f,x,y,coverage,old_coverage);
  checks=checks+1;
  if(de)begin
   if(^coverage===1'bx)$fatal(1,"Uninitialized output");
   pixels=pixels+1;if(coverage!=0)lit=lit+1;
  end
 end
end
initial begin
 repeat(4)@(negedge clk);rst=1;ready=1;
 for(f=0;f<2;f=f+1)begin
  for(yy=0;yy<H;yy=yy+1)for(xx=0;xx<W;xx=xx+1)begin
   if(f==0)map[yy*W+xx]=(xx==yy+10)||(xx+yy==430)||
       ((xx==55||xx==420)&&yy>=40&&yy<=220)||((yy==40||yy==220)&&xx>=55&&xx<=420)||
       ((xx-250)*(xx-250)+(yy-135)*(yy-135)>=2500&&(xx-250)*(xx-250)+(yy-135)*(yy-135)<2600);
   else map[yy*W+xx]=$urandom_range(0,31)==0||(xx>300&&xx<350&&yy>80&&yy<130);
  end
  @(negedge clk);de=0;vblank=1;repeat(8)@(negedge clk);vblank=0;
  wait(!dut.prefill);repeat(16)@(negedge clk);
  if(f==0)begin
   before_image=$fopen("results/ram_pack_20261022/canny_before.pgm","wb");
   after_image=$fopen("results/ram_pack_20261022/canny_after.pgm","wb");
   $fwrite(before_image,"P5\n1920 1080\n255\n");$fwrite(after_image,"P5\n1920 1080\n255\n");
  end
  for(yy=0;yy<H*4;yy=yy+1)begin
   for(xx=0;xx<W*4;xx=xx+1)begin
    @(negedge clk);de=1;x=xx;y=yy;
    @(posedge clk);#2;
    if(f==0)begin $fwrite(before_image,"%c",old_coverage);$fwrite(after_image,"%c",coverage);end
   end
   @(negedge clk);de=0;repeat(280)@(negedge clk);
  end
  if(f==0)begin $fclose(before_image);$fclose(after_image);end
 end
 if(lit<1000)$fatal(1,"No useful contour coverage");
 $display("PASS native1920x1080 Canny A/B: %0d pixel pairs, %0d complete cycles; bitmap/fetch/coverage/counts exact",pixels,checks);$finish;
end
initial begin #100000000;$fatal(1,"A/B timeout");end
endmodule
