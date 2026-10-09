`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg[11:0]x=8,y=4;reg[2:0]mode=2;reg[10:0]threshold=96;wire active,ink;
reg[13:0]ui=0;
reg fusion=0,matched=1;reg[287:0]packet=0;reg[15:0]age=0;
vision_osd dut(x,y,mode,threshold,1'b1,2'd0,3'd0,1'b1,2'd0,1'b0,1'b0,active,ink,11'd16,fusion,packet,matched,age,clk,ui);
task character(input integer position,input[7:0]wanted);
begin @(negedge clk);x=8+12*position;@(posedge clk);#1;if(dut.ch_q!==wanted||!active)$fatal(1,"OSD character %0d: %c expected %c",position,dut.ch_q,wanted);end
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
 fusion=1;y=40;packet[10:8]=2;character(3,"T");character(4,"E");character(5,"S");character(6,"T");
 packet[0]=1;matched=0;character(3,"O");character(4,"L");character(5,"D");
 age=16'h1a2b;character(15,"1");character(16,"A");character(17,"2");character(18,"B");
 y=58;packet[63:32]=32'h12345678;character(1,"1");character(8,"8");
 packet[127:96]=32'h76543210;character(11,"7");character(18,"0");
 y=76;packet[95:64]=32'hdeadbeef;packet[287:256]=32'h807f01ff;
 character(1,"D");character(8,"F");character(11,"F");character(12,"F");character(23,"8");character(24,"0");
 @(negedge clk);x=428;@(posedge clk);#1;if(active)$fatal(1,"OSD extent");
 fusion=0;mode=0;y=4;ui=(3<<11)|1408;
 character(0,"P");character(1,"A");character(2,"N");character(4,"X");character(9,"V");
 character(10,"1");character(11,"4");character(12,"0");character(13,"8");
 $display("PASS pipelined OSD mode/threshold, fusion TEST/OLD, independent IDs and signed score bytes");$finish;
end
endmodule
