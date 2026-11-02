`timescale 1ns/1ps
module tb;
reg clk=0,rst=0,cp=0,cr=1;reg[2:0]mode=0;wire[7:0]r,g,b;wire[63:0]status;
always #5 clk=~clk;
vision_display #(.EDGE_STRENGTH(0)) dut(.clk(clk),.rst_n(rst),.de(1'b0),.hs(1'b0),.vs(1'b0),.r(8'd0),.g(8'd0),.b(8'd0),
 .mode(mode),.threshold(11'd64),.median_en(1'b1),.memory_mode(2'd0),.history_index(3'd0),.canny_pixel(cp),.canny_ready(cr),.canny_coverage(8'd0),
 .orr(r),.ogg(g),.obb(b),.geometry_enable(1'b0),.shape_enable(1'b1),.shape_status(status),.canny_effective_threshold(11'd128),.canny_requested_threshold(11'd128),
 .analysis_enabled(1'b0),.analysis_context_changed(1'b0),.analysis_result(352'd0),.analysis_match(1'b0),.analysis_identity_match(1'b0),.analysis_age(16'd0),.ui_state(24'd0));
task check_pixel(input[2:0]m,input[23:0]wanted);
 begin @(negedge clk);mode=m;repeat(2)@(posedge clk);#1;if({r,g,b}!==wanted||status[62])$fatal(1,"display%0d pixel=%h expected%h or implicit detection",m,{r,g,b},wanted);end
endtask
integer i;
initial begin
 force dut.fd=1;force dut.border=0;force dut.x=700;force dut.y=300;
 force dut.fr=8'h12;force dut.fg=8'h34;force dut.fb=8'h56;force dut.gray=8'd90;force dut.edge1=1;
 repeat(3)@(negedge clk);rst=1;
 check_pixel(0,24'h123456);check_pixel(1,24'h5a5a5a);check_pixel(2,24'hffffff);check_pixel(3,24'h5a5a5a);check_pixel(4,24'hff3030);
 check_pixel(5,24'h000000);cp=1;check_pixel(5,24'hffffff);check_pixel(6,24'hff3030);cr=0;check_pixel(5,24'h000000);
 force dut.x=100;force dut.y=26;
 for(i=0;i<7;i++)begin mode=i;repeat(2)@(posedge clk);#1;if(dut.osd)$fatal(1,"retired geometry HUD returned in display%0d",i);end
 $display("PASS seven display backgrounds, no implicit classifier/geometry HUD when recognition disabled");$finish;
end
endmodule
