`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst=0,tick=0;reg[31:0]status=32'h207,id=0;reg signed[31:0]h=0,v=0;reg[15:0]sites=12;
wire[2:0]show;wire held;
vision_motion_readout #(.CLOCK_HZ(1000))dut(clk,rst,tick,status,id,h,v,sites,show,held);
integer checks=0,i,d;
task check(input[2:0]want);begin #1;if(show!==want)$fatal(1,"show=%d want=%d id=%d",show,want,id);checks=checks+1;end endtask
task reset;begin @(negedge clk);rst=0;tick=0;status=32'h207;id=0;h=0;v=0;sites=12;repeat(3)@(negedge clk);rst=1;end endtask
task frame;begin repeat(11)@(negedge clk);id=id+1;tick=1;@(negedge clk);tick=0;repeat(4)@(negedge clk);end endtask
task set_weak(input integer dir);begin h=0;v=0;case(dir)2:h=-100;3:h=100;4:v=-100;5:v=100;endcase end endtask
initial begin
 // Every raw per-frame score is below 256, yet consistent four-frame evidence is usable.
 for(d=2;d<=5;d=d+1)begin reset;set_weak(d);repeat(7)begin frame;check(0);end frame;check(d);end
 // Ambiguous diagonal and alternating/cancelling evidence must remain unknown.
 reset;h=100;v=100;repeat(16)frame;check(0);
 reset;repeat(16)begin h=(id%2)?100:-100;frame;end check(0);
 // A single strong active frame per window is insufficient.
 reset;for(i=0;i<16;i=i+1)begin sites=(i%4)==0?12:0;h=(i%4)==0?10000:0;frame;end check(0);
 // Confirmed direction survives a short UNKNOWN interval and is marked HOLD.
 reset;set_weak(2);repeat(8)frame;check(2);h=0;v=0;repeat(8)frame;check(2);if(!held)$fatal(1,"Stale evidence not labelled HOLD");checks=checks+1;
 // No new observations: the previous result has a bounded lifetime.
 repeat(600)@(negedge clk);check(0);
 // A reversal needs confirmation and minimum display dwell, then must update.
 reset;set_weak(2);repeat(8)frame;check(2);set_weak(3);repeat(8)frame;check(2);repeat(8)frame;check(3);
 // A brief opposite spike cannot flip the direction.
 reset;set_weak(2);repeat(8)frame;h=10000;frame;h=-100;repeat(7)frame;check(2);
 // Duplicated IDs do not create a window or refresh stale evidence.
 reset;set_weak(2);frame;repeat(12)begin repeat(15)@(negedge clk);tick=1;@(negedge clk);tick=0;end check(0);
 // Gaps, invalid history, faults and impossible site counts invalidate the display.
 reset;set_weak(2);repeat(8)frame;id=id+4;frame;check(0);
 repeat(8)frame;check(2);status=32'h205;frame;check(0);
 status=32'h207;repeat(8)frame;check(2);status=32'h247;frame;check(0);
 status=32'h207;sites=145;frame;check(0);
 // All-zero activity is stationary; activity without direction is not stationary.
 reset;sites=0;repeat(4)frame;check(1);sites=12;frame;check(0);
 // Signed 32-bit extremes accumulate without wrap/sign reversal.
 reset;h=32'sh80000000;repeat(8)frame;check(2);
 reset;v=32'sh7fffffff;repeat(8)frame;check(5);
 // Equality at 3:2 is accepted, a just-ambiguous ratio is not.
 reset;h=150;v=100;repeat(8)frame;check(3);
 reset;h=149;v=100;repeat(8)frame;check(0);
 // Sequential IDs remain valid across unsigned wrap.
 reset;id=32'hfffffffc;set_weak(4);repeat(8)frame;check(4);
 $display("PASS temporal readout black-box checks=%0d weak-direction/ambiguity/noise/hold/dwell/gap/fault/stall/overflow/wrap",checks);$finish;
end
initial begin #2000000;$fatal(1,"Readout timeout");end
endmodule
