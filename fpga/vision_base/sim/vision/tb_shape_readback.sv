`timescale 1ns/1ps
module tb;
reg clk=0,rst=0,de=0,vs=0;always #5 clk=~clk;
reg[11:0]x=640,y=300;reg[7:0]gray=0;reg[7:0]pixels[0:307199];
wire[1:0]kind;wire valid;wire[3:0]flags;wire[7:0]bg;wire[11:0]x0,y0,x1,y1;
vision_shape_classifier dut(clk,rst,de,vs,x,y,gray,8'd32,kind,valid,x0,y0,x1,y1,bg,flags);
string file;integer wanted,wanted_flags,wanted_bg,frame,row,col,unused;
task boundary;begin @(negedge clk);de=0;vs=1;@(negedge clk);vs=0;repeat(5)@(negedge clk);end endtask
initial begin
 if(!$value$plusargs("image=%s",file)||!$value$plusargs("kind=%d",wanted)||!$value$plusargs("flags=%d",wanted_flags)||!$value$plusargs("background=%d",wanted_bg))$fatal(1,"Missing readback fixture contract");
 $readmemh(file,pixels);repeat(4)@(negedge clk);rst=1;boundary;
 for(frame=0;frame<3;frame=frame+1)begin
  for(row=0;row<480;row=row+1)begin
   for(col=0;col<640;col=col+1)begin
    @(negedge clk);de=1;x=640+col;y=300+row;gray=pixels[row*640+col];
   end
   @(negedge clk);de=0;
  end
  boundary;
 end
 if(kind!=wanted||flags!=wanted_flags||bg!=wanted_bg||valid!=(wanted!=0))$fatal(1,"Shape readback parity: class%0d flags%0d bg%0d expected%0d/%0d/%0d",kind,flags,bg,wanted,wanted_flags,wanted_bg);
 $display("PASS three frozen640x480 ROI frames host/RTL class%0d flags%0d background%0d",kind,flags,bg);$finish;
end
endmodule
