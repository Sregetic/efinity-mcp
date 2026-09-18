module hdmi_bringup(
 input wire CLK_27M,
 input wire jtag_inst1_CAPTURE,jtag_inst1_DRCK,jtag_inst1_RESET,jtag_inst1_RUNTEST,jtag_inst1_SEL,jtag_inst1_SHIFT,jtag_inst1_TCK,jtag_inst1_TDI,jtag_inst1_TMS,jtag_inst1_UPDATE,
 output wire jtag_inst1_TDO,
 input wire CLK_25M,hdmi_tx_slow_clk,hdmi_tx_locked,
 output wire [9:0] tmds_data0_o,tmds_data1_o,tmds_data2_o,tmds_clk_o,
 output wire tmds_data0_TX_OE,tmds_data1_TX_OE,tmds_data2_TX_OE,tmds_clk_TX_OE,
 output wire tmds_data0_TX_RST,tmds_data1_TX_RST,tmds_data2_TX_RST,tmds_clk_TX_RST,
 output wire led0,led1
);
 reg [25:0] reference_ticks=0;
 always @(posedge CLK_25M) reference_ticks<=reference_ticks+1'b1;
 assign led0=reference_ticks[24];
 reg [2:0] reset_pipe=0;
 always @(posedge hdmi_tx_slow_clk or negedge hdmi_tx_locked)
  if(!hdmi_tx_locked)reset_pipe<=0;else reset_pipe<={reset_pipe[1:0],1'b1};
 wire [7:0] r,g,b;wire hs,vs,de;wire [31:0] frames;
 video_test_pattern pattern(.clk(hdmi_tx_slow_clk),.rst_n(reset_pipe[2]),.red(r),.green(g),.blue(b),.hs(hs),.vs(vs),.de(de),.frame_count(frames),.frame_pulse());
 assign led1=frames[5];
 wire [9:0] d0,d1,d2,dc;
 dvi_encoder encoder(.pixelclk(hdmi_tx_slow_clk),.rst_p(!reset_pipe[2]),.i_bdata(b),.i_gdata(g),.i_rdata(r),.i_hs(hs),.i_vs(vs),.i_de(de),.video_format(2'b00),.video_VIC(7'd16),.audio_L(24'd0),.audio_R(24'd0),.audio_valid(1'b0),.audio_N(20'd6144),.audio_CTS(20'd148500),.audio_sample_frequency(4'd2),.audio_word_length(4'd11),.tmds_data0(d0),.tmds_data1(d1),.tmds_data2(d2),.tmds_clk(dc));
 assign {tmds_data0_o,tmds_data1_o,tmds_data2_o,tmds_clk_o}={~d0,~d1,~d2,~dc};
 assign {tmds_data0_TX_OE,tmds_data1_TX_OE,tmds_data2_TX_OE,tmds_clk_TX_OE}=4'b1111;
 assign {tmds_data0_TX_RST,tmds_data1_TX_RST,tmds_data2_TX_RST,tmds_clk_TX_RST}=0;
reg [25:0] ref27_ticks=0;
 always @(posedge CLK_27M) ref27_ticks<=ref27_ticks+1'b1;
 reg [7:0] gray25=0,gray27=0;
 reg [6:0] grayframes=0;
 always @(posedge CLK_25M)gray25<=reference_ticks[24:17] ^ (reference_ticks[24:17]>>1);
 always @(posedge CLK_27M)gray27<=ref27_ticks[24:17] ^ (ref27_ticks[24:17]>>1);
 always @(posedge hdmi_tx_slow_clk)grayframes<=frames[6:0] ^ (frames[6:0]>>1);
 reg [23:0] status_meta=0,status_sync=0;
 always @(posedge jtag_inst1_DRCK)begin
  status_meta<={gray25,gray27,hdmi_tx_locked,grayframes};
  status_sync<=status_meta;
 end
 reg [31:0] debug_shift=0;
 always @(posedge jtag_inst1_DRCK) begin
  if(jtag_inst1_CAPTURE) debug_shift<={8'hA5,status_sync};
  else if(jtag_inst1_SHIFT)debug_shift<={jtag_inst1_TDI,debug_shift[31:1]};
 end
 assign jtag_inst1_TDO=debug_shift[0];
endmodule
