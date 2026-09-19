`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0,configured=0,req=0,wd=0,rd=0;reg[15:0]value=888;reg[7:0]rdata=0;
wire we,re,ack,fault,busy;wire[15:0]addr,applied,updates;wire[7:0]data;wire[23:0]rb;
sensor_exposure_writer #(.TIMEOUT(100))d(clk,rst,configured,req,value,wd,rd,rdata,we,re,addr,data,ack,fault,busy,applied,rb,updates,1'b0,1'b0,16'd0,8'd0,,,,);
reg[7:0]regs[0:2];integer i,writes=0,reads=0;reg corrupt=0,stall=0;
always @(negedge clk)begin
 wd=0;rd=0;
 if(we&&!stall)begin if(addr<16'h3e00||addr>16'h3e02)$fatal(1,"bad address");regs[addr-16'h3e00]=data;writes=writes+1;wd=1;end
 if(re&&!stall)begin rdata=regs[addr-16'h3e00]^(corrupt?8'h01:8'h00);reads=reads+1;rd=1;end
end
initial begin
 #21;rst=1;req=1;repeat(8)@(negedge clk);if(we||re||busy)$fatal(1,"used bus before startup");configured=1;
 repeat(50)@(negedge clk);
 if(fault||!ack||applied!=888||rb!=24'h003780||writes!=3||reads!=3||updates!=1)$fatal(1,"readback/write failed %h",rb);
 corrupt=1;value=700;req=0;repeat(50)@(negedge clk);if(!fault||!ack||applied!=888)$fatal(1,"mismatch accepted");
 rst=0;repeat(2)@(negedge clk);rst=1;corrupt=0;stall=1;req=1;repeat(120)@(negedge clk);if(!fault||busy)$fatal(1,"timeout missing");
 rst=0;repeat(2)@(negedge clk);req=0;stall=0;corrupt=0;value=2950;rst=1;req=1;repeat(60)@(negedge clk);
 if(fault||applied!=2950||rb!=24'h00b860)$fatal(1,"new exposure ceiling encoding/readback failed");
 rst=0;repeat(2)@(negedge clk);req=0;value=2951;rst=1;req=1;i=writes;repeat(60)@(negedge clk);
 if(!fault||writes!=i)$fatal(1,"out-of-range exposure accepted");
 $display("EXPOSURE WRITER PASS: boot arbitration, byte packing, verified ack, mismatch and timeout");$finish;
end
endmodule
