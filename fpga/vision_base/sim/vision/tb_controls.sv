`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0,vs=0;reg[2:0]keys=7;reg cmd=0;reg[7:0]op=0;reg[23:0]value=0;
wire[2:0]mode,idx;wire[10:0]thr,st,ct;wire med;wire[1:0]mem;
vision_controls #(.CLK_HZ(100),.DEBOUNCE(3),.LONG_PRESS(20))dut(clk,rst,vs,keys,cmd,op,value,mode,thr,med,mem,idx,st,ct);
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
 if(idx!=6)$fatal(1,"F2 automatic playback index6");
 press(1,8);frame;if(idx!=0)$fatal(1,"F2 forward wrap");
 press(2,8);frame;if(idx!=6)$fatal(1,"F2 reverse wrap");
 press(2,8);frame;if(idx!=5)$fatal(1,"F2 leave autoplay");
 press(2,30);frame;if(mem!=3||idx!=0)$fatal(1,"F3 resets index");
 press(2,8);frame;if(idx!=5)$fatal(1,"F3 remains six frames");
 @(negedge clk);cmd=1;op=5;value=7;#10;cmd=0;frame;if(idx!=0)$fatal(1,"invalid history index not normalized");
 @(negedge clk);cmd=1;op=2;value=2047;#10;cmd=0;frame;if(thr!=2047)$fatal;
 @(negedge clk);cmd=1;op=4;value=0;#10;cmd=0;frame;
 press(1,8);frame;if(thr!=2047)$fatal(1,"threshold increment wrapped at upper limit");
 press(2,8);frame;if(thr!=2031)$fatal(1,"threshold decrement at upper limit");
 @(negedge clk);cmd=1;op=2;value=16;#10;cmd=0;frame;
 press(2,8);frame;if(thr!=16)$fatal(1,"threshold lower limit");
 press(2,8);frame;if(thr!=16)$fatal(1,"threshold decrement wrapped below minimum");
 press(1,8);frame;if(thr!=32)$fatal(1,"threshold increment from lower limit");
 @(negedge clk);cmd=1;op=2;value=15;#10;cmd=0;frame;
 press(2,8);frame;if(thr!=16)$fatal(1,"threshold decrement from nonaligned value");
 @(negedge clk);cmd=1;op=2;value=96;#10;cmd=0;frame;
 repeat(80)begin
  press(1,8);frame;if(thr!=112||mem!=0)$fatal(1,"repeated physical increment");
  press(2,8);frame;if(thr!=96||mem!=0)$fatal(1,"repeated physical decrement");
 end
 // Switching algorithms preserves independent settings; keyed changes commit at VS.
 @(negedge clk);cmd=1;op=1;value=5;#10;cmd=0;frame;
 if(thr!=128||st!=96)$fatal(1,"Sobel leaked into Canny");
 press(1,8);if(ct!=128)$fatal(1,"Canny committed midframe");frame;
 if(ct!=144||st!=96)$fatal(1,"independent Canny increment");
 @(negedge clk);cmd=1;op=8'h28;value=80;#10;cmd=0;frame;
 if(st!=80||ct!=144||thr!=144)$fatal(1,"explicit Sobel command");
 @(negedge clk);cmd=1;op=8'h29;value=0;#10;cmd=0;frame;
 if(ct!=16||st!=80)$fatal(1,"explicit Canny minimum");
 repeat(4)begin press(2,8);frame;if(ct!=16)$fatal(1,"Canny key crossed lower limit");end
 @(negedge clk);cmd=1;op=1;value=2;#10;cmd=0;frame;
 if(thr!=80)$fatal(1,"Sobel threshold was not retained");
 $display("CONTROLS PASS independent Sobel/Canny, lower16 step16, saturation, debounce and frame commit");$finish;
end
endmodule
