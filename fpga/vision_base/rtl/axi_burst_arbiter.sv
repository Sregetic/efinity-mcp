`timescale 1ns/1ps
// Independent read/write round-robin, one outstanding burst per channel.
// Keep the selected owner through RLAST/B; never interleave AXI4 W data.
// ponytail: one outstanding burst; add tagged outstanding queues after profiling.
module axi_burst_arbiter #(parameter N=4,ID_WIDTH=6,OW=$clog2(N))(
 input clk,rst_n,input[N-1:0]read_urgent,
 input[N*ID_WIDTH-1:0]s_arid,s_awid,
 input[N*32-1:0]s_araddr,s_awaddr,
 input[N*8-1:0]s_arlen,s_awlen,
 input[N*3-1:0]s_arsize,s_awsize,
 input[N*2-1:0]s_arburst,s_awburst,
 input[N-1:0]s_arvalid,s_awvalid,output reg[N-1:0]s_arready,s_awready,
 input[N*128-1:0]s_wdata,input[N*16-1:0]s_wstrb,
 input[N-1:0]s_wlast,s_wvalid,output reg[N-1:0]s_wready,
 output[N*128-1:0]s_rdata,output[N*2-1:0]s_rresp,s_bresp,
 output[N*ID_WIDTH-1:0]s_rid,s_bid,
 output reg[N-1:0]s_rlast,s_rvalid,s_bvalid,input[N-1:0]s_rready,s_bready,
 output[ID_WIDTH-1:0]m_arid,m_awid,output[31:0]m_araddr,m_awaddr,
 output[7:0]m_arlen,m_awlen,output[2:0]m_arsize,m_awsize,
 output[1:0]m_arburst,m_awburst,output m_arvalid,m_awvalid,input m_arready,m_awready,
 output[127:0]m_wdata,output[15:0]m_wstrb,output m_wlast,m_wvalid,input m_wready,
 input[127:0]m_rdata,input[1:0]m_rresp,m_bresp,input[ID_WIDTH-1:0]m_rid,m_bid,
 input m_rlast,m_rvalid,m_bvalid,output m_rready,m_bready
);
 localparam IDLE=0,ADDR=1,DATA=2,RESP=3;
 reg[1:0]rs=IDLE,ws=IDLE;reg[OW-1:0]ro=0,wo=0,rl=N-1,wl=N-1;
 reg rf,wf,uf;reg[OW-1:0]rp,wp,up;integer k,ri,wi;
 reg[2:0]urgent_streak=0;reg selected_urgent=0;
 always @*begin
  rf=0;wf=0;uf=0;rp=0;wp=0;up=0;
  for(k=1;k<=N;k=k+1)begin
   ri=(int'(rl)+k)%N;wi=(int'(wl)+k)%N;
   if(!rf&&s_arvalid[ri])begin rf=1;rp=OW'(ri);end
   if(!uf&&s_arvalid[ri]&&read_urgent[ri])begin uf=1;up=OW'(ri);end
   if(!wf&&s_awvalid[wi])begin wf=1;wp=OW'(wi);end
  end
  s_arready=0;s_awready=0;s_wready=0;s_rvalid=0;s_rlast=0;s_bvalid=0;
  if(rs==ADDR)s_arready[ro]=m_arready;
  if(rs==DATA)begin s_rvalid[ro]=m_rvalid;s_rlast[ro]=m_rlast;end
  if(ws==ADDR)s_awready[wo]=m_awready;
  if(ws==DATA)s_wready[wo]=m_wready;
  if(ws==RESP)s_bvalid[wo]=m_bvalid;
 end
 assign m_arid=s_arid[ro*ID_WIDTH+:ID_WIDTH],m_araddr=s_araddr[ro*32+:32];
 assign m_arlen=s_arlen[ro*8+:8],m_arsize=s_arsize[ro*3+:3],m_arburst=s_arburst[ro*2+:2];
 assign m_arvalid=rs==ADDR&&s_arvalid[ro],m_rready=rs==DATA&&s_rready[ro];
 assign m_awid=s_awid[wo*ID_WIDTH+:ID_WIDTH],m_awaddr=s_awaddr[wo*32+:32];
 assign m_awlen=s_awlen[wo*8+:8],m_awsize=s_awsize[wo*3+:3],m_awburst=s_awburst[wo*2+:2];
 assign m_awvalid=ws==ADDR&&s_awvalid[wo];
 assign m_wdata=s_wdata[wo*128+:128],m_wstrb=s_wstrb[wo*16+:16];
 assign m_wlast=s_wlast[wo],m_wvalid=ws==DATA&&s_wvalid[wo],m_bready=ws==RESP&&s_bready[wo];
 assign s_rdata={N{m_rdata}},s_rresp={N{m_rresp}},s_rid={N{m_rid}};
 assign s_bresp={N{m_bresp}},s_bid={N{m_bid}};
 always @(posedge clk)begin
  if(!rst_n)begin rs<=IDLE;ws<=IDLE;ro<=0;wo<=0;rl<=N-1;wl<=N-1;urgent_streak<=0;selected_urgent<=0;end
  else begin
   case(rs)
    IDLE:if(rf)begin
     selected_urgent<=uf&&urgent_streak<1;ro<=(uf&&urgent_streak<1)?up:rp;rs<=ADDR;
    end
    ADDR:if(m_arvalid&&m_arready)rs<=DATA;
    DATA:if(m_rvalid&&m_rready&&m_rlast)begin
     // Preserve the normal cursor across priority bursts. Otherwise repeated
     // scan priority would repeatedly choose legacy and starve the renderer.
     if(selected_urgent)urgent_streak<=urgent_streak+1'b1;
     else begin rl<=ro;urgent_streak<=0;end
     rs<=IDLE;
    end
   endcase
   case(ws)
    IDLE:if(wf)begin wo<=wp;ws<=ADDR;end
    ADDR:if(m_awvalid&&m_awready)ws<=DATA;
    DATA:if(m_wvalid&&m_wready&&m_wlast)ws<=RESP;
    RESP:if(m_bvalid&&m_bready)begin wl<=wo;ws<=IDLE;end
   endcase
  end
 end
endmodule
