`timescale 1ns/1ps
// Packed16 source/result memory engine. Capture and scanout pixel adapters external.
// Memory map: four 4 MiB source banks, then two 4 MiB result banks by default.
module frame_render_engine #(
    parameter integer MAX_LINE_PIXELS=2560,
    parameter integer SOURCE_BANKS=4,BANK_BITS=$clog2(SOURCE_BANKS),KEEP_HISTORY=0,
    parameter [31:0] SOURCE_BASE=32'h00000000,
    parameter [31:0] RESULT_BASE=32'h01000000,
    parameter integer BANK_SHIFT=22
)(
    input wire clk,rst_n,
    input wire cap_req_valid,output wire cap_req_ready,
    input wire [31:0] cap_req_config_id,output wire [BANK_BITS-1:0] cap_req_bank,
    input wire cap_done_valid,output wire cap_done_ready,
    input wire [BANK_BITS-1:0] cap_done_bank,input wire cap_done_ok,
    input wire analysis_acquire_valid,output wire analysis_acquire_ready,
    input wire analysis_release,output wire analysis_hold_valid,
    output wire [BANK_BITS-1:0] analysis_hold_bank,
    output wire [31:0] analysis_hold_frame_id,analysis_hold_config_id,
    input wire pin_history,display_use_analysis,input wire[2:0]display_age,analysis_age,
    output wire[2:0]history_count,output wire[31:0]capture_frame_id,
    input wire job_valid,output wire job_ready,
    input wire freeze_source,release_source,input wire [31:0] job_config_id,
    input wire [15:0] src_width,src_height,roi_x,roi_y,roi_w,roi_h,dst_width,dst_height,
    input wire [31:0] src_stride_bytes,dst_stride_bytes,
    input wire vblank,
    output wire display_valid,output wire [31:0] display_base,display_frame_id,display_config_id,
    output reg [15:0] display_width,display_height,
    output reg [31:0] display_stride_bytes,
    output wire done,error,busy,pending,
    output wire [31:0] last_cycles,deadline_misses,
    output wire [3:0] m_axi_arid,
    output wire [31:0] m_axi_araddr,
    output wire [7:0] m_axi_arlen,
    output wire [2:0] m_axi_arsize,
    output wire [1:0] m_axi_arburst,
    output wire m_axi_arvalid,input wire m_axi_arready,
    input wire [127:0] m_axi_rdata,input wire [1:0] m_axi_rresp,
    input wire m_axi_rlast,m_axi_rvalid,output wire m_axi_rready,
    output wire [3:0] m_axi_awid,
    output wire [31:0] m_axi_awaddr,
    output wire [7:0] m_axi_awlen,
    output wire [2:0] m_axi_awsize,
    output wire [1:0] m_axi_awburst,
    output wire m_axi_awvalid,input wire m_axi_awready,
    output wire [127:0] m_axi_wdata,output wire [15:0] m_axi_wstrb,
    output wire m_axi_wlast,m_axi_wvalid,input wire m_axi_wready,
    input wire [1:0] m_axi_bresp,input wire m_axi_bvalid,output wire m_axi_bready,
    output wire source_hold_valid,output wire[31:0]source_hold_frame_id,source_hold_config_id
);
    localparam [63:0] BANK_BYTES=64'd1<<BANK_SHIFT;
    initial begin
        if(BANK_SHIFT<4 || BANK_SHIFT>28 || (SOURCE_BASE % BANK_BYTES)!=0 || (RESULT_BASE % BANK_BYTES)!=0)
            $fatal(1,"invalid aligned frame bank map");
        if((64'(SOURCE_BASE)+SOURCE_BANKS*BANK_BYTES)>64'h100000000 || (64'(RESULT_BASE)+2*BANK_BYTES)>64'h100000000 ||
           ((64'(SOURCE_BASE)<64'(RESULT_BASE)+2*BANK_BYTES) && (64'(RESULT_BASE)<64'(SOURCE_BASE)+SOURCE_BANKS*BANK_BYTES)))
            $fatal(1,"overlapping or overflowing frame bank map");
    end
    reg [15:0] sw,sh,rx,ry,rw,rh,dw,dh;
    reg [31:0] ss,ds;
    // A32-bit byte stride times a16-bit row index needs48 bits, not64x64.
    wire [15:0] source_last_row=src_height-16'd1,result_last_row=dst_height-16'd1;
    wire [47:0] source_offset=src_stride_bytes*source_last_row,result_offset=dst_stride_bytes*result_last_row;
    wire [63:0] source_extent={16'd0,source_offset}+64'(src_width)*2;
    wire [63:0] result_extent={16'd0,result_offset}+64'(dst_width)*2;
    wire config_ok=src_width!=0 && src_height!=0 && roi_w!=0 && roi_h!=0 && dst_width!=0 && dst_height!=0 &&
        roi_w<=MAX_LINE_PIXELS && {1'b0,roi_x}+{1'b0,roi_w}<={1'b0,src_width} &&
        {1'b0,roi_y}+{1'b0,roi_h}<={1'b0,src_height} && !src_stride_bytes[0] &&
        src_stride_bytes>={16'b0,src_width}*2 && dst_stride_bytes>={16'b0,dst_width}*2 &&
        dst_width[2:0]==0 && dst_stride_bytes[3:0]==0 && source_extent<=BANK_BYTES && result_extent<=BANK_BYTES &&
        (64'(RESULT_BASE)+BANK_BYTES+result_extent)<64'h100000000;
    always @(posedge clk) if(job_valid && job_ready) begin
        sw<=src_width;sh<=src_height;rx<=roi_x;ry<=roi_y;rw<=roi_w;rh<=roi_h;
        dw<=dst_width;dh<=dst_height;ss<=src_stride_bytes;ds<=dst_stride_bytes;
    end
    always @(posedge clk) begin
        if(!rst_n)begin display_width<=0;display_height<=0;display_stride_bytes<=0;end
        else if(pending && vblank)begin display_width<=dw;display_height<=dh;display_stride_bytes<=ds;end
    end
    wire run_valid,scale_ready,write_ready,scale_done,scale_error,write_done,write_error;
    wire [BANK_BITS-1:0] source_bank;
    wire result_bank,display_bank;
    wire [31:0] frame_id,config_id;
    frame_render_control #(.BANKS(SOURCE_BANKS),.BANK_BITS(BANK_BITS),.KEEP_HISTORY(KEEP_HISTORY)) control (
        .clk(clk),.rst_n(rst_n),.pin_history(pin_history),.display_use_analysis(display_use_analysis),.display_age(display_age),.analysis_age(analysis_age),.history_count(history_count),.capture_frame_id(capture_frame_id),.cap_req_valid(cap_req_valid),.cap_req_ready(cap_req_ready),
        .cap_req_config_id(cap_req_config_id),.cap_req_bank(cap_req_bank),
        .cap_done_valid(cap_done_valid),.cap_done_ready(cap_done_ready),.cap_done_bank(cap_done_bank),.cap_done_ok(cap_done_ok),
        .analysis_acquire_valid(analysis_acquire_valid),.analysis_acquire_ready(analysis_acquire_ready),
        .analysis_release(analysis_release),.analysis_hold_valid(analysis_hold_valid),.analysis_hold_bank(analysis_hold_bank),
        .analysis_hold_frame_id(analysis_hold_frame_id),.analysis_hold_config_id(analysis_hold_config_id),
        .job_valid(job_valid),.job_ready(job_ready),.job_config_ok(config_ok),.freeze_source(freeze_source),.release_source(release_source),.job_config_id(job_config_id),
        .run_valid(run_valid),.run_ready(scale_ready && write_ready),.run_source_bank(source_bank),
        .run_frame_id(frame_id),.run_config_id(config_id),.run_result_bank(result_bank),
        .scaler_done(scale_done),.scaler_error(scale_error),.writer_done(write_done),.writer_error(write_error),
        .vblank(vblank),.display_valid(display_valid),.display_bank(display_bank),
        .display_frame_id(display_frame_id),.display_config_id(display_config_id),
        .done(done),.error(error),.busy(busy),.pending(pending),.last_cycles(last_cycles),.deadline_misses(deadline_misses),
        .source_hold_valid(source_hold_valid),.source_hold_bank(),
        .source_hold_frame_id(source_hold_frame_id),.source_hold_config_id(source_hold_config_id)
    );
    wire [31:0] source_addr=SOURCE_BASE+(32'(source_bank)<<BANK_SHIFT);
    wire [31:0] result_addr=RESULT_BASE+({31'b0,result_bank}<<BANK_SHIFT);
    assign display_base=RESULT_BASE+({31'b0,display_bank}<<BANK_SHIFT);
    wire pv,pr,psof,peol,peof;wire [31:0] pd;wire [1:0] pk;
    roi_axi_scaler #(.MAX_LINE_PIXELS(MAX_LINE_PIXELS)) scaler (
        .clk(clk),.rst_n(rst_n),.job_valid(run_valid && write_ready),.job_ready(scale_ready),
        .base_addr(source_addr),.stride_bytes(ss),.frame_id(frame_id),.config_id(config_id),
        .src_width(sw),.src_height(sh),.roi_x(rx),.roi_y(ry),.roi_w(rw),.roi_h(rh),.dst_width(dw),.dst_height(dh),
        .pixel_valid(pv),.pixel_ready(pr),.pixel_data(pd),.pixel_keep(pk),.pixel_sof(psof),.pixel_eol(peol),.pixel_eof(peof),
        .pixel_frame_id(),.pixel_config_id(),.done(scale_done),.error(scale_error),
        .m_axi_arid(m_axi_arid),.m_axi_araddr(m_axi_araddr),.m_axi_arlen(m_axi_arlen),.m_axi_arsize(m_axi_arsize),
        .m_axi_arburst(m_axi_arburst),.m_axi_arvalid(m_axi_arvalid),.m_axi_arready(m_axi_arready),
        .m_axi_rdata(m_axi_rdata),.m_axi_rresp(m_axi_rresp),.m_axi_rlast(m_axi_rlast),.m_axi_rvalid(m_axi_rvalid),.m_axi_rready(m_axi_rready)
    );
    axi_frame_writer writer (
        .clk(clk),.rst_n(rst_n),.abort(1'b0),.job_valid(run_valid && scale_ready),.job_ready(write_ready),
        .base_addr(result_addr),.dst_width(dw),.dst_height(dh),.stride_bytes(ds),
        .pixel_valid(pv),.pixel_ready(pr),.pixel_data(pd),.pixel_keep(pk),.pixel_sof(psof),.pixel_eol(peol),.pixel_eof(peof),
        .busy(),.done(write_done),.error(write_error),
        .m_axi_awid(m_axi_awid),.m_axi_awaddr(m_axi_awaddr),.m_axi_awlen(m_axi_awlen),.m_axi_awsize(m_axi_awsize),
        .m_axi_awburst(m_axi_awburst),.m_axi_awvalid(m_axi_awvalid),.m_axi_awready(m_axi_awready),
        .m_axi_wdata(m_axi_wdata),.m_axi_wstrb(m_axi_wstrb),.m_axi_wlast(m_axi_wlast),.m_axi_wvalid(m_axi_wvalid),.m_axi_wready(m_axi_wready),
        .m_axi_bresp(m_axi_bresp),.m_axi_bvalid(m_axi_bvalid),.m_axi_bready(m_axi_bready)
    );
endmodule
