`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0,w=0,r=0;reg[1:0]mode=0;reg[2:0]index=0;
wire[31:0]wb,rb,cap,disp;wire[2:0]hc,ws,rs;
vision_frame_history #(.FRAME_BYTES(4096))dut(clk,rst,w,r,mode,index,wb,rb,cap,disp,hc,ws,rs);
integer i,errors=0;reg[31:0]frozen;reg[2:0]scratch;reg[31:0]mem[0:7];
task cycle(input iw,input ir);begin @(negedge clk);w=iw;r=ir;@(posedge clk);#1;if(ws==rs)errors++;@(negedge clk);w=0;r=0;end endtask
initial begin
 #21;rst=1;
 for(i=0;i<24;i++)begin cycle(1,0);cycle(0,1);end
 if(hc!=6||disp==0)$fatal;
 mode=1;cycle(0,1);frozen=rb;scratch=ws;
 for(i=0;i<20;i++)begin cycle(1,1);if(rb!=frozen||ws!=scratch)errors++;end
 mode=2;index=1;cycle(0,1);if(rb==scratch*4096)errors++;
 mode=3;for(i=0;i<65;i++)cycle(0,1);
 mode=0;for(i=0;i<16;i++)begin cycle(1,0);cycle(0,1);end
 $display("HISTORY errors=%0d capture=%0d display=%0d",errors,cap,disp);if(errors)$fatal;$finish;
end
endmodule
