`timescale 1ns/1ps
module tb;
reg clk=0;reg[2:0]mode=2;reg[7:0]coverage=0;wire[7:0]r,g,b;
vision_display dut(.ui_state(15'd0),.clk(clk),.rst_n(1'b1),.de(1'b0),.hs(1'b0),.vs(1'b0),.r(8'd0),.g(8'd0),.b(8'd0),
 .analysis_identity_match(1'b0),.mode(mode),.threshold(11'd64),.median_en(1'b0),.memory_mode(2'd0),.history_index(3'd0),
 .canny_pixel(1'b0),.canny_ready(1'b1),.canny_coverage(coverage),.orr(r),.ogg(g),.obb(b),
 .shape_enable(1'b0),.shape_threshold(8'd32),.canny_effective_threshold(11'd80),.canny_requested_threshold(11'd80));
always #5 clk=~clk;
task check(input[23:0]want);
 begin repeat(2)@(posedge clk);#1;if({r,g,b}!==want)$fatal(1,"mode%0d got%h expected%h",mode,{r,g,b},want);@(negedge clk);end
endtask
initial begin
 force dut.fd=1;force dut.border=0;force dut.x=700;force dut.y=500;
 force dut.fr=8'd100;force dut.fg=8'd80;force dut.fb=8'd60;
 force dut.edge1=1;force dut.mag=11'd200;check(24'h646464);
 force dut.mag=11'd700;check(24'hffffff);
 force dut.edge1=0;check(24'h000000);
 mode=5;coverage=64;check(24'h404040);
 if(dut.shape_gray!==0)$fatal(1,"display halo entered binary classifier");
 coverage=255;check(24'hffffff);
 mode=6;coverage=64;check({8'd138,8'd72,8'd57});
 coverage=0;check({8'd100,8'd80,8'd60});
 $display("PASS Sobel strength saturation/threshold, Canny antialias and binary recognition isolation");$finish;
end
endmodule
