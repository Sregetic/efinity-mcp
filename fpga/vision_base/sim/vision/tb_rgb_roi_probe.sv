`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0,vs=0,de=0;wire[95:0]sums,clips;integer x,y;
rgb_roi_probe #(.X0(2),.X1(5),.Y0(1),.Y1(4))dut(clk,rst,vs,de,24'h0a14ff,sums,clips);
initial begin
 #21;rst=1;@(negedge clk);vs=1;#30;vs=0;
 for(y=0;y<5;y=y+1)begin for(x=0;x<6;x=x+1)begin de=1;#10;end de=0;#30;end
 vs=1;#30;vs=0;#30;
 if(sums!=={32'd90,32'd180,32'd2295}||clips!=={32'd0,32'd0,32'd9})$fatal(1,"ROI sum mismatch");
 $display("RGB ROI PASS sum and clipping count");$finish;
end
endmodule
