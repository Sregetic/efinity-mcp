`timescale 1ns/1ps
module tb;
reg clk=0,rst=0;reg[31:0]frame_id=10,render_config_id=7,analysis_context=3;
reg[351:0]packet=0;wire geometry_done;wire[31:0]geometry_frame,geometry_config,geometry_context;
wire[7:0]r,g,b;reg analysis_match=1;
vision_display #(.FUSION(1)) dut(.ui_state(15'd0),.clk(clk),.rst_n(rst),.de(1'b0),.hs(1'b0),.vs(1'b0),.r(8'd0),.g(8'd0),.b(8'd0),
 .mode(3'd6),.threshold(11'd64),.median_en(1'b0),.memory_mode(2'd0),.history_index(3'd0),
 .canny_pixel(1'b0),.canny_ready(1'b1),.canny_coverage(8'd0),.shape_enable(1'b1),.shape_threshold(8'd32),
 .canny_effective_threshold(11'd80),.canny_requested_threshold(11'd80),
 .analysis_enabled(1'b1),.analysis_context_changed(1'b0),.frame_id(frame_id),.render_config_id(render_config_id),.analysis_context(analysis_context),
 .analysis_result(packet),.analysis_match(analysis_match),.analysis_identity_match(analysis_match),.analysis_age(16'd0),.geometry_done(geometry_done),.geometry_frame(geometry_frame),.geometry_config(geometry_config),.geometry_context(geometry_context),.orr(r),.ogg(g),.obb(b));
always #5 clk=~clk;
initial begin
 force dut.fd=1;force dut.border=0;force dut.x=0;force dut.y=0;force dut.fr=8'd100;force dut.fg=8'd80;force dut.fb=8'd60;force dut.gray=8'd90;
 force dut.shape_valid=1;force dut.shape_class=2;force dut.shape_done=0;
 force dut.sx0=700;force dut.sx1=800;force dut.sy0=300;force dut.sy1=400;
 repeat(2)@(negedge clk);rst=1;@(negedge clk);force dut.x=700;force dut.y=300;
 force dut.shape_done=1;@(negedge clk);force dut.shape_done=0;
 if(geometry_frame!=10||geometry_config!=7||geometry_context!=3)$fatal(1,"completed geometry tags");
 if(dut.shape_gray!=90)$fatal(1,"AI geometry grayscale input changed");
 frame_id=11;force dut.x=0;force dut.y=0;@(negedge clk);force dut.x=700;force dut.y=300;
 if(geometry_frame!=10||dut.shape_current)$fatal(1,"old geometry retagged with new source");
 packet[0]=1;packet[223:192]=700|(300<<16);packet[255:224]=800|(400<<16);
 repeat(2)@(posedge clk);#1;if({r,g,b}!=24'h00ffff)$fatal(1,"matched AI ROI absent");
 analysis_match=0;repeat(2)@(posedge clk);#1;if({r,g,b}!=24'h64503c)$fatal(1,"stale ROI drawn on new object");
 // One-beat base/OSD delay must preserve RGB and DE/HS/VS at line ends.
 @(negedge clk);force dut.fd=0;force dut.fh=1;force dut.fv=1;
 @(posedge clk);#1;if(dut.ode!=1||{r,g,b}!=24'h64503c)$fatal(1,"last active pixel lost");
 @(posedge clk);#1;if(dut.ode!=0||dut.ohs!=1||dut.ovs!=1||{r,g,b}!=0)$fatal(1,"control/RGB pipeline mismatch");
 $display("PASS fusion display completed-frame tags, AI geometry grayscale input, fresh/stale ROI and no retagging");$finish;
end
endmodule
