`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0,w=0,r=0;reg[1:0]mode=0;reg[2:0]index=0;
wire[31:0]wb,rb,cap,disp;wire[2:0]hc,ws,rs;
vision_frame_history #(.FRAME_BYTES(4096))dut(clk,rst,w,r,mode,index,wb,rb,cap,disp,hc,ws,rs);
integer i,j,errors=0;reg[31:0]frozen;reg[2:0]scratch,expected_slot;reg[31:0]mem[0:7];reg[5:0]seen;
task cycle(input iw,input ir);begin @(negedge clk);w=iw;r=ir;@(posedge clk);#1;if(ws==rs)errors++;@(negedge clk);w=0;r=0;end endtask
initial begin
 #21;rst=1;
 for(i=0;i<24;i++)begin cycle(1,0);cycle(0,1);end
 if(hc!=6||disp==0)$fatal;
 mode=1;cycle(0,1);frozen=rb;scratch=ws;
 for(i=0;i<20;i++)begin cycle(1,1);if(rb!=frozen||ws!=scratch)errors++;end
 mode=2;index=1;cycle(0,1);if(rb==scratch*4096)errors++;
 // Each selected history frame holds, even with scratch captures continuing.
 for(j=0;j<6;j=j+1)begin
  index=j;repeat(3)@(negedge clk);
  for(i=0;i<181;i=i+1)begin
   expected_slot=dut.history[j];cycle(1,1);
   if(rs!=expected_slot)$fatal(1,"static history changed index=%0d",j);
  end
 end
 index=6;repeat(3)@(negedge clk);seen=0;
 for(i=0;i<181;i=i+1)begin
  expected_slot=dut.history[dut.play];seen[dut.play]=1;cycle(0,1);
  if(rs!=expected_slot)$fatal(1,"automatic replay frame");
 end
 if(seen!=63)$fatal(1,"replay did not visit all history entries");
 index=2;repeat(3)@(negedge clk);cycle(0,1);
 frozen=rb;repeat(65)begin cycle(0,1);if(rb!=frozen)$fatal(1,"replay failed to stop");end
 index=6;repeat(3)@(negedge clk);expected_slot=dut.history[dut.play];cycle(0,1);
 if(rs!=expected_slot)$fatal(1,"replay did not resume existing phase");
 mode=3;index=4;repeat(3)@(negedge clk);
 for(i=0;i<65;i++)begin
  @(negedge clk);expected_slot=dut.history[(dut.tick<30)?4:5];cycle(0,1);
  if(rs!=expected_slot)$fatal(1,"comparison ignored selected index");
 end
 mode=0;for(i=0;i<16;i++)begin cycle(1,0);cycle(0,1);end
 $display("HISTORY errors=%0d capture=%0d display=%0d",errors,cap,disp);if(errors)$fatal;$finish;
end
endmodule
