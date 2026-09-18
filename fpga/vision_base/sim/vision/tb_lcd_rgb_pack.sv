`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0,en=0,src=1,vs=0,hs=0,de=0;reg[23:0]rgb=0;
wire ov,oh,v,fault;wire[63:0]data;wire[31:0]frames;wire[15:0]pairs;
lcd_rgb_pack d(clk,rst,en,src,vs,hs,de,rgb,ov,oh,v,data,frames,pairs,fault);
integer x,y,count=0;reg[23:0]first,now;
initial begin
 #21;rst=1;en=1;repeat(5)@(negedge clk);vs=1;@(negedge clk);vs=0;
 for(y=0;y<3;y=y+1)begin
  for(x=0;x<1920;x=x+1)begin
   de=1;rgb={8'(x),8'(x>>3),8'(y+20)};now={rgb[7:0],rgb[15:8],rgb[23:16]};
   @(posedge clk);#1;
   if(x%2==0)begin first=now;if(v)$fatal(1,"odd valid");end
   else begin if(!v||data!=={16'd0,now,first})$fatal(1,"pair mismatch");count=count+1;end
   @(negedge clk);
  end
  de=0;repeat(3)@(negedge clk);if(pairs!=960||fault)$fatal(1,"line mismatch");
 end
 src=0;de=1;repeat(8)@(negedge clk);if(v)$fatal(1,"partial frame not discarded");
 de=0;vs=1;@(negedge clk);vs=0;de=1;repeat(3)@(negedge clk);de=0;repeat(3)@(negedge clk);if(!fault)$fatal(1,"odd/truncated line not flagged");
 $display("LCD PACK PASS %0d pairs, RGB order, 960 pairs/line, source boundary and odd-line fault",count);$finish;
end
endmodule
