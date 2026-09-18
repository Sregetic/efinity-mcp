`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0,vs=0,de=0;reg[15:0]pix=0;reg[11:0]addr=0;
wire[31:0]data,seq;wire busy;
raw_snapshot #(.PAIRS(48),.HEIGHT(96),.COLS(2),.ROWS(2))d(clk,rst,vs,de,pix,1'b0,clk,addr,data,seq,busy);
integer x,y,i;reg[31:0]expected;
initial begin
 #21;rst=1;@(negedge clk);vs=1;@(negedge clk);vs=0;
 for(y=0;y<96;y=y+1)begin for(x=0;x<48;x=x+1)begin de=1;pix={8'(y),8'(x)};@(negedge clk);end de=0;repeat(2)@(negedge clk);end
 vs=1;@(negedge clk);vs=0;repeat(2)@(negedge clk);if(seq!=1||busy)$fatal(1,"capture completion");
 for(i=0;i<4;i=i+1)begin addr=i;repeat(2)@(negedge clk);expected={8'((i/2)*48),8'((i%2)*24),8'((i/2)*48+1),8'((i%2)*24)};if(data!==expected)$fatal(1,"tile %d got%h exp%h",i,data,expected);end
 addr=4095;repeat(2)@(negedge clk);if(data!=0)$fatal(1,"out-of-range");
 $display("COMPACT RAW PASS48x48 spacing, packing, completion, bounds");$finish;
end
endmodule
