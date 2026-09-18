`timescale 1ns/1ps
module tb;
reg clk=0,rc=0;always #5 clk=~clk;always #7 rc=~rc;
reg rst=0,vs=0,de=0,arm=0;reg[15:0]p=0;reg[11:0]addr=0;
wire[31:0]q,seq;wire busy;
raw_snapshot #(.PAIRS(12),.HEIGHT(8),.XS(3),.YS(2),.COLS(4),.ROWS(4))dut(clk,rst,vs,de,p,arm,rc,addr,q,seq,busy);
integer x,y,i,n;reg[7:0]a,b,c,d;reg[31:0]expected;
task frame(input integer f);begin
 @(negedge clk);vs=1;repeat(4)@(negedge clk);vs=0;
 for(y=0;y<8;y=y+1)begin
  for(x=0;x<12;x=x+1)begin de=1;p={8'(f*32+y+x*2+1),8'(f*32+y+x*2)};@(negedge clk);end
  de=0;repeat(4)@(negedge clk);
 end
end endtask
task check(input integer f);begin
 for(i=0;i<16;i=i+1)begin
  addr=i;repeat(3)@(negedge rc);n=f*32+(i/4)*2+(i%4)*6;
  a=n;b=n+1;c=n+1;d=n+2;expected={b,a,d,c};
  if(q!==expected)$fatal(1,"raw tile %0d got %h expected %h",i,q,expected);
 end
end endtask
initial begin
 #21;rst=1;frame(0);frame(1);if(seq!=1||busy)$fatal;check(0);
 arm=1;repeat(6)@(negedge clk);frame(2);frame(3);if(seq!=2||busy)$fatal;check(2);
 $display("RAW SNAPSHOT PASS tiles32 packing, stable snapshot, rearm, independent read clock");$finish;
end
endmodule
