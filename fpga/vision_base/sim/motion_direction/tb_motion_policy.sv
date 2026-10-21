`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst=0,iv=0,verified=1,tv=1,rv=0,ready=0;reg[31:0]id=0,stamp=0;reg[15:0]cfg=0;
wire ir,ov,fault;wire[1:0]task_code;wire[31:0]oid;wire[11:0]x0,y0,x1,y1;
vision_motion_policy dut(clk,rst,iv,ir,verified,id,stamp,cfg,tv,rv,12'd10,12'd20,12'd30,12'd40,ov,ready,task_code,oid,x0,y0,x1,y1,fault);
task submit(input[31:0]fid,t,input v,roi,input[1:0]expected);
 begin
  @(negedge clk);iv=1;id=fid;stamp=t;verified=v;rv=roi;
  while(!ir)@(negedge clk);
  @(negedge clk);iv=0;
  if(!ov||task_code!==expected||oid!==fid)$fatal(1,"Policy mismatch fid=%0d task=%0d expected=%0d",fid,task_code,expected);
  repeat(4)begin @(negedge clk);if(!ov||ir||task_code!==expected)$fatal(1,"Policy backpressure");end
  ready=1;@(negedge clk);ready=0;
 end
endtask
initial begin
 repeat(3)@(negedge clk);rst=1;
 submit(0,0,1,0,2);submit(1,50000,1,1,1);submit(2,100000,1,1,2);submit(3,150000,1,0,0);
 submit(5,180000,1,1,2); // missing source frame
 cfg=1;submit(6,200000,1,1,2);submit(7,250000,1,1,1);
 submit(8,300000,0,1,2);submit(9,350000,0,0,2); // never gate unverified raster
 submit(9,350000,1,1,2);submit(9,400000,1,1,2);if(!fault)$fatal(1,"Duplicate metadata not flagged");
 @(negedge clk);rst=0;@(negedge clk);rst=1;
 submit(32'hffffffff,32'hffff3cb0,1,0,2);submit(0,0,1,0,0);submit(1,50000,1,1,2);
 $display("PASS motion policy full/roi/skip, source guard, gap/config, backpressure, wrap, stale");$finish;
end
endmodule
