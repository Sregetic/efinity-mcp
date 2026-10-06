`timescale 1ns/1ps
module tb;
reg[11:0]x=8,y=4;reg[2:0]mode=2;reg[10:0]threshold=96;wire active,ink;
vision_osd dut(x,y,mode,threshold,1'b1,2'd0,3'd0,1'b1,2'd0,1'b0,1'b0,active,ink,11'd16);
task character(input integer position,input[7:0]wanted);
begin x=8+12*position;#1;if(dut.ch!==wanted||!active)$fatal(1,"OSD character %0d: %c expected %c",position,dut.ch,wanted);end
endtask
initial begin
 character(0,"S");character(1,"O");character(2,"B");character(3,"E");character(4,"L");
 character(10,"0");character(11,"0");character(12,"9");character(13,"6");
 mode=5;threshold=2047;
 character(0,"C");character(1,"A");character(2,"N");character(3,"N");character(4,"Y");
 character(10,"2");character(11,"0");character(12,"4");character(13,"7");
 threshold=16;character(10,"0");character(11,"0");character(12,"1");character(13,"6");
 threshold=24;character(10,"0");character(11,"0");character(12,"2");character(13,"4");
 character(29,"R");character(30,"0");character(31,"0");character(32,"1");character(33,"6");
 x=428;#1;if(active)$fatal(1,"OSD extent");
 $display("PASS mode names, decimal threshold16/96/2047 and OSD extent");$finish;
end
endmodule
