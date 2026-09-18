`timescale 1ns/1ps
// One in-flight RGB565 line read, AXI4 128-bit INCR bursts.
// Addresses/stride are bytes. Lowest-address pixel is RDATA[15:0].
module axi_line_reader #(
    parameter integer MAX_BURST_BEATS = 16
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         req_valid,
    output wire         req_ready,
    input  wire [31:0]  req_addr,
    input  wire [15:0]  req_pixels,
    output wire         pixel_valid,
    input  wire         pixel_ready,
    output wire [15:0]  pixel_data,
    output reg          done,
    output reg          error,
    output wire [3:0]   m_axi_arid,
    output wire [31:0]  m_axi_araddr,
    output wire [7:0]   m_axi_arlen,
    output wire [2:0]   m_axi_arsize,
    output wire [1:0]   m_axi_arburst,
    output wire         m_axi_arvalid,
    input  wire         m_axi_arready,
    input  wire [127:0] m_axi_rdata,
    input  wire [1:0]   m_axi_rresp,
    input  wire         m_axi_rlast,
    input  wire         m_axi_rvalid,
    output wire         m_axi_rready
);
    localparam [1:0] IDLE=0, ADDRESS=1, RECEIVE=2;
    reg [1:0] state;
    reg [31:0] address;
    reg [16:0] beats_remaining;
    reg [8:0] burst_remaining;
    reg [15:0] pixels_remaining;
    reg [2:0] first_skip, pixel_index;
    reg first_beat, buffer_valid, buffer_last;
    reg [127:0] buffer_data;
    wire [32:0] request_end = {1'b0,req_addr} + ({17'd0,req_pixels} << 1);
    wire [17:0] request_bytes = {14'd0,req_addr[3:0]} + ({2'd0,req_pixels} << 1);
    wire [8:0] boundary_beats = (13'd4096 - {1'b0,address[11:0]}) >> 4;
    reg [8:0] next_burst;

    // The burst cap and 4 KiB split are independent of the requested ROI width.
    always @* begin
        next_burst = MAX_BURST_BEATS;
        if (beats_remaining < next_burst)
            next_burst = beats_remaining[8:0];
        if (boundary_beats < next_burst)
            next_burst = boundary_beats;
    end

    assign req_ready = (state == IDLE);
    assign pixel_valid = buffer_valid;
    assign pixel_data = buffer_data[pixel_index*16 +: 16];
    assign m_axi_arid = 4'd0;
    assign m_axi_araddr = address;
    assign m_axi_arlen = next_burst - 1'b1;
    assign m_axi_arsize = 3'd4; // 16 bytes per beat
    assign m_axi_arburst = 2'b01;
    assign m_axi_arvalid = (state == ADDRESS);
    assign m_axi_rready = (state == RECEIVE) && !buffer_valid;

    always @(posedge clk) begin
        if (!rst_n) begin
            state <= IDLE;
            address <= 0;
            beats_remaining <= 0;
            burst_remaining <= 0;
            pixels_remaining <= 0;
            first_skip <= 0;
            pixel_index <= 0;
            first_beat <= 0;
            buffer_valid <= 0;
            buffer_last <= 0;
            buffer_data <= 0;
            done <= 0;
            error <= 0;
        end else begin
            done <= 0;
            if (state == IDLE && req_valid) begin
                error <= 0;
                if (req_pixels == 0 || req_addr[0] || request_end > 33'h100000000) begin
                    done <= 1;
                    error <= 1;
                end else begin
                    address <= {req_addr[31:4],4'b0};
                    beats_remaining <= (request_bytes + 18'd15) >> 4;
                    pixels_remaining <= req_pixels;
                    first_skip <= req_addr[3:1];
                    first_beat <= 1;
                    state <= ADDRESS;
                end
            end
            if (m_axi_arvalid && m_axi_arready) begin
                burst_remaining <= next_burst;
                beats_remaining <= beats_remaining - next_burst;
                address <= address + ({23'd0,next_burst} << 4);
                state <= RECEIVE;
            end
            if (m_axi_rvalid && m_axi_rready) begin
                buffer_data <= m_axi_rdata;
                buffer_valid <= 1;
                pixel_index <= first_beat ? first_skip : 3'd0;
                first_beat <= 0;
                buffer_last <= (burst_remaining == 1);
                burst_remaining <= burst_remaining - 1'b1;
                if (m_axi_rresp != 0 || m_axi_rlast != (burst_remaining == 1))
                    error <= 1;
            end
            if (pixel_valid && pixel_ready) begin
                pixels_remaining <= pixels_remaining - 1'b1;
                if (pixels_remaining == 1) begin
                    buffer_valid <= 0;
                    state <= IDLE;
                    done <= 1;
                end else if (pixel_index == 7) begin
                    buffer_valid <= 0;
                    if (buffer_last)
                        state <= ADDRESS;
                end else begin
                    pixel_index <= pixel_index + 1'b1;
                end
            end
        end
    end
endmodule
