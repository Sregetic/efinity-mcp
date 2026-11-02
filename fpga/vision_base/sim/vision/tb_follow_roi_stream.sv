`timescale 1ns/1ps
`include "display_reset.svh"
module tb;
 reg clk=0,vid_rst_n=0,roi_config_changed=0;always #5 clk=~clk;
 reg de=0,hs=0,vs=0;reg[7:0]r=0,g=0,b=0;reg[2:0]mode=0;
 wire display_reset=`DISPLAY_RESET;
 wire[1:0]ode,ohs,ovs;wire[23:0]rgb[0:1];
 genvar n;generate for(n=0;n<2;n=n+1)begin:lane
  vision_display #(.WIDTH(96)) dut(.clk(clk),.rst_n(n==0?vid_rst_n:display_reset),.de(de),.hs(hs),.vs(vs),.r(r),.g(g),.b(b),.mode(mode),.threshold(11'd80),.median_en(1'b1),
   .memory_mode(2'd0),.history_index(3'd0),.canny_pixel(1'b1),.canny_ready(1'b1),.ode(ode[n]),.ohs(ohs[n]),.ovs(ovs[n]),.orr(rgb[n][23:16]),.ogg(rgb[n][15:8]),.obb(rgb[n][7:0]),
   .shape_enable(1'b0),.canny_effective_threshold(11'd80),.canny_requested_threshold(11'd80),.canny_coverage(8'd255),.analysis_enabled(1'b0),.analysis_context_changed(1'b0),
   .frame_id(32'd1),.render_config_id(32'd1),.analysis_context(32'd0),.analysis_result(352'd0),.analysis_match(1'b0),.analysis_identity_match(1'b0),.analysis_age(16'd0),.ui_state(24'd0),
   .motion_enable(1'b0),.geometry_rst_n(vid_rst_n),.geometry_source_valid(1'b1),.geometry_changed(roi_config_changed),.canny_capture_start(1'b0),.canny_completed(32'd1),.geometry_source_errors(32'd0),
   .geometry_cpu_clk(clk),.geometry_cpu_rst_n(vid_rst_n),.geometry_paddr(8'd0),.geometry_psel(1'b0),.geometry_penable(1'b0),.geometry_pwrite(1'b0),.geometry_pwdata(32'd0),.geometry_enable(1'b0),.geometry_selection(3'd0),.geometry_selection_bank(1'b0));
 end endgenerate
 integer frame,row,col,checks=0,pulses=0;
 task beat;begin @(posedge clk);#1;if(vid_rst_n)begin
  if({ode[1],ohs[1],ovs[1]}!=={ode[0],ohs[0],ovs[0]})$fatal(1,"ROI reset changed HDMI sync mode=%0d frame=%0d row=%0d col=%0d",mode,frame,row,col);
  if(ode[0]&&rgb[1]!==rgb[0])$fatal(1,"ROI reset blackened display pixels");checks=checks+1;
 end end endtask
 initial begin
  repeat(5)begin @(negedge clk);beat();end
  @(negedge clk);vid_rst_n=1;
  for(frame=0;frame<21;frame=frame+1)begin
   mode=frame/3;
   for(row=0;row<24;row=row+1)for(col=0;col<128;col=col+1)begin
    @(negedge clk);vs=row<2;hs=col<8;de=row>=4&&row<16&&col>=16&&col<112;
    r=(col+frame*3);g=(row*7);b=col^row;
    // ROI metadata can arrive anywhere in blanking, not only the VS edge.
    roi_config_changed=frame%3!=0&&((row==0&&col==40)||(row==3&&col==10));
    if(roi_config_changed)pulses=pulses+1;beat();
   end
  end
  if(pulses!=28||checks<60000)$fatal(1,"test coverage");
  $display("PASS ROI updates preserve HDMI sync and exact display pixels M0-M6: %0d cycles %0d invalidations",checks,pulses);$finish;
 end
endmodule
