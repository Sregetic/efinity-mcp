`timescale 1ns/1ps
// Elastic stream crossing. The payload contains pixels and their frame markers.
// Both clock domains share arst_n; reset discards all in-flight data.
module stream_cdc #(parameter WIDTH=35,AW=9)(
 input arst_n,s_clk,s_valid,output s_ready,input[WIDTH-1:0]s_data,
 input m_clk,output reg m_valid=0,input m_ready,output reg[WIDTH-1:0]m_data=0,
 output[AW:0]s_level,output[AW:0]m_level
);
 reg[WIDTH-1:0]mem[0:(1<<AW)-1];
 reg[AW:0]wb=0,wg=0,rb=0,rg=0;reg full=0;
 (* async_reg="true" *)reg[AW:0]rg1=0,rg2=0,wg1=0,wg2=0;
 (* async_reg="true" *)reg[1:0]su=0,mu=0;
 wire push=s_valid&&s_ready;
 wire[AW:0]wn=wb+push,wgn=(wn>>1)^wn;
 wire fetch=mu[1]&&(rg!=wg2)&&(!m_valid||m_ready);
 wire[AW:0]rn=rb+1'b1;
 function automatic[AW:0]binary(input[AW:0]g);integer i;begin
  binary[AW]=g[AW];for(i=AW-1;i>=0;i=i-1)binary[i]=binary[i+1]^g[i];
 end endfunction
 assign s_level=wb-binary(rg2);
 assign m_level=binary(wg2)-rb+(m_valid?1'b1:1'b0);
 assign s_ready=su[1]&&!full;
 always @(posedge s_clk or negedge arst_n)begin
  if(!arst_n)begin su<=0;rg1<=0;rg2<=0;wb<=0;wg<=0;full<=0;end
  else begin
   su<={su[0],1'b1};rg1<=rg;rg2<=rg1;
   if(su[1])begin wb<=wn;wg<=wgn;full<=wgn=={~rg2[AW:AW-1],rg2[AW-2:0]};end
  end
 end
 always @(posedge s_clk)if(push)mem[wb[AW-1:0]]<=s_data;
 always @(posedge m_clk or negedge arst_n)begin
  if(!arst_n)begin mu<=0;wg1<=0;wg2<=0;rb<=0;rg<=0;m_valid<=0;end
  else begin
   mu<={mu[0],1'b1};wg1<=wg;wg2<=wg1;
   if(fetch)begin m_data<=mem[rb[AW-1:0]];m_valid<=1;rb<=rn;rg<=(rn>>1)^rn;end
   else if(m_ready)m_valid<=0;
  end
 end
endmodule
