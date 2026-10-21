`timescale 1ns/1ps
module tb;
reg sc=0,dc=0,sr=0,dr=0,req=0;always #3 sc=~sc;always #11 dc=~dc;
reg[63:0]data=0;wire[63:0]snapshot;wire valid;
vision_motion_snapshot_cdc #(.W(64))dut(sc,sr,data,dc,dr,req,snapshot,valid);
integer i;reg[63:0]held;
always @(posedge sc)if(sr)data<=data+64'h0000000100000001;
initial begin
 repeat(3)@(negedge dc);sr=1;dr=1;
 for(i=0;i<20;i=i+1)begin
  @(negedge dc);req=1;@(negedge dc);req=0;
  repeat(12)@(negedge dc);
  if(!valid||snapshot[63:32]!==snapshot[31:0])$fatal(1,"Torn/invalid CDC snapshot");
  held=snapshot;repeat(6)begin @(negedge dc);if(snapshot!==held)$fatal(1,"Snapshot changed without request");end
 end
 $display("PASS held bundled-data CDC snapshots=20 asynchronous clock ratios");$finish;
end
endmodule
