`timescale 1ns/1ps
module tb_stream_cdc;
 parameter AW=3;
 reg arst_n=0,s_clk=0,m_clk=0,s_valid=0,m_ready=0;reg[98:0]s_data=0;
 wire [AW:0]s_level,m_level;wire s_ready,m_valid;wire[98:0]m_data;
 always #3.37 s_clk=~s_clk;always #5 m_clk=~m_clk;
 stream_cdc #(.WIDTH(99),.AW(AW))dut(.*);
 integer sent=0,received=0,cycle=0,stall_cycles=0;
 function automatic[98:0]payload(input integer n);
  payload={32'(n/32),32'(n/128),3'(n%8),32'(n*2210)};
 endfunction
 always @(negedge s_clk)begin
  s_valid=arst_n&&sent<2048&&sent%7!=cycle%7;
  s_data=payload(sent);
 end
 always @(posedge s_clk)begin
  if(arst_n&&s_level>(1<<AW))$fatal(1,"CDC occupancy exceeds capacity");
  if(s_valid&&s_ready)sent<=sent+1;
 end
 always @(negedge m_clk)begin cycle=cycle+1;m_ready=arst_n&&cycle%23>12;end
 reg stalled=0;reg[98:0]held;
 always @(posedge m_clk)begin
  if(stalled&&(!m_valid||m_data!==held))$fatal(1,"CDC output changed under backpressure");
  stalled=arst_n&&m_valid&&!m_ready;held=m_data;
  if(stalled)stall_cycles=stall_cycles+1;
  if(m_valid&&m_ready)begin
   if(m_data!==payload(received))$fatal(1,"CDC loss/order/tag at%0d",received);
   received=received+1;
  end
 end
 initial begin
  #70;arst_n=1;wait(received==2048);#30;
  if(sent!=2048||stall_cycles<100)$fatal(1,"CDC coverage");
  arst_n=0;#20;if(m_valid||s_ready)$fatal(1,"CDC reset not empty");
  $display("PASS tb_stream_cdc 2048 tagged beats, async clocks, FIFO wrap/full, stalled stability and reset");$finish;
 end
 initial begin #1000000;$fatal(1,"CDC watchdog");end
endmodule
