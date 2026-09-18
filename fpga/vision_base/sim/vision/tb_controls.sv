`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0,vs=0;reg[2:0]keys=7;reg cmd=0;reg[7:0]op=0;reg[23:0]value=0;
wire[2:0]mode,idx;wire[10:0]thr;wire med;wire[1:0]mem;
vision_controls #(.CLK_HZ(100),.DEBOUNCE(3),.LONG_PRESS(20))dut(clk,rst,vs,keys,cmd,op,value,mode,thr,med,mem,idx);
task frame;begin @(negedge clk);vs=1;#20;vs=0;#20;end endtask
task press(input integer k,input integer cycles);begin @(negedge clk);keys[k]=0;repeat(cycles)@(negedge clk);keys[k]=1;repeat(6)@(negedge clk);end endtask
initial begin
 #21;rst=1;frame;if(mode!=3||thr!=128)$fatal;
 press(0,1);frame;if(mode!=3)$fatal(1,"bounce accepted");
 press(0,8);if(mode!=3)$fatal(1,"mode committed midframe");frame;if(mode!=4)$fatal;
 press(1,8);frame;if(thr!=144)$fatal;
 press(2,8);frame;if(thr!=128)$fatal;
 press(0,30);frame;if(!med||mode!=4)$fatal;
 press(1,30);frame;if(mem!=1)$fatal;
 press(2,30);frame;if(mem!=2)$fatal;
 press(1,8);frame;if(idx!=1)$fatal;
 repeat(5)begin press(1,8);frame;if(mem!=2)$fatal(1,"short presses accumulated into a long press");end
 if(idx!=0)$fatal(1,"history index must wrap at six frames");
 press(2,8);frame;if(idx!=5)$fatal(1,"history index reverse wrap");
 @(negedge clk);cmd=1;op=5;value=7;#10;cmd=0;frame;if(idx!=0)$fatal(1,"invalid history index not normalized");
 @(negedge clk);cmd=1;op=2;value=2047;#10;cmd=0;frame;if(thr!=2047)$fatal;
 $display("CONTROLS PASS debounce short/long frame commit JTAG path");$finish;
end
endmodule
