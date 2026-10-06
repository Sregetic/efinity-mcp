`timescale 1ns/1ps

// AXI4 frame writer for a 2PPC packed16 render stream.
//
// One accepted pixel beat contains two opaque16-bit pixels:
//   pixel_data[15:0]  = lower-address (left) pixel
//   pixel_data[31:16] = next pixel
// Four input beats are packed into one 128-bit AXI W beat, preserving the
// low-address-first ordering.  The writer owns only a small assembled-word
// FIFO; it does not contain frame-sized storage.
module axi_frame_writer #(
    parameter integer MAX_BURST_BEATS = 16,
    parameter integer FIFO_DEPTH = ((MAX_BURST_BEATS < 2) ? 4 : MAX_BURST_BEATS)
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         abort,

    input  wire         job_valid,
    output wire         job_ready,
    input  wire [31:0]  base_addr,
    input  wire [15:0]  dst_width,
    input  wire [15:0]  dst_height,
    input  wire [31:0]  stride_bytes,

    input  wire         pixel_valid,
    output wire         pixel_ready,
    input  wire [31:0]  pixel_data,
    input  wire [1:0]   pixel_keep,
    input  wire         pixel_sof,
    input  wire         pixel_eol,
    input  wire         pixel_eof,

    output wire         busy,
    output reg          done,
    output reg          error,

    output wire [3:0]   m_axi_awid,
    output wire [31:0]  m_axi_awaddr,
    output wire [7:0]   m_axi_awlen,
    output wire [2:0]   m_axi_awsize,
    output wire [1:0]   m_axi_awburst,
    output wire         m_axi_awvalid,
    input  wire         m_axi_awready,

    output wire [127:0] m_axi_wdata,
    output wire [15:0]  m_axi_wstrb,
    output wire         m_axi_wlast,
    output wire         m_axi_wvalid,
    input  wire         m_axi_wready,

    input  wire [1:0]   m_axi_bresp,
    input  wire         m_axi_bvalid,
    output wire         m_axi_bready
);

    localparam [1:0] ST_IDLE = 2'd0;
    localparam [1:0] ST_AW   = 2'd1;
    localparam [1:0] ST_W    = 2'd2;
    localparam [1:0] ST_B    = 2'd3;

    localparam integer FIFO_COUNT_WIDTH = $clog2(FIFO_DEPTH + 1);

    reg [1:0] state;
    reg       active;
    reg       input_complete;
    reg       aborting;
    wire cancel=abort||aborting;

    reg [31:0] base_addr_r;
    reg [15:0] dst_width_r;
    reg [15:0] dst_height_r;
    reg [31:0] stride_bytes_r;
    reg [31:0] row_bytes_r;
    reg [31:0] row_beats_r;
    reg [31:0] input_row_beats_r;

    reg [31:0] input_beats_remaining;
    reg [31:0] input_total_beats_r;
    reg [31:0] input_row_beat;
    reg [31:0] out_beats_remaining;
    reg [31:0] out_row_beats_remaining;
    reg [15:0] out_rows_remaining;
    reg [31:0] out_addr;

    reg [127:0] pack_word;
    reg [2:0]  pack_count;

    // Push-only shift FIFO permits native SRLs; count-1 selects the oldest.
    // Depth and full-burst ownership remain unchanged, with no block RAM.
    (* syn_ramstyle="registers" *) reg [127:0] fifo_mem [0:FIFO_DEPTH-1];
    reg [FIFO_COUNT_WIDTH-1:0] fifo_count;

    reg [31:0] burst_addr_r;
    reg [8:0]  burst_len_r;
    reg [8:0]  burst_w_count;

    wire job_bad;
    wire [31:0] input_row_beats_w = {16'd0, dst_width} >> 1;
    wire [63:0] input_total_beats_product_w =
        {32'd0, input_row_beats_w} * {48'd0, dst_height};
    wire [31:0] input_total_beats_w = input_total_beats_product_w[31:0];
    wire [31:0] output_row_beats_w = {16'd0, dst_width} >> 3;
    wire [63:0] output_total_beats_product_w =
        {32'd0, output_row_beats_w} * {48'd0, dst_height};
    wire [31:0] output_total_beats_w = output_total_beats_product_w[31:0];
    wire [31:0] input_row_bytes_w = {15'd0, dst_width, 1'b0};
    wire [63:0] last_byte_exclusive_w =
        {32'd0, base_addr}
        + ({48'd0, (dst_height - 16'd1)} * {32'd0, stride_bytes})
        + {47'd0, dst_width, 1'b0};

    // Width is in pixels.  The writer intentionally accepts only complete
    // 128-bit words per row so that every W beat uses all 16 byte strobes.
    assign job_bad =
        (dst_width == 16'd0) ||
        (dst_height == 16'd0) ||
        (dst_width[2:0] != 3'd0) ||
        (base_addr[3:0] != 4'd0) ||
        (stride_bytes[3:0] != 4'd0) ||
        ({1'b0, stride_bytes} < {1'b0, input_row_bytes_w}) ||
        (last_byte_exclusive_w[63:32] != 32'd0);

    wire input_fire;
    wire fifo_push;
    wire fifo_pop;
    wire aw_fire;
    wire w_fire;
    wire b_fire;

    wire [8:0] page_beats;
    reg  [8:0] planned_burst_len;
    wire fifo_has_planned_burst;

    assign job_ready = !active;
    assign busy = active;
    assign input_fire = pixel_valid && pixel_ready;
    assign fifo_push = input_fire && (pack_count == 3'd3);

    assign page_beats = (13'd4096 - {1'b0, out_addr[11:0]}) >> 4;

    // Rows and 4 KiB boundaries are independent limits.  MAX_BURST_BEATS is
    // intentionally bounded by the integration contract to 16 or 32.
    always @* begin
        planned_burst_len = 9'd0;
        if (active && (out_beats_remaining != 0) &&
            (out_row_beats_remaining != 0)) begin
            planned_burst_len = MAX_BURST_BEATS;
            if (out_beats_remaining < planned_burst_len)
                planned_burst_len = out_beats_remaining[8:0];
            if (out_row_beats_remaining < planned_burst_len)
                planned_burst_len = out_row_beats_remaining[8:0];
            if (page_beats < planned_burst_len)
                planned_burst_len = page_beats;
        end
    end

    assign fifo_has_planned_burst =
        (planned_burst_len != 0) &&
        (fifo_count >= planned_burst_len);

    // A partial four-input-beat pack can be filled even when the word FIFO is
    // full.  The fourth beat is accepted only when a FIFO slot is available,
    // or when a W beat is being removed on this same edge.
    assign pixel_ready = active && !input_complete && !cancel &&
        ((pack_count != 3'd3) || (fifo_count < FIFO_DEPTH) || fifo_pop);

    assign m_axi_awid = 4'd0;
    assign m_axi_awaddr = burst_addr_r;
    assign m_axi_awlen = (burst_len_r == 0) ? 8'd0 : burst_len_r - 1'b1;
    assign m_axi_awsize = 3'd4;
    assign m_axi_awburst = 2'b01;
    assign m_axi_awvalid = (state == ST_AW);

    assign m_axi_wdata = fifo_mem[fifo_count-1'b1];
    assign m_axi_wstrb = 16'hffff;
    assign m_axi_wlast = (burst_len_r != 0) &&
                         (burst_w_count == (burst_len_r - 1'b1));
    assign m_axi_wvalid = (state == ST_W) && (fifo_count != 0) &&
                          (burst_w_count < burst_len_r);
    assign m_axi_bready = (state == ST_B);

    assign fifo_pop = m_axi_wvalid && m_axi_wready;
    assign aw_fire = m_axi_awvalid && m_axi_awready;
    assign w_fire = m_axi_wvalid && m_axi_wready;
    assign b_fire = m_axi_bvalid && m_axi_bready;

    integer fifo_index;
    always @(posedge clk) if (fifo_push) begin
        fifo_mem[0] <= {pixel_data, pack_word[95:0]};
        for (fifo_index=1; fifo_index<FIFO_DEPTH; fifo_index=fifo_index+1)
            fifo_mem[fifo_index] <= fifo_mem[fifo_index-1];
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            state <= ST_IDLE;
            active <= 1'b0;
            input_complete <= 1'b0;
            aborting <= 1'b0;
            base_addr_r <= 32'd0;
            dst_width_r <= 16'd0;
            dst_height_r <= 16'd0;
            stride_bytes_r <= 32'd0;
            row_bytes_r <= 32'd0;
            row_beats_r <= 32'd0;
            input_row_beats_r <= 32'd0;
            input_beats_remaining <= 32'd0;
            input_total_beats_r <= 32'd0;
            input_row_beat <= 32'd0;
            out_beats_remaining <= 32'd0;
            out_row_beats_remaining <= 32'd0;
            out_rows_remaining <= 16'd0;
            out_addr <= 32'd0;
            pack_word <= 128'd0;
            pack_count <= 3'd0;
            fifo_count <= {FIFO_COUNT_WIDTH{1'b0}};
            burst_addr_r <= 32'd0;
            burst_len_r <= 9'd0;
            burst_w_count <= 9'd0;
            done <= 1'b0;
            if(active&&abort)begin aborting<=1;error<=1;end
            error <= 1'b0;
        end else begin
            done <= 1'b0;

            // The FIFO count is updated from the independent
            // input and W channel handshakes.  Simultaneous push/pop is safe,
            // including when the FIFO is full.
            case ({fifo_push, fifo_pop})
                2'b10: fifo_count <= fifo_count + 1'b1;
                2'b01: fifo_count <= fifo_count - 1'b1;
                default: fifo_count <= fifo_count;
            endcase

            // Input packing and protocol checks.  A malformed keep/marker is
            // recorded, but the known dimensions still drain the frame so a
            // bad producer cannot strand half a job.
            if (input_fire) begin
                if (pixel_keep != 2'b11)
                    error <= 1'b1;
                if (pixel_sof != (input_beats_remaining == input_total_beats_r))
                    error <= 1'b1;
                if (pixel_eol != (input_row_beat == (input_row_beats_r - 1'b1)))
                    error <= 1'b1;
                if (pixel_eof != (input_beats_remaining == 32'd1))
                    error <= 1'b1;

                case (pack_count)
                    3'd0: begin
                        pack_word[31:0] <= pixel_data;
                        pack_count <= 3'd1;
                    end
                    3'd1: begin
                        pack_word[63:32] <= pixel_data;
                        pack_count <= 3'd2;
                    end
                    3'd2: begin
                        pack_word[95:64] <= pixel_data;
                        pack_count <= 3'd3;
                    end
                    default: begin
                        pack_count <= 3'd0;
                    end
                endcase

                if (input_beats_remaining == 32'd1) begin
                    input_beats_remaining <= 32'd0;
                    input_complete <= 1'b1;
                end else begin
                    input_beats_remaining <= input_beats_remaining - 1'b1;
                end
                if (input_row_beat == (input_row_beats_r - 1'b1))
                    input_row_beat <= 32'd0;
                else
                    input_row_beat <= input_row_beat + 1'b1;
            end

            case (state)
                ST_IDLE: begin
                    if (active) begin
                        if(cancel)begin
                            active<=0;done<=1;error<=1;aborting<=0;
                            fifo_count<=0;pack_count<=0;
                        end else if (fifo_has_planned_burst) begin
                            burst_addr_r <= out_addr;
                            burst_len_r <= planned_burst_len;
                            burst_w_count <= 9'd0;
                            state <= ST_AW;
                        end
                    end else if (job_valid && job_ready) begin
                        if (job_bad) begin
                            // Invalid configuration never enters the AXI
                            // states and completes on the accepting edge.
                            error <= 1'b1;
                            done <= 1'b1;
                        end else begin
                            active <= 1'b1;
                            aborting <= 1'b0;
                            error <= 1'b0;
                            input_complete <= 1'b0;
                            base_addr_r <= base_addr;
                            dst_width_r <= dst_width;
                            dst_height_r <= dst_height;
                            stride_bytes_r <= stride_bytes;
                            row_bytes_r <= input_row_bytes_w;
                            row_beats_r <= dst_width >> 3;
                            input_row_beats_r <= dst_width >> 1;
                            input_beats_remaining <= input_total_beats_w;
                            input_total_beats_r <= input_total_beats_w;
                            input_row_beat <= 32'd0;
                            out_beats_remaining <= output_total_beats_w;
                            out_row_beats_remaining <= output_row_beats_w;
                            out_rows_remaining <= dst_height;
                            out_addr <= base_addr;
                            pack_word <= 128'd0;
                            pack_count <= 3'd0;
                            fifo_count <= {FIFO_COUNT_WIDTH{1'b0}};
                        end
                    end
                end

                ST_AW: begin
                    if (aw_fire)
                        state <= ST_W;
                end

                ST_W: begin
                    if (w_fire) begin
                        if (m_axi_wlast) begin
                            // Advance the next burst address only after every
                            // W beat of this burst has been accepted.  A row
                            // end adds the padding delta, so no burst spans a
                            // row even when stride is larger than row bytes.
                            out_beats_remaining <= out_beats_remaining - burst_len_r;
                            if (out_row_beats_remaining == burst_len_r) begin
                                if (out_rows_remaining > 16'd1) begin
                                    out_addr <= out_addr +
                                        ({23'd0, burst_len_r} << 4) +
                                        stride_bytes_r - row_bytes_r;
                                    out_row_beats_remaining <= row_beats_r;
                                    out_rows_remaining <= out_rows_remaining - 1'b1;
                                end else begin
                                    out_addr <= out_addr +
                                        ({23'd0, burst_len_r} << 4);
                                    out_row_beats_remaining <= 32'd0;
                                    out_rows_remaining <= 16'd0;
                                end
                            end else begin
                                out_addr <= out_addr + ({23'd0, burst_len_r} << 4);
                                out_row_beats_remaining <=
                                    out_row_beats_remaining - burst_len_r;
                            end
                            state <= ST_B;
                        end else begin
                            burst_w_count <= burst_w_count + 1'b1;
                        end
                    end
                end

                ST_B: begin
                    if (b_fire) begin
                        if (m_axi_bresp != 2'b00)
                            error <= 1'b1;
                        // Every advertised burst already owns all its FIFO
                        // words. On camera overflow, finish that burst/B before
                        // discarding unissued data and releasing the bad lease.
                        if(cancel)begin
                            active<=0;done<=1;error<=1;aborting<=0;state<=ST_IDLE;
                            fifo_count<=0;pack_count<=0;
                        end else if (out_beats_remaining == 32'd0) begin
                            if (input_complete && (fifo_count == 0) &&
                                (pack_count == 3'd0)) begin
                                // The final B is the publication boundary.
                                // Input acceptance is dimension-driven; no
                                // timeout is fabricated for a producer or
                                // slave that stalls.
                                active <= 1'b0;
                                done <= 1'b1;
                                state <= ST_IDLE;
                            end else begin
                                // This path indicates an internal stream-
                                // length invariant violation.  Keep the job
                                // active and wait for coordinated reset rather
                                // than exposing a premature completion.
                                error <= 1'b1;
                            end
                        end else begin
                            state <= ST_IDLE;
                        end
                    end
                end

                default: begin
                    state <= ST_IDLE;
                    active <= 1'b0;
                end
            endcase
        end
    end

endmodule

`default_nettype wire
