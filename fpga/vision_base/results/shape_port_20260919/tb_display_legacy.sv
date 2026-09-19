`timescale 1ns/1ps
module tb;
reg clk=0,rst_n=0,de=0,hs=0,vs=0;reg[7:0]r=0,g=0,b=0;reg[2:0]mode=0;
wire[11:0]ax,ay,bx,by;wire ade,ahs,avs,bde,bhs,bvs,ae,be;
wire[7:0]ar,ag,ab,br,bg,bb;wire[10:0]am,bm;wire[63:0]status;
vision_display a(clk,rst_n,de,hs,vs,r,g,b,mode,11'd64,1'b1,2'b0,3'b0,1'b1,1'b1,ax,ay,ade,ahs,avs,ar,ag,ab,am,ae,1'b0,8'd48,status);
vision_display_before c(clk,rst_n,de,hs,vs,r,g,b,mode,11'd64,1'b1,2'b0,3'b0,1'b1,1'b1,bx,by,bde,bhs,bvs,br,bg,bb,bm,be);
always #5 clk=~clk;
always @(negedge clk)if(rst_n&&{ade,ahs,avs,ar,ag,ab,ax,ay,am,ae}!=={bde,bhs,bvs,br,bg,bb,bx,by,bm,be})$fatal(1,"display regression mode%0d",mode);
integer m,px,py;
initial begin
 repeat(6)@(negedge clk);rst_n=1;
 for(m=0;m<8;m=m+1)begin
  @(negedge clk);mode=m;vs=1;de=0;hs=0;repeat(4)@(negedge clk);vs=0;
  for(py=0;py<64;py=py+1)begin
   @(negedge clk);hs=1;
   for(px=0;px<128;px=px+1)begin @(negedge clk);de=1;r=(px*3+py)%256;g=(px+py*9)%256;b=(px*7+py*5)%256;end
   @(negedge clk);de=0;hs=0;repeat(10)@(negedge clk);
  end
  repeat(20)@(negedge clk);$display("PASS old display mode%0d exact",m);
 end
 $display("PASS display legacy modes0..7 unchanged with shape disabled");$finish;
end
endmodule
