`timescale 1ns/1ps
// Packed16 capture -> leased source -> ROI render -> double-buffered result -> scan.
// Optional legacy client precedes the optional CPU client on the same DDR port.
module frame_memory_system #(
 parameter MAX_LINE_PIXELS=1920,BANK_SHIFT=22,SCAN_BURST_BEATS=16,CPU_ENABLED=0,LEGACY_ENABLED=1,
 parameter SOURCE_BANKS=4,BANK_BITS=$clog2(SOURCE_BANKS),KEEP_HISTORY=0,COMPUTE_ENABLED=0,DIRECT_SCAN=0,
 parameter[31:0]SOURCE_BASE=32'h02000000,RESULT_BASE=32'h03000000
)(
 input clk,rst_n,capture_abort,scan_enable,scan_urgent,
 input direct_scan,input[1:0]memory_mode,input[2:0]history_index,
 output[2:0]history_count,output reg[31:0]capture_frame_id=0,
 input capture_valid,output capture_ready,input[31:0]capture_config_id,
 input[15:0]src_width,src_height,input[31:0]src_stride_bytes,
 input capture_pixel_valid,output capture_pixel_ready,input[31:0]capture_pixel_data,
 input capture_pixel_sof,capture_pixel_eol,capture_pixel_eof,
 output capture_done,capture_error,
 input job_valid,output job_ready,input freeze_source,release_source,input[31:0]job_config_id,
 input[15:0]roi_x,roi_y,roi_w,roi_h,dst_width,dst_height,input[31:0]dst_stride_bytes,
    input wire compute_acquire_valid,compute_latest,compute_release,
    input wire[31:0]compute_request_frame_id,
    output wire compute_acquire_ready,compute_missing,compute_hold_valid,
    output wire[BANK_BITS-1:0]compute_hold_bank,
    output wire[31:0]compute_hold_frame_id,compute_hold_config_id,
 input analysis_acquire_valid,output analysis_acquire_ready,input analysis_release,
 output analysis_hold_valid,output[BANK_BITS-1:0]analysis_hold_bank,
 output[31:0]analysis_hold_frame_id,analysis_hold_config_id,
 // vblank means the downstream scanout has consumed every pixel of its old frame.
 input vblank,
 output display_valid,output[31:0]display_base,display_frame_id,display_config_id,
 output[15:0]display_width,display_height,output[31:0]display_stride_bytes,
 output render_done,render_error,render_busy,render_pending,
 output[31:0]last_cycles,deadline_misses,
 output scan_source_mode,
 output scan_pixel_valid,input scan_pixel_ready,output[31:0]scan_pixel_data,
 output[1:0]scan_pixel_keep,output scan_pixel_sof,scan_pixel_eol,scan_pixel_eof,
 output[31:0]scan_pixel_frame_id,scan_pixel_config_id,output scan_busy,scan_done,scan_error,
 input[5:0]legacy_arid,
 input[31:0]legacy_araddr,
 input[7:0]legacy_arlen,
 input[2:0]legacy_arsize,
 input[1:0]legacy_arburst,
 input legacy_arvalid,
 output legacy_arready,
 output[127:0]legacy_rdata,
 output[1:0]legacy_rresp,
 output[5:0]legacy_rid,
 output legacy_rlast,
 output legacy_rvalid,
 input legacy_rready,
 input[5:0]legacy_awid,
 input[31:0]legacy_awaddr,
 input[7:0]legacy_awlen,
 input[2:0]legacy_awsize,
 input[1:0]legacy_awburst,
 input legacy_awvalid,
 output legacy_awready,
 input[127:0]legacy_wdata,
 input[15:0]legacy_wstrb,
 input legacy_wlast,
 input legacy_wvalid,
 output legacy_wready,
 output[1:0]legacy_bresp,
 output[5:0]legacy_bid,
 output legacy_bvalid,
 input legacy_bready,
 input[5:0]dma_arid,dma_awid,
 input[31:0]dma_araddr,dma_awaddr,input[7:0]dma_arlen,dma_awlen,
 input[2:0]dma_arsize,dma_awsize,input[1:0]dma_arburst,dma_awburst,
 input dma_arvalid,dma_awvalid,output dma_arready,dma_awready,
 output[127:0]dma_rdata,output[1:0]dma_rresp,output dma_rlast,dma_rvalid,input dma_rready,
 input[127:0]dma_wdata,input[15:0]dma_wstrb,input dma_wlast,dma_wvalid,output dma_wready,
 output[1:0]dma_bresp,output dma_bvalid,input dma_bready,
 input[5:0]cpu_arid,
 input[31:0]cpu_araddr,
 input[7:0]cpu_arlen,
 input[2:0]cpu_arsize,
 input[1:0]cpu_arburst,
 input cpu_arvalid,
 output cpu_arready,
 output[127:0]cpu_rdata,
 output[1:0]cpu_rresp,
 output[5:0]cpu_rid,
 output cpu_rlast,
 output cpu_rvalid,
 input cpu_rready,
 input[5:0]cpu_awid,
 input[31:0]cpu_awaddr,
 input[7:0]cpu_awlen,
 input[2:0]cpu_awsize,
 input[1:0]cpu_awburst,
 input cpu_awvalid,
 output cpu_awready,
 input[127:0]cpu_wdata,
 input[15:0]cpu_wstrb,
 input cpu_wlast,
 input cpu_wvalid,
 output cpu_wready,
 output[1:0]cpu_bresp,
 output[5:0]cpu_bid,
 output cpu_bvalid,
 input cpu_bready,
 output[5:0]m_axi_arid,
 output[31:0]m_axi_araddr,
 output[7:0]m_axi_arlen,
 output[2:0]m_axi_arsize,
 output[1:0]m_axi_arburst,
 output m_axi_arvalid,
 input m_axi_arready,
 input[127:0]m_axi_rdata,
 input[1:0]m_axi_rresp,
 input[5:0]m_axi_rid,
 input m_axi_rlast,
 input m_axi_rvalid,
 output m_axi_rready,
 output[5:0]m_axi_awid,
 output[31:0]m_axi_awaddr,
 output[7:0]m_axi_awlen,
 output[2:0]m_axi_awsize,
 output[1:0]m_axi_awburst,
 output m_axi_awvalid,
 input m_axi_awready,
 output[127:0]m_axi_wdata,
 output[15:0]m_axi_wstrb,
 output m_axi_wlast,
 output m_axi_wvalid,
 input m_axi_wready,
 input[1:0]m_axi_bresp,
 input[5:0]m_axi_bid,
 input m_axi_bvalid,
 output m_axi_bready,
 output source_hold_valid,output[31:0]source_hold_frame_id,source_hold_config_id
 );
 wire[BANK_BITS-1:0]cap_bank;reg[BANK_BITS-1:0]held_cap_bank=0;
 reg[1:0]cap_state=0;
 reg[15:0]cap_width=0,cap_height=0;reg[31:0]cap_stride=0;
 wire[15:0]cap_last_row=src_height-16'd1;
 wire[47:0]cap_offset=src_stride_bytes*cap_last_row;
 wire[63:0]cap_extent={16'd0,cap_offset}+64'(src_width)*2;
 wire cap_bad=src_width==0||src_height==0||src_width[2:0]!=0||src_stride_bytes[3:0]!=0||
  src_stride_bytes<32'(src_width)*2||cap_extent>(64'd1<<BANK_SHIFT);
 wire cap_req_ready,cap_done_ready,writer_ready,writer_done,writer_error,writer_pixel_ready;
 assign capture_ready=cap_state==0&&cap_req_ready&&writer_ready;
 assign capture_done=writer_done||cap_state==3,capture_error=writer_error||cap_state==3;
 assign capture_pixel_ready=cap_state==2&&writer_pixel_ready;
 wire capture_fire=capture_valid&&capture_ready;
 always @(posedge clk)begin
  if(!rst_n)begin cap_state<=0;held_cap_bank<=0;cap_width<=0;cap_height<=0;cap_stride<=0;end
  else case(cap_state)
   0:if(capture_fire)begin
    if(cap_bad)cap_state<=3;
    else begin held_cap_bank<=cap_bank;cap_width<=src_width;cap_height<=src_height;cap_stride<=src_stride_bytes;cap_state<=1;end
   end
   1:if(writer_ready)cap_state<=2;
   2:if(writer_done&&cap_done_ready)cap_state<=0;
   3:cap_state<=0;
  endcase
 end
 localparam BASE_CLIENTS=LEGACY_ENABLED?4:3,DMA_CLIENT=BASE_CLIENTS+CPU_ENABLED,CLIENTS=BASE_CLIENTS+CPU_ENABLED+COMPUTE_ENABLED;
 wire[CLIENTS*6-1:0]b_arid;
 wire[CLIENTS*32-1:0]b_araddr;
 wire[CLIENTS*8-1:0]b_arlen;
 wire[CLIENTS*3-1:0]b_arsize;
 wire[CLIENTS*2-1:0]b_arburst;
 wire[CLIENTS*1-1:0]b_arvalid;
 wire[CLIENTS*1-1:0]b_arready;
 wire[CLIENTS*128-1:0]b_rdata;
 wire[CLIENTS*2-1:0]b_rresp;
 wire[CLIENTS*6-1:0]b_rid;
 wire[CLIENTS*1-1:0]b_rlast;
 wire[CLIENTS*1-1:0]b_rvalid;
 wire[CLIENTS*1-1:0]b_rready;
 wire[CLIENTS*6-1:0]b_awid;
 wire[CLIENTS*32-1:0]b_awaddr;
 wire[CLIENTS*8-1:0]b_awlen;
 wire[CLIENTS*3-1:0]b_awsize;
 wire[CLIENTS*2-1:0]b_awburst;
 wire[CLIENTS*1-1:0]b_awvalid;
 wire[CLIENTS*1-1:0]b_awready;
 wire[CLIENTS*128-1:0]b_wdata;
 wire[CLIENTS*16-1:0]b_wstrb;
 wire[CLIENTS*1-1:0]b_wlast;
 wire[CLIENTS*1-1:0]b_wvalid;
 wire[CLIENTS*1-1:0]b_wready;
 wire[CLIENTS*2-1:0]b_bresp;
 wire[CLIENTS*6-1:0]b_bid;
 wire[CLIENTS*1-1:0]b_bvalid;
 wire[CLIENTS*1-1:0]b_bready;
 generate if(LEGACY_ENABLED)begin:legacy_client
 assign b_arid[18+:6]=legacy_arid;
 assign b_araddr[96+:32]=legacy_araddr;
 assign b_arlen[24+:8]=legacy_arlen;
 assign b_arsize[9+:3]=legacy_arsize;
 assign b_arburst[6+:2]=legacy_arburst;
 assign b_arvalid[3]=legacy_arvalid;
 assign legacy_arready=b_arready[3];
 assign legacy_rdata=b_rdata[384+:128];
 assign legacy_rresp=b_rresp[6+:2];
 assign legacy_rid=b_rid[18+:6];
 assign legacy_rlast=b_rlast[3];
 assign legacy_rvalid=b_rvalid[3];
 assign b_rready[3]=legacy_rready;
 assign b_awid[18+:6]=legacy_awid;
 assign b_awaddr[96+:32]=legacy_awaddr;
 assign b_awlen[24+:8]=legacy_awlen;
 assign b_awsize[9+:3]=legacy_awsize;
 assign b_awburst[6+:2]=legacy_awburst;
 assign b_awvalid[3]=legacy_awvalid;
 assign legacy_awready=b_awready[3];
 assign b_wdata[384+:128]=legacy_wdata;
 assign b_wstrb[48+:16]=legacy_wstrb;
 assign b_wlast[3]=legacy_wlast;
 assign b_wvalid[3]=legacy_wvalid;
 assign legacy_wready=b_wready[3];
 assign legacy_bresp=b_bresp[6+:2];
 assign legacy_bid=b_bid[18+:6];
 assign legacy_bvalid=b_bvalid[3];
 assign b_bready[3]=legacy_bready;
 end else begin:no_legacy
 assign legacy_arready=0;
 assign legacy_rdata=0;
 assign legacy_rresp=0;
 assign legacy_rid=0;
 assign legacy_rlast=0;
 assign legacy_rvalid=0;
 assign legacy_awready=0;
 assign legacy_wready=0;
 assign legacy_bresp=0;
 assign legacy_bid=0;
 assign legacy_bvalid=0;
 end endgenerate
 generate if(COMPUTE_ENABLED)begin:compute_client
 assign b_arid[DMA_CLIENT*6+:6]=dma_arid;
 assign b_araddr[DMA_CLIENT*32+:32]=dma_araddr;
 assign b_arlen[DMA_CLIENT*8+:8]=dma_arlen;
 assign b_arsize[DMA_CLIENT*3+:3]=dma_arsize;
 assign b_arburst[DMA_CLIENT*2+:2]=dma_arburst;
 assign b_arvalid[DMA_CLIENT]=dma_arvalid;
 assign b_rready[DMA_CLIENT]=dma_rready;
 assign b_awid[DMA_CLIENT*6+:6]=dma_awid;
 assign b_awaddr[DMA_CLIENT*32+:32]=dma_awaddr;
 assign b_awlen[DMA_CLIENT*8+:8]=dma_awlen;
 assign b_awsize[DMA_CLIENT*3+:3]=dma_awsize;
 assign b_awburst[DMA_CLIENT*2+:2]=dma_awburst;
 assign b_awvalid[DMA_CLIENT]=dma_awvalid;
 assign b_wdata[DMA_CLIENT*128+:128]=dma_wdata;
 assign b_wstrb[DMA_CLIENT*16+:16]=dma_wstrb;
 assign b_wlast[DMA_CLIENT]=dma_wlast;
 assign b_wvalid[DMA_CLIENT]=dma_wvalid;
 assign b_bready[DMA_CLIENT]=dma_bready;
 assign dma_arready=b_arready[DMA_CLIENT];
 assign dma_rdata=b_rdata[DMA_CLIENT*128+:128];
 assign dma_rresp=b_rresp[DMA_CLIENT*2+:2];
 assign dma_rlast=b_rlast[DMA_CLIENT];
 assign dma_rvalid=b_rvalid[DMA_CLIENT];
 assign dma_awready=b_awready[DMA_CLIENT];
 assign dma_wready=b_wready[DMA_CLIENT];
 assign dma_bresp=b_bresp[DMA_CLIENT*2+:2];
 assign dma_bvalid=b_bvalid[DMA_CLIENT];
 end else begin:no_compute_client
 assign dma_arready=0;
 assign dma_rdata=0;
 assign dma_rresp=0;
 assign dma_rlast=0;
 assign dma_rvalid=0;
 assign dma_awready=0;
 assign dma_wready=0;
 assign dma_bresp=0;
 assign dma_bvalid=0;
 end endgenerate
 generate if(CPU_ENABLED)begin:cpu_client
 assign b_arid[BASE_CLIENTS*6+:6]=cpu_arid;
 assign b_araddr[BASE_CLIENTS*32+:32]=cpu_araddr;
 assign b_arlen[BASE_CLIENTS*8+:8]=cpu_arlen;
 assign b_arsize[BASE_CLIENTS*3+:3]=cpu_arsize;
 assign b_arburst[BASE_CLIENTS*2+:2]=cpu_arburst;
 assign b_arvalid[BASE_CLIENTS]=cpu_arvalid;
 assign cpu_arready=b_arready[BASE_CLIENTS];
 assign cpu_rdata=b_rdata[BASE_CLIENTS*128+:128];
 assign cpu_rresp=b_rresp[BASE_CLIENTS*2+:2];
 assign cpu_rid=b_rid[BASE_CLIENTS*6+:6];
 assign cpu_rlast=b_rlast[BASE_CLIENTS];
 assign cpu_rvalid=b_rvalid[BASE_CLIENTS];
 assign b_rready[BASE_CLIENTS]=cpu_rready;
 assign b_awid[BASE_CLIENTS*6+:6]=cpu_awid;
 // Sapphire BMB->AXI already expands data/strobes and SIZE to128bits but keeps
 // the original byte address. DDR consumes the aligned beat plus its strobe.
 assign b_awaddr[BASE_CLIENTS*32+:32]={cpu_awaddr[31:4],4'b0};
 assign b_awlen[BASE_CLIENTS*8+:8]=cpu_awlen;
 assign b_awsize[BASE_CLIENTS*3+:3]=cpu_awsize;
 assign b_awburst[BASE_CLIENTS*2+:2]=cpu_awburst;
 assign b_awvalid[BASE_CLIENTS]=cpu_awvalid;
 assign cpu_awready=b_awready[BASE_CLIENTS];
 assign b_wdata[BASE_CLIENTS*128+:128]=cpu_wdata;
 assign b_wstrb[BASE_CLIENTS*16+:16]=cpu_wstrb;
 assign b_wlast[BASE_CLIENTS]=cpu_wlast;
 assign b_wvalid[BASE_CLIENTS]=cpu_wvalid;
 assign cpu_wready=b_wready[BASE_CLIENTS];
 assign cpu_bresp=b_bresp[BASE_CLIENTS*2+:2];
 assign cpu_bid=b_bid[BASE_CLIENTS*6+:6];
 assign cpu_bvalid=b_bvalid[BASE_CLIENTS];
 assign b_bready[BASE_CLIENTS]=cpu_bready;
 end else begin:no_cpu
 assign cpu_arready=0;
 assign cpu_rdata=0;
 assign cpu_rresp=0;
 assign cpu_rid=0;
 assign cpu_rlast=0;
 assign cpu_rvalid=0;
 assign cpu_awready=0;
 assign cpu_wready=0;
 assign cpu_bresp=0;
 assign cpu_bid=0;
 assign cpu_bvalid=0;
 end endgenerate
 assign b_arid[0+:6]=0,b_awid[0+:6]=0;
 assign b_arid[6+:6]=0,b_awid[6+:6]=0;
 assign b_arid[12+:6]=0,b_awid[12+:6]=0;
 assign b_araddr[0+:32]=0;
 assign b_arlen[0+:8]=0;
 assign b_arsize[0+:3]=0;
 assign b_arburst[0+:2]=0;
 assign b_arvalid[0]=0;
 assign b_rready[0]=0;
 assign b_awaddr[64+:32]=0;
 assign b_awlen[16+:8]=0;
 assign b_awsize[6+:3]=0;
 assign b_awburst[4+:2]=0;
 assign b_awvalid[2]=0;
 assign b_wdata[256+:128]=0;
 assign b_wstrb[32+:16]=0;
 assign b_wlast[2]=0;
 assign b_wvalid[2]=0;
 assign b_bready[2]=0;
 axi_frame_writer capture_dma(.clk(clk),.rst_n(rst_n),.abort(capture_abort),
  .job_valid(cap_state==1),.job_ready(writer_ready),
  .base_addr(SOURCE_BASE+(32'(held_cap_bank)<<BANK_SHIFT)),
  .dst_width(cap_width),.dst_height(cap_height),.stride_bytes(cap_stride),
  .pixel_valid(capture_pixel_valid&&cap_state==2),.pixel_ready(writer_pixel_ready),
  .pixel_data(capture_pixel_data),.pixel_keep(2'b11),
  .pixel_sof(capture_pixel_sof),.pixel_eol(capture_pixel_eol),.pixel_eof(capture_pixel_eof),
  .done(writer_done),.error(writer_error),
  .m_axi_awaddr(b_awaddr[0+:32]),
  .m_axi_awlen(b_awlen[0+:8]),
  .m_axi_awsize(b_awsize[0+:3]),
  .m_axi_awburst(b_awburst[0+:2]),
  .m_axi_awvalid(b_awvalid[0]),
  .m_axi_awready(b_awready[0]),
  .m_axi_wdata(b_wdata[0+:128]),
  .m_axi_wstrb(b_wstrb[0+:16]),
  .m_axi_wlast(b_wlast[0]),
  .m_axi_wvalid(b_wvalid[0]),
  .m_axi_wready(b_wready[0]),
  .m_axi_bresp(b_bresp[0+:2]),
  .m_axi_bvalid(b_bvalid[0]),
  .m_axi_bready(b_bready[0]));
 reg[1:0]mode_meta=0,mode_core=0,previous_mode=0;
 reg[2:0]index_meta=0,index_core=0,play=0;reg[5:0]history_tick=0;
 always @(posedge clk)begin
  mode_meta<=memory_mode;mode_core<=mode_meta;index_meta<=history_index;index_core<=index_meta;
  previous_mode<=mode_core;
  if(!rst_n)begin mode_meta<=0;mode_core<=0;index_meta<=0;index_core<=0;previous_mode<=0;play<=0;history_tick<=0;end
  else if(mode_core!=previous_mode)begin play<=0;history_tick<=0;end
  else if(vblank)begin
   history_tick<=history_tick==59?0:history_tick+1'b1;
   if(history_tick==29||history_tick==59)play<=(play+1>=history_count)?0:play+1'b1;
  end
 end
 wire pin_history=KEEP_HISTORY&&mode_core!=0;
 wire[2:0]idx=index_core<history_count?index_core:3'd0;
 wire[3:0]replay_sum={1'b0,idx}+{1'b0,(index_core==6?play:3'd0)};
 wire[2:0]replay_age=replay_sum>=history_count?3'(replay_sum-history_count):replay_sum[2:0];
 wire[2:0]next_age=idx+1>=history_count?3'd0:idx+1'b1;
 // F2 indices0..5 hold a frame; reserved index6 explicitly starts playback.
 wire[2:0]selected_age=mode_core==2?replay_age:mode_core==3?((history_tick<30||history_count<2)?idx:next_age):3'd0;
 reg start_scan=0,scan_from_source=0;
 assign scan_source_mode=scan_from_source;
 wire internal_acquire=DIRECT_SCAN&&direct_scan&&vblank&&scan_enable&&!scan_busy&&!(mode_core==1&&analysis_hold_valid);
 wire internal_release=DIRECT_SCAN&&analysis_hold_valid&&!scan_busy&&
  ((direct_scan&&vblank&&mode_core!=1)||(!direct_scan&&mode_core!=1&&!start_scan));
 wire[31:0]capture_active_id;
 always @(posedge clk)begin
  if(!rst_n)begin start_scan<=0;scan_from_source<=0;capture_frame_id<=0;end
  else begin
   start_scan<=vblank&&scan_enable&&!scan_busy&&
    ((DIRECT_SCAN&&direct_scan)?((mode_core==1&&analysis_hold_valid)||analysis_acquire_ready):(display_valid||render_pending));
   if(vblank&&scan_enable&&!scan_busy)scan_from_source<=DIRECT_SCAN&&direct_scan;
   if(writer_done&&!writer_error)capture_frame_id<=capture_active_id;
  end
 end
 frame_render_engine #(.SOURCE_BANKS(SOURCE_BANKS),.BANK_BITS(BANK_BITS),.KEEP_HISTORY(KEEP_HISTORY),.COMPUTE_ENABLED(COMPUTE_ENABLED),.MAX_LINE_PIXELS(MAX_LINE_PIXELS),.SOURCE_BASE(SOURCE_BASE),.RESULT_BASE(RESULT_BASE),.BANK_SHIFT(BANK_SHIFT)) engine(
  .clk(clk),.rst_n(rst_n),.pin_history(pin_history),.display_use_analysis(DIRECT_SCAN&&mode_core==1&&analysis_hold_valid),.display_age(selected_age),.analysis_age(selected_age),.history_count(history_count),.capture_frame_id(capture_active_id),.cap_req_valid(capture_fire&&!cap_bad),.cap_req_ready(cap_req_ready),
  .cap_req_config_id(capture_config_id),.cap_req_bank(cap_bank),
  .cap_done_valid(writer_done),.cap_done_ready(cap_done_ready),.cap_done_bank(held_cap_bank),.cap_done_ok(!writer_error&&!pin_history),
          .compute_acquire_valid(compute_acquire_valid),.compute_latest(compute_latest),.compute_release(compute_release),
        .compute_request_frame_id(compute_request_frame_id),.compute_acquire_ready(compute_acquire_ready),.compute_missing(compute_missing),
        .compute_hold_valid(compute_hold_valid),.compute_hold_bank(compute_hold_bank),
        .compute_hold_frame_id(compute_hold_frame_id),.compute_hold_config_id(compute_hold_config_id),
.analysis_acquire_valid(DIRECT_SCAN?internal_acquire:analysis_acquire_valid),.analysis_acquire_ready(analysis_acquire_ready),
  .analysis_release(DIRECT_SCAN?internal_release:analysis_release),.analysis_hold_valid(analysis_hold_valid),.analysis_hold_bank(analysis_hold_bank),
  .analysis_hold_frame_id(analysis_hold_frame_id),.analysis_hold_config_id(analysis_hold_config_id),
  .job_valid(job_valid),.job_ready(job_ready),.freeze_source(freeze_source),.release_source(release_source),.job_config_id(job_config_id),
  .src_width(src_width),.src_height(src_height),.src_stride_bytes(src_stride_bytes),
  .roi_x(roi_x),.roi_y(roi_y),.roi_w(roi_w),.roi_h(roi_h),
  .dst_width(dst_width),.dst_height(dst_height),.dst_stride_bytes(dst_stride_bytes),
  .vblank(vblank&&!scan_busy),.display_valid(display_valid),.display_base(display_base),
  .display_frame_id(display_frame_id),.display_config_id(display_config_id),
  .display_width(display_width),.display_height(display_height),.display_stride_bytes(display_stride_bytes),
  .done(render_done),.error(render_error),.busy(render_busy),.pending(render_pending),
  .last_cycles(last_cycles),.deadline_misses(deadline_misses),
  .source_hold_valid(source_hold_valid),.source_hold_frame_id(source_hold_frame_id),.source_hold_config_id(source_hold_config_id),
  .m_axi_araddr(b_araddr[32+:32]),
  .m_axi_arlen(b_arlen[8+:8]),
  .m_axi_arsize(b_arsize[3+:3]),
  .m_axi_arburst(b_arburst[2+:2]),
  .m_axi_arvalid(b_arvalid[1]),
  .m_axi_arready(b_arready[1]),
  .m_axi_rdata(b_rdata[128+:128]),
  .m_axi_rresp(b_rresp[2+:2]),
  .m_axi_rlast(b_rlast[1]),
  .m_axi_rvalid(b_rvalid[1]),
  .m_axi_rready(b_rready[1]),
  .m_axi_awaddr(b_awaddr[32+:32]),
  .m_axi_awlen(b_awlen[8+:8]),
  .m_axi_awsize(b_awsize[3+:3]),
  .m_axi_awburst(b_awburst[2+:2]),
  .m_axi_awvalid(b_awvalid[1]),
  .m_axi_awready(b_awready[1]),
  .m_axi_wdata(b_wdata[128+:128]),
  .m_axi_wstrb(b_wstrb[16+:16]),
  .m_axi_wlast(b_wlast[1]),
  .m_axi_wvalid(b_wvalid[1]),
  .m_axi_wready(b_wready[1]),
  .m_axi_bresp(b_bresp[2+:2]),
  .m_axi_bvalid(b_bvalid[1]),
  .m_axi_bready(b_bready[1]));
 axi_frame_reader #(.MAX_BURST_BEATS(SCAN_BURST_BEATS)) scan_dma(.clk(clk),.rst_n(rst_n),.job_valid(start_scan),.job_ready(),
  .base_addr(scan_from_source?(SOURCE_BASE+(32'(analysis_hold_bank)<<BANK_SHIFT)):display_base),
  .width(scan_from_source?src_width:display_width),.height(scan_from_source?src_height:display_height),.stride_bytes(scan_from_source?src_stride_bytes:display_stride_bytes),
  .frame_id(scan_from_source?analysis_hold_frame_id:display_frame_id),.config_id(scan_from_source?32'd0:display_config_id),
  .pixel_valid(scan_pixel_valid),.pixel_ready(scan_pixel_ready),.pixel_data(scan_pixel_data),.pixel_keep(scan_pixel_keep),
  .pixel_sof(scan_pixel_sof),.pixel_eol(scan_pixel_eol),.pixel_eof(scan_pixel_eof),
  .pixel_frame_id(scan_pixel_frame_id),.pixel_config_id(scan_pixel_config_id),
  .busy(scan_busy),.done(scan_done),.error(scan_error),
  .m_axi_araddr(b_araddr[64+:32]),
  .m_axi_arlen(b_arlen[16+:8]),
  .m_axi_arsize(b_arsize[6+:3]),
  .m_axi_arburst(b_arburst[4+:2]),
  .m_axi_arvalid(b_arvalid[2]),
  .m_axi_arready(b_arready[2]),
  .m_axi_rdata(b_rdata[256+:128]),
  .m_axi_rresp(b_rresp[4+:2]),
  .m_axi_rlast(b_rlast[2]),
  .m_axi_rvalid(b_rvalid[2]),
  .m_axi_rready(b_rready[2]));
 axi_burst_arbiter #(.N(CLIENTS)) bus(.clk(clk),.rst_n(rst_n),.read_urgent({{(CLIENTS-3){1'b0}},scan_urgent,2'b0}),
  .s_arid(b_arid),.m_arid(m_axi_arid),
  .s_araddr(b_araddr),.m_araddr(m_axi_araddr),
  .s_arlen(b_arlen),.m_arlen(m_axi_arlen),
  .s_arsize(b_arsize),.m_arsize(m_axi_arsize),
  .s_arburst(b_arburst),.m_arburst(m_axi_arburst),
  .s_arvalid(b_arvalid),.m_arvalid(m_axi_arvalid),
  .s_arready(b_arready),.m_arready(m_axi_arready),
  .s_rdata(b_rdata),.m_rdata(m_axi_rdata),
  .s_rresp(b_rresp),.m_rresp(m_axi_rresp),
  .s_rid(b_rid),.m_rid(m_axi_rid),
  .s_rlast(b_rlast),.m_rlast(m_axi_rlast),
  .s_rvalid(b_rvalid),.m_rvalid(m_axi_rvalid),
  .s_rready(b_rready),.m_rready(m_axi_rready),
  .s_awid(b_awid),.m_awid(m_axi_awid),
  .s_awaddr(b_awaddr),.m_awaddr(m_axi_awaddr),
  .s_awlen(b_awlen),.m_awlen(m_axi_awlen),
  .s_awsize(b_awsize),.m_awsize(m_axi_awsize),
  .s_awburst(b_awburst),.m_awburst(m_axi_awburst),
  .s_awvalid(b_awvalid),.m_awvalid(m_axi_awvalid),
  .s_awready(b_awready),.m_awready(m_axi_awready),
  .s_wdata(b_wdata),.m_wdata(m_axi_wdata),
  .s_wstrb(b_wstrb),.m_wstrb(m_axi_wstrb),
  .s_wlast(b_wlast),.m_wlast(m_axi_wlast),
  .s_wvalid(b_wvalid),.m_wvalid(m_axi_wvalid),
  .s_wready(b_wready),.m_wready(m_axi_wready),
  .s_bresp(b_bresp),.m_bresp(m_axi_bresp),
  .s_bid(b_bid),.m_bid(m_axi_bid),
  .s_bvalid(b_bvalid),.m_bvalid(m_axi_bvalid),
  .s_bready(b_bready),.m_bready(m_axi_bready));
endmodule
