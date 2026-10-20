`default_nettype none
`timescale 1ns/1ps

// AXI4 reader for an RGB565 line.  AXI carries eight 16-bit pixels per
// 128-bit beat; the local stream carries two pixels per beat.  The first and
// last local beat may carry one pixel (keep=01).  req_addr and stride are byte
// addresses, and req_addr may be any even byte offset.
module axi_line_reader #(
    parameter integer MAX_BURST_BEATS = 16,
    parameter integer FIFO_BEATS       = MAX_BURST_BEATS
) (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        req_valid,
    output wire        req_ready,
    input  wire [31:0] req_addr,
    input  wire [15:0] req_pixels,
    output wire        pixel_valid,
    input  wire        pixel_ready,
    output wire [31:0] pixel_data,
    output wire [1:0]  pixel_keep,
    output reg         done,
    output reg         error,
    output wire [3:0]  m_axi_arid,
    output wire [31:0] m_axi_araddr,
    output wire [7:0]  m_axi_arlen,
    output wire [2:0]  m_axi_arsize,
    output wire [1:0]  m_axi_arburst,
    output wire        m_axi_arvalid,
    input  wire        m_axi_arready,
    input  wire [127:0] m_axi_rdata,
    input  wire [1:0]  m_axi_rresp,
    input  wire        m_axi_rlast,
    input  wire        m_axi_rvalid,
    output wire        m_axi_rready
);
    localparam [1:0] ST_IDLE = 2'd0;
    localparam [1:0] ST_AR   = 2'd1;
    localparam [1:0] ST_R    = 2'd2;
    localparam integer FIFO_PTR_W = (FIFO_BEATS <= 2) ? 1 : $clog2(FIFO_BEATS);

    reg [1:0]  state;
    reg [31:0] address;
    reg [16:0] beats_remaining;
    reg [8:0]  burst_remaining;
    reg [15:0] pixels_remaining;
    reg [2:0]  first_skip;
    reg        first_word;

    // Reserve a complete burst before AR so pixel unpacking never holds DDR.
    reg [FIFO_PTR_W:0]   fifo_count;
    reg [FIFO_PTR_W-1:0] fifo_write_ptr, fifo_read_ptr;
    reg [127:0] fifo_read_data;
    reg fifo_read_pending;

    // Current and one-beat look-ahead word.  The look-ahead word makes a
    // pair spanning two AXI beats a normal one-cycle local transfer.
    reg        cur_word_valid;
    reg [127:0] cur_word_data;
    reg [2:0]  cur_index;
    reg        next_word_valid;
    reg [127:0] next_word_data;

    reg        pixel_valid_r;
    reg [31:0] pixel_data_r;
    reg [1:0]  pixel_keep_r;
    reg        last_beat_r;
    reg        read_finished_r;

    wire [32:0] request_end = {1'b0, req_addr}
                            + ({17'd0, req_pixels} << 1);
    wire [18:0] request_bytes = {15'd0, req_addr[3:0]}
                               + ({3'd0, req_pixels} << 1);
    wire [16:0] request_beats = (request_bytes + 19'd15) >> 4;
    wire [8:0] page_beats = (13'd4096 - {1'b0, address[11:0]}) >> 4;

    reg [8:0] next_burst_c;
    always @* begin
        // ARLEN depends only on the request cursor and the 4-KiB boundary.
        // It must remain stable while ARVALID is backpressured; RREADY later
        // throttles the bounded FIFO if a full burst outruns local parsing.
        next_burst_c = 9'd0;
        if (beats_remaining != 0) begin
            next_burst_c = (MAX_BURST_BEATS > 511) ? 9'd511 : MAX_BURST_BEATS[8:0];
            if (FIFO_BEATS < next_burst_c)
                next_burst_c = FIFO_BEATS;
            if (beats_remaining < next_burst_c)
                next_burst_c = beats_remaining[8:0];
            if (page_beats < next_burst_c)
                next_burst_c = page_beats;
        end
    end

    wire fifo_push = (state == ST_R) && m_axi_rvalid && m_axi_rready;
    wire load_cur = fifo_read_pending && !cur_word_valid && !next_word_valid;
    wire load_next = fifo_read_pending && cur_word_valid && !next_word_valid;
    wire fifo_pop = (fifo_count != 0) && !fifo_read_pending && !next_word_valid;
    generate if (FIFO_BEATS <= 32) begin : short_fifo
        // Keep the renderer's32-word queue in SRLs to leave image RAM spare.
        (* syn_ramstyle="registers" *) reg [127:0] mem [0:FIFO_BEATS-1];
        integer i;
        always @(posedge clk) begin
            if (fifo_push) begin
                mem[0] <= m_axi_rdata;
                for (i=1; i<FIFO_BEATS; i=i+1) mem[i] <= mem[i-1];
            end
            if (fifo_pop) fifo_read_data <= mem[fifo_count-1'b1];
        end
    end else begin : burst_fifo
        reg [127:0] mem [0:FIFO_BEATS-1];
        always @(posedge clk) begin
            if (fifo_push) mem[fifo_write_ptr] <= m_axi_rdata;
            if (fifo_pop) fifo_read_data <= mem[fifo_read_ptr];
        end
    end endgenerate

    wire output_slot = !pixel_valid_r || pixel_ready;
    wire [127:0] cur_shifted = cur_word_data >> (cur_index * 16);
    wire [127:0] next_shifted_same = cur_word_data >> ((cur_index + 1'b1) * 16);
    wire [15:0] cur_pixel = cur_shifted[15:0];
    wire [15:0] next_pixel_same = next_shifted_same[15:0];
    wire [15:0] next_pixel = (cur_index == 3'd7)
                           ? next_word_data[15:0] : next_pixel_same;
    wire enough_for_two = cur_word_valid
                       && (pixels_remaining >= 16'd2)
                       && ((cur_index != 3'd7) || next_word_valid);
    wire enough_for_one = cur_word_valid && (pixels_remaining != 0);
    wire emit_one = output_slot && enough_for_one
                 && (pixels_remaining == 16'd1);
    wire emit_two = output_slot && enough_for_two;
    wire emit = emit_one || emit_two;

    assign req_ready = (state == ST_IDLE) && !pixel_valid_r;
    assign pixel_valid = pixel_valid_r;
    assign pixel_data = pixel_data_r;
    assign pixel_keep = pixel_keep_r;
    assign m_axi_arid = 4'd0;
    assign m_axi_araddr = address;
    wire [8:0] next_burst_minus1 = (next_burst_c == 0) ? 9'd0 : next_burst_c - 9'd1;
    assign m_axi_arlen = next_burst_minus1[7:0];
    assign m_axi_arsize = 3'd4; // 16 bytes
    assign m_axi_arburst = 2'b01; // INCR
    assign m_axi_arvalid = (state == ST_AR) && (next_burst_c != 0)
                         && (fifo_count + next_burst_c <= FIFO_BEATS);
    // AR already reserved this burst's storage, independent of pixel_ready.
    assign m_axi_rready = (state == ST_R) && (fifo_count < FIFO_BEATS);

    always @(posedge clk) begin
        if (!rst_n) begin
            state             <= ST_IDLE;
            address           <= 32'd0;
            beats_remaining   <= 17'd0;
            burst_remaining   <= 9'd0;
            pixels_remaining  <= 16'd0;
            first_skip        <= 3'd0;
            first_word        <= 1'b0;
            fifo_count        <= {(FIFO_PTR_W+1){1'b0}};
            fifo_write_ptr    <= 0;
            fifo_read_ptr     <= 0;
            fifo_read_pending <= 0;
            cur_word_valid    <= 1'b0;
            cur_word_data     <= 128'd0;
            cur_index         <= 3'd0;
            next_word_valid   <= 1'b0;
            next_word_data    <= 128'd0;
            pixel_valid_r     <= 1'b0;
            pixel_data_r      <= 32'd0;
            pixel_keep_r      <= 2'b00;
            last_beat_r       <= 1'b0;
            read_finished_r   <= 1'b0;
            done              <= 1'b0;
            error             <= 1'b0;
        end else begin
            done <= 1'b0;

            if (fifo_push)
                fifo_write_ptr <= (fifo_write_ptr == FIFO_BEATS-1) ? 0 : fifo_write_ptr + 1'b1;
            if (fifo_pop) begin
                fifo_read_ptr <= (fifo_read_ptr == FIFO_BEATS-1) ? 0 : fifo_read_ptr + 1'b1;
                fifo_read_pending <= 1;
            end else if (load_cur || load_next)
                fifo_read_pending <= 0;

            // A simultaneous push/pop keeps occupancy.
            case ({fifo_push, fifo_pop})
                2'b10: begin
                    fifo_count <= fifo_count + 1'b1;
                end
                2'b01: begin
                    fifo_count <= fifo_count - 1'b1;
                end
                default: begin end
            endcase

            // Request acceptance is the only place where address and pixel
            // count are sampled.  The 33-bit end check accepts fffffffe+one
            // pixel and rejects every range beyond the 32-bit address space.
            if (state == ST_IDLE && req_valid && req_ready) begin
                error <= 1'b0;
                if (req_pixels == 16'd0 || req_addr[0]
                    || request_end > 33'h1_0000_0000) begin
                    error <= 1'b1;
                    done <= 1'b1;
                end else begin
                    address          <= {req_addr[31:4], 4'b0};
                    beats_remaining  <= request_beats;
                    pixels_remaining <= req_pixels;
                    first_skip       <= req_addr[3:1];
                    first_word       <= 1'b1;
                    cur_word_valid   <= 1'b0;
                    next_word_valid  <= 1'b0;
                    pixel_valid_r    <= 1'b0;
                    last_beat_r      <= 1'b0;
                    read_finished_r  <= 1'b0;
                    fifo_count       <= {(FIFO_PTR_W+1){1'b0}};
                    fifo_write_ptr   <= 0;
                    fifo_read_ptr    <= 0;
                    fifo_read_pending <= 0;
                    state            <= ST_AR;
                end
            end

            if (m_axi_arvalid && m_axi_arready) begin
                burst_remaining <= next_burst_c;
                beats_remaining <= beats_remaining - next_burst_c;
                address <= address + ({23'd0, next_burst_c} << 4);
                state <= ST_R;
            end

            if (fifo_push) begin
                if (m_axi_rresp != 2'b00
                    || m_axi_rlast != (burst_remaining == 9'd1))
                    error <= 1'b1;
                if (burst_remaining == 9'd1) begin
                    burst_remaining <= 9'd0;
                    if (beats_remaining != 0)
                        state <= ST_AR;
                    else
                        read_finished_r <= 1'b1;
                end else begin
                    burst_remaining <= burst_remaining - 1'b1;
                end
            end

            // Fill current and look-ahead words from the prefetched FIFO.
            // If the current word was exhausted on the preceding edge while
            // the look-ahead word was being filled, promote that word before
            // taking another FIFO entry.
            if (!cur_word_valid && next_word_valid) begin
                cur_word_data  <= next_word_data;
                cur_word_valid <= 1'b1;
                cur_index      <= 3'd0;
                next_word_valid <= 1'b0;
            end else if (load_cur) begin
                cur_word_data  <= fifo_read_data;
                cur_word_valid <= 1'b1;
                cur_index      <= first_word ? first_skip : 3'd0;
                first_word     <= 1'b0;
            end else if (load_next) begin
                next_word_data  <= fifo_read_data;
                next_word_valid <= 1'b1;
            end

            // Build the next two-pixel stream beat.  `output_slot` permits a
            // new beat to replace an accepted beat in the same cycle, giving
            // one local beat per clock after the initial RAM/AXI latency.
            if (emit) begin
                pixel_data_r <= emit_two ? {next_pixel, cur_pixel}
                                         : {16'd0, cur_pixel};
                pixel_keep_r <= emit_two ? 2'b11 : 2'b01;
                pixel_valid_r <= 1'b1;
                last_beat_r <= emit_one || (pixels_remaining == 16'd2);
                if (emit_two)
                    pixels_remaining <= pixels_remaining - 16'd2;
                else
                    pixels_remaining <= pixels_remaining - 16'd1;

                if (cur_index == 3'd7) begin
                    if (emit_two) begin
                        if (next_word_valid) begin
                            cur_word_data  <= next_word_data;
                            cur_word_valid <= 1'b1;
                            cur_index      <= 3'd1;
                            next_word_valid <= 1'b0;
                        end else begin
                            cur_word_valid <= 1'b0;
                            cur_index      <= 3'd0;
                        end
                    end else begin
                        cur_word_valid <= 1'b0;
                        cur_index      <= 3'd0;
                    end
                end else if (emit_two) begin
                    if (cur_index == 3'd6) begin
                        if (next_word_valid) begin
                            cur_word_data  <= next_word_data;
                            cur_word_valid <= 1'b1;
                            cur_index      <= 3'd0;
                            next_word_valid <= 1'b0;
                        end else begin
                            cur_word_valid <= 1'b0;
                            cur_index      <= 3'd0;
                        end
                    end else begin
                        cur_index <= cur_index + 2'd2;
                    end
                end else begin
                    cur_index <= cur_index + 1'b1;
                end
            end

            if (pixel_valid_r && pixel_ready) begin
                if (last_beat_r) begin
                    pixel_valid_r <= 1'b0;
                    done <= 1'b1;
                    state <= ST_IDLE;
                    read_finished_r <= 1'b0;
                    cur_word_valid <= 1'b0;
                    next_word_valid <= 1'b0;
                    fifo_count <= {(FIFO_PTR_W+1){1'b0}};
                    fifo_read_pending <= 0;
                end else if (!emit) begin
                    pixel_valid_r <= 1'b0;
                end
            end
        end
    end
endmodule

`default_nettype wire
