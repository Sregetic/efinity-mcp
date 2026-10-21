`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0;wire de,hs,vs;wire[7:0]r,g,b;
reg[31:0]in_status=32'h207;reg[31:0]observation=0;reg signed[31:0]hx=-100;reg[11:0]px=772,py=112;reg frame_vs=0;
vision_display #(.LOCAL_MOTION_ENABLE(1))dut(.clk(clk),.rst_n(rst),.de(1'b0),.hs(1'b0),.vs(1'b0),.r(8'd0),.g(8'd0),.b(8'd0),.mode(3'd7),.threshold(11'd128),.median_en(1'b0),.memory_mode(2'd0),.history_index(3'd0),.canny_pixel(1'b0),.canny_ready(1'b0),.ode(de),.ohs(hs),.ovs(vs),.orr(r),.ogg(g),.obb(b));
task settle;begin repeat(4)@(negedge clk);end endtask
task boundary;begin repeat(7)@(negedge clk);observation=observation+1;frame_vs=1;settle;frame_vs=0;settle;end endtask
defparam dut.readout.CLOCK_HZ=1000;
initial begin
 force dut.fd0=1'b1;force dut.fh0=1'b0;force dut.fv0=frame_vs;
 force dut.x0=px;force dut.y0=py;force dut.border0=1'b0;
 force dut.fr0=8'd0;force dut.fg0=8'd0;force dut.fb0=8'd0;
 force dut.motion_status=in_status;force dut.motion_active=16'd12;force dut.motion_observation=observation;force dut.motion_h=hx;force dut.motion_v=32'd0;
 force dut.mx0=12'd0;force dut.my0=12'd0;force dut.mx1=12'd0;force dut.my1=12'd0;
 settle;rst=1;repeat(9)boundary;
 if({r,g,b}!==24'h40ffd0)$fatal(1,"Left arrow pipeline or initial snapshot alignment");
 in_status=32'h21b;hx=100;settle;
 if({r,g,b}!==24'h40ffd0)$fatal(1,"Direction changed halfway through raster");
 repeat(20)boundary;
 if({r,g,b}!==24'h101820)$fatal(1,"New frame did not switch to right arrow snapshot");
 px=828;settle;if({r,g,b}!==24'h40ffd0)$fatal(1,"Right arrow pipeline alignment");
 $display("PASS coherent frame-held direction snapshot and pixel-aligned HUD");$finish;
end
initial begin #100000;$fatal(1,"Snapshot timeout");end
endmodule
