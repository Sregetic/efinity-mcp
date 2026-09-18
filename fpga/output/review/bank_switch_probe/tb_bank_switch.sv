`timescale 1ns/1ps
module tb;
reg clk=0, rst_n=0, wr_sw=0, rd_sw=0;
always #5 clk=~clk;
wire [1:0] wr_bank,rd_bank;
wire wa,ra;
wire [31:0] raddr,waddr;
bank_switch #(.FB_NUM(3),.MAX_VID_WIDTH(1920),.MAX_VID_HIGHT(1080),
 .VID_DATA_WIDTH(32),.AXI_DATA_WIDTH(128),.START_ADDR(0)) dut(
 .ddr_clk(clk),.rst_n(rst_n),.wr_sw(wr_sw),.rd_sw(rd_sw),
 .wr_bank(wr_bank),.rd_bank(rd_bank),.wr_sw_ack(wa),.rd_sw_ack(ra),
 .rd_start_addr(raddr),.wr_start_addr(waddr));
task seed_completed_frame;
 begin
  @(negedge clk); rst_n=0; wr_sw=0; rd_sw=0;
  repeat(2) @(negedge clk);
  rst_n=1;
  @(negedge clk); wr_sw=1;
  @(posedge clk); #1;
  if(wr_bank!==2 || rd_bank!==1) $fatal(1,"Seed failed");
  @(negedge clk); wr_sw=0;
  @(posedge clk); #1;
 end
endtask
initial begin
 seed_completed_frame;
 @(negedge clk); rd_sw=1;
 @(posedge clk); #1;
 $display("NORMAL: rd_ack=%0d rd_bank=%0d expected_bank=0",ra,rd_bank);
 if(ra!==1 || rd_bank!==0) $fatal(1,"Normal read switch failed");
 seed_completed_frame;
 @(negedge clk); rd_sw=1; wr_sw=1;
 @(posedge clk); #1;
 $display("SIMULTANEOUS: wr_ack=%0d rd_ack=%0d rd_bank=%0d pending_clean_bank=%0d",wa,ra,rd_bank,dut.three_fb.clean_bank);
 if(wa!==1 || ra!==1 || rd_bank!==1 || dut.three_fb.clean_bank!==0)
   $fatal(1,"Counterexample not reproduced");
 $display("REPRODUCED: read request acknowledged without selecting the pending completed frame.");
 $finish;
end
endmodule
