`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0,de=0,hs=0,vs=0;reg[7:0]p=0;reg[11:0]dx=0,dy=0;
wire edgepix,ready,busy,fault;wire[31:0]done;
vision_canny dut(clk,rst,de,hs,vs,p,p,p,11'd128,dx,dy,edgepix,ready,busy,fault,done);
reg[7:0]mem[0:32399];reg gold[0:32399];integer x,y,n=0,errors=0;
initial begin
 $readmemh("results/overnight_features_20260916/canny_input.mem",mem);$readmemh("results/overnight_features_20260916/canny_expected.mem",gold);
 #21;rst=1;wait(dut.hyst.state==1);@(negedge clk);vs=1;#80;vs=0;#80;
 for(y=0;y<1080;y++)begin
 for(x=0;x<1920;x++)begin de=1;p=mem[(y/8)*240+x/8];#10;end
 de=0;hs=1;#80;hs=0;#80;
 end
 wait(dut.hyst.state==7);@(negedge clk);vs=1;#80;vs=0;wait(ready);
 for(y=0;y<135;y++)for(x=0;x<240;x++)begin
 @(negedge clk);dx=x*8;dy=y*8;@(posedge clk);#1;
 if(edgepix!==gold[y*240+x])begin errors++;if(errors<10)$display("CANNY BAD x%0d y%0d got%b expected%b",x,y,edgepix,gold[y*240+x]);end
 if(edgepix)n++;
 end
 $display("CANNY pixels32400 edges%0d errors%0d",n,errors);if(errors||fault||done!=1)$fatal;$finish;
end
initial begin #50000000;$fatal(1,"timeout state%0d",dut.hyst.state);end
endmodule
