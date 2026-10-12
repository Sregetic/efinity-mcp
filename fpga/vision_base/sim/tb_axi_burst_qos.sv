`timescale 1ns/1ps
module tb_axi_burst_qos;
 reg clk=0,rst_n=0;always #5 clk=~clk;
 reg[3:0]read_urgent=4'b0100,clients=4'b1111;
 reg[31:0]lengths=0;
 wire[3:0]s_arready,s_rvalid,s_rlast;
 wire[31:0]m_araddr;wire m_arvalid,m_rready;
 reg m_rvalid=0;reg[31:0]owner=0;
 axi_burst_arbiter dut(.clk(clk),.rst_n(rst_n),.read_urgent(read_urgent),
  .s_arid(24'd0),.s_araddr({32'd3,32'd2,32'd1,32'd0}),.s_arlen(lengths),.s_arsize(12'd0),.s_arburst(8'd0),
  .s_arvalid(clients),.s_arready(s_arready),.s_rready(4'b1111),.s_rvalid(s_rvalid),.s_rlast(s_rlast),
  .s_awvalid(4'd0),.s_wvalid(4'd0),.s_bready(4'd0),
  .m_araddr(m_araddr),.m_arvalid(m_arvalid),.m_arready(1'b1),.m_rready(m_rready),
  .m_rvalid(m_rvalid),.m_rlast(1'b1),.m_rdata(128'd0),.m_rresp(2'd0),.m_rid(6'd0),
  .m_awready(1'b0),.m_wready(1'b0),.m_bvalid(1'b0),.m_bresp(2'd0),.m_bid(6'd0));
 integer n=0,want;reg[3:0]seen=0;
 always @(posedge clk)if(rst_n)begin
  if(m_arvalid)begin
   want=n<42?((n%3==2)?(((n/3)%3)==2?3:(n/3)%3):2):n<46?2:n<54?(n-46+3)%4:((n-54)%3<2?2:1);
   if(m_araddr!=want)$fatal(1,"priority/fairness grant%0d got%0d want%0d",n,m_araddr,want);
   owner<=m_araddr;m_rvalid<=1;
  end
  if(m_rvalid&&m_rready)begin
   if(s_rvalid!==(4'b1<<owner)||s_rlast!==(4'b1<<owner))$fatal(1,"response owner lost");
   seen[owner]=1;n=n+1;m_rvalid<=0;
   if(n==42)clients=4'b0100;
   if(n==46)begin clients=4'b1111;read_urgent=0;end
   if(n==54)begin clients=4'b0110;read_urgent=4'b0100;lengths={8'd0,8'd63,8'd31,8'd0};end
   if(n==75)begin
    if(seen!=15)$fatal(1,"normal clients starved");
    $display("PASS tb_axi_burst_qos64/32 scan/render quanta, nonurgent RR, scan-only progress, ordinary RR and response ownership");$finish;
   end
  end
 end
 initial begin #40;rst_n=1;#10000;$fatal(1,"QoS watchdog");end
endmodule
