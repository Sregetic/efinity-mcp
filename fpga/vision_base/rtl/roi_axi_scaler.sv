`timescale 1ns/1ps
// 2PPC frame-task renderer.  The scaler owns two source line buffers and
// overlaps line prefetch with output; the reader owns AXI4 128-bit INCR.
module roi_axi_scaler #(
    parameter integer MAX_LINE_PIXELS = 2560,
    parameter integer MAX_BURST_BEATS = 16,
    parameter integer FIFO_BEATS       = 8
) (
    input wire clk, rst_n,
    input wire job_valid,
    output wire job_ready,
    input wire [31:0] base_addr, stride_bytes, frame_id, config_id,
    input wire [15:0] src_width, src_height, roi_x, roi_y, roi_w, roi_h,
    input wire [15:0] dst_width, dst_height,
    output wire pixel_valid,
    input wire pixel_ready,
    output wire [31:0] pixel_data,
    output wire [1:0] pixel_keep,
    output wire pixel_sof, pixel_eol, pixel_eof,
    output wire [31:0] pixel_frame_id, pixel_config_id,
    output wire done,
    output wire error,
    output wire [3:0] m_axi_arid,
    output wire [31:0] m_axi_araddr,
    output wire [7:0] m_axi_arlen,
    output wire [2:0] m_axi_arsize,
    output wire [1:0] m_axi_arburst,
    output wire m_axi_arvalid,
    input wire m_axi_arready,
    input wire [127:0] m_axi_rdata,
    input wire [1:0] m_axi_rresp,
    input wire m_axi_rlast, m_axi_rvalid,
    output wire m_axi_rready
);
    wire rd_cmd_valid, rd_cmd_ready, rd_data_valid, rd_data_ready;
    wire [31:0] rd_addr, rd_data;
    wire [15:0] rd_pixels;
    wire [1:0] rd_keep;
    wire rd_error;
    wire scale_error;

    roi_scaler #(.MAX_LINE_PIXELS(MAX_LINE_PIXELS)) scaler (
        .clk(clk), .rst_n(rst_n),
        .job_valid(job_valid), .job_ready(job_ready),
        .base_addr(base_addr), .src_width(src_width), .src_height(src_height),
        .stride_bytes(stride_bytes), .roi_x(roi_x), .roi_y(roi_y),
        .roi_w(roi_w), .roi_h(roi_h), .dst_width(dst_width),
        .dst_height(dst_height), .frame_id(frame_id), .config_id(config_id),
        .pixel_valid(pixel_valid), .pixel_ready(pixel_ready),
        .pixel_data(pixel_data), .pixel_keep(pixel_keep),
        .pixel_sof(pixel_sof), .pixel_eol(pixel_eol), .pixel_eof(pixel_eof),
        .pixel_frame_id(pixel_frame_id), .pixel_config_id(pixel_config_id),
        .done(done), .error(scale_error),
        .rd_cmd_valid(rd_cmd_valid), .rd_cmd_ready(rd_cmd_ready),
        .rd_addr(rd_addr), .rd_pixels(rd_pixels),
        .rd_data_valid(rd_data_valid), .rd_data_ready(rd_data_ready),
        .rd_data(rd_data), .rd_keep(rd_keep), .rd_error(rd_error)
    );

    axi_line_reader #(
        .MAX_BURST_BEATS(MAX_BURST_BEATS), .FIFO_BEATS(FIFO_BEATS)
    ) reader (
        .clk(clk), .rst_n(rst_n),
        .req_valid(rd_cmd_valid), .req_ready(rd_cmd_ready),
        .req_addr(rd_addr), .req_pixels(rd_pixels),
        .pixel_valid(rd_data_valid), .pixel_ready(rd_data_ready),
        .pixel_data(rd_data), .pixel_keep(rd_keep),
        .done(), .error(rd_error),
        .m_axi_arid(m_axi_arid), .m_axi_araddr(m_axi_araddr),
        .m_axi_arlen(m_axi_arlen), .m_axi_arsize(m_axi_arsize),
        .m_axi_arburst(m_axi_arburst), .m_axi_arvalid(m_axi_arvalid),
        .m_axi_arready(m_axi_arready), .m_axi_rdata(m_axi_rdata),
        .m_axi_rresp(m_axi_rresp), .m_axi_rlast(m_axi_rlast),
        .m_axi_rvalid(m_axi_rvalid), .m_axi_rready(m_axi_rready)
    );

    assign error = scale_error;
endmodule
