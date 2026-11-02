
/////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2013-2021 Efinix Inc. All rights reserved.
//
// Description:
// Example top file for ti60f225 dev kit OOB design
//
// Language:  Verilog 2001
//Ti60f225_sc431hai2hdmi_v6：
//使用了最新版本的framebuffer_v3;
// ------------------------------------------------------------------------------

/////////////////////////////////////////////////////////////////////////////////
//`define SOFT_TAP 1
`include "ddr3_controller/ddr3_parameter.vh"
// `include "define.v"

`include "vision_board_config.vh"
`include "vision_sensor_config.vh"
module ti60f225_oob_top #(
	// 0: competition,1: all image probes,2: RGB row snapshot only.
	parameter                       IMAGE_DEBUG        = 2,
	parameter                       RAW_FIFO_DEPTH     = 512,
	parameter                       SAPPHIRE_ENABLE    = 1,
	parameter                       RAW_TO_POOL        = 1,
 parameter ANALYSIS_DMA_ENABLE=1,
 parameter DISPLAY_LATENCY_PROBE = 0,

	parameter                       RANK_RATIO         = 1,       // # of unique CS outputs per rank
	parameter                       ASYN_AXI_CLK       = `ASYN_AXI_CLK, 
	parameter                       RANKS              = `RANKS,
	parameter                       CK_WIDTH           = `CK_WIDTH,       // # of CK/CK# outputs to memory   
	parameter                       CKE_WIDTH          = `CKE_WIDTH,       // # of cke outputs
	parameter                       CS_WIDTH           = `CS_WIDTH,       // # of unique CS outputs
	parameter                       BANK_WIDTH         = `BANK_WIDTH,       // # of bank bits
	parameter                       ROW_WIDTH          = `ROW_WIDTH,       // DRAM address bus width
	parameter                       COL_WIDTH          = `COL_WIDTH,      // column address width
	parameter                       DM_WIDTH           = `DM_WIDTH,       // # of DM (data mask)
	parameter                       DQS_WIDTH          = `DQS_WIDTH,       // # of DQS (strobe)
	parameter                       DQ_WIDTH           = `DQ_WIDTH,      // # of DQ (data)
	parameter                       ODT_WIDTH          = `ODT_WIDTH,
	parameter                       DQ_CNT_WIDTH       = `DQ_CNT_WIDTH,       // = ceil(log2(DQ_WIDTH))
	parameter                       DQS_CNT_WIDTH      = `DQS_CNT_WIDTH,       // = ceil(log2(DQS_WIDTH))  
	parameter                       DRAM_WIDTH         = `DRAM_WIDTH,       // # of DQ per DQS   
	parameter                       DATA_WIDTH         = `DATA_WIDTH,
	parameter                       ADDR_WIDTH         = `ADDR_WIDTH,    
	parameter                       AXI_ID_WIDTH       = `AXI_ID_WIDTH,
	parameter                       AXI_ADDR_WIDTH     = `AXI_ADDR_WIDTH,
	parameter                       AXI_DATA_WIDTH     = `AXI_DATA_WIDTH
)
(

 input wire flash_miso,
 output wire flash_sck,flash_cs,flash_mosi,flash_hold,flash_wp,flash_cs_oe,flash_sck_oe,flash_mosi_oe,flash_wp_oe,flash_hold_oe,

  (* syn_peri_port = 0 *) input jtag_inst1_CAPTURE,
  (* syn_peri_port = 0 *) input jtag_inst1_DRCK,
  (* syn_peri_port = 0 *) input jtag_inst1_RESET,
  (* syn_peri_port = 0 *) input jtag_inst1_RUNTEST,
  (* syn_peri_port = 0 *) input jtag_inst1_SEL,
  (* syn_peri_port = 0 *) input jtag_inst1_SHIFT,
  (* syn_peri_port = 0 *) input jtag_inst1_TCK,
  (* syn_peri_port = 0 *) input jtag_inst1_TDI,
  (* syn_peri_port = 0 *) input jtag_inst1_TMS,
  (* syn_peri_port = 0 *) input jtag_inst1_UPDATE,
  (* syn_peri_port = 0 *) output jtag_inst1_TDO,

  (* syn_peri_port = 0 *) input jtag_diag_CAPTURE,
  (* syn_peri_port = 0 *) input jtag_diag_DRCK,
  (* syn_peri_port = 0 *) input jtag_diag_RESET,
  (* syn_peri_port = 0 *) input jtag_diag_RUNTEST,
  (* syn_peri_port = 0 *) input jtag_diag_SEL,
  (* syn_peri_port = 0 *) input jtag_diag_SHIFT,
  (* syn_peri_port = 0 *) input jtag_diag_TCK,
  (* syn_peri_port = 0 *) input jtag_diag_TDI,
  (* syn_peri_port = 0 *) input jtag_diag_TMS,
  (* syn_peri_port = 0 *) input jtag_diag_UPDATE,
  (* syn_peri_port = 0 *) output jtag_diag_TDO,

   //Clocks 
	input	wire	i_arstn,
    input	wire	i_mipi_rx_pclk,
    input wire  vid_clk_dvi2,
    input wire hdmi_tx_slow_clk,
    input wire CLK_5M,
    input  wire CLK_25M,
	output  wire    pll_inst1_RSTN,
	input	wire	i_pll_locked,
	input 	wire  	pll_locked,
	output  wire  	USER_PLL_RSTN,
    output 	wire 	DDR3_PLL_RSTN,
	input 	wire  	user_pll_locked,
    //CSI Interface
    input	 wire		io_cam_sda_IN,
    output wire   io_cam_sda_OUT,
    output wire		io_cam_sda_OE,

    output io_cam_scl_OUT,
    input io_cam_scl_IN,
    output io_cam_scl_OE,

    output	wire		o_cam_rst_p,
    
    input	wire		i_cam_ck_LP_P_IN,
    input	wire		i_cam_ck_LP_N_IN,
    output	wire		o_cam_ck_HS_TERM,
    output	wire		o_cam_ck_HS_ENA,
    input	wire		i_cam_ck_CLKOUT,
    
    input	wire	[7:0]			cam_d0_HS_IN,
    output wire cam_d0_DLY_RST,cam_d0_DLY_ENA,cam_d0_DLY_INC,
    output wire cam_d1_DLY_RST,cam_d1_DLY_ENA,cam_d1_DLY_INC,
    output wire cam_d2_DLY_RST,cam_d2_DLY_ENA,cam_d2_DLY_INC,
    output wire cam_d3_DLY_RST,cam_d3_DLY_ENA,cam_d3_DLY_INC,
    input	  wire		      cam_d0_LP_P_IN,
    input	  wire		      cam_d0_LP_N_IN,
    output	wire		      cam_d0_HS_TERM,
    output	wire		      cam_d0_HS_ENA,
    output	wire		      cam_d0_RST,
    output	wire		      cam_d0_FIFO_RD,
    input	  wire		      cam_d0_FIFO_EMPTY,
    
    input 	wire	[7:0]			cam_d1_HS_IN,
    input	  wire		        cam_d1_LP_P_IN,
    input	  wire		        cam_d1_LP_N_IN,
    output	wire		        cam_d1_HS_TERM,
    output	wire		        cam_d1_HS_ENA,
    output	wire		        cam_d1_RST,
    output	wire		        cam_d1_FIFO_RD,
    input	  wire		        cam_d1_FIFO_EMPTY,
    
    input 	wire	[7:0]			cam_d2_HS_IN,
    input	  wire		        cam_d2_LP_P_IN,
    input	  wire		        cam_d2_LP_N_IN,
    output	wire		        cam_d2_HS_TERM,
    output	wire		        cam_d2_HS_ENA,
    output	wire		        cam_d2_RST,
    output	wire		        cam_d2_FIFO_RD,
    input	  wire		        cam_d2_FIFO_EMPTY,  
   
    input 	wire	[7:0]			cam_d3_HS_IN,
    input	  wire		        cam_d3_LP_P_IN,
    input	  wire		        cam_d3_LP_N_IN,
    output	wire		        cam_d3_HS_TERM,
    output	wire		        cam_d3_HS_ENA,
    output	wire		        cam_d3_RST,
    output	wire		        cam_d3_FIFO_RD,
    input	  wire		        cam_d3_FIFO_EMPTY,

	
	input 					tx_cal_clk_90edge,
  	input 					rx_cal_clk,
  	input 					tx_cal_clk,
	input                              core_clk,     // CORE CLK @ 100MHz
	input                              sdram_clk,    // SDRAM CK @ 400MHz
	// PLL status flags  
	output [2:0]                       pll_shift,  
	output [4:0]                       pll_shift_sel,
	output                             pll_shift_ena,  
	// memory interface ports
	output                             ddr_ck_hi,
	output                             ddr_ck_lo,
	output                             ddr_reset_n,
	output [CKE_WIDTH-1:0]             ddr_cke,     
	output [ROW_WIDTH-1:0]             ddr_addr,
	output [BANK_WIDTH-1:0]            ddr_ba,
	output                             ddr_cas_n,
 
	output [CS_WIDTH*RANK_RATIO-1:0]   ddr_cs_n,
	output                             ddr_ras_n,
	output                             ddr_we_n,
	
	input  [DQS_WIDTH-1:0]             ddr_dqs_in_hi,
	input  [DQS_WIDTH-1:0]             ddr_dqs_in_lo,
	input  [DQ_WIDTH-1:0]              ddr_dq_in_hi,
	input  [DQ_WIDTH-1:0]              ddr_dq_in_lo,
	
	output [DQS_WIDTH-1:0]             ddr_dqs_oe,
	output [DQS_WIDTH-1:0]             ddr_dqs_oe_n,
	output [DQ_WIDTH-1:0]              ddr_dq_oe,  
	output [DQS_WIDTH-1:0]             ddr_dqs_out_hi,
	output [DQS_WIDTH-1:0]             ddr_dqs_out_lo,
	output [DQ_WIDTH-1:0]              ddr_dq_out_hi,
	output [DQ_WIDTH-1:0]              ddr_dq_out_lo,
	output [DM_WIDTH-1:0]              ddr_dm_hi,
	output [DM_WIDTH-1:0]              ddr_dm_lo,
	output [ODT_WIDTH-1:0]             ddr_odt,

       //LED
       output [3:0] led,
       input [2:0] vision_keys_n,

       // MIPI DSI
       input	wire	                     i_mipi_tx_pclk		,
       output	wire	                     mipi_dp_clk_LP_P_OUT		,
       output	wire	                     mipi_dp_clk_LP_N_OUT		,
       output	wire	[7:0] 	              mipi_dp_clk_HS_OUT		,
       output	wire	                     mipi_dp_clk_HS_OE		,
       output	wire	                     mipi_dp_data3_LP_P_OUT	,
       output	wire	                     mipi_dp_data2_LP_P_OUT	,
       output	wire	                     mipi_dp_data1_LP_P_OUT	,
       output	wire	                     mipi_dp_data0_LP_P_OUT	,
       output	wire	                     mipi_dp_data3_LP_N_OUT	,
       output	wire	                     mipi_dp_data2_LP_N_OUT	,
       output	wire	                     mipi_dp_data1_LP_N_OUT	,
       output	wire	                     mipi_dp_data0_LP_N_OUT	,
       output	wire	[7:0] 	              mipi_dp_data0_HS_OUT	       ,
       output	wire	[7:0] 	              mipi_dp_data1_HS_OUT	       ,
       output	wire	[7:0] 	              mipi_dp_data2_HS_OUT	       ,
       output	wire	[7:0] 	              mipi_dp_data3_HS_OUT	       ,
       output	wire	                     mipi_dp_data3_HS_OE		,
       output	wire	                     mipi_dp_data2_HS_OE		,
       output	wire	                     mipi_dp_data1_HS_OE		,
       output	wire	                     mipi_dp_data0_HS_OE		,

       output	wire	                     mipi_dp_clk_RST		,
       output	wire	                     mipi_dp_data0_RST		,
       output	wire	                     mipi_dp_data1_RST		,
       output	wire	                     mipi_dp_data2_RST		,
       output	wire	                     mipi_dp_data3_RST		,
       output	wire	                     mipi_dp_clk_LP_P_OE		,
       output	wire	                     mipi_dp_clk_LP_N_OE		,
       output	wire	                     mipi_dp_data3_LP_P_OE	,
       output	wire	                     mipi_dp_data3_LP_N_OE	,
       output	wire	                     mipi_dp_data2_LP_P_OE	,
       output	wire	                     mipi_dp_data2_LP_N_OE	,
       output	wire	                     mipi_dp_data1_LP_P_OE	,
       output	wire	                     mipi_dp_data1_LP_N_OE	,
       output	wire	                     mipi_dp_data0_LP_P_OE	,
       output	wire	                     mipi_dp_data0_LP_N_OE	,

       input  wire	                     mipi_dp_data0_LP_P_IN	,
       input  wire	                     mipi_dp_data0_LP_N_IN	,
       output	wire	                     LCD_RST_P			,
       output wire                        LCD_POWER			,

       // hdmi interface

    output tmds_tx_clk_TX_OE,
    output [9:0] tmds_tx_clk_TX_DATA,
    output tmds_tx_clk_TX_RST,
    output tmds_tx_data0_TX_OE,
    output [9:0] tmds_tx_data0_TX_DATA,
    output tmds_tx_data0_TX_RST,
    output tmds_tx_data1_TX_OE,
    output [9:0] tmds_tx_data1_TX_DATA,
    output tmds_tx_data1_TX_RST,
    output tmds_tx_data2_TX_OE,
    output [9:0] tmds_tx_data2_TX_DATA,
    output tmds_tx_data2_TX_RST


);

function integer log2;
	input	integer	val;
	integer	i;
	begin
		log2 = 0;
		for (i=0; 2**i<val; i=i+1)
			log2 = i+1;
	end
endfunction


//===============================================================================
//localparam
//===============================================================================

// localparam	MAX_HRES		= 12'd1920;
// localparam	MAX_VRES		= 12'd1080;
// localparam	HSP			= 8'd2;
// localparam	HBP			= 8'd88;
// localparam	HFP			= 8'd120;
// localparam	VSP			= 8'd2;
// localparam	VBP			= 8'd20;
// localparam	VFP			= 8'd20;

localparam MAX_HRES = 1920;
localparam HFP      = 88;
localparam HSP      = 44;
localparam HBP      = 148;

localparam MAX_VRES = 1080;
localparam VFP      = 4;
localparam VSP      = 5;
localparam VBP      = 36;
//===============================================================================
//signal
//===============================================================================
   
wire                              app_sr_active;
wire                              app_ref_ack;
wire                              app_zq_ack;
wire                              cal_done;
// Explicit module-scope reset: both generated sensor branches use this driver.
wire                              vid_rst_n;

// Shared command/control types precede every generated module connection.
wire gamma_vs;
reg[31:0] feature_command=0;reg feature_command_toggle=0;
reg[2:0] feature_cmd_sync=0;reg feature_cmd_seen=0;reg[5:0]feature_diag_page=0;
wire feature_cmd_event=feature_cmd_sync[2]!=feature_cmd_seen;
wire[2:0] feature_mode,history_index;wire[10:0] feature_threshold,sobel_threshold,canny_threshold;wire feature_median;wire[1:0] memory_mode;
reg [191:0] diag_shift=0;
wire feature_coordinate_de;
wire[31:0]canny_coarse_edges,canny_display_edges,canny_analysis_cycles,canny_analysis_passes,canny_analysis_weak;
reg snapshot_request=0,snapshot_source=0;reg[10:0]snapshot_row=0;
wire[31:0]snapshot_status,snapshot_sequence,snapshot_frame,snapshot_config;
wire snapshot_payload_phase,snapshot_payload_tdo;

// Slave Interface Write Address Ports
wire [AXI_ID_WIDTH-1:0]           s_axi_awid;
wire [AXI_ADDR_WIDTH-1:0]         s_axi_awaddr;
wire [7:0]                        s_axi_awlen;
wire [2:0]                        s_axi_awsize;
wire [1:0]                        s_axi_awburst;
wire [0:0]                        s_axi_awlock;
wire [3:0]                        s_axi_awcache;
wire [2:0]                        s_axi_awprot;
wire                              s_axi_awvalid;
wire                              s_axi_awready;
// Slave Interface Write Data Ports
wire [AXI_DATA_WIDTH-1:0]         s_axi_wdata;
wire [(AXI_DATA_WIDTH/8)-1:0]     s_axi_wstrb;
wire                              s_axi_wlast;
wire                              s_axi_wvalid;
wire                              s_axi_wready;
// Slave Interface Write Response Ports
wire                              s_axi_bready;
wire [AXI_ID_WIDTH-1:0]           s_axi_bid;
wire [1:0]                        s_axi_bresp;
wire                              s_axi_bvalid;
// Slave Interface Read Address Ports
wire [AXI_ID_WIDTH-1:0]           s_axi_arid;
wire [AXI_ADDR_WIDTH-1:0]         s_axi_araddr;
wire [7:0]                        s_axi_arlen;
wire [2:0]                        s_axi_arsize;
wire [1:0]                        s_axi_arburst;
wire [0:0]                        s_axi_arlock;
wire [3:0]                        s_axi_arcache;
wire [2:0]                        s_axi_arprot;
wire                              s_axi_arvalid;
wire                              s_axi_arready;
// Slave Interface Read Data Ports
wire                              s_axi_rready;
wire [AXI_ID_WIDTH-1:0]           s_axi_rid;
wire [AXI_DATA_WIDTH-1:0]         s_axi_rdata;
wire [1:0]                        s_axi_rresp;
wire                              s_axi_rlast;
wire                              s_axi_rvalid;




////////////////////////////////////////////////////////////////
// System & Debugger
wire    w_arstn;
// KEY1 is a debounced back key; CONFIG retains device reconfiguration.
wire peripheral_reset_n = 1'b1;
// wire	w_sysclk_mcu_arstn;
// wire	w_sysclk_mcu_arst;
wire	w_mipi_rx_pclk_arstn;
wire	w_mipi_rx_pclk_arst;

wire		       w_mipi_rx_vs;
wire		       w_mipi_rx_hs;
wire	       w_mipi_rx_de;
wire [5:0] diag_rx_type;
wire [3:0] diag_rx_ppc;
wire	[63:0]			w_mipi_rx_data	;

wire					io_systemReset;



//===================================================================================================
//reset module
//===================================================================================================

assign w_arstn  		       = i_pll_locked & pll_locked & user_pll_locked;
assign pll_inst1_RSTN  		= peripheral_reset_n;
assign USER_PLL_RSTN      		= peripheral_reset_n;
assign mipi_dsi_tx_pll_RSTN 	= peripheral_reset_n;
assign DDR3_PLL_RSTN 		= peripheral_reset_n;
reset_ctrl
#(
	.NUM_RST		(2),
	.CYCLE			(1),
	.IN_RST_ACTIVE	(4'b00),
	.OUT_RST_ACTIVE	(4'b10)
)
inst_reset_ctrl
(
	.i_arst		({2{w_arstn}}),//({{4{i_pll_locked}},                  {2{i_arstn}}}),
	.i_clk			({2{i_mipi_rx_pclk}}),
	.o_srst		({w_mipi_rx_pclk_arst, w_mipi_rx_pclk_arstn})
);



reg [25:0] cnt = 'd0;
always @( posedge core_clk)
begin 
       cnt <= cnt + 1'b1;
end
assign led[0]  = cal_done ? cnt[24] : 1'b0;

//========================================================================================================
//MIPI RX
//========================================================================================================
wire i_mipi_clk ;
assign i_mipi_clk = core_clk;

		assign	cam_d0_RST		= 1'b0;
		assign	cam_d1_RST		= 1'b0;
		assign  cam_d2_RST = 1'b0;
    assign  cam_d3_RST = 1'b0;
	
// Ti60 dynamic input-delay controls are synchronous to the MIPI byte clock.
reg[2:0]phy_cmd_sync=0;reg phy_cmd_seen=0;
reg[2:0]phy_state=0;reg[5:0]phy_target=17,phy_applied=17,phy_count=0;
reg[7:0]phy_updates=0;reg phy_dly_rst=0,phy_dly_ena=0;
wire[31:0]phy_status_byte={8'hd1,phy_updates,2'b0,phy_applied,7'b0,(phy_state!=0)};
(* async_reg = "true" *) reg[31:0]phy_status_meta=0,phy_status_core=0;
always @(posedge core_clk)begin phy_status_meta<=phy_status_byte;phy_status_core<=phy_status_meta;end
assign {cam_d3_DLY_RST,cam_d2_DLY_RST,cam_d1_DLY_RST,cam_d0_DLY_RST}={4{phy_dly_rst}};
assign {cam_d3_DLY_ENA,cam_d2_DLY_ENA,cam_d1_DLY_ENA,cam_d0_DLY_ENA}={4{phy_dly_ena}};
assign {cam_d3_DLY_INC,cam_d2_DLY_INC,cam_d1_DLY_INC,cam_d0_DLY_INC}=4'b1111;
always @(posedge i_cam_ck_CLKOUT)begin
 phy_cmd_sync<={phy_cmd_sync[1:0],feature_command_toggle};phy_cmd_seen<=phy_cmd_sync[2];
 case(phy_state)
 0:if(phy_cmd_sync[2]!=phy_cmd_seen&&feature_command[31:24]==19)begin
    phy_target<=feature_command[5:0];phy_count<=0;phy_dly_rst<=1;phy_state<=1;
   end
 1:begin phy_dly_rst<=0;if(phy_target==0)phy_state<=3;else begin phy_dly_ena<=1;phy_state<=2;end end
 2:begin phy_count<=phy_count+1'b1;if(phy_count==phy_target-1'b1)begin phy_dly_ena<=0;phy_state<=3;end end
 3:begin phy_applied<=phy_target;phy_updates<=phy_updates+1'b1;phy_state<=0;end
 default:begin phy_dly_rst<=0;phy_dly_ena<=0;phy_state<=0;end
 endcase
end
// Optional observational CSI diagnostics. Opcode20 soft reset was withdrawn:
// it reproducibly destroys the valid baseline until full FPGA reconfiguration.
reg[2:0]probe_cmd_sync=0;reg probe_cmd_seen=0,probe_csi_view=0;
always @(posedge core_clk)begin
 probe_cmd_sync<={probe_cmd_sync[1:0],feature_command_toggle};probe_cmd_seen<=probe_cmd_sync[2];
 if(probe_cmd_sync[2]!=probe_cmd_seen&&feature_command[31:24]==21)probe_csi_view<=feature_command[0];
end
wire [31:0] mipi_debug_out;
// Independent physical burst/byte-clock probes distinguish sensor traffic from CSI decoding.
reg[31:0] cam_byte_ticks=0,cam_byte_gray=0;
wire[31:0]cam_byte_next=cam_byte_ticks+1'b1;
always @(posedge i_cam_ck_CLKOUT)begin
 cam_byte_ticks<=cam_byte_next;cam_byte_gray<=(cam_byte_next>>1)^cam_byte_next;
end
(* async_reg = "true" *) reg[31:0]cam_byte_gray_meta=0,cam_byte_gray_sync=0;
reg[31:0]cam_byte_core=0;
function[31:0]decode_byte_gray(input[31:0]g);
 integer j;begin for(j=0;j<32;j=j+1)decode_byte_gray[j]=^(g>>j);end
endfunction
always @(posedge core_clk)begin
 cam_byte_gray_meta<=cam_byte_gray;cam_byte_gray_sync<=cam_byte_gray_meta;
 cam_byte_core<=decode_byte_gray(cam_byte_gray_sync);
end
// Peak byte-clock edges per 100 core cycles (1 us), retained per received frame.
reg[6:0]cam_clock_window=0;reg[31:0]cam_byte_prev=0;
reg[15:0]cam_clock_delta=0,cam_clock_peak=0,cam_clock_peak_hold=0;
reg[2:0]cam_probe_vs=0;
wire[31:0]cam_tick_delta=cam_byte_core-cam_byte_prev;
always @(posedge core_clk)begin
 cam_probe_vs<={cam_probe_vs[1:0],w_mipi_rx_vs};
 if(cam_clock_window==99)begin
  cam_clock_window<=0;cam_byte_prev<=cam_byte_core;cam_clock_delta<=cam_tick_delta[15:0];
  if(cam_tick_delta[15:0]>cam_clock_peak)cam_clock_peak<=cam_tick_delta[15:0];
 end else cam_clock_window<=cam_clock_window+1'b1;
 if(cam_probe_vs[1]&&!cam_probe_vs[2])begin cam_clock_peak_hold<=cam_clock_peak;cam_clock_peak<=0;end
end
reg[2:0]cam_lp00_sync=0,cam_hsen_sync=0;
reg[31:0]cam_lp00_entries=0,cam_hsen_entries=0;
always @(posedge core_clk)begin
 cam_lp00_sync<={cam_lp00_sync[1:0],!cam_d0_LP_P_IN&&!cam_d0_LP_N_IN};
 cam_hsen_sync<={cam_hsen_sync[1:0],cam_d0_HS_ENA};
 if(cam_lp00_sync[1]&&!cam_lp00_sync[2])cam_lp00_entries<=cam_lp00_entries+1'b1;
 if(cam_hsen_sync[1]&&!cam_hsen_sync[2])cam_hsen_entries<=cam_hsen_entries+1'b1;
end
		

		csi_rx_controller inst_efx_csi2_rx
		(
              .reset_n			(peripheral_reset_n),
              .clk				(i_mipi_clk),
              .reset_byte_HS_n	(peripheral_reset_n),
              .clk_byte_HS		  (i_cam_ck_CLKOUT),
              .reset_pixel_n		(w_mipi_rx_pclk_arstn),
              .clk_pixel			  (i_mipi_rx_pclk),
              
              .Rx_LP_CLK_P		  (i_cam_ck_LP_P_IN),
              .Rx_LP_CLK_N		  (i_cam_ck_LP_N_IN),
              .Rx_HS_enable_C		(o_cam_ck_HS_ENA),
              .LVDS_termen_C		(o_cam_ck_HS_TERM),
              
              .Rx_LP_D_P			({cam_d3_LP_P_IN, cam_d2_LP_P_IN, cam_d1_LP_P_IN, cam_d0_LP_P_IN}),//(r_mipi_rx_data_LP_P_IN_2P),
              .Rx_LP_D_N			({cam_d3_LP_N_IN, cam_d2_LP_N_IN, cam_d1_LP_N_IN, cam_d0_LP_N_IN}),//(r_mipi_rx_data_LP_N_IN_2P),
              .Rx_HS_D_0			(cam_d0_HS_IN),//(r_mipi_rx_data_HS_IN_2P[0*8+:8]),
              .Rx_HS_D_1			(cam_d1_HS_IN),//(r_mipi_rx_data_HS_IN_2P[1*8+:8]),
              .Rx_HS_D_2			(cam_d2_HS_IN),
              .Rx_HS_D_3			(cam_d3_HS_IN),
              .Rx_HS_D_4			(),
              .Rx_HS_D_5			(),
              .Rx_HS_D_6			(),
              .Rx_HS_D_7			(),
              .Rx_HS_enable_D		({cam_d3_HS_ENA    ,cam_d2_HS_ENA    ,cam_d1_HS_ENA    ,cam_d0_HS_ENA    }),//( w_cam_d_HS_ENA),
              .LVDS_termen_D		({cam_d3_HS_TERM   ,cam_d2_HS_TERM   ,cam_d1_HS_TERM   ,cam_d0_HS_TERM   }),
              .fifo_rd_enable		({cam_d3_FIFO_RD   ,cam_d2_FIFO_RD   ,cam_d1_FIFO_RD   ,cam_d0_FIFO_RD   }),
              .fifo_rd_empty		({cam_d3_FIFO_EMPTY,cam_d2_FIFO_EMPTY,cam_d1_FIFO_EMPTY,cam_d0_FIFO_EMPTY}),
              .DLY_enable_D		       (),
              .DLY_inc_D			(),
              .u_dly_enable_D(4'b0),
              .u_dly_inc_D(4'b0),
              
              .axi_clk(core_clk),
              .axi_reset_n(peripheral_reset_n),
              .axi_awaddr			(6'b0),
              .axi_awvalid		       (1'b0),
              .axi_awready		       (),
              .axi_wdata			(32'b0),
              .axi_wvalid			(1'b0),
              .axi_wready			(),
              
              .axi_bvalid			(),
              .axi_bready			(1'b0),
              .axi_araddr			(6'b0),
              .axi_arvalid		       (1'b0),
              .axi_arready		       (),
              .axi_rdata			(),
              .axi_rvalid			(),
              .axi_rready			(1'b1),
              
              .hsync_vc0			(w_mipi_rx_hs),
              .hsync_vc1			(),
              .hsync_vc2			(),
              .hsync_vc3			(),
              .vsync_vc0			(w_mipi_rx_vs),
              .vsync_vc1			(),
              .vsync_vc2			(),
              .vsync_vc3			(),
              .vc				(),
              .word_count			(),
              .shortpkt_data_field        (),
              .datatype(diag_rx_type),
              .pixel_per_clk(diag_rx_ppc),
              .pixel_data			(w_mipi_rx_data),
              .pixel_data_valid	       (w_mipi_rx_de),
              .irq				(),
              .mipi_debug_in(32'd0),.mipi_debug_out(mipi_debug_out)
		);

//     wire		       w1_mipi_rx_vs;
// wire		       w1_mipi_rx_hs;
// wire	       w1_mipi_rx_de;
// wire	[39:0]			w1_mipi_rx_data	;
// sensor_clipper  sensor_clipper_inst (
//     .clk(i_mipi_rx_pclk),
//     .i_vs(w_mipi_rx_vs),
//     .i_hs(w_mipi_rx_hs),
//     .i_de(w_mipi_rx_de),
//     .i_dat(w_mipi_rx_data[39:0]),

//     .o_hs(w1_mipi_rx_hs),
//     .o_vs(w1_mipi_rx_vs),
//     .o_de(w1_mipi_rx_de),
//     .o_dat(w1_mipi_rx_data)
   
//   );


wire mdebug_pixel_fifo_full     = mipi_debug_out[0] ;
wire mdebug_pixel_fifo_empty    = mipi_debug_out[1] ;
wire mdebug_crc_error           = mipi_debug_out[2] ;
wire mdebug_ecc_1bit_error      = mipi_debug_out[3] ;
wire mdebug_ecc_2bit_error      = mipi_debug_out[4] ;
wire mdebug_undersize_pkt_error = mipi_debug_out[5] ;
wire mdebug_line_vc0_error      = mipi_debug_out[6] ;
wire mdebug_frame_vc0_error    = mipi_debug_out[10];   
wire mdebug_receive_error      = mipi_debug_out[14];


//========================================================================================================
//
//========================================================================================================
		

//*************** imx219 config********************/
// mipi_config_imx219_top u_config_imx219(
// 										.i_sys_clk(CLK_5M)    	,    /////48M 
// 										.sys_rstn(vid_rst_n )    ,
// 										.o_sen_rst_n(o_cam_rstn)  	,
										
										// .o_iic_sda_OE(io_cam_sda_OE) ,
										// .i_iic_sda(io_cam_sda_IN)   	,
										// .o_iic_sda(io_cam_sda_OUT)   	,
										// .o_iic_scl(io_cam_scl)    	
										// ); 	

wire scl_padoen_o;
wire sda_padoen_o;


// SC2210 requires >2ms after XSHUTDN release; CLK_5M gives 5ms here.
localparam I2C_RESET_CYCLES = `VISION_SENSOR_SC2210 ? 25000 : 4096;
reg [$clog2(I2C_RESET_CYCLES+1)-1:0] i2c_rst_cnt = '0;

always @( posedge CLK_5M or negedge w_arstn )
begin
    if( !w_arstn )
       i2c_rst_cnt <= 'd0;
    else 
       i2c_rst_cnt <= i2c_rst_n ? i2c_rst_cnt : i2c_rst_cnt + 1'b1;
end
wire i2c_rst_n = `VISION_SENSOR_SC2210 ? i2c_rst_cnt == I2C_RESET_CYCLES : i2c_rst_cnt[12];

wire ae_req,ae_ack,ae_fault,ae_busy;wire[15:0]ae_request,ae_applied,ae_updates;wire[23:0]ae_readback;
wire[31:0]ae_sum;wire[15:0]ae_ncenter,ae_ntotal,ae_nclip;wire[1:0]ae_decision;wire ae_shadow;
// Diagnostic register requests share the exposure writer's sole I2C owner.
reg[2:0]sensor_cmd_sync=0;reg sensor_cmd_seen=0,sensor_req=0,sensor_write=0;
reg[15:0]sensor_addr=0;reg[7:0]sensor_data=0;reg[31:0]sensor_seq=0;
wire sensor_ack,sensor_fault,sensor_busy;wire[7:0]sensor_readback;
always @(posedge CLK_5M)begin
 sensor_cmd_sync<={sensor_cmd_sync[1:0],feature_command_toggle};sensor_cmd_seen<=sensor_cmd_sync[2];
 if(!i2c_rst_n)begin sensor_req<=0;sensor_seq<=0;sensor_cmd_sync<=0;sensor_cmd_seen<=0;end
 else if(sensor_cmd_sync[2]!=sensor_cmd_seen && (feature_command[31:24]==16 || feature_command[31:24]==17) && sensor_req==sensor_ack)begin
  sensor_addr<=feature_command[23:8];sensor_data<=feature_command[7:0];sensor_write<=feature_command[31:24]==17;
  sensor_req<=~sensor_req;sensor_seq<=sensor_seq+1'b1;
 end
end
i2c_master_ctrl_top #(.DATA_LENGTH(`VISION_SENSOR_INIT_LENGTH),
 .INIT_FILE(`VISION_SENSOR_INIT_FILE),.EXPOSURE_MIN(`VISION_SENSOR_EXPOSURE_MIN),
 .EXPOSURE_MAX(`VISION_SENSOR_EXPOSURE_MAX),.EXPOSURE_INITIAL(`VISION_SENSOR_EXPOSURE_INITIAL)) u2_i2c_master_ctrl_top(
 .debug_req(sensor_req),.debug_write(sensor_write),.debug_addr(sensor_addr),.debug_data(sensor_data),
 .debug_ack(sensor_ack),.debug_fault(sensor_fault),.debug_busy(sensor_busy),.debug_readback(sensor_readback),
 .exposure_req_toggle(ae_req),.exposure_req_value(ae_request),.exposure_ack(ae_ack),.exposure_fault(ae_fault),
 .exposure_busy(ae_busy),.exposure_applied(ae_applied),.exposure_updates(ae_updates),.exposure_readback(ae_readback),
  /*i*/.clk			(CLK_5M		),
  /*i*/.rst_n			(i2c_rst_n		),
  /*i*/.scl_pad_i     (io_cam_scl_IN),//(1'b1),
  /*o*/.scl_pad_o     (io_cam_scl_OUT),
  /*o*/.scl_padoen_o  (scl_padoen_o),
  /*i*/.sda_pad_i     (io_cam_sda_IN),
  /*o*/.sda_pad_o     (io_cam_sda_OUT),
  /*o*/.sda_padoen_o  (sda_padoen_o)
  
  );
assign o_cam_rst_p = `VISION_SENSOR_SC2210 ? w_arstn : ~w_arstn;
assign io_cam_scl_OE = ~scl_padoen_o;
assign io_cam_sda_OE = ~sda_padoen_o;

//=====================================================================================
//frame buffer
//=====================================================================================
wire [7:0] 	ch0_r;
wire [7:0]    ch0_g;
wire [7:0]    ch0_b;
wire ch0_vs;
wire ch0_hs;
wire ch0_de;
wire fov_vs,fov_hs,fov_valid,fov_overrun;
reg[31:0]fov_overruns=0;reg fov_overrun_q=0;
always @(posedge i_mipi_rx_pclk)begin
 fov_overrun_q<=fov_overrun;
 if(!vid_rst_n)fov_overruns<=0;else if(fov_overrun&&!fov_overrun_q)fov_overruns<=fov_overruns+1'b1;
end
wire[31:0]fov_data;
generate if(`VISION_SENSOR_NATIVE_1080)begin:native_input
 camera_native_1080 native_1080(.clk(i_mipi_rx_pclk),.rst_n(vid_rst_n),.vs(w_mipi_rx_vs),.hs(w_mipi_rx_hs),.valid(w_mipi_rx_de),
  .data(w_mipi_rx_data[39:0]),.o_vs(fov_vs),.o_hs(fov_hs),.o_valid(fov_valid),.o_data(fov_data));
 assign fov_overrun=1'b0;
end else begin:sc431hai_input
 bayer_fov_reduce fov_reduce(.clk(i_mipi_rx_pclk),.rst_n(vid_rst_n),.vs(w_mipi_rx_vs),.hs(w_mipi_rx_hs),.valid(w_mipi_rx_de),
  .data({w_mipi_rx_data[9:2],w_mipi_rx_data[19:12],w_mipi_rx_data[29:22],w_mipi_rx_data[39:32]}),
  .o_vs(fov_vs),.o_hs(fov_hs),.o_valid(fov_valid),.o_data(fov_data),.overrun(fov_overrun));
end endgenerate
wire[31:0] memory_capture_id,memory_display_id,memory_write_errors;wire[2:0]memory_history_count;
wire[5:0] fb_axi_awid;
wire[31:0] fb_axi_awaddr;
wire[7:0] fb_axi_awlen;
wire[2:0] fb_axi_awsize;
wire[1:0] fb_axi_awburst;
wire fb_axi_awvalid;
wire fb_axi_awready;
wire[127:0] fb_axi_wdata;
wire[15:0] fb_axi_wstrb;
wire fb_axi_wlast;
wire fb_axi_wvalid;
wire fb_axi_wready;
wire[5:0] fb_axi_bid;
wire[1:0] fb_axi_bresp;
wire fb_axi_bvalid;
wire fb_axi_bready;
wire[5:0] fb_axi_arid;
wire[31:0] fb_axi_araddr;
wire[7:0] fb_axi_arlen;
wire[2:0] fb_axi_arsize;
wire[1:0] fb_axi_arburst;
wire fb_axi_arvalid;
wire fb_axi_arready;
wire[5:0] fb_axi_rid;
wire[127:0] fb_axi_rdata;
wire[1:0] fb_axi_rresp;
wire fb_axi_rlast;
wire fb_axi_rvalid;
wire fb_axi_rready;
wire[5:0]roi_axi_awid,roi_axi_arid;
assign s_axi_awid=roi_axi_awid[3:0],s_axi_arid=roi_axi_arid[3:0];
wire roi_enable,roi_freeze,roi_job_valid,roi_job_ready,roi_capture_valid,roi_capture_ready,roi_capture_pvalid,roi_capture_pready,roi_capture_sof,roi_capture_eol,roi_capture_eof,roi_capture_abort,roi_capture_done,roi_capture_error,roi_capture_active;
wire[31:0]roi_capture_id,roi_capture_data,roi_capture_count,roi_capture_discard,roi_job_id,roi_display_base,roi_display_frame,roi_display_config,roi_display_stride,roi_cycles,roi_misses;
wire[15:0]roi_x,roi_y,roi_w,roi_h,roi_dw,roi_dh,roi_posx,roi_posy,roi_display_width,roi_display_height;
wire roi_scan_urgent,roi_scan_enable,roi_display_valid,roi_render_done,roi_render_error,roi_render_busy,roi_render_pending,roi_scan_valid,roi_scan_ready,roi_scan_sof,roi_scan_eol,roi_scan_eof,roi_scan_busy,roi_scan_done,roi_scan_error,roi_vblank;
wire[31:0]roi_scan_data,roi_scan_frame,roi_scan_config;wire[1:0]roi_scan_keep;
wire [7:0] pattern_r,pattern_g,pattern_b;
wire pattern_hs,pattern_vs,pattern_de,pattern_frame_pulse;
wire [31:0] pattern_frames;
wire unified_view_active,scan_source_mode;wire[2:0]pool_history_count;wire[31:0]pool_capture_frame;wire pool_scan_hold;
wire[31:0]pool_capture_debug,rgb_capture_debug;
wire roi_hold_valid,roi_config_busy,roi_config_error,roi_commit_rejected;wire[31:0]roi_hold_frame,roi_hold_raw,roi_commit_id,roi_requested_id,roi_rejected_id;
wire[23:0]roi_rgb;wire roi_vs,roi_hs,roi_de,roi_view_enable,roi_frame_ok,roi_config_changed;wire[31:0]roi_view_frame,roi_view_config,roi_bad_frames;
wire[5:0]cpu_arid;
wire[31:0]cpu_araddr;
wire[7:0]cpu_arlen;
wire[2:0]cpu_arsize;
wire[1:0]cpu_arburst;
wire[0:0]cpu_arvalid;
wire[0:0]cpu_arready;
wire[127:0]cpu_rdata;
wire[1:0]cpu_rresp;
wire[5:0]cpu_rid;
wire[0:0]cpu_rlast;
wire[0:0]cpu_rvalid;
wire[0:0]cpu_rready;
wire[5:0]cpu_awid;
wire[31:0]cpu_awaddr;
wire[7:0]cpu_awlen;
wire[2:0]cpu_awsize;
wire[1:0]cpu_awburst;
wire[0:0]cpu_awvalid;
wire[0:0]cpu_awready;
wire[127:0]cpu_wdata;
wire[15:0]cpu_wstrb;
wire[0:0]cpu_wlast;
wire[0:0]cpu_wvalid;
wire[0:0]cpu_wready;
wire[1:0]cpu_bresp;
wire[5:0]cpu_bid;
wire[0:0]cpu_bvalid;
wire[0:0]cpu_bready;
wire soc_jtag_tdo;
wire[31:0]pool_scan_raw_id;
localparam COMPUTE_BANK_BITS=RAW_TO_POOL?3:2;
wire compute_acquire_valid,compute_latest,compute_release,compute_acquire_ready,compute_missing,compute_hold_valid;
wire[31:0]compute_request_frame_id,compute_hold_frame_id,compute_hold_config_id;
wire[COMPUTE_BANK_BITS-1:0]compute_hold_bank;
wire[3:0]dma_arid;
wire[3:0]dma_awid;
wire[31:0]dma_araddr;
wire[31:0]dma_awaddr;
wire[7:0]dma_arlen;
wire[7:0]dma_awlen;
wire[2:0]dma_arsize;
wire[2:0]dma_awsize;
wire[1:0]dma_arburst;
wire[1:0]dma_awburst;
wire[0:0]dma_arvalid;
wire[0:0]dma_awvalid;
wire[0:0]dma_arready;
wire[0:0]dma_awready;
wire[127:0]dma_rdata;
wire[1:0]dma_rresp;
wire[0:0]dma_rlast;
wire[0:0]dma_rvalid;
wire[0:0]dma_rready;
wire[127:0]dma_wdata;
wire[15:0]dma_wstrb;
wire[0:0]dma_wlast;
wire[0:0]dma_wvalid;
wire[0:0]dma_wready;
wire[1:0]dma_bresp;
wire[0:0]dma_bvalid;
wire[0:0]dma_bready;
generate if(!SAPPHIRE_ENABLE||!ANALYSIS_DMA_ENABLE)begin:no_analysis_dma
assign dma_arid=0;
assign dma_araddr=0;
assign dma_arlen=0;
assign dma_arsize=0;
assign dma_arburst=0;
assign dma_arvalid=0;
assign dma_rready=0;
assign dma_awid=0;
assign dma_awaddr=0;
assign dma_awlen=0;
assign dma_awsize=0;
assign dma_awburst=0;
assign dma_awvalid=0;
assign dma_wdata=0;
assign dma_wstrb=0;
assign dma_wlast=0;
assign dma_wvalid=0;
assign dma_bready=0;
assign compute_acquire_valid=0;
assign compute_latest=0;
assign compute_release=0;
assign compute_request_frame_id=0;
end endgenerate
frame_memory_system #(.SCAN_BURST_BEATS(64),.CPU_ENABLED(SAPPHIRE_ENABLE),.COMPUTE_ENABLED(SAPPHIRE_ENABLE&&ANALYSIS_DMA_ENABLE),.LEGACY_ENABLED(!RAW_TO_POOL),.SOURCE_BANKS(RAW_TO_POOL?8:4),.KEEP_HISTORY(RAW_TO_POOL),.DIRECT_SCAN(RAW_TO_POOL),.SOURCE_BASE(RAW_TO_POOL?32'h00000000:32'h02000000),.RESULT_BASE(RAW_TO_POOL?32'h02000000:32'h03000000)) unified_memory(
 .capture_debug(pool_capture_debug),
 .dma_arid({2'b0,dma_arid}),
 .dma_awid({2'b0,dma_awid}),
 .dma_araddr(dma_araddr),
 .dma_awaddr(dma_awaddr),
 .dma_arlen(dma_arlen),
 .dma_awlen(dma_awlen),
 .dma_arsize(dma_arsize),
 .dma_awsize(dma_awsize),
 .dma_arburst(dma_arburst),
 .dma_awburst(dma_awburst),
 .dma_arvalid(dma_arvalid),
 .dma_awvalid(dma_awvalid),
 .dma_arready(dma_arready),
 .dma_awready(dma_awready),
 .dma_rdata(dma_rdata),
 .dma_rresp(dma_rresp),
 .dma_rlast(dma_rlast),
 .dma_rvalid(dma_rvalid),
 .dma_rready(dma_rready),
 .dma_wdata(dma_wdata),
 .dma_wstrb(dma_wstrb),
 .dma_wlast(dma_wlast),
 .dma_wvalid(dma_wvalid),
 .dma_wready(dma_wready),
 .dma_bresp(dma_bresp),
 .dma_bvalid(dma_bvalid),
 .dma_bready(dma_bready),
 .compute_acquire_valid(compute_acquire_valid),
 .compute_latest(compute_latest),
 .compute_release(compute_release),
 .compute_request_frame_id(compute_request_frame_id),
 .compute_acquire_ready(compute_acquire_ready),
 .compute_missing(compute_missing),
 .compute_hold_valid(compute_hold_valid),
 .compute_hold_bank(compute_hold_bank),
 .compute_hold_frame_id(compute_hold_frame_id),
 .compute_hold_config_id(compute_hold_config_id),
 .cpu_arid(cpu_arid),
 // Sapphire's configured DDR aperture is128MiB; upper address bits never reach it.
 .cpu_araddr({5'b0,cpu_araddr[26:0]}),
 .cpu_arlen(cpu_arlen),
 .cpu_arsize(cpu_arsize),
 .cpu_arburst(cpu_arburst),
 .cpu_arvalid(cpu_arvalid),
 .cpu_arready(cpu_arready),
 .cpu_rdata(cpu_rdata),
 .cpu_rresp(cpu_rresp),
 .cpu_rid(cpu_rid),
 .cpu_rlast(cpu_rlast),
 .cpu_rvalid(cpu_rvalid),
 .cpu_rready(cpu_rready),
 .cpu_awid(cpu_awid),
 .cpu_awaddr({5'b0,cpu_awaddr[26:0]}),
 .cpu_awlen(cpu_awlen),
 .cpu_awsize(cpu_awsize),
 .cpu_awburst(cpu_awburst),
 .cpu_awvalid(cpu_awvalid),
 .cpu_awready(cpu_awready),
 .cpu_wdata(cpu_wdata),
 .cpu_wstrb(cpu_wstrb),
 .cpu_wlast(cpu_wlast),
 .cpu_wvalid(cpu_wvalid),
 .cpu_wready(cpu_wready),
 .cpu_bresp(cpu_bresp),
 .cpu_bid(cpu_bid),
 .cpu_bvalid(cpu_bvalid),
 .cpu_bready(cpu_bready),

 .clk(core_clk),
 .rst_n(vid_rst_n),.direct_scan(!roi_enable),.memory_mode(memory_mode),.history_index(history_index),.history_count(pool_history_count),.capture_frame_id(pool_capture_frame),.scan_source_mode(scan_source_mode),
 .capture_abort(roi_capture_abort),
 .scan_enable(roi_scan_enable),.scan_urgent(roi_scan_urgent),
 .capture_valid(roi_capture_valid),
 .capture_ready(roi_capture_ready),
 .capture_config_id(roi_capture_id),
 .src_width(16'd1920),
 .src_height(16'd1080),
 .src_stride_bytes(32'd3840),
 .capture_pixel_valid(roi_capture_pvalid),
 .capture_pixel_ready(roi_capture_pready),
 .capture_pixel_data(roi_capture_data),
 .capture_pixel_sof(roi_capture_sof),
 .capture_pixel_eol(roi_capture_eol),
 .capture_pixel_eof(roi_capture_eof),
 .capture_done(roi_capture_done),
 .capture_error(roi_capture_error),
 .job_valid(roi_job_valid),
 .job_ready(roi_job_ready),
 .freeze_source(roi_freeze),
 .release_source(!roi_enable||!roi_freeze),
 .job_config_id(roi_job_id),
 .roi_x(roi_x),
 .roi_y(roi_y),
 .roi_w(roi_w),
 .roi_h(roi_h),
 .dst_width(roi_dw),
 .dst_height(roi_dh),
 .dst_stride_bytes({15'b0,roi_dw,1'b0}),
 .analysis_acquire_valid(1'b0),
 .analysis_acquire_ready(),
 .analysis_release(1'b0),
 .analysis_hold_valid(pool_scan_hold),
 .analysis_hold_bank(),
 .analysis_hold_frame_id(),
 .analysis_hold_config_id(pool_scan_raw_id),
 .vblank(roi_vblank),
 .display_valid(roi_display_valid),
 .display_base(roi_display_base),
 .display_frame_id(roi_display_frame),
 .display_config_id(roi_display_config),
 .display_width(roi_display_width),
 .display_height(roi_display_height),
 .display_stride_bytes(roi_display_stride),
 .render_done(roi_render_done),
 .render_error(roi_render_error),
 .render_busy(roi_render_busy),
 .render_pending(roi_render_pending),
 .last_cycles(roi_cycles),
 .deadline_misses(roi_misses),
 .scan_pixel_valid(roi_scan_valid),
 .scan_pixel_ready(roi_scan_ready),
 .scan_pixel_data(roi_scan_data),
 .scan_pixel_keep(roi_scan_keep),
 .scan_pixel_sof(roi_scan_sof),
 .scan_pixel_eol(roi_scan_eol),
 .scan_pixel_eof(roi_scan_eof),
 .scan_pixel_frame_id(roi_scan_frame),
 .scan_pixel_config_id(roi_scan_config),
 .scan_busy(roi_scan_busy),
 .scan_done(roi_scan_done),
 .scan_error(roi_scan_error),
 .legacy_arid(fb_axi_arid),
 .legacy_araddr(fb_axi_araddr),
 .legacy_arlen(fb_axi_arlen),
 .legacy_arsize(fb_axi_arsize),
 .legacy_arburst(fb_axi_arburst),
 .legacy_arvalid(fb_axi_arvalid),
 .legacy_arready(fb_axi_arready),
 .legacy_rdata(fb_axi_rdata),
 .legacy_rresp(fb_axi_rresp),
 .legacy_rid(fb_axi_rid),
 .legacy_rlast(fb_axi_rlast),
 .legacy_rvalid(fb_axi_rvalid),
 .legacy_rready(fb_axi_rready),
 .legacy_awid(fb_axi_awid),
 .legacy_awaddr(fb_axi_awaddr),
 .legacy_awlen(fb_axi_awlen),
 .legacy_awsize(fb_axi_awsize),
 .legacy_awburst(fb_axi_awburst),
 .legacy_awvalid(fb_axi_awvalid),
 .legacy_awready(fb_axi_awready),
 .legacy_wdata(fb_axi_wdata),
 .legacy_wstrb(fb_axi_wstrb),
 .legacy_wlast(fb_axi_wlast),
 .legacy_wvalid(fb_axi_wvalid),
 .legacy_wready(fb_axi_wready),
 .legacy_bresp(fb_axi_bresp),
 .legacy_bid(fb_axi_bid),
 .legacy_bvalid(fb_axi_bvalid),
 .legacy_bready(fb_axi_bready),
 .m_axi_arid(roi_axi_arid),
 .m_axi_araddr(s_axi_araddr),
 .m_axi_arlen(s_axi_arlen),
 .m_axi_arsize(s_axi_arsize),
 .m_axi_arburst(s_axi_arburst),
 .m_axi_arvalid(s_axi_arvalid),
 .m_axi_arready(s_axi_arready),
 .m_axi_rdata(s_axi_rdata),
 .m_axi_rresp(s_axi_rresp),
 .m_axi_rid({2'b0,s_axi_rid}),
 .m_axi_rlast(s_axi_rlast),
 .m_axi_rvalid(s_axi_rvalid),
 .m_axi_rready(s_axi_rready),
 .m_axi_awid(roi_axi_awid),
 .m_axi_awaddr(s_axi_awaddr),
 .m_axi_awlen(s_axi_awlen),
 .m_axi_awsize(s_axi_awsize),
 .m_axi_awburst(s_axi_awburst),
 .m_axi_awvalid(s_axi_awvalid),
 .m_axi_awready(s_axi_awready),
 .m_axi_wdata(s_axi_wdata),
 .m_axi_wstrb(s_axi_wstrb),
 .m_axi_wlast(s_axi_wlast),
 .m_axi_wvalid(s_axi_wvalid),
 .m_axi_wready(s_axi_wready),
 .m_axi_bresp(s_axi_bresp),
 .m_axi_bid({2'b0,s_axi_bid}),
 .m_axi_bvalid(s_axi_bvalid),
 .m_axi_bready(s_axi_bready),
 .source_hold_valid(roi_hold_valid),
 .source_hold_frame_id(roi_hold_frame),
 .source_hold_config_id(roi_hold_raw)
);
wire isp_clk=RAW_TO_POOL?hdmi_tx_slow_clk:vid_clk_dvi2;wire[31:0]camera_source_frame;wire camera_source_bad;
generate if(!RAW_TO_POOL)begin:legacy_raw
assign camera_source_frame=memory_display_id,camera_source_bad=0;
// IMX219
  frame_buffer #(
.I_VID_WIDTH         (32),
.O_VID_WIDTH         (16),
.START_ADDR          (32'h00000        ),
.AXI_DATA_WIDTH      ( AXI_DATA_WIDTH	),
.AXI_ADDR_WIDTH      ( AXI_ADDR_WIDTH	),
.WR_FIFO_DEPTH	      ( RAW_FIFO_DEPTH ),
.RD_FIFO_DEPTH 	      ( RAW_FIFO_DEPTH ),
.BURST_LEN  	       (127),
.FB_NUM	            (8),
.MAX_VID_WIDTH	    (MAX_HRES/4) ,
.MAX_VID_HIGHT	    (1080) 


)checker0(
 .memory_mode(memory_mode),.history_index(history_index),.bresp(fb_axi_bresp),
 .capture_id(memory_capture_id),.display_id(memory_display_id),.history_count(memory_history_count),.write_errors(memory_write_errors),

       .axi_clk		(core_clk 	        ),
       .rst_n			(vid_rst_n   ),

/*i*/.i_clk			(i_mipi_rx_pclk      ),
/*i*/.i_vs			(fov_vs	),
/*i*/.i_de			(fov_valid & fov_hs	),
/*i*/.vin 			(fov_data	),
                     
/*i*/.o_clk			(vid_clk_dvi2),//(i_mipi_rx_pclk	),
/*i*/.o_hs    		(ch0_hs		),			
/*i*/.o_vs    		(ch0_vs		),			
/*i*/.o_de    		(ch0_de		),			
/*i*/.vout    		({ch0_g,ch0_b}	),//ch0_r,

/*i*/.H_FRONT_PORCH (HFP/2  		),//
/*i*/.H_SYNC 	 	    (HSP/2	 	),///2
/*i*/.H_VALID 	 	  (MAX_HRES/2     ),//		
/*i*/.H_BACK_PORCH	(HBP/2		),//		
/*i*/.V_FRONT_PORCH (VFP  		),//		
/*i*/.V_SYNC 	 	    (VSP 	 	),//		
/*i*/.V_VALID 	 	  (MAX_VRES     ),//		
/*i*/.V_BACK_PORCH	(VBP		),//		

       .awid			(fb_axi_awid	),      
       .awaddr		(fb_axi_awaddr	),
       .awlen			(fb_axi_awlen	),
       .awsize		(fb_axi_awsize	),
       .awburst		(fb_axi_awburst),
       .awprot    (s_axi_awprot ),
       .awcache   (s_axi_awcache),
       .awlock		(s_axi_awlock	),
       .awvalid		(fb_axi_awvalid),
       .awready		(fb_axi_awready),

       .arid			(fb_axi_arid	  ),
       .araddr		(fb_axi_araddr	),
       .arlen			(fb_axi_arlen	),
       .arsize		(fb_axi_arsize	),
       .arburst 	(fb_axi_arburst),

       .arprot    (s_axi_arprot ),
       .arcache   (s_axi_arcache),
       .arlock 		(s_axi_arlock	),
       .arvalid		(fb_axi_arvalid),
       .arready		(fb_axi_arready),

       .wdata			(fb_axi_wdata	),
       .wstrb			(fb_axi_wstrb	),
       .wlast			(fb_axi_wlast	),
       .wvalid		(fb_axi_wvalid	),
       .wready		(fb_axi_wready	),


       .rid			  (fb_axi_rid	),
       .rdata			(fb_axi_rdata	),
       .rlast			(fb_axi_rlast	),
       .rvalid 		(fb_axi_rvalid	),
       .rready		(fb_axi_rready	),
       .rresp			(fb_axi_rresp	),

       .bid			  (fb_axi_bid	),
       .bvalid		(fb_axi_bvalid	),
       .bready	  (fb_axi_bready	)
);
end else begin:pooled_raw
 wire raw_vs,raw_de,raw_bad;wire[15:0]raw_data;wire[31:0]sensor_frame,raw_overflows;
 vision_raw_frontend #(.PREFILL_WORDS(`VISION_SENSOR_NATIVE_1080?1920/4:1920/8)) raw_front(.rst_n(vid_rst_n),.input_clk(i_mipi_rx_pclk),.vs(fov_vs),.valid(fov_valid&&fov_hs),.data(fov_data),
  .isp_clk(hdmi_tx_slow_clk),.out_vs(raw_vs),.out_de(raw_de),.out_data(raw_data),.frame_id(sensor_frame),.frame_bad(raw_bad),.overflow_count(raw_overflows));
 assign ch0_vs=raw_vs,ch0_hs=raw_de,ch0_de=raw_de,{ch0_g,ch0_b}=raw_data;
 assign camera_source_frame=sensor_frame,camera_source_bad=raw_bad;
 assign memory_capture_id=pool_capture_frame,memory_display_id=roi_view_frame,memory_history_count=pool_history_count,memory_write_errors=raw_overflows;
 assign fb_axi_arid=0,fb_axi_araddr=0,fb_axi_arlen=0,fb_axi_arsize=0,fb_axi_arburst=0,fb_axi_arvalid=0,fb_axi_rready=0;
 assign fb_axi_awid=0,fb_axi_awaddr=0,fb_axi_awlen=0,fb_axi_awsize=0,fb_axi_awburst=0,fb_axi_awvalid=0;
 assign fb_axi_wdata=0,fb_axi_wstrb=0,fb_axi_wlast=0,fb_axi_wvalid=0,fb_axi_bready=0;
 assign s_axi_awprot=0,s_axi_awcache=0,s_axi_awlock=0,s_axi_arprot=0,s_axi_arcache=0,s_axi_arlock=0;
end endgenerate



ddr3_top                 u_ddr3_top
(

.axi_clk                (core_clk            ),
.core_clk               (core_clk            ),
.sdram_clk              (sdram_clk           ),  
.rx_cal_clk             (rx_cal_clk          ),
.tx_cal_clk             (tx_cal_clk          ),
.tx_cal_clk_90edge      (tx_cal_clk_90edge   ),
.rstn                   (w_arstn             ),      
.pll_shift              (pll_shift           ),
.pll_shift_sel          (pll_shift_sel       ),
.pll_shift_ena          (pll_shift_ena       ),       
///////////////DDR BUS
.ddr_ck_hi              (ddr_ck_hi           ),
.ddr_ck_lo              (ddr_ck_lo           ),
.ddr_cke                (ddr_cke             ),    
.ddr_reset_n            (ddr_reset_n         ),
.ddr_cs_n               (ddr_cs_n            ),
.ddr_ras_n              (ddr_ras_n           ),
.ddr_cas_n              (ddr_cas_n           ),
.ddr_we_n               (ddr_we_n            ),     
.ddr_addr               (ddr_addr            ),
.ddr_ba                 (ddr_ba              ),

.ddr_dqs_oe             (ddr_dqs_oe          ),
.ddr_dqs_oe_n           (ddr_dqs_oe_n        ),
.ddr_dq_oe              (ddr_dq_oe           ),
.ddr_dqs_in_hi          (ddr_dqs_in_hi       ),
.ddr_dqs_in_lo          (ddr_dqs_in_lo       ),
.ddr_dq_in_hi           (ddr_dq_in_hi        ),
.ddr_dq_in_lo           (ddr_dq_in_lo        ),

.ddr_dqs_out_hi         (ddr_dqs_out_hi      ),
.ddr_dqs_out_lo         (ddr_dqs_out_lo      ),
.ddr_dq_out_hi          (ddr_dq_out_hi       ),
.ddr_dq_out_lo          (ddr_dq_out_lo       ),

.ddr_dm_hi              (ddr_dm_hi           ),
.ddr_dm_lo              (ddr_dm_lo           ),
.ddr_odt                (ddr_odt             ),

// Application interface ports
.app_sr_req                     (1'b0),
.app_ref_req                    (1'b0),
.app_zq_req                     (1'b0),
.app_sr_active                  (app_sr_active),
.app_ref_ack                    (app_ref_ack),
.app_zq_ack                     (app_zq_ack),

// Slave Interface Write Address Ports
.s_axi_awid                     (s_axi_awid        ),
.s_axi_awaddr                   (s_axi_awaddr      ),
.s_axi_awlen                    (s_axi_awlen       ),
.s_axi_awsize                   (s_axi_awsize      ),
.s_axi_awburst                  (s_axi_awburst     ),
.s_axi_awlock                   (s_axi_awlock      ),
.s_axi_awcache                  (s_axi_awcache     ),
.s_axi_awprot                   (s_axi_awprot      ),
.s_axi_awqos                    (4'h0              ),
.s_axi_awvalid                  (s_axi_awvalid     ),
.s_axi_awready                  (s_axi_awready     ),
// Slave Interface Write Data Ports
.s_axi_wdata                    (s_axi_wdata       ),
.s_axi_wstrb                    (s_axi_wstrb       ),
.s_axi_wlast                    (s_axi_wlast       ),
.s_axi_wvalid                   (s_axi_wvalid      ),
.s_axi_wready                   (s_axi_wready      ),
// Slave Interface Write Response Ports
.s_axi_bid                      (s_axi_bid         ),
.s_axi_bresp                    (s_axi_bresp       ),
.s_axi_bvalid                   (s_axi_bvalid      ),
.s_axi_bready                   (s_axi_bready      ),
// Slave Interface Read Address Ports
.s_axi_arid                     (s_axi_arid        ),
.s_axi_araddr                   (s_axi_araddr      ),
.s_axi_arlen                    (s_axi_arlen       ),
.s_axi_arsize                   (s_axi_arsize      ),
.s_axi_arburst                  (s_axi_arburst     ),
.s_axi_arlock                   (s_axi_arlock      ),
.s_axi_arcache                  (s_axi_arcache     ),
.s_axi_arprot                   (s_axi_arprot      ),
.s_axi_arqos                    (4'h0              ),
.s_axi_arvalid                  (s_axi_arvalid     ),
.s_axi_arready                  (s_axi_arready     ),
// Slave Interface Read Data Ports
.s_axi_rid                      (s_axi_rid         ),
.s_axi_rdata                    (s_axi_rdata       ),
.s_axi_rresp                    (s_axi_rresp       ),
.s_axi_rlast                    (s_axi_rlast       ),
.s_axi_rvalid                   (s_axi_rvalid      ),
.s_axi_rready                   (s_axi_rready      ),
//DEBUG       
.wrlvl_dq_check                 (wrlvl_dq_check    ) ,
.rd_level_dqs_check             (rd_level_dqs_check) ,
.init_cur_state                 (init_cur_state    ) ,
.idelay_ld                      (idelay_ld         ) ,
.mpr_rdlvl_dly                  (mpr_rdlvl_dly     ) ,
.cal_done                       (cal_done          ) 
);

//***************************************************************************
// debayer
//***************************************************************************


wire        rgb_vs;
wire        rgb_hs;
wire        rgb_de;
wire        rgb_valid;
wire [47:0] rgb_datax2;
wire [15:0] r_gain;
wire [15:0] g_gain;
wire [15:0] b_gain;

// Physical RGB white balance. The legacy debayer has R/B names reversed
// relative to the measured BGGR input, so gains are routed accordingly below.
// SC431HAI indoor RAW measurement: R/G/B signal medians24/31.5/16 (BLC16).
// Normalize to the strongest channel instead of attenuating low-light precision.
// SC2210 retains its prepared settings until that module is measured.
localparam[15:0]WB_R_DEFAULT=`VISION_SENSOR_SC2210?16'd162:16'd336,
 WB_G_DEFAULT=`VISION_SENSOR_SC2210?16'd161:16'd256,
 WB_B_DEFAULT=`VISION_SENSOR_SC2210?16'd256:16'd504;
reg[15:0]wb_r=WB_R_DEFAULT,wb_g=WB_G_DEFAULT,wb_b=WB_B_DEFAULT,
 wb_pr=WB_R_DEFAULT,wb_pg=WB_G_DEFAULT,wb_pb=WB_B_DEFAULT;
reg ae_enable=1;reg[15:0]ae_manual=`VISION_SENSOR_EXPOSURE_INITIAL;
reg[2:0]gain_cmd_sync=0;reg gain_cmd_seen=0,gain_vq=0;
always @(posedge isp_clk)begin
 gain_cmd_sync<={gain_cmd_sync[1:0],feature_command_toggle};gain_cmd_seen<=gain_cmd_sync[2];gain_vq<=ch0_vs;
 if(gain_cmd_sync[2]!=gain_cmd_seen)case(feature_command[31:24])
  8:wb_pr<=feature_command[15:0];9:wb_pg<=feature_command[15:0];10:wb_pb<=feature_command[15:0];11:ae_enable<=feature_command[0];12:ae_manual<=feature_command[15:0];default:;
 endcase
 if(ch0_vs&&!gain_vq)begin wb_r<=wb_pr;wb_g<=wb_pg;wb_b<=wb_pb;end
end

reg[1:0]ae_mode_meta=0,ae_mode_sync=0;reg[31:0]ae_frame_tag=0;
always @(posedge isp_clk)begin
 ae_mode_meta<=memory_mode;ae_mode_sync<=ae_mode_meta;
 if(!vid_rst_n)begin ae_mode_meta<=0;ae_mode_sync<=0;ae_frame_tag<=0;end
 else if(ch0_vs&&ae_mode_sync==0)ae_frame_tag<=camera_source_frame;
end
camera_auto_exposure #(.EXPOSURE_MIN(`VISION_SENSOR_EXPOSURE_MIN),.EXPOSURE_MAX(`VISION_SENSOR_EXPOSURE_MAX),
 .EXPOSURE_INITIAL(`VISION_SENSOR_EXPOSURE_INITIAL)) auto_exposure(.clk(isp_clk),.rst_n(vid_rst_n),.vs(ch0_vs),.de(ch0_de),.pixels({ch0_b,ch0_g}),
 .capture_id(RAW_TO_POOL?ae_frame_tag:memory_display_id),.enable(ae_enable),.manual_value(ae_manual),.ack_toggle(ae_ack),.fault(ae_fault),
 .req_toggle(ae_req),.request(ae_request),.center_sum(ae_sum),.center_count(ae_ncenter),.total_count(ae_ntotal),
 .clip_count(ae_nclip),.decision(ae_decision),.shadow_boost(ae_shadow));

debayer_top_2to1 debayer_top
(
	.in_pclk		  (isp_clk),//(i_mipi_rx_pclk ),
	.in_rstn		  (vid_rst_n&&!camera_source_bad	),
	
	.raw_vs_i		  (ch0_vs		      ),
	.raw_hs_i		  (ch0_hs		      ),
	.raw_de_i		  (ch0_de		      ),
	.raw_valid_i	(ch0_de	        ),
	.raw_datax4_i	({ch0_b,ch0_g}	),
	.r_gain(wb_b),
  .g_gain(wb_g),
  .b_gain(wb_r),
	.rgb_vs_o		  (rgb_vs         ),
	.rgb_hs_o		  (rgb_hs         ),
	.rgb_de_o		  (rgb_de         ),
	.rgb_valid_o	(rgb_valid      ),
	.rgb_datax2_o (rgb_datax2     )//b,g,r,b,g,r
);
wire                            video_hs;
wire                            video_vs;
wire                            video_de;
wire[7:0]                       video_r;
wire[7:0]                       video_g;
wire[7:0]                       video_b;


wire[31:0]x3_frame,x3_pixels,x3_edge_count,x3_pipeline_cycles,x3_semantic_min,x3_semantic_max,x3_gray_sum;
wire[31:0]x3_display_min,x3_display_max,x3_display_samples,x3_display_unmatched;
generate if(RAW_TO_POOL)begin:line_direct
// Direct-scan raw tag is held through its lease; ample blanking precedes active video.
(* async_reg="true" *)reg[31:0]scan_raw_meta=0,scan_raw_sync=0;
always @(posedge isp_clk)begin
 if(!vid_rst_n)begin scan_raw_meta<=0;scan_raw_sync<=0;end else begin scan_raw_meta<=pool_scan_raw_id;scan_raw_sync<=scan_raw_meta;end
end
// X3 camera branch is before DDR; 2PPC keeps the ISP burst contract intact.
wire[15:0]x3_luma0=rgb_datax2[7:0]*16'd77+rgb_datax2[15:8]*16'd150+rgb_datax2[23:16]*16'd29+16'd128;
wire[15:0]x3_luma1=rgb_datax2[31:24]*16'd77+rgb_datax2[39:32]*16'd150+rgb_datax2[47:40]*16'd29+16'd128;
reg[15:0]x3_pair=0;reg x3_de=0,x3_hs=0,x3_vs=0;
always @(posedge isp_clk)begin
 x3_pair<={x3_luma1[15:8],x3_luma0[15:8]};x3_de<=rgb_de&&rgb_valid;x3_hs<=rgb_hs;x3_vs<=rgb_vs;
 if(!vid_rst_n)begin x3_de<=0;x3_hs<=0;x3_vs<=0;end
end
wire x3_ode,x3_ohs,x3_ovs;wire[11:0]x3_x,x3_y;wire[15:0]x3_gray;wire[1:0]x3_edges;wire[21:0]x3_mag;
vision_line_direct x3_direct(.clk(isp_clk),.rst_n(vid_rst_n&&!camera_source_bad),.de(x3_de),.hs(x3_hs),.vs(x3_vs),.pixels(x3_pair),.median_en(feature_median),.threshold(sobel_threshold),
 .ode(x3_ode),.ohs(x3_ohs),.ovs(x3_ovs),.x(x3_x),.y(x3_y),.gray(x3_gray),.edges(x3_edges),.magnitudes(x3_mag));
vision_line_metrics #(.MEASURE_DISPLAY(DISPLAY_LATENCY_PROBE)) x3_metrics(.clk(isp_clk),.rst_n(vid_rst_n&&!camera_source_bad),.input_de(x3_de),.input_vs(x3_vs),.input_frame(camera_source_frame),
 .display_de(video_de),.display_vs(video_vs),.display_live(memory_mode==0&&!roi_enable&&unified_view_active&&roi_frame_ok),.display_source_frame(scan_raw_sync),
 .output_de(x3_ode),.output_vs(x3_ovs),.output_x(x3_x),.output_y(x3_y),.gray(x3_gray),.edges(x3_edges),
 .completed_frame(x3_frame),.last_pixels(x3_pixels),.last_edges(x3_edge_count),.pipeline_cycles(x3_pipeline_cycles),.semantic_min(x3_semantic_min),.semantic_max(x3_semantic_max),.last_gray_sum(x3_gray_sum),.display_min(x3_display_min),.display_max(x3_display_max),.display_samples(x3_display_samples),.display_unmatched(x3_display_unmatched));
end else begin
 assign x3_frame=0,x3_pixels=0,x3_edge_count=0,x3_pipeline_cycles=0,x3_semantic_min=0,x3_semantic_max=0,x3_gray_sum=0,x3_display_min=0,x3_display_max=0,x3_display_samples=0,x3_display_unmatched=0;
end endgenerate
reg x3_profile_view=0;
always @(posedge hdmi_tx_slow_clk)begin
 if(!vid_rst_n)x3_profile_view<=0;else if(feature_cmd_event&&feature_command[31:24]==8'h2a)x3_profile_view<=feature_command[0];
end
reg [7:0]hdmi_tx_rdata,hdmi_tx_gdata,hdmi_tx_bdata;reg hdmi_tx_vs,hdmi_tx_hs,hdmi_tx_de;
generate if(!RAW_TO_POOL)begin:legacy_rgb_serial
reg rgb_vs_r = 'd0;
always @( posedge hdmi_tx_slow_clk )
begin
  rgb_vs_r <= rgb_vs;
end
assign pos_vs = {rgb_vs_r,rgb_vs} == 2'b01;
reg vid_cnt = 'd0;






always @( posedge hdmi_tx_slow_clk )
begin
    if( pos_vs )
      vid_cnt <= 1'b1;
    else if( rgb_de )
      vid_cnt <= ~vid_cnt ;

    if( vid_cnt )
      {hdmi_tx_bdata,hdmi_tx_gdata,hdmi_tx_rdata} <= rgb_datax2[23:0];
    else 
      {hdmi_tx_bdata,hdmi_tx_gdata,hdmi_tx_rdata} <= rgb_datax2[47:24];

  hdmi_tx_vs <= rgb_vs;
  hdmi_tx_hs <= rgb_hs;
  hdmi_tx_de <= rgb_de;
end

end else begin:pool_raster
 assign pos_vs=1'b0;
 always @(posedge hdmi_tx_slow_clk)begin
  hdmi_tx_rdata<=0;hdmi_tx_gdata<=0;hdmi_tx_bdata<=0;
  hdmi_tx_vs<=pattern_vs;hdmi_tx_hs<=pattern_hs;hdmi_tx_de<=pattern_de;
 end
end endgenerate
wire[7:0]control_paddr;wire control_psel,control_penable,control_pwrite,control_pready,control_pslverror;
wire[31:0]control_pwdata,control_prdata;
wire[23:0]control_ui;wire[1:0]control_model;wire control_geometry,control_recognition;wire tone_shadow_frame,control_motion;
wire[27:0]target_classes;wire[2:0]geometry_selection;wire geometry_selection_bank;
wire[3:0]boot_gpio;
assign flash_sck=boot_gpio[0],flash_cs=boot_gpio[1],flash_mosi=boot_gpio[2];
assign flash_wp=1'b1,flash_hold=1'b1,{flash_cs_oe,flash_sck_oe,flash_mosi_oe,flash_wp_oe,flash_hold_oe}={5{boot_gpio[3]}};
generate if(SAPPHIRE_ENABLE)begin:firmware_control
vision_control_bridge controls(.clk(core_clk),.rst_n(vid_rst_n),.video_clk(hdmi_tx_slow_clk),.vs(gamma_vs),.keys_n(vision_keys_n),.back_n(i_arstn),
 .flash_miso(flash_miso),.flash_gpio(boot_gpio),
 .cmd_event(feature_cmd_event),.cmd_op(feature_command[31:24]),.cmd_value(feature_command[23:0]),
 .paddr(control_paddr),.psel(control_psel),.penable(control_penable),.pwrite(control_pwrite),.pwdata(control_pwdata),.prdata(control_prdata),.pready(control_pready),.pslverror(control_pslverror),
 .mode(feature_mode),.threshold(feature_threshold),.sobel_threshold(sobel_threshold),.canny_threshold(canny_threshold),.median_en(feature_median),.motion_enable(control_motion),.memory_mode(memory_mode),.history_index(history_index),.ui_state(control_ui),.recognition_model(control_model),.geometry_enable(control_geometry),.recognition_enable(control_recognition),.target_classes(target_classes),.geometry_selection(geometry_selection),.geometry_selection_bank(geometry_selection_bank),
 .job_ready(roi_job_ready),.capture_done(roi_capture_done),.capture_error(roi_capture_error),.capture_count(roi_capture_count),.source_hold_valid(roi_hold_valid),.render_done(roi_render_done),.render_error(roi_render_error),.render_pending(roi_render_pending),.vblank(roi_vblank),.scan_busy(roi_scan_busy),
 .job_valid(roi_job_valid),.enable(roi_enable),.freeze_source(roi_freeze),.job_config_id(roi_job_id),.roi_x(roi_x),.roi_y(roi_y),.roi_w(roi_w),.roi_h(roi_h),.dst_w(roi_dw),.dst_h(roi_dh),.display_x(roi_posx),.display_y(roi_posy),.config_busy(roi_config_busy),.commit_rejected(roi_commit_rejected),.requested_id(roi_requested_id),.config_error(roi_config_error),.committed_id(roi_commit_id),.rejected_id(roi_rejected_id));
end else begin:hardware_roi
 assign boot_gpio=4'b0010;
 assign control_prdata=0,control_pready=1,control_pslverror=1,control_ui=0,control_model=0,control_geometry=0,control_recognition=0,control_motion=0,target_classes=0,geometry_selection=0,geometry_selection_bank=0;
vision_roi_control roi_control(.rst_n(vid_rst_n),.video_clk(hdmi_tx_slow_clk),.cmd_event(feature_cmd_event),.cmd_op(feature_command[31:24]),.cmd_value(feature_command[23:0]),.memory_mode(memory_mode),.clk(core_clk),
 .job_ready(roi_job_ready),.capture_done(roi_capture_done),.capture_error(roi_capture_error),.source_hold_valid(roi_hold_valid),.render_done(roi_render_done),.render_error(roi_render_error),.render_pending(roi_render_pending),.vblank(roi_vblank),.scan_busy(roi_scan_busy),
 .job_valid(roi_job_valid),.enable(roi_enable),.freeze_source(roi_freeze),.job_config_id(roi_job_id),.roi_x(roi_x),.roi_y(roi_y),.roi_w(roi_w),.roi_h(roi_h),.dst_w(roi_dw),.dst_h(roi_dh),.display_x(roi_posx),.display_y(roi_posy),.config_busy(roi_config_busy),.commit_rejected(roi_commit_rejected),.requested_id(roi_requested_id),.config_error(roi_config_error),.committed_id(roi_commit_id),.rejected_id(roi_rejected_id));
end endgenerate
vision_rgb_capture #(.INPUT_PPC(RAW_TO_POOL?2:1),.FIFO_AW(RAW_TO_POOL?11:10),.PAIR_DENOISE(RAW_TO_POOL)) roi_capture(.rst_n(vid_rst_n),.video_clk(hdmi_tx_slow_clk),.vs(RAW_TO_POOL?rgb_vs:hdmi_tx_vs),.de(RAW_TO_POOL?(rgb_de&&rgb_valid):hdmi_tx_de),.rgb(RAW_TO_POOL?{rgb_datax2[7:0],rgb_datax2[15:8],rgb_datax2[23:16]}:{hdmi_tx_rdata,hdmi_tx_gdata,hdmi_tx_bdata}),.rgb_upper({rgb_datax2[31:24],rgb_datax2[39:32],rgb_datax2[47:40]}),.source_abort(camera_source_bad),.raw_id(camera_source_frame),.clk(core_clk),.enable(RAW_TO_POOL?1'b1:roi_enable),.freeze_source(!RAW_TO_POOL&&roi_freeze&&roi_hold_valid),
 .capture_debug(rgb_capture_debug),
 .capture_valid(roi_capture_valid),.capture_ready(roi_capture_ready),.capture_config_id(roi_capture_id),.capture_pixel_valid(roi_capture_pvalid),.capture_pixel_ready(roi_capture_pready),.capture_pixel_data(roi_capture_data),.capture_pixel_sof(roi_capture_sof),.capture_pixel_eol(roi_capture_eol),.capture_pixel_eof(roi_capture_eof),.capture_abort(roi_capture_abort),.capture_done(roi_capture_done),.capture_error(roi_capture_error),.active(roi_capture_active),.completed(roi_capture_count),.discarded(roi_capture_discard));
vision_rgb_scanout #(.FIFO_AW(11)) roi_scanout(.rst_n(vid_rst_n),.clk(core_clk),.enable(RAW_TO_POOL?1'b1:roi_enable),.have_result(RAW_TO_POOL?(!roi_enable?(pool_history_count!=0):roi_display_valid):roi_display_valid),.pixel_valid(roi_scan_valid),.pixel_ready(roi_scan_ready),.pixel_data(roi_scan_data),.pixel_eol(roi_scan_eol),.pixel_eof(roi_scan_eof),.pixel_frame_id(roi_scan_frame),.pixel_config_id(roi_scan_config),.width(scan_source_mode?16'd1920:roi_display_width),.height(scan_source_mode?16'd1080:roi_display_height),.pos_x(scan_source_mode?16'd0:roi_posx),.pos_y(scan_source_mode?16'd0:roi_posy),.scan_done(roi_scan_done),.scan_error(roi_scan_error),.vblank(roi_vblank),.scan_enable(roi_scan_enable),.read_urgent(roi_scan_urgent),
 .video_clk(hdmi_tx_slow_clk),.vs(hdmi_tx_vs),.hs(hdmi_tx_hs),.de(hdmi_tx_de),.rgb({hdmi_tx_rdata,hdmi_tx_gdata,hdmi_tx_bdata}),.view_rgb(roi_rgb),.view_vs(roi_vs),.view_hs(roi_hs),.view_de(roi_de),.view_enabled(unified_view_active),.frame_ok(roi_frame_ok),.config_changed(roi_config_changed),.view_frame_id(roi_view_frame),.view_config_id(roi_view_config),.bad_frames(roi_bad_frames));

//==============================================================================
// MIPI DSI
//==============================================================================
// signal 

reg		[25:0]	r_rst_cnt;

wire	[31:0]	w_axi_rdata;
wire			w_axi_awready;
wire			w_axi_wready;
wire			w_axi_arready;
wire			w_axi_rvalid;
wire			w_axi_bvalid;

wire	[6:0]	w_axi_awaddr;
wire			w_axi_awvalid;
wire	[31:0]	w_axi_wdata;
wire			w_axi_wvalid;
wire			w_axi_bready;
wire	[6:0]	w_axi_araddr;
wire			w_axi_arvalid;
wire			w_axi_rready;

wire			w_confdone;
assign w_confdone = 1'b1;








////////////////////////////////////////////////////////////////
always@(posedge i_mipi_clk or  negedge w_arstn )
begin
  if ( !w_arstn ) begin
    r_rst_cnt	<= 'd0;
  end else 		
    r_rst_cnt	<= r_rst_cnt[25] ? r_rst_cnt :r_rst_cnt + 1'b1;
end

wire axi_rst_n = r_rst_cnt[25];

reg [26:0] dly_cnt = 'd0;

always @( posedge vid_clk_dvi2 or negedge w_arstn )
begin
  if( !w_arstn )
    dly_cnt <= 'd0;
  else if( w_confdone )
    dly_cnt <= dly_cnt[26] ? dly_cnt :(dly_cnt + 1'b1);
  else 
    dly_cnt <= 'd0;
end 

assign vid_rst_n = dly_cnt[26];




wire hs;
wire vs;
wire de;
wire [7:0] rgb_r;
wire [7:0] rgb_g;
wire [7:0] rgb_b;
  
  // color_bar_rgb #(
  // .HS_POLORY 		(1'b1		),
  // .VS_POLORY 		(1'b1		),
  // .H_FRONT_PORCH 	(HFP		),///2
  // .H_SYNC 		(HSP		),//
  // .H_VALID 		(MAX_HRES	),//
  // .H_BACK_PORCH 	(HBP		),//
  // .V_FRONT_PORCH 	(VFP		),
  // .V_SYNC 		(VSP		),
  // .V_VALID 		(MAX_VRES	),
  // .V_BACK_PORCH 	(VBP		),
  // .TEST_MODE 		(2'd2)
  // )u_color_bar_rgb1(
  // /*i*/.clk	(vid_clk_dvi2),//(vid_clk),
  // /*i*/.rst_n	(vid_rst_n),
  // /*o*/.hs	(hs),
  // /*o*/.vs	(vs),
  // /*o*/.de	(de),
  // // /*O*/.h_cnt (h_cnt),
  // // /*O*/.v_cnt (v_cnt),
  // /*o*/.rgb_r	(rgb_r),    //像素数据、红色分量
  // /*o*/.rgb_g	(rgb_g),    //像素数据、绿色分量
  // /*o*/.rgb_b (rgb_b)    //像素数据、蓝色分量
  
  // );

//=================================================================================
//hdmi tx ctrl 
//=================================================================================
assign tmds_tx_data0_TX_OE = 1'b1; // HDMI enabled.
assign tmds_tx_data1_TX_OE = 1'b1; // HDMI enabled.
assign tmds_tx_data2_TX_OE = 1'b1; // HDMI enabled.
assign tmds_tx_clk_TX_OE   = 1'b1; // HDMI enabled.

// Hold all TX serializers in reset for 256 pixel clocks after PLL lock.
reg [8:0] tx_startup_count=0;
always @(posedge hdmi_tx_slow_clk or negedge user_pll_locked)
 if(!user_pll_locked)tx_startup_count<=0;
 else if(!tx_startup_count[8])tx_startup_count<=tx_startup_count+1'b1;
wire tx_serializer_reset=~tx_startup_count[8];
assign tmds_tx_data0_TX_RST = tx_serializer_reset;
assign tmds_tx_data1_TX_RST = tx_serializer_reset;
assign tmds_tx_data2_TX_RST = tx_serializer_reset;
assign tmds_tx_clk_TX_RST   = tx_serializer_reset;

// 	  color_bar color_bar_m0(
// 	.clk(hdmi_tx_slow_clk),
// 	.rst(~vid_rst_n),
// 	.hs(video_hs),
// 	.vs(video_vs),
// 	.de(video_de),
// 	.rgb_r(video_r),
// 	.rgb_g(video_g),
// 	.rgb_b(video_b)
// );

wire [9:0] tmds_data0;
wire [9:0] tmds_data1;
wire [9:0] tmds_data2;
wire [9:0] tmds_clk ;
wire [7:0] gamma_rdata ;
wire [7:0] gamma_gdata ;
wire [7:0] gamma_bdata ;
wire gamma_valid;
wire gamma_hs;
wire gamma_sel = 1'b1;
wire gamma_vio_unused;
wire[7:0]legacy_rdata,legacy_gdata,legacy_bdata;
wire legacy_valid,legacy_hs,legacy_vs;
wire[23:0]chroma_rgb,linear_rgb,plain_chroma_rgb;wire highlight_active;
reg[23:0]legacy_delay1=0,legacy_delay2=0,legacy_delay3=0;
always @(posedge hdmi_tx_slow_clk)begin legacy_delay1<={legacy_rdata,legacy_gdata,legacy_bdata};legacy_delay2<=legacy_delay1;legacy_delay3<=legacy_delay2;end
assign {gamma_rdata,gamma_gdata,gamma_bdata}=(tone_mode==0)?linear_rgb:((tone_mode==1)?legacy_delay3:((tone_mode==2)?plain_chroma_rgb:chroma_rgb));
rgb_chroma_tone chroma_tone(.clk(hdmi_tx_slow_clk),.rst_n(vid_rst_n),.de(den_de),.hs(den_hs),.vs(den_vs),
 .r(den_r),.g(den_g),.b(den_b),.ode(gamma_valid),.ohs(gamma_hs),.ovs(gamma_vs),.rgb(chroma_rgb),.linear_rgb(linear_rgb),.gain_r(wb_b),.gain_g(wb_g),.gain_b(wb_r),.plain_rgb(plain_chroma_rgb),.highlight_active(highlight_active),.shadow_boost(ae_shadow),.freeze_tone(memory_mode!=0),.shadow_frame(tone_shadow_frame));

wire [7:0] con_rdata ;
wire [7:0] con_gdata ;
wire [7:0] con_bdata ;
wire con_de;
wire con_hs;
wire con_vs;
wire con_sel;

wire [7:0] BRIGHT_SIG    ;
wire CONTRAST_SIG_G;
wire CONTRAST_SIG_R;
wire [7:0] CONTRAST_G    ;
wire CONTRAST_SIG_B;
wire [7:0] BRIGHT        ;
wire [7:0] CONTRAST_R    ;


wire CONTRAST_B    ;


wire[7:0] den_r,den_g,den_b;
wire den_de,den_hs,den_vs;
rgb_shadow_denoise shadow_denoise(.clk(hdmi_tx_slow_clk),.rst_n(vid_rst_n),
 .de(roi_de),.hs(roi_hs),.vs(roi_vs),.r(roi_rgb[23:16]),.g(roi_rgb[15:8]),.b(roi_rgb[7:0]),
 .o_de(den_de),.o_hs(den_hs),.o_vs(den_vs),.o_r(den_r),.o_g(den_g),.o_b(den_b));
gamma_correction
#(
	.DATA_WIDTH		(8),
	.GAMMA_CURVE	("./rtl/gamma_conrrection/display_gamma_2p2.mem")
)
inst_gamma_correction
(
	.i_pclk		(hdmi_tx_slow_clk),
	.i_rstn		(vid_rst_n),
	
	.i_red		(den_r),//(con_rdata  ),//
	.i_green	(den_g),//(con_gdata  ),//
	.i_blue		(den_b),//(con_bdata  ),//
  .i_valid	(den_de   ),//(con_de     ),//
  .i_hs     (den_hs   ),//(con_hs     ),//
  .i_vs     (den_vs   ),//(con_vs     ),//
	.o_blue		(legacy_bdata		),
  .o_green	(legacy_gdata	  ),
	.o_red		(legacy_rdata		),
	.o_valid	(legacy_valid	  ),
  .o_hs     (legacy_hs       ),
  .o_vs     (legacy_vs       )
);

// Camera-independent raster for connector/clock/color bring-up.
reg [1:0] pattern_reset_sync=0;
always @(posedge hdmi_tx_slow_clk or negedge w_arstn)
    if(!w_arstn) pattern_reset_sync<=0;
    else pattern_reset_sync<={pattern_reset_sync[0],1'b1};
video_test_pattern pattern (
    .clk(hdmi_tx_slow_clk),.rst_n(pattern_reset_sync[1]),
    .red(pattern_r),.green(pattern_g),.blue(pattern_b),
    .hs(pattern_hs),.vs(pattern_vs),.de(pattern_de),
    .frame_count(pattern_frames),.frame_pulse(pattern_frame_pulse)
);
// LED levels only: no multi-bit asynchronous debug bus is introduced.
reg camera_vs_q=0;
reg [31:0] camera_frames=0;
always @(posedge i_mipi_rx_pclk) begin
    camera_vs_q<=w_mipi_rx_vs;
    if(w_mipi_rx_vs && !camera_vs_q)camera_frames<=camera_frames+1'b1;
end
reg output_vs_q=0;
reg [7:0] output_frames=0;
always @(posedge hdmi_tx_slow_clk) begin
    output_vs_q<=hdmi_tx_vs;
    if(hdmi_tx_vs && !output_vs_q)output_frames<=output_frames+1'b1;
end
assign led[1]=`VISION_TEST_PATTERN ? pattern_frames[5] : output_frames[5];
generate if(`VISION_TIMING_PROBE) begin: engine_probe_mode
    wire [31:0] checksum;
    wire active,failed;
    frame_engine_timing_probe probe(
        .clk(core_clk),.rst_n(axi_rst_n),
        .control_a(r_gain),.control_b(g_gain),.control_c(b_gain),
        .checksum(checksum),.active(active),.failed(failed)
    );
    assign led[2]=active;
    assign led[3]=(^checksum) ^ failed;
end else begin: camera_status_mode
    assign led[2]=w_arstn;
    assign led[3]=camera_frames[5];
end endgenerate

// Competition feature controls; command payload held stable across toggle CDC.
reg raw_arm_toggle=0;reg[11:0]raw_read_addr=0;
reg fly_profile_view=0;reg fly_feature_view=0;reg[1:0]fly_feature_quarter=0;wire[127:0]fly_feature_probe;
// Read-only RAW snapshot restored for sensor/ISP boundary diagnostics.
wire[31:0]raw_read_data,raw_sequence;wire raw_busy;
generate if(IMAGE_DEBUG==1)begin:raw_debug
raw_snapshot raw_probe(.clk(isp_clk),.rst_n(vid_rst_n),.vs(ch0_vs),.de(ch0_de),.pixels({ch0_b,ch0_g}),.arm_toggle(raw_arm_toggle),.read_clk(jtag_diag_DRCK),.read_addr(raw_read_addr),.read_data(raw_read_data),.sequence_id(raw_sequence),.busy(raw_busy));
end else begin
 assign raw_read_data=0,raw_sequence=0,raw_busy=0;
end endgenerate
always @(posedge jtag_diag_UPDATE)begin
 if(diag_shift[63:32]==32'h56495331)begin
 feature_command<=diag_shift[31:0];feature_command_toggle<=~feature_command_toggle;
 if(diag_shift[31:24]==8'h20)raw_arm_toggle<=~raw_arm_toggle;
 if(diag_shift[31:24]==8'h21)raw_read_addr<=diag_shift[11:0];
 if(diag_shift[31:24]==8'h40)begin snapshot_row<=diag_shift[10:0];snapshot_source<=diag_shift[11];snapshot_request<=~snapshot_request;end
 if(diag_shift[31:24]==8'h56)begin fly_profile_view<=0;fly_feature_view<=1;fly_feature_quarter<=diag_shift[1:0];end
 if(diag_shift[31:24]==8'h57)begin fly_feature_view<=0;fly_profile_view<=0;end
 if(diag_shift[31:24]==8'h58)begin fly_feature_view<=0;fly_profile_view<=1;end

 end
end
always @(posedge hdmi_tx_slow_clk)begin
 feature_cmd_sync<={feature_cmd_sync[1:0],feature_command_toggle};feature_cmd_seen<=feature_cmd_sync[2];
 if(feature_cmd_event&&feature_command[31:24]==8'h7e)feature_diag_page<=feature_command[5:0];
end
// Shape commands share the existing CDC mailbox; apply only at frame boundary.
reg shape_enable=1,shape_pending=1,shape_vq=0;
wire[7:0]model_state={1'b0,geometry_selection,control_recognition,control_geometry,control_model};
wire[63:0]shape_status;wire geo_hold,geo_raw_read;
wire[7:0]geo_paddr;wire geometry_result_current;wire geo_psel,geo_penable,geo_pwrite,geo_pready,geo_cpu_rst_n;
wire[31:0]geo_pwdata,geo_prdata;
wire use_m7=SAPPHIRE_ENABLE&&ANALYSIS_DMA_ENABLE&&control_geometry;
wire[10:0]active_canny_request=canny_threshold;
wire[10:0]reported_threshold=feature_threshold;
wire ai_enabled,ai_context_changed,ai_match,geometry_done;
wire[31:0]ai_context,geometry_frame,geometry_config,geometry_context;
wire ai_identity;wire[351:0]ai_result;wire[15:0]ai_age;
wire[7:0]ai_paddr;wire ai_psel,ai_penable,ai_pwrite,ai_pready,ai_pslverror;
wire[31:0]ai_pwdata,ai_prdata;

always @(posedge hdmi_tx_slow_clk)begin
 shape_vq<=gamma_vs;
 if(!vid_rst_n)begin shape_enable<=1;shape_pending<=1;end
 else begin
  if(feature_cmd_event&&feature_command[31:24]==22)shape_pending<=feature_command[0];
  if(gamma_vs&&!shape_vq)begin shape_enable<=shape_pending;end
 end
end
// RAW red-target measurement confirms BGGR at the framebuffer output.
reg[2:0]color_order=2,color_pending=2;reg color_vq=0;
reg[1:0]tone_mode=3,tone_pending=3;
wire[7:0]base_r=gamma_rdata,base_g=gamma_gdata,base_b=gamma_bdata;
always @(posedge hdmi_tx_slow_clk)begin
 color_vq<=gamma_vs;
 if(feature_cmd_event&&feature_command[31:24]==8'd7)tone_pending<=feature_command[1:0];
 if(gamma_vs&&!color_vq)tone_mode<=tone_pending;
 if(feature_cmd_event&&feature_command[31:24]==8'd6)color_pending<=feature_command[2:0];
 if(gamma_vs&&!color_vq)color_order<=color_pending;
end
reg[23:0]color_pixel;
always @*case(color_order)
 0:color_pixel={base_r,base_g,base_b};
 1:color_pixel={base_r,base_b,base_g};
 2:color_pixel={base_b,base_g,base_r};
 3:color_pixel={base_g,base_r,base_b};
 4:color_pixel={base_g,base_b,base_r};
 default:color_pixel={base_b,base_r,base_g};
endcase
wire[7:0]color_r=color_pixel[23:16],color_g=color_pixel[15:8],color_b=color_pixel[7:0];
generate if(SAPPHIRE_ENABLE&&ANALYSIS_DMA_ENABLE)begin:ai_link
 vision_ai_bridge #(.SIG_BITS(84)) bridge(.clk(core_clk),.rst_n(vid_rst_n),.video_clk(hdmi_tx_slow_clk),.vs(gamma_vs),
  .view_frame(roi_view_frame),.view_config(roi_view_config),.frame_ok(roi_frame_ok),
  .signature({tone_shadow_frame,wb_r,wb_g,wb_b,tone_mode,color_order,feature_mode,feature_median,sobel_threshold,active_canny_request,control_model,control_geometry,control_recognition}),
  .geometry_done(geometry_done),.geometry_frame(geometry_frame),.geometry_config(geometry_config),.geometry_context(geometry_context),.geometry_status(shape_status),
  .paddr(ai_paddr),.psel(ai_psel),.penable(ai_penable),.pwrite(ai_pwrite),.pwdata(ai_pwdata),.prdata(ai_prdata),.pready(ai_pready),.pslverror(ai_pslverror),
  .enabled(ai_enabled),.context_changed(ai_context_changed),.context_id(ai_context),.result(ai_result),.result_match(ai_match),.result_identity_match(ai_identity),.result_age(ai_age));
end else begin:no_ai_link
 assign ai_enabled=0,ai_context_changed=0,ai_context=0,ai_result=0,ai_match=0,ai_identity=0,ai_age=0,ai_prdata=0,ai_pready=1,ai_pslverror=1;
end endgenerate
wire[95:0]pre_gamma_sums,post_gamma_sums,display_color_sums,post_gamma_clips,unused_pre_clips,unused_display_clips;
generate if(IMAGE_DEBUG==1)begin:color_debug
rgb_roi_probe before_gamma_probe(hdmi_tx_slow_clk,vid_rst_n,den_vs,den_de,{den_r,den_g,den_b},pre_gamma_sums,unused_pre_clips);
rgb_roi_probe after_gamma_probe(hdmi_tx_slow_clk,vid_rst_n,gamma_vs,gamma_valid,{gamma_rdata,gamma_gdata,gamma_bdata},post_gamma_sums,post_gamma_clips);
rgb_roi_probe display_color_probe(hdmi_tx_slow_clk,vid_rst_n,gamma_vs,gamma_valid,color_pixel,display_color_sums,unused_display_clips);
end else begin
 assign pre_gamma_sums=0,post_gamma_sums=0,display_color_sums=0,post_gamma_clips=0,unused_pre_clips=0,unused_display_clips=0;
end endgenerate
generate if(!SAPPHIRE_ENABLE)begin:hardware_controls
vision_controls feature_controls(.clk(hdmi_tx_slow_clk),.rst_n(vid_rst_n),.vs(gamma_vs),.keys_n(vision_keys_n),
 .cmd_event(feature_cmd_event),.cmd_op(feature_command[31:24]),.cmd_value(feature_command[23:0]),
 .mode(feature_mode),.threshold(feature_threshold),.sobel_threshold(sobel_threshold),.canny_threshold(canny_threshold),.median_en(feature_median),.memory_mode(memory_mode),.history_index(history_index));
end endgenerate
wire[7:0] feature_r,feature_g,feature_b;wire feature_de,feature_hs,feature_vs;
wire[11:0] feature_x,feature_y;wire[10:0] feature_mag;wire feature_edge;
reg canny_probe_hold=0,canny_probe_req=0;reg[11:0]canny_probe_address=0;
wire canny_probe_ack,canny_probe_busy;wire[31:0]canny_probe_data;wire[11:0]canny_probe_read_address;
wire fly_bitmap_req,fly_bitmap_busy;wire[11:0]fly_bitmap_address;
wire probe_idle=!canny_probe_busy&&canny_probe_req==canny_probe_ack;
reg fly_bitmap_pending=0,jtag_probe_pending=0;reg[11:0]jtag_probe_address=0;
wire fly_bitmap_ready=probe_idle&&!jtag_probe_pending;
wire fly_bitmap_valid=fly_bitmap_pending&&probe_idle;
always @(posedge hdmi_tx_slow_clk)begin
 if(!vid_rst_n)begin canny_probe_hold<=0;canny_probe_req<=0;canny_probe_address<=0;
  fly_bitmap_pending<=0;jtag_probe_pending<=0;jtag_probe_address<=0;end
 else begin
  if(fly_bitmap_valid||(!fly_bitmap_busy&&!geo_raw_read))fly_bitmap_pending<=0;
  if(probe_idle)begin
   if(jtag_probe_pending&&!fly_bitmap_busy)begin
    canny_probe_address<=jtag_probe_address;canny_probe_req<=~canny_probe_req;jtag_probe_pending<=0;
   end else if(fly_bitmap_req&&fly_bitmap_ready)begin
    canny_probe_address<=fly_bitmap_address;canny_probe_req<=~canny_probe_req;fly_bitmap_pending<=1;

   end
  end
  if(feature_cmd_event)case(feature_command[31:24])
   8'h26:canny_probe_hold<=feature_command[0];
   8'h27:if(!fly_bitmap_busy)begin jtag_probe_address<=feature_command[11:0];jtag_probe_pending<=1;end
  endcase
 end
end
wire canny_capture_start;
wire[7:0]canny_noise_mean;wire canny_noise_valid;wire[10:0]canny_effective_threshold;
wire canny_pixel,canny_ready,canny_busy,canny_fault;wire[31:0]canny_completed;
wire[7:0]canny_coverage;
// ROI motion is a new video frame, not a reset of the retained Canny result/calibration.
vision_canny #(.CONTOUR_RASTER(1),.STABLE_NMS(1)) canny(.clk(hdmi_tx_slow_clk),.rst_n(vid_rst_n),.de(gamma_valid),.hs(gamma_hs),.vs(gamma_vs),
 .r(color_r),.g(color_g),.b(color_b),.high_threshold(active_canny_request),.display_x(feature_x),.display_y(feature_y),
 .edge_pixel(canny_pixel),.ready(canny_ready),.busy(canny_busy),.fault(canny_fault),.completed(canny_completed),
 .display_de(feature_de),.probe_hold(canny_probe_hold||geo_hold),.probe_req(canny_probe_req),.probe_address(canny_probe_address),
 .probe_ack(canny_probe_ack),.probe_data(canny_probe_data),.probe_read_address(canny_probe_read_address),.probe_busy(canny_probe_busy),.median_en(feature_median),.noise_mean(canny_noise_mean),.noise_valid(canny_noise_valid),.effective_threshold(canny_effective_threshold),.raster_de(feature_coordinate_de),.coarse_edges(canny_coarse_edges),.display_edges(canny_display_edges),.analysis_cycles(canny_analysis_cycles),.analysis_passes(canny_analysis_passes),.analysis_weak(canny_analysis_weak),.edge_coverage(canny_coverage),.capture_start(canny_capture_start));
wire[2:0]motion_direction;wire motion_held;
// ROI invalidation must not truncate the HDMI timing pipeline; each VS restarts the windows.
vision_display #(.FUSION(SAPPHIRE_ENABLE&&ANALYSIS_DMA_ENABLE),.LOCAL_MOTION_ENABLE(SAPPHIRE_ENABLE),.EXTERNAL_GEOMETRY(SAPPHIRE_ENABLE&&ANALYSIS_DMA_ENABLE)) feature_display(.clk(hdmi_tx_slow_clk),.rst_n(vid_rst_n),.de(gamma_valid),.hs(gamma_hs),.vs(gamma_vs),
 .r(color_r),.g(color_g),.b(color_b),.mode(feature_mode),.threshold(sobel_threshold),.canny_effective_threshold(canny_effective_threshold),.canny_requested_threshold(active_canny_request),.median_en(feature_median),
 .memory_mode(memory_mode),.history_index(history_index),.canny_pixel(canny_pixel),.canny_ready(canny_ready),.canny_coverage(canny_coverage),.cx(feature_x),.cy(feature_y),
 .ode(feature_de),.ohs(feature_hs),.ovs(feature_vs),.orr(feature_r),.ogg(feature_g),.obb(feature_b),.debug_mag(feature_mag),.debug_edge(feature_edge),.shape_enable(shape_enable),.shape_status(shape_status),.coordinate_de(feature_coordinate_de),
 .ui_state({9'b0,control_ui[23]?4'd0:control_ui[14:11],control_ui[10:0]}),.analysis_enabled(ai_enabled),.analysis_context_changed(ai_context_changed),.frame_id(roi_view_frame),.render_config_id(roi_view_config),.analysis_context(ai_context),
 .motion_enable(control_motion),.motion_direction(motion_direction),.motion_held(motion_held),
 .analysis_result(ai_result),.analysis_match(ai_match),.analysis_identity_match(ai_identity),.analysis_age(ai_age),.geometry_done(geometry_done),.geometry_frame(geometry_frame),.geometry_config(geometry_config),.geometry_context(geometry_context),
 .geometry_rst_n(vid_rst_n),.geometry_source_valid(roi_frame_ok),.geometry_changed(roi_config_changed),.canny_capture_start(canny_capture_start),.canny_completed(canny_completed),.geometry_source_errors(roi_bad_frames),
 .geometry_cpu_clk(core_clk),.geometry_cpu_rst_n(geo_cpu_rst_n),.geometry_paddr(geo_paddr),.geometry_psel(geo_psel),.geometry_penable(geo_penable),.geometry_pwrite(geo_pwrite),.geometry_pwdata(geo_pwdata),
 .geometry_prdata(geo_prdata),.geometry_pready(geo_pready),.geometry_bitmap_hold(geo_hold),.geometry_raw_read(geo_raw_read),.geometry_enable(control_geometry),.geometry_result_current(geometry_result_current),.geometry_selection(geometry_selection),.geometry_selection_bank(geometry_selection_bank));
// M0 is an ISP bypass only when filtering is off. HDMI and readback share
// this selection so the displayed camera image obeys the same noise switch.
wire camera_bypass=feature_mode==0&&!feature_median&&!control_recognition&&(control_ui[23]||control_ui[14:11]==0);
vision_sidebar_overlay sidebar_output(.clk(hdmi_tx_slow_clk),.rst_n(vid_rst_n),
 .de(camera_bypass?gamma_valid:feature_de),.hs(camera_bypass?gamma_hs:feature_hs),.vs(camera_bypass?gamma_vs:feature_vs),
 .rgb(camera_bypass?color_pixel:{feature_r,feature_g,feature_b}),
 .ui_state({control_ui[23:15],control_ui[14],3'b0,control_ui[10:0]}),
 .target_classes(target_classes),
 .motion_enable(control_motion&&memory_mode==0),.motion_direction(motion_direction),.motion_held(motion_held),
 .ai_status(control_model==2?{2'd0,(!control_recognition?2'd0:geometry_result_current?2'd2:2'd1)}:ai_result[14:11]),
 .ode(video_de),.ohs(video_hs),.ovs(video_vs),.orgb({video_r,video_g,video_b}));
// Exact pre-TMDS output tap, plus the leased shared-range RGB16 source before Gamma.
generate if(IMAGE_DEBUG)begin:image_debug
vision_line_snapshot image_snapshot(.clk(hdmi_tx_slow_clk),.rst_n(vid_rst_n),
 .request_toggle(snapshot_request),.request_row(snapshot_row),.request_source(snapshot_source),
 .source_vs(roi_vs),.source_de(roi_de),.source_rgb(roi_rgb),
 .display_vs(video_vs),.display_de(video_de),.display_rgb({video_r,video_g,video_b}),
 .frame_id(roi_view_frame),.config_id(roi_view_config),.mode(feature_mode),.threshold(reported_threshold),.median(feature_median),.tone(tone_mode),
 .status(snapshot_status),.sequence_id(snapshot_sequence),.captured_frame(snapshot_frame),.captured_config(snapshot_config),
 .read_clk(jtag_diag_DRCK),.bulk_capture(jtag_diag_CAPTURE&&feature_diag_page==27),.bulk_shift(jtag_diag_SHIFT&&feature_diag_page==27),
 .payload_phase(snapshot_payload_phase),.payload_tdo(snapshot_payload_tdo));
end else begin
 assign snapshot_status=32'h20000000,snapshot_sequence=0,snapshot_frame=0,snapshot_config=0;
 assign snapshot_payload_phase=0,snapshot_payload_tdo=0;
end endgenerate
reg feature_vs_q=0;reg[31:0] feature_edges=0,feature_edges_hold=0,feature_frames=0;
wire[255:0]flyhash_result;wire[31:0]flyhash_status,flyhash_frame,flyhash_config,flyhash_epoch;
reg[2:0]flyhash_held_sync=0;
always @(posedge hdmi_tx_slow_clk)flyhash_held_sync<=vid_rst_n?{flyhash_held_sync[1:0],roi_hold_valid}:3'b0;
wire[31:0]flyhash_full_cycles,flyhash_firmware_state;
generate if(SAPPHIRE_ENABLE)begin:sapphire
wire soc_reset;wire[15:0]soc_paddr;wire soc_psel,soc_penable,soc_pready,soc_pwrite,soc_pslverror;wire[31:0]soc_pwdata,soc_prdata;
wire[31:0]mail_prdata,dma_prdata;wire mail_pready,mail_pslverror,dma_pready,dma_pslverror;
wire dma_select=ANALYSIS_DMA_ENABLE&&soc_paddr[15:8]==1;wire control_select=soc_paddr[15:8]==2;
wire ai_select=ANALYSIS_DMA_ENABLE&&soc_paddr[15:8]==3;
wire geo_select=ANALYSIS_DMA_ENABLE&&soc_paddr[15:8]==5;
assign geo_paddr=soc_paddr[7:0],geo_psel=soc_psel&&geo_select,geo_penable=soc_penable,geo_pwrite=soc_pwrite,geo_pwdata=soc_pwdata,geo_cpu_rst_n=!soc_reset;
assign ai_paddr=soc_paddr[7:0],ai_psel=soc_psel&&ai_select,ai_penable=soc_penable,ai_pwrite=soc_pwrite,ai_pwdata=soc_pwdata;
assign control_paddr=soc_paddr[7:0],control_psel=soc_psel&&control_select,control_penable=soc_penable,control_pwrite=soc_pwrite,control_pwdata=soc_pwdata;
assign soc_prdata=geo_select?geo_prdata:(ai_select?ai_prdata:(control_select?control_prdata:(dma_select?dma_prdata:mail_prdata))),
 soc_pready=geo_select?geo_pready:(ai_select?ai_pready:(control_select?control_pready:(dma_select?dma_pready:mail_pready))),
 soc_pslverror=geo_select?1'b0:(ai_select?ai_pslverror:(control_select?control_pslverror:(dma_select?dma_pslverror:mail_pslverror)));
if(ANALYSIS_DMA_ENABLE)begin:analysis_input
 vision_analysis_dma #(.BANK_BITS(COMPUTE_BANK_BITS),.SOURCE_BASE(RAW_TO_POOL?32'h0:32'h02000000)) dma(
 .clk(core_clk),.rst_n(vid_rst_n),.paddr(soc_paddr[7:0]),.psel(soc_psel&&dma_select),.penable(soc_penable),.pwrite(soc_pwrite),.pwdata(soc_pwdata),.prdata(dma_prdata),.pready(dma_pready),.pslverror(dma_pslverror),
 .compute_acquire_valid(compute_acquire_valid),
 .compute_latest(compute_latest),
 .compute_release(compute_release),
 .compute_request_frame_id(compute_request_frame_id),
 .compute_acquire_ready(compute_acquire_ready),
 .compute_missing(compute_missing),
 .compute_hold_valid(compute_hold_valid),
 .compute_hold_bank(compute_hold_bank),
 .compute_hold_frame_id(compute_hold_frame_id),
 .compute_hold_config_id(compute_hold_config_id),
 .m_axi_arid(dma_arid),
 .m_axi_awid(dma_awid),
 .m_axi_araddr(dma_araddr),
 .m_axi_awaddr(dma_awaddr),
 .m_axi_arlen(dma_arlen),
 .m_axi_awlen(dma_awlen),
 .m_axi_arsize(dma_arsize),
 .m_axi_awsize(dma_awsize),
 .m_axi_arburst(dma_arburst),
 .m_axi_awburst(dma_awburst),
 .m_axi_arvalid(dma_arvalid),
 .m_axi_awvalid(dma_awvalid),
 .m_axi_arready(dma_arready),
 .m_axi_awready(dma_awready),
 .m_axi_rdata(dma_rdata),
 .m_axi_rresp(dma_rresp),
 .m_axi_rlast(dma_rlast),
 .m_axi_rvalid(dma_rvalid),
 .m_axi_rready(dma_rready),
 .m_axi_wdata(dma_wdata),
 .m_axi_wstrb(dma_wstrb),
 .m_axi_wlast(dma_wlast),
 .m_axi_wvalid(dma_wvalid),
 .m_axi_wready(dma_wready),
 .m_axi_bresp(dma_bresp),
 .m_axi_bvalid(dma_bvalid),
 .m_axi_bready(dma_bready));
end else begin:no_dma_apb
 assign dma_prdata=0,dma_pready=1,dma_pslverror=1;
end

wire cfu_cmd_valid,cfu_cmd_ready,cfu_rsp_valid,cfu_rsp_ready;wire[9:0]cfu_function_id;wire[31:0]cfu_inputs_0,cfu_inputs_1,cfu_outputs_0;
assign cpu_arid[5:4]=0,cpu_awid[5:4]=0;
VisionSapphire cpu(
 .io_systemClk(core_clk),
 .io_asyncReset(!vid_rst_n||!cal_done),
 .io_systemReset(soc_reset),
 .jtagCtrl_tck(jtag_inst1_TCK),
 .jtagCtrl_tdi(jtag_inst1_TDI),
 .jtagCtrl_enable(jtag_inst1_SEL),
 .jtagCtrl_capture(jtag_inst1_CAPTURE),
 .jtagCtrl_shift(jtag_inst1_SHIFT),
 .jtagCtrl_update(jtag_inst1_UPDATE),
 .jtagCtrl_reset(jtag_inst1_RESET),
 .jtagCtrl_tdo(soc_jtag_tdo),
 .system_uart_0_io_rxd(1'b1),
 .system_uart_0_io_txd(),
 .system_gpio_0_io_read(4'b0),
 .system_gpio_0_io_write(),
 .system_gpio_0_io_writeEnable(),
 .io_ddrA_ar_payload_id(cpu_arid[3:0]),
 .io_ddrA_ar_payload_addr(cpu_araddr),
 .io_ddrA_ar_payload_len(cpu_arlen),
 .io_ddrA_ar_payload_size(cpu_arsize),
 .io_ddrA_ar_payload_burst(cpu_arburst),
 .io_ddrA_ar_valid(cpu_arvalid),
 .io_ddrA_ar_ready(cpu_arready),
 .io_ddrA_aw_payload_id(cpu_awid[3:0]),
 .io_ddrA_aw_payload_addr(cpu_awaddr),
 .io_ddrA_aw_payload_len(cpu_awlen),
 .io_ddrA_aw_payload_size(cpu_awsize),
 .io_ddrA_aw_payload_burst(cpu_awburst),
 .io_ddrA_aw_valid(cpu_awvalid),
 .io_ddrA_aw_ready(cpu_awready),
 .io_ddrA_w_payload_data(cpu_wdata),
 .io_ddrA_w_payload_strb(cpu_wstrb),
 .io_ddrA_w_payload_last(cpu_wlast),
 .io_ddrA_w_valid(cpu_wvalid),
 .io_ddrA_w_ready(cpu_wready),
 .io_ddrA_r_payload_data(cpu_rdata),
 .io_ddrA_r_payload_resp(cpu_rresp),
 .io_ddrA_r_payload_id(cpu_rid[3:0]),
 .io_ddrA_r_payload_last(cpu_rlast),
 .io_ddrA_r_valid(cpu_rvalid),
 .io_ddrA_r_ready(cpu_rready),
 .io_ddrA_b_payload_resp(cpu_bresp),
 .io_ddrA_b_payload_id(cpu_bid[3:0]),
 .io_ddrA_b_valid(cpu_bvalid),
 .io_ddrA_b_ready(cpu_bready),
 .cpu0_customInstruction_cmd_valid(cfu_cmd_valid),
 .cpu0_customInstruction_cmd_ready(cfu_cmd_ready),
 .cpu0_customInstruction_function_id(cfu_function_id),
 .cpu0_customInstruction_inputs_0(cfu_inputs_0),
 .cpu0_customInstruction_inputs_1(cfu_inputs_1),
 .cpu0_customInstruction_rsp_valid(cfu_rsp_valid),
 .cpu0_customInstruction_rsp_ready(cfu_rsp_ready),
 .cpu0_customInstruction_outputs_0(cfu_outputs_0),
 .vision_apb_PADDR(soc_paddr),
 .vision_apb_PSEL(soc_psel),
 .vision_apb_PENABLE(soc_penable),
 .vision_apb_PREADY(soc_pready),
 .vision_apb_PWRITE(soc_pwrite),
 .vision_apb_PWDATA(soc_pwdata),
 .vision_apb_PRDATA(soc_prdata),
 .vision_apb_PSLVERROR(soc_pslverror));
vision_int8_cfu int8_cfu(.clk(core_clk),.rst_n(!soc_reset),.cmd_valid(cfu_cmd_valid),.cmd_ready(cfu_cmd_ready),.function_id(cfu_function_id),.a(cfu_inputs_0),.b(cfu_inputs_1),.rsp_valid(cfu_rsp_valid),.rsp_ready(cfu_rsp_ready),.result(cfu_outputs_0));
vision_flyhash_mailbox #(.RAW_READ_PORT(1)) flyhash_control(.raw_bitmap_enable(geo_raw_read),.clk(hdmi_tx_slow_clk),.rst_n(vid_rst_n),.cpu_clk(core_clk),.cpu_rst_n(!soc_reset),
 .paddr(soc_paddr),.psel(soc_psel&&!dma_select&&!control_select&&!geo_select),.penable(soc_penable),.pwrite(soc_pwrite),.pwdata(soc_pwdata),.prdata(mail_prdata),.pready(mail_pready),.pslverror(mail_pslverror),
 .firmware_state(flyhash_firmware_state),.full_cycles(flyhash_full_cycles),
 .cmd_event(feature_cmd_event),.cmd_op(feature_command[31:24]),.cmd_value(feature_command[23:0]),
 // frame_ok clears at every VS; the frozen lease is persistent. Any actual
 // scan failure increments bad_frames and cancels the tagged analysis job.
 .context_valid(roi_view_enable&&flyhash_held_sync[2]&&memory_mode==1&&canny_probe_hold&&canny_ready),
 .frame_id(roi_view_frame),.config_id(roi_view_config),.epoch(canny_completed),.stream_errors(roi_bad_frames),
 .status(flyhash_status),.result_frame_id(flyhash_frame),
 .result_config_id(flyhash_config),.result_epoch(flyhash_epoch),
 .bitmap_req(fly_bitmap_req),.bitmap_busy(fly_bitmap_busy),.bitmap_ready(fly_bitmap_ready),
 .bitmap_address(fly_bitmap_address),.bitmap_valid(fly_bitmap_valid),.bitmap_data(canny_probe_data)
 );
assign flyhash_result=0,fly_feature_probe=0;
end else begin:hardware_flyhash
assign geo_paddr=0,geo_psel=0,geo_penable=0,geo_pwrite=0,geo_pwdata=0,geo_cpu_rst_n=0;
assign control_paddr=0,control_psel=0,control_penable=0,control_pwrite=0,control_pwdata=0;
vision_flyhash_control flyhash_control(.clk(hdmi_tx_slow_clk),.rst_n(vid_rst_n),
 .cmd_event(feature_cmd_event),.cmd_op(feature_command[31:24]),.cmd_value(feature_command[23:0]),
 // frame_ok clears at every VS; the frozen lease is persistent. Any actual
 // scan failure increments bad_frames and cancels the tagged analysis job.
 .context_valid(roi_view_enable&&flyhash_held_sync[2]&&memory_mode==1&&canny_probe_hold&&canny_ready),
 .frame_id(roi_view_frame),.config_id(roi_view_config),.epoch(canny_completed),.stream_errors(roi_bad_frames),
 .hash(flyhash_result),.status(flyhash_status),.result_frame_id(flyhash_frame),
 .result_config_id(flyhash_config),.result_epoch(flyhash_epoch),
 .bitmap_req(fly_bitmap_req),.bitmap_busy(fly_bitmap_busy),.bitmap_ready(fly_bitmap_ready),
 .bitmap_address(fly_bitmap_address),.bitmap_valid(fly_bitmap_valid),.bitmap_data(canny_probe_data),
 .feature_quarter(fly_feature_quarter),.feature_probe(fly_feature_probe));
assign flyhash_full_cycles={19'b0,flyhash_status[12:0]},flyhash_firmware_state=0,soc_jtag_tdo=0;
assign ai_paddr=0,ai_psel=0,ai_penable=0,ai_pwrite=0,ai_pwdata=0;
assign cpu_arid=0;
assign cpu_araddr=0;
assign cpu_arlen=0;
assign cpu_arsize=0;
assign cpu_arburst=0;
assign cpu_arvalid=0;
assign cpu_rready=0;
assign cpu_awid=0;
assign cpu_awaddr=0;
assign cpu_awlen=0;
assign cpu_awsize=0;
assign cpu_awburst=0;
assign cpu_awvalid=0;
assign cpu_wdata=0;
assign cpu_wstrb=0;
assign cpu_wlast=0;
assign cpu_wvalid=0;
assign cpu_bready=0;
end endgenerate
always @(posedge hdmi_tx_slow_clk)begin
 feature_vs_q<=feature_vs;
 if(feature_vs&&!feature_vs_q)begin feature_frames<=feature_frames+1;feature_edges_hold<=feature_edges;feature_edges<=0;end
 else if(feature_de&&feature_edge)feature_edges<=feature_edges+1;
end
assign roi_view_enable=unified_view_active&&(!RAW_TO_POOL||roi_view_config!=0);
reg[31:0]highlight_hits=0,highlight_hits_hold=0;
reg gamma_vs_prev=0;reg[31:0]source_checksum=0,source_checksum_hold=0;
always @(posedge hdmi_tx_slow_clk)begin
 gamma_vs_prev<=gamma_vs;
 if(gamma_vs&&!gamma_vs_prev)begin source_checksum_hold<=source_checksum;source_checksum<=0;highlight_hits_hold<=highlight_hits;highlight_hits<=0;end
 else if(gamma_valid)begin source_checksum<=source_checksum+{8'd0,gamma_rdata,gamma_bdata,gamma_gdata};if(tone_mode==3&&highlight_active)highlight_hits<=highlight_hits+1'b1;end
end
wire[31:0] feature_status={canny_fault,canny_busy,canny_ready,memory_history_count,2'b0,feature_mode,feature_median,memory_mode,history_index,reported_threshold,i_arstn,vision_keys_n};
// Full HDMI video/control/data-island encoding with an AVI InfoFrame (VIC 16).
dvi_encoder hdmi_encoder_m0
(
	.pixelclk      		(hdmi_tx_slow_clk          ),// system clock
	.rst_p (`VISION_TEST_PATTERN ? ~pattern_reset_sync[1] : ~vid_rst_n),
	.i_bdata (`VISION_TEST_PATTERN ? pattern_b : video_b),
	.i_gdata (`VISION_TEST_PATTERN ? pattern_g : video_g),
	.i_rdata (`VISION_TEST_PATTERN ? pattern_r : video_r),
  .i_de (`VISION_TEST_PATTERN ? pattern_de : video_de),
	.i_hs (`VISION_TEST_PATTERN ? pattern_hs : video_hs),
	.i_vs (`VISION_TEST_PATTERN ? pattern_vs : video_vs),
  .video_format(2'b00), .video_VIC(7'd16),
  .audio_L(24'd0), .audio_R(24'd0), .audio_valid(1'b0),
  .audio_N(20'd6144), .audio_CTS(20'd148500),
  .audio_sample_frequency(4'd2), .audio_word_length(4'd2),
	

	.tmds_data0    		(tmds_data0),
  .tmds_data1    		(tmds_data1),
  .tmds_data2    		(tmds_data2),
  .tmds_clk      	  (tmds_clk  )
);
// Preserve each complete TMDS symbol; compensate board differential-pair polarity.
assign tmds_tx_clk_TX_DATA   = ~tmds_clk;
assign tmds_tx_data0_TX_DATA = ~tmds_data0;
assign tmds_tx_data1_TX_DATA = ~tmds_data1;
assign tmds_tx_data2_TX_DATA = ~tmds_data2;

// HDMI-only build: DSI PHY inactive and LCD backlight off.
assign LCD_POWER=1'b0; assign LCD_RST_P=1'b1;
assign mipi_dp_clk_RST=1'b1;
assign mipi_dp_clk_HS_OUT=8'd0;
assign mipi_dp_clk_HS_OE=1'b0;
assign mipi_dp_clk_LP_P_OUT=1'b0; assign mipi_dp_clk_LP_P_OE=1'b0;
assign mipi_dp_clk_LP_N_OUT=1'b0; assign mipi_dp_clk_LP_N_OE=1'b0;
assign mipi_dp_data0_RST=1'b1;
assign mipi_dp_data0_HS_OUT=8'd0;
assign mipi_dp_data0_HS_OE=1'b0;
assign mipi_dp_data0_LP_P_OUT=1'b0; assign mipi_dp_data0_LP_P_OE=1'b0;
assign mipi_dp_data0_LP_N_OUT=1'b0; assign mipi_dp_data0_LP_N_OE=1'b0;
assign mipi_dp_data1_RST=1'b1;
assign mipi_dp_data1_HS_OUT=8'd0;
assign mipi_dp_data1_HS_OE=1'b0;
assign mipi_dp_data1_LP_P_OUT=1'b0; assign mipi_dp_data1_LP_P_OE=1'b0;
assign mipi_dp_data1_LP_N_OUT=1'b0; assign mipi_dp_data1_LP_N_OE=1'b0;
assign mipi_dp_data2_RST=1'b1;
assign mipi_dp_data2_HS_OUT=8'd0;
assign mipi_dp_data2_HS_OE=1'b0;
assign mipi_dp_data2_LP_P_OUT=1'b0; assign mipi_dp_data2_LP_P_OE=1'b0;
assign mipi_dp_data2_LP_N_OUT=1'b0; assign mipi_dp_data2_LP_N_OE=1'b0;
assign mipi_dp_data3_RST=1'b1;
assign mipi_dp_data3_HS_OUT=8'd0;
assign mipi_dp_data3_HS_OE=1'b0;
assign mipi_dp_data3_LP_P_OUT=1'b0; assign mipi_dp_data3_LP_P_OE=1'b0;
assign mipi_dp_data3_LP_N_OUT=1'b0; assign mipi_dp_data3_LP_N_OE=1'b0;
// Legacy USER1 analyzer removed; USER2 operational diagnostics retained.
// Keep the USER1 interface pins live with a minimal identification shift register.
reg[7:0]user1_id=8'h51;
always @(posedge jtag_inst1_DRCK)begin
 if(jtag_inst1_RESET||jtag_inst1_CAPTURE)user1_id<=8'h51;
 else if(jtag_inst1_SEL&&jtag_inst1_SHIFT)user1_id<={jtag_inst1_TDI,user1_id[7:1]};
end
assign jtag_inst1_TDO=SAPPHIRE_ENABLE?soc_jtag_tdo:user1_id[0];
assign r_gain=16'd256;assign g_gain=16'd256;assign b_gain=16'd256;


// Diagnostic only: source-domain Gray counters, double-synchronized to JTAG.
reg [7:0] diag_frame_gray=0,diag_core_gray=0;
always @(posedge hdmi_tx_slow_clk)diag_frame_gray<=pattern_frames[7:0] ^ (pattern_frames[7:0]>>1);
always @(posedge core_clk)diag_core_gray<=cnt[25:18] ^ (cnt[25:18]>>1);
reg [23:0] diag_meta=0,diag_sync=0;
// Snapshot a complete raster interval, not just the free-running frame counter.
reg [21:0] diag_active_pixels=0;
reg [7:0] diag_video_flags=0;
reg [31:0] diag_video_summary=0;
reg [29:0] diag_tmds_prev=0;
always @(posedge hdmi_tx_slow_clk) begin
 diag_tmds_prev<={tmds_data2,tmds_data1,tmds_data0};
 if(!pattern_reset_sync[1]) begin
  diag_active_pixels<=0;
  diag_video_flags<=0;
  diag_video_summary<=0;
 end else if(pattern_frame_pulse) begin
  diag_video_summary<={diag_active_pixels,diag_video_flags,`VISION_TEST_PATTERN != 0,1'b1};
  diag_active_pixels<=0;
  diag_video_flags<=0;
 end else begin
  if(pattern_de)diag_active_pixels<=diag_active_pixels+1'b1;
  diag_video_flags<=diag_video_flags | {
   (tmds_clk!=10'b0 && tmds_clk!=10'h3ff),
   (tmds_data2!=diag_tmds_prev[29:20]),
   (tmds_data1!=diag_tmds_prev[19:10]),
   (tmds_data0!=diag_tmds_prev[9:0]),
   pattern_de,
   (pattern_de && |pattern_r),
   (pattern_de && |pattern_g),
   (pattern_de && |pattern_b)};
 end
end
// Summary is held for a full frame. Prime JTAG and accept repeated matching
// snapshots; the two-stage bus synchronizer is observational, not control.
reg [31:0] diag_video_meta=0,diag_video_sync=0;
// Observational geometry snapshots, held between frame edges.
reg rx_vs_q=0,rx_hs_q=0;
reg [11:0] rx_beats=0,rx_max=0,rx_lines=0;
reg [23:0] rx_total=0;
reg [3:0] rx_ppc_hold=0;
reg [5:0] rx_type_hold=0;
reg [59:0] rx_geometry=0;
always @(posedge i_mipi_rx_pclk) begin
 rx_vs_q<=w_mipi_rx_vs;rx_hs_q<=w_mipi_rx_hs;
 if(!w_arstn)begin rx_beats<=0;rx_max<=0;rx_lines<=0;rx_total<=0;rx_geometry<=0;end
 else if(w_mipi_rx_vs && !rx_vs_q)begin
  rx_geometry<={rx_max,rx_lines,rx_total,rx_ppc_hold,rx_type_hold,2'b01};
  rx_beats<=0;rx_max<=0;rx_lines<=0;rx_total<=0;
 end else begin
  if(w_mipi_rx_de && w_mipi_rx_hs)begin
   rx_beats<=rx_beats+1'b1;rx_total<=rx_total+1'b1;
   rx_ppc_hold<=diag_rx_ppc;rx_type_hold<=diag_rx_type;
  end
  if(rx_hs_q && !w_mipi_rx_hs)begin
   if(rx_beats!=0)begin rx_lines<=rx_lines+1'b1;if(rx_beats>rx_max)rx_max<=rx_beats;end
   rx_beats<=0;
  end
 end
end
// Count DE and HS independently; geometry requires their intersection.
reg[31:0]probe_de_count=0,probe_hs_count=0;
reg[15:0]probe_error_seen=0;
always @(posedge i_mipi_rx_pclk)begin
 if(w_mipi_rx_de)probe_de_count<=probe_de_count+1'b1;
 if(w_mipi_rx_hs&&!rx_hs_q)probe_hs_count<=probe_hs_count+1'b1;
 probe_error_seen<=probe_error_seen|mipi_debug_out[15:0];
end
reg out_vs_q=0,out_de_q=0;
reg [11:0] out_width=0,out_min=12'hfff,out_max=0,out_lines=0;
reg [23:0] out_total=0;
reg [59:0] out_geometry=0;
always @(posedge hdmi_tx_slow_clk) begin
 out_vs_q<=hdmi_tx_vs;out_de_q<=hdmi_tx_de;
 if(!vid_rst_n)begin out_width<=0;out_min<=12'hfff;out_max<=0;out_lines<=0;out_total<=0;out_geometry<=0;end
 else if(hdmi_tx_vs && !out_vs_q)begin
  out_geometry<={out_min,out_max,out_lines,out_total};
  out_width<=0;out_min<=12'hfff;out_max<=0;out_lines<=0;out_total<=0;
 end else begin
  if(hdmi_tx_de)begin out_width<=out_width+1'b1;out_total<=out_total+1'b1;end
  if(out_de_q && !hdmi_tx_de)begin
   if(out_width<out_min)out_min<=out_width;
   if(out_width>out_max)out_max<=out_width;
   out_lines<=out_lines+1'b1;out_width<=0;
  end
 end
end
// RGB channel measurements; arithmetic and output pixels are untouched.
reg [31:0] sum_r=0,sum_g=0,sum_b=0;
reg [7:0] min_r=255,min_g=255,min_b=255,max_r=0,max_g=0,max_b=0;
reg [119:0] rgb_stats=0;
reg [31:0] rgb_min_status=0;
always @(posedge hdmi_tx_slow_clk)begin
 if(!vid_rst_n)begin
  sum_r<=0;sum_g<=0;sum_b<=0;min_r<=255;min_g<=255;min_b<=255;max_r<=0;max_g<=0;max_b<=0;
 end else if(hdmi_tx_vs && !out_vs_q)begin
  rgb_stats<={sum_r,sum_g,sum_b,max_r,max_g,max_b};
  rgb_min_status<={min_r,min_g,min_b,7'b0,gamma_sel};
  sum_r<=0;sum_g<=0;sum_b<=0;min_r<=255;min_g<=255;min_b<=255;max_r<=0;max_g<=0;max_b<=0;
 end else if(hdmi_tx_de && out_width>=832 && out_width<1088 && out_lines>=412 && out_lines<668)begin
  sum_r<=sum_r+hdmi_tx_rdata;sum_g<=sum_g+hdmi_tx_gdata;sum_b<=sum_b+hdmi_tx_bdata;
  if(hdmi_tx_rdata<min_r)min_r<=hdmi_tx_rdata;
  if(hdmi_tx_gdata<min_g)min_g<=hdmi_tx_gdata;
  if(hdmi_tx_bdata<min_b)min_b<=hdmi_tx_bdata;
  if(hdmi_tx_rdata>max_r)max_r<=hdmi_tx_rdata;
  if(hdmi_tx_gdata>max_g)max_g<=hdmi_tx_gdata;
  if(hdmi_tx_bdata>max_b)max_b<=hdmi_tx_bdata;
 end
end
// Post-filter frame boundary measurement, independent of image arithmetic.
reg filter_vs_q=0,filter_hs_q=0;
reg[23:0] filter_words=0;reg[11:0] filter_lines=0,filter_width=0,filter_max=0;
reg[7:0] filter_late=0;reg[59:0] filter_geometry=0;
always @(posedge i_mipi_rx_pclk)begin
 filter_vs_q<=fov_vs;filter_hs_q<=fov_hs;
 if(!vid_rst_n || (fov_vs && !filter_vs_q))begin
  filter_words<=0;filter_lines<=0;filter_width<=0;filter_max<=0;filter_late<=0;
 end else begin
  if(fov_valid)begin filter_words<=filter_words+1'b1;filter_width<=filter_width+1'b1;
   if(!fov_vs && filter_late!=255)filter_late<=filter_late+1'b1;
  end
  if(filter_hs_q && !fov_hs)begin
   filter_lines<=filter_lines+1'b1;if(filter_width>filter_max)filter_max<=filter_width;filter_width<=0;
  end
  if(filter_vs_q && !fov_vs)filter_geometry<={filter_words,filter_lines,filter_max,filter_late,4'h1};
 end
end
wire [119:0] diag_code_hold={rx_geometry,filter_geometry};
reg [119:0] diag_code_meta=0,diag_code_sync=0;
always @(posedge jtag_diag_DRCK) begin
 diag_code_meta<=diag_code_hold;
 diag_code_sync<=diag_code_meta;
 diag_video_meta<=rgb_min_status;
 diag_video_sync<=diag_video_meta;
 diag_meta<={diag_frame_gray,diag_core_gray,i_arstn,i_pll_locked,pll_locked,user_pll_locked,w_arstn,vid_rst_n,pattern_reset_sync[1],1'b0};
 diag_sync<=diag_meta;
 if(jtag_diag_CAPTURE)begin
  // Page addresses are disjoint; only profile selection within a page has priority.
  case(feature_diag_page)
   6'd1: begin
     diag_shift<={32'h56495331,32'h26091715,feature_status,memory_write_errors,feature_edges_hold,feature_frames};
   end
   6'd2: begin
     diag_shift<={32'h56495331,32'h26091725,feature_status,source_checksum_hold,memory_display_id,memory_capture_id};
   end
   6'd3: begin
    if(IMAGE_DEBUG!=1) diag_shift<={32'h56495331,(32'h26100600+{26'b0,feature_diag_page}),feature_status,((IMAGE_DEBUG&&feature_diag_page==3)?{17'b0,color_order,76'b0}:96'b0)};
    else diag_shift<={32'h56495331,32'h26091737,feature_status,{raw_busy,16'b0,color_order,raw_read_addr},raw_read_data,raw_sequence};
   end
   6'd4: begin
    if(IMAGE_DEBUG!=1) diag_shift<={32'h56495331,(32'h26100600+{26'b0,feature_diag_page}),feature_status,((IMAGE_DEBUG&&feature_diag_page==3)?{17'b0,color_order,76'b0}:96'b0)};
    else diag_shift<={32'h56495331,32'h26091745,feature_status,pre_gamma_sums};
   end
   6'd5: begin
    if(IMAGE_DEBUG!=1) diag_shift<={32'h56495331,(32'h26100600+{26'b0,feature_diag_page}),feature_status,((IMAGE_DEBUG&&feature_diag_page==3)?{17'b0,color_order,76'b0}:96'b0)};
    else diag_shift<={32'h56495331,32'h26091755,feature_status,post_gamma_sums};
   end
   6'd6: begin
    if(IMAGE_DEBUG!=1) diag_shift<={32'h56495331,(32'h26100600+{26'b0,feature_diag_page}),feature_status,((IMAGE_DEBUG&&feature_diag_page==3)?{17'b0,color_order,76'b0}:96'b0)};
    else diag_shift<={32'h56495331,32'h26091765,feature_status,display_color_sums};
   end
   6'd7: begin
    if(IMAGE_DEBUG!=1) diag_shift<={32'h56495331,(32'h26100600+{26'b0,feature_diag_page}),feature_status,((IMAGE_DEBUG&&feature_diag_page==3)?{17'b0,color_order,76'b0}:96'b0)};
    else diag_shift<={32'h56495331,32'h26091775,feature_status,post_gamma_clips};
   end
   6'd8: begin
     diag_shift<={32'h56495331,32'h26091785,feature_status,wb_r,wb_g,wb_b,13'b0,sobel_threshold,canny_threshold,canny_effective_threshold,tone_mode};
   end
   6'd9: begin
     diag_shift<={32'h56495331,32'h26091909,feature_status,sensor_seq,sensor_addr,sensor_readback,4'b0,sensor_busy,sensor_fault,sensor_ack,sensor_req,phy_status_core};
   end
   6'd10: begin
     diag_shift<={32'h56495331,32'h260919a6,feature_status,highlight_hits_hold,shape_status};
   end
   6'd11: begin
     diag_shift<={32'h56495331,32'h260917b5,feature_status,ae_applied,ae_request,ae_updates,ae_readback,20'b0,ae_shadow,ae_enable,ae_busy,ae_fault};
   end
   6'd12: begin
     diag_shift<={32'h56495331,32'h260917c5,feature_status,ae_sum,ae_ncenter,ae_ntotal,ae_nclip,14'b0,ae_decision};
   end
   6'd13: begin
     diag_shift<={32'h56495331,32'h2609190d,feature_status,camera_frames,rx_geometry,4'b0};
   end
   6'd14: begin
     diag_shift<={32'h56495331,32'h2609190e,feature_status,fov_overruns,filter_geometry,4'b0};
   end
   6'd15: begin
    if(x3_profile_view) diag_shift<={32'h56495331,32'h2610070f,feature_status,x3_frame,x3_gray_sum,32'd148500000};
    else if(probe_csi_view) diag_shift<={32'h56495331,32'h2609192f,feature_status,probe_de_count,probe_hs_count,probe_error_seen,mipi_debug_out[15:0]};
    else diag_shift<={32'h56495331,32'h2609191f,feature_status,cam_byte_core,cam_lp00_entries,cam_clock_peak_hold,cam_clock_delta};
   end
   6'd16: begin
     diag_shift<={32'h56495331,32'h26100410,feature_status,{canny_probe_busy,canny_probe_hold,canny_probe_req,canny_probe_ack,16'b0,canny_probe_read_address},canny_probe_data,canny_completed};
   end
   6'd17: begin
     diag_shift<={32'h56495331,32'h26100411,feature_status,canny_completed,{canny_noise_mean,canny_noise_valid,feature_median,11'b0,canny_effective_threshold},memory_display_id};
   end
   6'd18: begin
     diag_shift<={32'h56495331,32'h26100412,feature_status,roi_view_frame,roi_view_config,{roi_view_enable,roi_frame_ok,roi_hold_valid,roi_freeze,roi_render_busy,roi_render_pending,roi_capture_active,roi_config_busy,roi_config_error,roi_render_error,roi_scan_error,roi_commit_rejected,20'b0}};
   end
   6'd19: begin
     diag_shift<={32'h56495331,32'h26100413,feature_status,roi_x,roi_y,roi_w,roi_h,roi_dw,roi_dh};
   end
   6'd20: begin
     diag_shift<={32'h56495331,32'h26100414,feature_status,roi_capture_discard,roi_bad_frames,roi_cycles};
   end
   6'd21: begin
     diag_shift<={32'h56495331,32'h26100415,feature_status,roi_requested_id,roi_commit_id,roi_rejected_id};
   end
   6'd22: begin
     diag_shift<={32'h56495331,32'h26100416,feature_status,roi_hold_frame,roi_hold_raw,roi_capture_count};
   end
   6'd23: begin
    if(x3_profile_view) diag_shift<={32'h56495331,(DISPLAY_LATENCY_PROBE?32'h26100717:32'h26100617),x3_display_min,x3_display_max,x3_display_samples,x3_display_unmatched};
    else diag_shift<={32'h56495331,32'h26100417,feature_status,roi_posx,roi_posy,roi_display_width,roi_display_height,roi_misses};
   end
   6'd24: begin
    if(x3_profile_view) diag_shift<={32'h56495331,32'h26100718,feature_status,x3_frame,x3_pixels,x3_edge_count};
    else diag_shift<={32'h56495331,32'h26100418,feature_status,16'd480,16'd270,canny_coarse_edges,canny_display_edges};
   end
   6'd25: begin
    if(x3_profile_view) diag_shift<={32'h56495331,32'h26100719,feature_status,x3_pipeline_cycles,x3_semantic_min,x3_semantic_max};
    else diag_shift<={32'h56495331,32'h26100419,feature_status,canny_analysis_cycles,canny_analysis_passes,canny_analysis_weak};
   end
   6'd26: begin
    if(!IMAGE_DEBUG) diag_shift<={32'h56495331,(32'h26100600+{26'b0,feature_diag_page}),feature_status,((IMAGE_DEBUG&&feature_diag_page==3)?{17'b0,color_order,76'b0}:96'b0)};
    else diag_shift<={32'h56495331,(feature_diag_page==26?32'h2610051a:32'h2610051b),snapshot_frame,snapshot_config,snapshot_sequence,snapshot_status};
   end
   6'd27: begin
    if(!IMAGE_DEBUG) diag_shift<={32'h56495331,(32'h26100600+{26'b0,feature_diag_page}),feature_status,((IMAGE_DEBUG&&feature_diag_page==3)?{17'b0,color_order,76'b0}:96'b0)};
    else diag_shift<={32'h56495331,(feature_diag_page==26?32'h2610051a:32'h2610051b),snapshot_frame,snapshot_config,snapshot_sequence,snapshot_status};
   end
   6'd28: begin
     diag_shift<={32'h56495331,32'h2610051c,feature_status,32'd1920,32'd1080,(IMAGE_DEBUG?32'd24:32'd0)};
   end
   6'd29: begin
     diag_shift<={32'h56495331,(SAPPHIRE_ENABLE?32'h2610081d:32'h2610051d),flyhash_epoch,flyhash_frame,flyhash_config,flyhash_status};
   end
   6'd30: begin
    if(fly_profile_view) diag_shift<={32'h56495331,32'h26100720,flyhash_firmware_state,flyhash_full_cycles,32'd100000000,{31'b0,(SAPPHIRE_ENABLE!=0)}};
    else if(SAPPHIRE_ENABLE) diag_shift<={32'h56495331,32'h2610081e,32'h07620000,32'h07620100,flyhash_firmware_state,flyhash_full_cycles};
    else if(fly_feature_view) diag_shift<={32'h56495331,(32'h26100520+{30'b0,fly_feature_quarter}),fly_feature_probe};
    else diag_shift<={32'h56495331,32'h2610051e,flyhash_result[127:0]};
   end
   6'd31: begin
    if(SAPPHIRE_ENABLE) diag_shift<={32'h56495331,32'h2610083f,ai_age,ai_enabled,ai_match,ai_result[13:0],ai_result[63:32],ai_result[127:96],ai_context};
    else diag_shift<={32'h56495331,32'h2610051f,flyhash_result[255:128]};
   end
   6'd32: begin
    if(SAPPHIRE_ENABLE) diag_shift<={32'h56495331,32'h26103144,feature_status,control_ui[23:15],model_state,control_ui[14:0],roi_requested_id,roi_commit_id};
    else diag_shift<={32'h56495331,32'h26091707,feature_status,memory_capture_id,memory_display_id,canny_completed};
   end
   6'd33:diag_shift<={32'h56495331,32'h26103121,feature_status,camera_source_frame,rgb_capture_debug,pool_capture_debug};
   default: diag_shift<={32'h56495331,32'h26091707,feature_status,memory_capture_id,memory_display_id,canny_completed};
  endcase
 end
 else if(jtag_diag_SHIFT)diag_shift<={jtag_diag_TDI,diag_shift[191:1]};
end
assign jtag_diag_TDO=(feature_diag_page==27&&snapshot_payload_phase)?snapshot_payload_tdo:diag_shift[0];

endmodule
