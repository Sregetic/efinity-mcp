`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0,de=0,hs=0,vs=0;reg[7:0]p=0;reg[11:0]dx=0,dy=0;
wire edgepix,ready,busy,fault;wire[31:0]done;
vision_canny dut(clk,rst,de,hs,vs,p,p,p,11'd128,dx,dy,edgepix,ready,busy,fault,done);
reg[7:0]mem[0:129599];reg gold[0:129599];integer x,y,n=0,errors=0;
initial begin
 $readmemh("sim/vision/canny_input.mem",mem);$readmemh("sim/vision/canny_expected.mem",gold);
 #21;rst=1;wait(dut.hyst.state==1);@(negedge clk);vs=1;#80;vs=0;#80;
 for(y=0;y<1080;y++)begin
 for(x=0;x<1920;x++)begin de=1;p=mem[(y/4)*480+x/4]+(((x+y)%2)?7:-7);#10;end
 de=0;hs=1;#80;hs=0;#80;
 end
 wait(dut.hyst.state==8);@(negedge clk);vs=1;#80;vs=0;wait(ready);
 for(y=0;y<270;y++)for(x=0;x<480;x++)begin
 @(negedge clk);dx=x*4;dy=y*4;@(posedge clk);#1;
 if(edgepix!==gold[y*480+x])begin errors++;if(errors<10)$display("CANNY BAD x%0d y%0d got%b expected%b",x,y,edgepix,gold[y*480+x]);end
 if(edgepix)n++;
 end
 $display("CANNY pixels129600 edges%0d errors%0d",n,errors);if(errors||fault||done!=1)$fatal;$finish;
end
initial begin #150000000;$fatal(1,"timeout state%0d",dut.hyst.state);end
endmodule
