`timescale 1ns/1ps
module tb_board_bank_switch;
reg clk=0,rst_n=0,wr_sw=0,rd_sw=0;
always #5 clk=~clk;
wire [1:0] wr_bank,rd_bank;
wire wa,ra;
wire [31:0] raddr,waddr;
localparam integer FRAME_SPAN=480*1080*4+512;
bank_switch #(.FB_NUM(3),.MAX_VID_WIDTH(480),.MAX_VID_HIGHT(1080),
 .VID_DATA_WIDTH(32),.AXI_DATA_WIDTH(128),.START_ADDR(0)) dut(
 .ddr_clk(clk),.rst_n(rst_n),.wr_sw(wr_sw),.rd_sw(rd_sw),
 .wr_bank(wr_bank),.rd_bank(rd_bank),.wr_sw_ack(wa),.rd_sw_ack(ra),
 .rd_start_addr(raddr),.wr_start_addr(waddr));
task seed;
 begin
  @(negedge clk);rst_n=0;wr_sw=0;rd_sw=0;
  repeat(2) @(negedge clk);rst_n=1;
  @(negedge clk);wr_sw=1;
  @(posedge clk);#1;
  if(wr_bank!==2 || rd_bank!==1) $fatal(1,"Initial publication failed");
  @(negedge clk);wr_sw=0;
  @(posedge clk);#1;
 end
endtask
initial begin
 seed;
 @(negedge clk);rd_sw=1;
 @(posedge clk);#1;
 if(ra!==1 || rd_bank!==0) $fatal(1,"Single read boundary failed");
 seed;
 @(negedge clk);rd_sw=1;wr_sw=1;
 @(posedge clk);#1;
 if(wa!==1 || ra!==1 || rd_bank!==0 || wr_bank!==1 || dut.three_fb.clean_bank!==2)
  $fatal(1,"Concurrent events lost");
 if(raddr!==0 || waddr!==FRAME_SPAN) $fatal(1,"Frame stride mismatch");
 @(negedge clk);rd_sw=0;wr_sw=0;
 @(posedge clk);#1;
 @(negedge clk);rd_sw=1;
 @(posedge clk);#1;
 if(rd_bank!==2 || raddr!==(2*FRAME_SPAN)) $fatal(1,"Next completed frame unavailable");
 if(rd_bank===wr_bank) $fatal(1,"Writer overlaps display");
 $display("PASS tb_board_bank_switch concurrent_events=handled frame_span=%0d",FRAME_SPAN);
 $finish;
end
initial begin #5000;$fatal(1,"Timeout");end
endmodule
