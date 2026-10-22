`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst_n=0,de=0,hs=0,vs=0,motion_enable=0;reg[7:0]gray=0;reg[2:0]mode=0;reg[1:0]memory_mode=0;
wire[23:0]rgb,base_rgb;wire ode,ohs,ovs,bde,bhs,bvs;wire[2:0]direction;wire held;
vision_display #(.LOCAL_MOTION_ENABLE(1),.WIDTH(192),.HEIGHT(96)) dut(
 .clk(clk),.rst_n(rst_n),.de(1'b0),.hs(1'b0),.vs(1'b0),.r(8'd0),.g(8'd0),.b(8'd0),.mode(mode),.threshold(11'd96),.median_en(1'b0),
 .memory_mode(memory_mode),.history_index(3'd0),.canny_pixel(1'b0),.canny_ready(1'b1),.canny_coverage(8'd0),
 .canny_effective_threshold(11'd80),.canny_requested_threshold(11'd80),.shape_enable(1'b0),.shape_threshold(8'd32),
 .analysis_enabled(1'b0),.analysis_context_changed(1'b0),.frame_id(32'd1),.render_config_id(32'd0),.analysis_context(32'd0),
 .analysis_result(352'd0),.analysis_match(1'b0),.analysis_identity_match(1'b0),.analysis_age(16'd0),.ui_state(24'd0),
 .motion_enable(motion_enable),.motion_direction(direction),.motion_held(held),.ode(ode),.ohs(ohs),.ovs(ovs),.orr(rgb[23:16]),.ogg(rgb[15:8]),.obb(rgb[7:0]));
vision_display #(.WIDTH(192),.HEIGHT(96)) reference(
 .clk(clk),.rst_n(rst_n),.de(1'b0),.hs(1'b0),.vs(1'b0),.r(8'd0),.g(8'd0),.b(8'd0),.mode(mode),.threshold(11'd96),.median_en(1'b0),
 .memory_mode(memory_mode),.history_index(3'd0),.canny_pixel(1'b0),.canny_ready(1'b1),.canny_coverage(8'd0),
 .canny_effective_threshold(11'd80),.canny_requested_threshold(11'd80),.shape_enable(1'b0),.shape_threshold(8'd32),
 .analysis_enabled(1'b0),.analysis_context_changed(1'b0),.frame_id(32'd1),.render_config_id(32'd0),.analysis_context(32'd0),
 .analysis_result(352'd0),.analysis_match(1'b0),.analysis_identity_match(1'b0),.analysis_age(16'd0),.ui_state(24'd0),
 .motion_enable(1'b0),.ode(bde),.ohs(bhs),.ovs(bvs),.orr(base_rgb[23:16]),.ogg(base_rgb[15:8]),.obb(base_rgb[7:0]));
integer f,ix,iy,p,checked=0,saw_right=0;
always @(posedge clk)begin #1;if(rst_n)begin
 if({ode,ohs,ovs,rgb}!=={bde,bhs,bvs,base_rgb})$fatal(1,"motion tap changed video/sync in mode%0d",mode);
 checked=checked+1;if(direction==3)saw_right=1;
end end
task boundary;begin de=0;vs=1;repeat(20)@(negedge clk);vs=0;repeat(20)@(negedge clk);end endtask
initial begin
 // Inject aligned frontend outputs; the existing frontend suite tests its pixel arithmetic.
 force dut.fd0=de;force dut.fh0=hs;force dut.fv0=vs;force dut.gray0=gray;
 force dut.x0=ix;force dut.y0=iy;force dut.fr0=gray;force dut.fg0=gray;force dut.fb0=gray;
 force dut.border0=0;force dut.edge0=gray<96;force dut.mag0=11'd512;
 force reference.fd0=de;force reference.fh0=hs;force reference.fv0=vs;force reference.gray0=gray;
 force reference.x0=ix;force reference.y0=iy;force reference.fr0=gray;force reference.fg0=gray;force reference.fb0=gray;
 force reference.border0=0;force reference.edge0=gray<96;force reference.mag0=11'd512;
 repeat(5)@(negedge clk);rst_n=1;motion_enable=1;
 for(f=0;f<24;f=f+1)begin
  $display("motion raster %0d at %0t",f,$time);$fflush();
  mode=f%8;boundary;p=2+f%8;
  for(iy=0;iy<96;iy=iy+1)begin
   for(ix=0;ix<192;ix=ix+1)begin de=1;gray=(iy>=32&&iy<56&&ix>=p*16&&ix<(p+2)*16)?20:180;@(negedge clk);end
   de=0;repeat(8)@(negedge clk);
  end
  repeat(50)@(negedge clk);
 end
 boundary;repeat(50)@(negedge clk);
 if(!saw_right||dut.motion.tap.dropped_frames)$fatal(1,"live direction not reached/dropped frame %0d %0d",saw_right,dut.motion.tap.dropped_frames);
 memory_mode=1;repeat(3)@(negedge clk);if(direction||held)$fatal(1,"frozen motion not cleared");
 memory_mode=2;repeat(3)@(negedge clk);if(direction||held)$fatal(1,"history motion not cleared");
 memory_mode=0;motion_enable=0;repeat(3)@(negedge clk);if(direction||held)$fatal(1,"disabled motion not cleared");
 $display("PASS motion_display post-frontend tap+readout, 24 rasters/all8 modes, %0d RGB/sync cycles exact; freeze/history/off reset",checked);$finish;
end
initial begin #100000000;$fatal(1,"motion display timeout");end
endmodule
