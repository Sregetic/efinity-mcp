`timescale 1ns/1ps
module tb;
reg clk=0,rst=0,blank=0,de=0,bitmap=0;reg[11:0]x=0,y=0;always #5 clk=~clk;
wire[8:0]fx,fy,rx,ry;wire p,rp;wire[7:0]c,rc;wire[31:0]ce,se,rce,rse;
vision_canny_raster #(.INDEX_FILE("board/ti60f225_v4/rtl/vision/canny_coverage_index.mem"),.PALETTE_FILE("board/ti60f225_v4/rtl/vision/canny_coverage_palette.mem"))dut(clk,rst,blank,de,x,y,bitmap,1'b1,fx,fy,p,ce,se,c);
vision_canny_raster_reference #(.INDEX_FILE("board/ti60f225_v4/rtl/vision/canny_coverage_index.mem"),.PALETTE_FILE("board/ti60f225_v4/rtl/vision/canny_coverage_palette.mem"))original(clk,rst,blank,de,x,y,bitmap,1'b1,rx,ry,rp,rce,rse,rc);
reg[31:0]plane[0:4049];integer ticks=0,checks=0,phases=0;
always @(posedge clk)begin
 bitmap<=fx<480&&fy<270?((plane[(fy*480+fx)>>5]>>((fy*480+fx)&31))&1):0;
 ticks=ticks+1;
 if(rst&&dut.line_fit.busy)begin
  if({dut.line_fit.trace_hl_q,dut.line_fit.trace_hr_q,dut.line_fit.trace_vl_q,dut.line_fit.trace_vr_q}!==
     {dut.line_fit.trace_line(dut.line_fit.job_window,dut.line_fit.step,1'b1,1'b0),dut.line_fit.trace_line(dut.line_fit.job_window,dut.line_fit.step,1'b1,1'b1),dut.line_fit.trace_line(dut.line_fit.job_window,dut.line_fit.step,1'b0,1'b0),dut.line_fit.trace_line(dut.line_fit.job_window,dut.line_fit.step,1'b0,1'b1)})$fatal(1,"prefetch phase");
  phases=phases+1;
 end
 #1;
 if(rst&&{fx,fy,p,c,ce,se}!=={rx,ry,rp,rc,rce,rse})$fatal(1,"raster cycle%0d xy%0d/%0d cov%0d/%0d",ticks,x,y,c,rc);
end
integer f,xx,yy;string path;
initial begin
 for(f=0;f<3;f++)begin
  case(f)0:path="results/geometry_m7_20261028/photo_raw_v2_bitmap.mem";1:path="results/geometry_m7_20261028/face_raw_v2_bitmap.mem";2:path="results/geometry_m7_20261028/two_faces_raw_bitmap.mem";endcase
  $readmemh(path,plane);
  if(f==0)begin repeat(4)@(negedge clk);rst=1;end
  @(negedge clk);blank=1;de=0;repeat(8)@(negedge clk);blank=0;
  wait(!dut.prefill);repeat(16)@(negedge clk);
  for(yy=0;yy<1080;yy++)begin
   for(xx=0;xx<1920;xx++)begin @(negedge clk);de=1;x=xx;y=yy;checks++;end
   @(negedge clk);de=0;x=0;repeat(280)@(negedge clk);
  end
 end
 if(checks!=6220800||phases==0)$fatal(1,"coverage");
 $display("PASS %0d native raster pixels: all8-bit coverage, binary pixels, fetch addresses and counters cycle-identical; %0d trace phases",checks,phases);$finish;
end
initial begin #100000000;$fatal(1,"watchdog");end
endmodule
