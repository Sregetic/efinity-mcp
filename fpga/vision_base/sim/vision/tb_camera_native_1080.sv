`timescale 1ns/1ps
module tb;
reg clk=0,rst=0,vs=0,hs=0,valid=0;reg[39:0]data=0;
wire ovs,ohs,ov;wire[31:0]od;
camera_native_1080 dut(clk,rst,vs,hs,valid,data,ovs,ohs,ov,od);
always #5 clk=~clk;
integer f,yy,ww,words=0,lines=0,frames=0;reg old_hs=0,old_vs=0;
always @(posedge clk)begin
 #1;
 if(rst)begin
  if(ov)begin
   if(!ovs||!ohs||od!=={data[9:2],data[19:12],data[29:22],data[39:32]})$fatal(1,"native pixel/order/frame mismatch");
   words=words+1;
  end
  if(old_hs&&!ohs)lines=lines+1;
  if(old_vs&&!ovs)begin
   if(lines!=1080||words!=518400)$fatal(1,"native frame geometry %0d/%0d",lines,words);
   frames=frames+1;lines=0;words=0;
  end
 end
 old_hs=ohs;old_vs=ovs;
end
initial begin
 repeat(4)@(negedge clk);rst=1;
 for(f=0;f<2;f=f+1)begin
  vs=1;repeat(3)@(negedge clk);if(f==0)vs=0;
  for(yy=0;yy<1080;yy=yy+1)begin
   hs=1;
   for(ww=0;ww<480;ww=ww+1)begin
    data={10'((ww*4+3+yy)&1023),10'((ww*4+2+yy)&1023),10'((ww*4+1+yy)&1023),10'((ww*4+yy)&1023)};
    valid=1;@(negedge clk);
    if(ww%71==7)begin valid=0;repeat(2)@(negedge clk);end
   end
   valid=0;hs=0;repeat(5)@(negedge clk);
  end
  vs=0;repeat(8)@(negedge clk);
  if(ovs)$fatal(1,"frame did not close");
 end
 rst=0;repeat(3)@(negedge clk);if(ovs)$fatal(1,"reset stale frame");
 if(frames!=2)$fatal(1,"missing frame");
 $display("PASS native SC2210 4147200 pixels, RAW10 order, FS pulse/level, bubbles and frame closure");$finish;
end
endmodule
