`timescale 1ns/1ps
// Read priority must reach the DDR scheduler, not merely the AR channel.
module tb_axi_write_pressure;
 reg clk=0,rst_n=0;always #5 clk=~clk;
 reg[3:0]read_urgent=4'b0100,clients=0;
 wire[3:0]s_arready,s_rvalid,s_rlast;wire[31:0]m_araddr;
 wire m_arvalid,m_rready,m_awvalid,m_wvalid,m_wlast,m_bready;
 reg m_rvalid=0,m_bvalid=0;integer cycle=0,age=0,quiet=0,reads=0,writes=0,read_start=0,first_latency=0;reg pending=0;
 axi_burst_arbiter dut(.clk(clk),.rst_n(rst_n),.read_urgent(read_urgent),
  .s_arid(24'd0),.s_araddr({32'd3,32'd2,32'd1,32'd0}),.s_arlen(32'd0),.s_arsize(12'd0),.s_arburst(8'd0),
  .s_arvalid(clients),.s_arready(s_arready),.s_rready(4'b1111),.s_rvalid(s_rvalid),.s_rlast(s_rlast),
  .s_awid(24'd0),.s_awaddr(128'd0),.s_awlen(32'd0),.s_awsize(12'd0),.s_awburst(8'd0),
  .s_awvalid(4'b0001),.s_wvalid(4'b0001),.s_wdata(512'd0),.s_wstrb(64'hffff),.s_wlast(4'b0001),.s_bready(4'b1111),
  .m_araddr(m_araddr),.m_arvalid(m_arvalid),.m_arready(1'b1),.m_rready(m_rready),
  .m_rvalid(m_rvalid),.m_rlast(1'b1),.m_rdata(128'd0),.m_rresp(2'd0),.m_rid(6'd0),
  .m_awvalid(m_awvalid),.m_awready(1'b1),.m_wvalid(m_wvalid),.m_wlast(m_wlast),.m_wready(1'b1),.m_bvalid(m_bvalid),.m_bready(m_bready),.m_bresp(2'd0),.m_bid(6'd0));
 always @(posedge clk)if(rst_n)begin
  cycle=cycle+1;
  if(m_wvalid&&m_wlast)begin writes=writes+1;m_bvalid<=1;end
  if(m_bvalid&&m_bready)m_bvalid<=0;
  if(m_arvalid)begin pending<=1;age<=0;quiet<=0;read_start=cycle;end
  if(pending&&!m_rvalid)begin
   age<=age+1;
   if(m_awvalid)quiet<=0;else quiet<=quiet+1;
   // Bounded write-draining memory: an admitted write delays an urgent read.
   if(quiet>=8||age>=32)m_rvalid<=1;
  end
  if(m_rvalid&&m_rready)begin
   pending<=0;m_rvalid<=0;reads=reads+1;
   if(reads==1)begin first_latency=cycle-read_start;if(first_latency>16)$fatal(1,"urgent read delayed by new writes: %0d cycles",first_latency);end
  end
 end
 initial begin
  #40;rst_n=1;
  // An empty display FIFO alone must never block boot/source writes.
  repeat(40)@(negedge clk);if(writes<5)$fatal(1,"write-only startup blocked");
  clients=4'b0100;
  repeat(300)@(negedge clk);
  if(reads<8||writes<12)$fatal(1,"read/write progress lost reads%0d writes%0d",reads,writes);
  $display("PASS write-pressure QoS first urgent read%0d cycles, reads%0d writes%0d; boot writes and owner completion retained",first_latency,reads,writes);$finish;
 end
endmodule
