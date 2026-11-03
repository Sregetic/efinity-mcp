`timescale 1ns/1ps
`include "canny_reset.svh"
module tb;
 reg clk=0,vid_rst_n=0,roi_config_changed=0;always #5 clk=~clk;
 reg de=0,hs=0,vs=0;reg[7:0]pixel=0;reg[11:0]x=0,y=0;
 wire[1:0]ready,busy,fault,edge_on;wire[31:0]completed[0:1];wire[7:0]coverage[0:1];
 genvar n;generate for(n=0;n<2;n=n+1)begin:lane
 vision_canny #(.W(24),.H(20),.CONTOUR_RASTER(1),.STABLE_NMS(1)) dut(.clk(clk),.rst_n(n==0?vid_rst_n:`CANNY_RESET),.de(de),.hs(hs),.vs(vs),.r(pixel),.g(pixel),.b(pixel),.high_threshold(11'd80),
 .display_x(x),.display_y(y),.edge_pixel(edge_on[n]),.ready(ready[n]),.busy(busy[n]),.fault(fault[n]),.completed(completed[n]),.display_de(de),.probe_hold(1'b0),.probe_req(1'b0),.probe_address(12'd0),.median_en(1'b1),.raster_de(de),.edge_coverage(coverage[n]));
 end endgenerate
 integer frame,row,col,checks=0,pulses=0;
 initial begin
  repeat(5)@(negedge clk);vid_rst_n=1;
  for(frame=0;frame<14;frame=frame+1)for(row=0;row<120;row=row+1)for(col=0;col<128;col=col+1)begin
   @(negedge clk);vs=row<2;hs=col<8;de=row>=4&&row<84&&col>=16&&col<112;x=col-16;y=row-4;
   pixel=(x>=24+(frame%3)*4&&x<80+(frame%3)*4&&y>=20&&y<68)?8'd230:8'd24;
   roi_config_changed=frame>=6&&row==0&&col==40;
   if(roi_config_changed)begin if(completed[0]<2||!ready[0])$fatal(1,"reference never warmed");pulses=pulses+1;end
   @(posedge clk);#1;
   if({ready[1],busy[1],fault[1],completed[1]}!=={ready[0],busy[0],fault[0],completed[0]})$fatal(1,"ROI reset discarded Canny state frame=%0d ready=%b completed=%0d/%0d",frame,ready,completed[0],completed[1]);
   if(de&&ready[0]&&{edge_on[1],coverage[1]}!=={edge_on[0],coverage[0]})$fatal(1,"ROI altered accepted Canny pixels");checks=checks+1;
  end
  if(pulses!=8||completed[0]<2||!ready[0])$fatal(1,"coverage");
  $display("PASS Canny ROI continuity: %0d identical cycles, %0d ROI changes, %0d completed frames, unchanged accepted pixels",checks,pulses,completed[0]);$finish;
 end
endmodule
