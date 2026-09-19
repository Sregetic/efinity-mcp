
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
module ti60f225_oob_top #(

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
localparam WR_FIFO_DEPTH  = 1024;
localparam RD_FIFO_DEPTH  = 1024;

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
assign pll_inst1_RSTN  		= i_arstn;
assign USER_PLL_RSTN      		= i_arstn;
assign mipi_dsi_tx_pll_RSTN 	= i_arstn;
assign DDR3_PLL_RSTN 		= i_arstn;
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
	
wire [15:0] mipi_debug_out;
		

		csi_rx_controller inst_efx_csi2_rx
		(
              .reset_n			(i_arstn),
              .clk				(i_mipi_clk),
              .reset_byte_HS_n	(i_arstn),
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
              .u_dly_enable_D		(),
              .u_dly_inc_D		       (),
              
              .axi_clk			(1'b0),
              .axi_reset_n		       (1'b0),
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
              .mipi_debug_out(mipi_debug_out)
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


reg [12:0] i2c_rst_cnt = '0;

always @( posedge CLK_5M or negedge w_arstn )
begin
    if( !w_arstn )
       i2c_rst_cnt <= 'd0;
    else 
       i2c_rst_cnt <= i2c_rst_cnt[12] ? i2c_rst_cnt : i2c_rst_cnt + 1'b1;
end
wire i2c_rst_n = i2c_rst_cnt[12];

wire ae_req,ae_ack,ae_fault,ae_busy;wire[15:0]ae_request,ae_applied,ae_updates;wire[23:0]ae_readback;
wire[31:0]ae_sum;wire[15:0]ae_ncenter,ae_ntotal,ae_nclip;wire[1:0]ae_decision;wire ae_shadow;
i2c_master_ctrl_top u2_i2c_master_ctrl_top(
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
assign o_cam_rst_p = ~w_arstn;
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
wire fov_vs,fov_hs,fov_valid;wire[31:0]fov_data;
bayer_fov_reduce fov_reduce(.clk(i_mipi_rx_pclk),.rst_n(vid_rst_n),.vs(w_mipi_rx_vs),.hs(w_mipi_rx_hs),.valid(w_mipi_rx_de),
 .data({w_mipi_rx_data[9:2],w_mipi_rx_data[19:12],w_mipi_rx_data[29:22],w_mipi_rx_data[39:32]}),
 .o_vs(fov_vs),.o_hs(fov_hs),.o_valid(fov_valid),.o_data(fov_data));
wire[31:0] memory_capture_id,memory_display_id,memory_write_errors;wire[2:0]memory_history_count;
// IMX219
  frame_buffer #(
.I_VID_WIDTH         (32),
.O_VID_WIDTH         (16),
.START_ADDR          (32'h00000        ),
.AXI_DATA_WIDTH      ( AXI_DATA_WIDTH	),
.AXI_ADDR_WIDTH      ( AXI_ADDR_WIDTH	),
.WR_FIFO_DEPTH	      ( 1024		),    
.RD_FIFO_DEPTH 	      ( 1024 	),
.BURST_LEN  	       (127),
.FB_NUM	            (8),
.MAX_VID_WIDTH	    (MAX_HRES/4) ,
.MAX_VID_HIGHT	    (1080) 


)checker0(
 .memory_mode(memory_mode),.history_index(history_index),.bresp(s_axi_bresp),
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

       .awid			(s_axi_awid	),      
       .awaddr		(s_axi_awaddr	),
       .awlen			(s_axi_awlen	),
       .awsize		(s_axi_awsize	),
       .awburst		(s_axi_awburst),
       .awprot    (s_axi_awprot ),
       .awcache   (s_axi_awcache),
       .awlock		(s_axi_awlock	),
       .awvalid		(s_axi_awvalid),
       .awready		(s_axi_awready),

       .arid			(s_axi_arid	  ),
       .araddr		(s_axi_araddr	),
       .arlen			(s_axi_arlen	),
       .arsize		(s_axi_arsize	),
       .arburst 	(s_axi_arburst),

       .arprot    (s_axi_arprot ),
       .arcache   (s_axi_arcache),
       .arlock 		(s_axi_arlock	),
       .arvalid		(s_axi_arvalid),
       .arready		(s_axi_arready),

       .wdata			(s_axi_wdata	),
       .wstrb			(s_axi_wstrb	),
       .wlast			(s_axi_wlast	),
       .wvalid		(s_axi_wvalid	),
       .wready		(s_axi_wready	),


       .rid			  (s_axi_rid	),
       .rdata			(s_axi_rdata	),
       .rlast			(s_axi_rlast	),
       .rvalid 		(s_axi_rvalid	),
       .rready		(s_axi_rready	),
       .rresp			(s_axi_rresp	),

       .bid			  (s_axi_bid	),
       .bvalid		(s_axi_bvalid	),
       .bready	  (s_axi_bready	)
);


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
reg[15:0]wb_r=162,wb_g=161,wb_b=256,wb_pr=162,wb_pg=161,wb_pb=256;
reg ae_enable=1;reg[15:0]ae_manual=444;
reg[2:0]gain_cmd_sync=0;reg gain_cmd_seen=0,gain_vq=0;
always @(posedge vid_clk_dvi2)begin
 gain_cmd_sync<={gain_cmd_sync[1:0],feature_command_toggle};gain_cmd_seen<=gain_cmd_sync[2];gain_vq<=ch0_vs;
 if(gain_cmd_sync[2]!=gain_cmd_seen)case(feature_command[31:24])
  8:wb_pr<=feature_command[15:0];9:wb_pg<=feature_command[15:0];10:wb_pb<=feature_command[15:0];11:ae_enable<=feature_command[0];12:ae_manual<=feature_command[15:0];default:;
 endcase
 if(ch0_vs&&!gain_vq)begin wb_r<=wb_pr;wb_g<=wb_pg;wb_b<=wb_pb;end
end

camera_auto_exposure auto_exposure(.clk(vid_clk_dvi2),.rst_n(vid_rst_n),.vs(ch0_vs),.de(ch0_de),.pixels({ch0_b,ch0_g}),
 .capture_id(memory_display_id),.enable(ae_enable),.manual_value(ae_manual),.ack_toggle(ae_ack),.fault(ae_fault),
 .req_toggle(ae_req),.request(ae_request),.center_sum(ae_sum),.center_count(ae_ncenter),.total_count(ae_ntotal),
 .clip_count(ae_nclip),.decision(ae_decision),.shadow_boost(ae_shadow));

debayer_top_2to1 debayer_top
(
	.in_pclk		  (vid_clk_dvi2),//(i_mipi_rx_pclk ),
	.in_rstn		  (vid_rst_n	),
	
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
reg rgb_vs_r = 'd0;
always @( posedge hdmi_tx_slow_clk )
begin
  rgb_vs_r <= rgb_vs;
end
assign pos_vs = {rgb_vs_r,rgb_vs} == 2'b01;
reg vid_cnt = 'd0;
reg [7:0] hdmi_tx_rdata ;
reg [7:0] hdmi_tx_gdata ;
reg [7:0] hdmi_tx_bdata ;
reg hdmi_tx_vs;
reg hdmi_tx_hs;
reg hdmi_tx_de;
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
wire                            video_hs;
wire                            video_vs;
wire                            video_de;
wire[7:0]                       video_r;
wire[7:0]                       video_g;
wire[7:0]                       video_b;

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
wire gamma_vs;
wire gamma_sel = 1'b1;
wire gamma_vio_unused;
wire[7:0]legacy_rdata,legacy_gdata,legacy_bdata;
wire legacy_valid,legacy_hs,legacy_vs;
wire[23:0]chroma_rgb,linear_rgb,plain_chroma_rgb;wire highlight_active;
reg[23:0]legacy_delay1=0,legacy_delay2=0,legacy_delay3=0;
always @(posedge hdmi_tx_slow_clk)begin legacy_delay1<={legacy_rdata,legacy_gdata,legacy_bdata};legacy_delay2<=legacy_delay1;legacy_delay3<=legacy_delay2;end
assign {gamma_rdata,gamma_gdata,gamma_bdata}=(tone_mode==0)?linear_rgb:((tone_mode==1)?legacy_delay3:((tone_mode==2)?plain_chroma_rgb:chroma_rgb));
rgb_chroma_tone chroma_tone(.clk(hdmi_tx_slow_clk),.rst_n(vid_rst_n),.de(den_de),.hs(den_hs),.vs(den_vs),
 .r(den_r),.g(den_g),.b(den_b),.ode(gamma_valid),.ohs(gamma_hs),.ovs(gamma_vs),.rgb(chroma_rgb),.linear_rgb(linear_rgb),.gain_r(wb_b),.gain_g(wb_g),.gain_b(wb_r),.plain_rgb(plain_chroma_rgb),.highlight_active(highlight_active),.shadow_boost(ae_shadow));

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
 .de(hdmi_tx_de),.hs(hdmi_tx_hs),.vs(hdmi_tx_vs),.r(hdmi_tx_rdata),.g(hdmi_tx_gdata),.b(hdmi_tx_bdata),
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
wire [7:0] pattern_r,pattern_g,pattern_b;
wire pattern_hs,pattern_vs,pattern_de,pattern_frame_pulse;
wire [31:0] pattern_frames;
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
reg [7:0] camera_frames=0;
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
reg[31:0] feature_command=0;reg feature_command_toggle=0;
reg raw_arm_toggle=0;reg[11:0]raw_read_addr=0;
// Read-only RAW snapshot restored for sensor/ISP boundary diagnostics.
wire[31:0]raw_read_data,raw_sequence;wire raw_busy;
raw_snapshot raw_probe(.clk(vid_clk_dvi2),.rst_n(vid_rst_n),.vs(ch0_vs),.de(ch0_de),.pixels({ch0_b,ch0_g}),.arm_toggle(raw_arm_toggle),.read_clk(jtag_diag_DRCK),.read_addr(raw_read_addr),.read_data(raw_read_data),.sequence_id(raw_sequence),.busy(raw_busy));
always @(posedge jtag_diag_UPDATE)begin
 if(diag_shift[63:32]==32'h56495331)begin
 feature_command<=diag_shift[31:0];feature_command_toggle<=~feature_command_toggle;
 if(diag_shift[31:24]==8'h20)raw_arm_toggle<=~raw_arm_toggle;
 if(diag_shift[31:24]==8'h21)raw_read_addr<=diag_shift[11:0];
 end
end
reg[2:0] feature_cmd_sync=0;reg feature_cmd_seen=0;reg[3:0]feature_diag_page=0;
wire feature_cmd_event=feature_cmd_sync[2]!=feature_cmd_seen;
always @(posedge hdmi_tx_slow_clk)begin
 feature_cmd_sync<={feature_cmd_sync[1:0],feature_command_toggle};feature_cmd_seen<=feature_cmd_sync[2];
 if(feature_cmd_event&&feature_command[31:24]==8'h7e)feature_diag_page<=feature_command[3:0];
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
wire[95:0]pre_gamma_sums,post_gamma_sums,display_color_sums,post_gamma_clips,unused_pre_clips,unused_display_clips;
rgb_roi_probe before_gamma_probe(hdmi_tx_slow_clk,vid_rst_n,den_vs,den_de,{den_r,den_g,den_b},pre_gamma_sums,unused_pre_clips);
rgb_roi_probe after_gamma_probe(hdmi_tx_slow_clk,vid_rst_n,gamma_vs,gamma_valid,{gamma_rdata,gamma_gdata,gamma_bdata},post_gamma_sums,post_gamma_clips);
rgb_roi_probe display_color_probe(hdmi_tx_slow_clk,vid_rst_n,gamma_vs,gamma_valid,color_pixel,display_color_sums,unused_display_clips);
wire[2:0] feature_mode,history_index;wire[10:0] feature_threshold;wire feature_median;wire[1:0] memory_mode;
vision_controls feature_controls(.clk(hdmi_tx_slow_clk),.rst_n(vid_rst_n),.vs(gamma_vs),.keys_n(vision_keys_n),
 .cmd_event(feature_cmd_event),.cmd_op(feature_command[31:24]),.cmd_value(feature_command[23:0]),
 .mode(feature_mode),.threshold(feature_threshold),.median_en(feature_median),.memory_mode(memory_mode),.history_index(history_index));
wire[7:0] feature_r,feature_g,feature_b;wire feature_de,feature_hs,feature_vs;
wire[11:0] feature_x,feature_y;wire[10:0] feature_mag;wire feature_edge;
wire canny_pixel,canny_ready,canny_busy,canny_fault;wire[31:0]canny_completed;
vision_canny canny(.clk(hdmi_tx_slow_clk),.rst_n(vid_rst_n),.de(gamma_valid),.hs(gamma_hs),.vs(gamma_vs),
 .r(color_r),.g(color_g),.b(color_b),.high_threshold(feature_threshold),.display_x(feature_x),.display_y(feature_y),
 .edge_pixel(canny_pixel),.ready(canny_ready),.busy(canny_busy),.fault(canny_fault),.completed(canny_completed));
vision_display feature_display(.clk(hdmi_tx_slow_clk),.rst_n(vid_rst_n),.de(gamma_valid),.hs(gamma_hs),.vs(gamma_vs),
 .r(color_r),.g(color_g),.b(color_b),.mode(feature_mode),.threshold(feature_threshold),.median_en(feature_median),
 .memory_mode(memory_mode),.history_index(history_index),.canny_pixel(canny_pixel),.canny_ready(canny_ready),.cx(feature_x),.cy(feature_y),
 .ode(feature_de),.ohs(feature_hs),.ovs(feature_vs),.orr(feature_r),.ogg(feature_g),.obb(feature_b),.debug_mag(feature_mag),.debug_edge(feature_edge));
reg feature_vs_q=0;reg[31:0] feature_edges=0,feature_edges_hold=0,feature_frames=0;
always @(posedge hdmi_tx_slow_clk)begin
 feature_vs_q<=feature_vs;
 if(feature_vs&&!feature_vs_q)begin feature_frames<=feature_frames+1;feature_edges_hold<=feature_edges;feature_edges<=0;end
 else if(feature_de&&feature_edge)feature_edges<=feature_edges+1;
end
reg[31:0]highlight_hits=0,highlight_hits_hold=0;
reg gamma_vs_prev=0;reg[31:0]source_checksum=0,source_checksum_hold=0;
always @(posedge hdmi_tx_slow_clk)begin
 gamma_vs_prev<=gamma_vs;
 if(gamma_vs&&!gamma_vs_prev)begin source_checksum_hold<=source_checksum;source_checksum<=0;highlight_hits_hold<=highlight_hits;highlight_hits<=0;end
 else if(gamma_valid)begin source_checksum<=source_checksum+{8'd0,gamma_rdata,gamma_bdata,gamma_gdata};if(tone_mode==3&&highlight_active)highlight_hits<=highlight_hits+1'b1;end
end
wire[31:0] feature_status={canny_fault,canny_busy,canny_ready,memory_history_count,2'b0,feature_mode,feature_median,memory_mode,history_index,feature_threshold,1'b0,vision_keys_n};
// M0 bypasses feature windows and retains baseline ISP color/timing.
dvi_encoder_pure dvi_encoder_m0
(
	.pixelclk      		(hdmi_tx_slow_clk          ),// system clock
	.rstin         		(`VISION_TEST_PATTERN ? ~pattern_reset_sync[1] : ~vid_rst_n),// reset
	.blue_din (`VISION_TEST_PATTERN ? pattern_b : (feature_mode==0 ? color_b : feature_b)),
	.green_din (`VISION_TEST_PATTERN ? pattern_g : (feature_mode==0 ? color_g : feature_g)),
	.red_din (`VISION_TEST_PATTERN ? pattern_r : (feature_mode==0 ? color_r : feature_r)),
  .de (`VISION_TEST_PATTERN ? pattern_de : (feature_mode==0 ? gamma_valid : feature_de)),
	.hsync (`VISION_TEST_PATTERN ? pattern_hs : (feature_mode==0 ? gamma_hs : feature_hs)),
	.vsync (`VISION_TEST_PATTERN ? pattern_vs : (feature_mode==0 ? gamma_vs : feature_vs)),
	

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
assign jtag_inst1_TDO=user1_id[0];
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
reg [191:0] diag_shift=0;
always @(posedge jtag_diag_DRCK) begin
 diag_code_meta<=diag_code_hold;
 diag_code_sync<=diag_code_meta;
 diag_video_meta<=rgb_min_status;
 diag_video_sync<=diag_video_meta;
 diag_meta<={diag_frame_gray,diag_core_gray,i_arstn,i_pll_locked,pll_locked,user_pll_locked,w_arstn,vid_rst_n,pattern_reset_sync[1],1'b0};
 diag_sync<=diag_meta;
 if(jtag_diag_CAPTURE)begin
  if(feature_diag_page==11)diag_shift<={32'h56495331,32'h260917b5,feature_status,ae_applied,ae_request,ae_updates,ae_readback,20'b0,ae_shadow,ae_enable,ae_busy,ae_fault};
  else if(feature_diag_page==12)diag_shift<={32'h56495331,32'h260917c5,feature_status,ae_sum,ae_ncenter,ae_ntotal,ae_nclip,14'b0,ae_decision};
  else if(feature_diag_page==10)diag_shift<={32'h56495331,32'h260917a5,feature_status,highlight_hits_hold,64'b0};
  else if(feature_diag_page==8)diag_shift<={32'h56495331,32'h26091785,feature_status,wb_r,wb_g,wb_b,46'b0,tone_mode};
  else if(feature_diag_page==4)diag_shift<={32'h56495331,32'h26091745,feature_status,pre_gamma_sums};
  else if(feature_diag_page==5)diag_shift<={32'h56495331,32'h26091755,feature_status,post_gamma_sums};
  else if(feature_diag_page==6)diag_shift<={32'h56495331,32'h26091765,feature_status,display_color_sums};
  else if(feature_diag_page==7)diag_shift<={32'h56495331,32'h26091775,feature_status,post_gamma_clips};
  else if(feature_diag_page==3)diag_shift<={32'h56495331,32'h26091737,feature_status,{raw_busy,16'b0,color_order,raw_read_addr},raw_read_data,raw_sequence};
  else if(feature_diag_page==1)diag_shift<={32'h56495331,32'h26091715,feature_status,memory_write_errors,feature_edges_hold,feature_frames};
  else if(feature_diag_page==2)diag_shift<={32'h56495331,32'h26091725,feature_status,source_checksum_hold,memory_display_id,memory_capture_id};
  else diag_shift<={32'h56495331,32'h26091707,feature_status,memory_capture_id,memory_display_id,canny_completed};
 end
 else if(jtag_diag_SHIFT)diag_shift<={jtag_diag_TDI,diag_shift[191:1]};
end
assign jtag_diag_TDO=diag_shift[0];

endmodule
