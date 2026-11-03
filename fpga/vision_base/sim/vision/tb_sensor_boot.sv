`timescale 1ns/1ps
module tb;
parameter N=256;
parameter INIT_FILE="results/sc2210_preparation_20261003/boot_256.mem";
reg clk=0,rst=0,done=0;
wire we,re,configured;wire[15:0]addr;wire[7:0]data,dev;
reg[24:0]expected[0:N-1];integer writes=0,latency=0;
i2c_master_reg_set #(.DATA_LENGTH(N),.INIT_FILE(INIT_FILE),.I2C_DEVICE_ADDR(8'h60))
 dut(clk,rst,1'b1,1'b0,done,we,re,addr,data,configured,dev);
always #5 clk=~clk;
always @(negedge clk)begin
 done=0;
 if(latency!=0)begin latency=latency-1;if(latency==0)done=1;end
 if(re)$fatal(1,"unexpected boot read");
 if(we)begin
  if(writes>=N||{addr,data,1'b0}!==expected[writes]||dev!=8'h60)$fatal(1,"boot sequence mismatch index=%0d",writes);
  writes=writes+1;latency=4; // Completion follows the I2C transaction, not launch.
 end
end
initial begin
 $readmemh(INIT_FILE,expected);
 repeat(4)@(negedge clk);rst=1;
 wait(configured);repeat(20)@(negedge clk);
 if(writes!=N||we)$fatal(1,"terminal counter wrapped or boot repeated");
 $display("PASS sensor boot %0d entries, ROM latency, order, device address, terminal counter",N);$finish;
end
initial begin #100000;$fatal(1,"boot timeout");end
endmodule
