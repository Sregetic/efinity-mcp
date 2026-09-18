`default_nettype none
`timescale 1ns/1ps

// Two-read/two-write synchronous line RAM.  The two clocked processes are
// intentionally independent: Efinity can infer a true dual-port RAM, while
// simulation keeps the read registers unreset just like the target primitive.
module roi_line_ram_2r2w #(
    parameter integer MAX_LINE_PIXELS = 2560,
    parameter integer ADDR_WIDTH = (MAX_LINE_PIXELS <= 2) ? 1 : $clog2(MAX_LINE_PIXELS)
) (
    input  wire                   clk,
    input  wire                   we0,
    input  wire                   we1,
    input  wire [ADDR_WIDTH-1:0]  waddr0,
    input  wire [ADDR_WIDTH-1:0]  waddr1,
    input  wire [15:0]            wdata0,
    input  wire [15:0]            wdata1,
    input  wire                   re0,
    input  wire                   re1,
    input  wire [ADDR_WIDTH-1:0]  raddr0,
    input  wire [ADDR_WIDTH-1:0]  raddr1,
    output reg  [15:0]            rdata0,
    output reg  [15:0]            rdata1
);
    reg [15:0] mem [0:MAX_LINE_PIXELS-1];
    // Efinity's RAM extractor requires one common address expression per
    // physical port.  Write and read are mutually exclusive on each port;
    // the opposite bank is read while the inactive bank is written.
    wire [ADDR_WIDTH-1:0] addr0 = we0 ? waddr0 : raddr0;
    wire [ADDR_WIDTH-1:0] addr1 = we1 ? waddr1 : raddr1;

    always @(posedge clk) begin
        if (we0)
            mem[addr0] <= wdata0;
        rdata0 <= mem[addr0];
    end

    always @(posedge clk) begin
        if (we1)
            mem[addr1] <= wdata1;
        rdata1 <= mem[addr1];
    end
endmodule

module roi_scaler #(
    parameter integer MAX_LINE_PIXELS = 2560
) (
    input  wire        clk,
    input  wire        rst_n,

    input  wire        job_valid,
    output logic       job_ready,
    input  wire [31:0] base_addr,
    input  wire [15:0] src_width,
    input  wire [15:0] src_height,
    input  wire [31:0] stride_bytes,
    input  wire [15:0] roi_x,
    input  wire [15:0] roi_y,
    input  wire [15:0] roi_w,
    input  wire [15:0] roi_h,
    input  wire [15:0] dst_width,
    input  wire [15:0] dst_height,
    input  wire [31:0] frame_id,
    input  wire [31:0] config_id,

    output logic        pixel_valid,
    input  wire         pixel_ready,
    output logic [31:0] pixel_data,
    output logic [1:0]  pixel_keep,
    output logic        pixel_sof,
    output logic        pixel_eol,
    output logic        pixel_eof,
    output logic [31:0] pixel_frame_id,
    output logic [31:0] pixel_config_id,

    output logic        done,
    output logic        error,

    output logic        rd_cmd_valid,
    input  wire         rd_cmd_ready,
    output logic [31:0] rd_addr,
    output logic [15:0] rd_pixels,
    input  wire         rd_data_valid,
    output logic        rd_data_ready,
    input  wire [31:0] rd_data,
    input  wire [1:0]  rd_keep,
    input  wire        rd_error
);
    localparam [2:0] ST_IDLE         = 3'd0;
    localparam [2:0] ST_DIVIDE       = 3'd1;
    localparam [2:0] ST_WAIT_INITIAL = 3'd2;
    localparam [2:0] ST_RENDER       = 3'd3;
    localparam [2:0] ST_WAIT_ROW     = 3'd4;

    localparam integer LINE_ADDR_W = (MAX_LINE_PIXELS <= 2)
                                   ? 1 : $clog2(MAX_LINE_PIXELS);

    logic [2:0] state;
    logic       error_r;

    logic [31:0] base_addr_r;
    logic [31:0] stride_bytes_r;
    logic [15:0] src_width_r;
    logic [15:0] src_height_r;
    logic [15:0] roi_x_r;
    logic [15:0] roi_y_r;
    logic [15:0] roi_w_r;
    logic [15:0] roi_h_r;
    logic [15:0] dst_width_r;
    logic [15:0] dst_height_r;
    logic [31:0] frame_id_r;
    logic [31:0] config_id_r;

    // 16-round restoring dividers.  They are used only once per job; the
    // streaming coordinate path below is add/compare/subtract only.
    logic [4:0]  div_count_r;
    logic [15:0] x_div_num_r;
    logic [16:0] x_div_rem_r;
    logic [15:0] x_div_quot_r;
    logic [15:0] y_div_num_r;
    logic [16:0] y_div_rem_r;
    logic [15:0] y_div_quot_r;
    logic [15:0] x_step_int_r;
    logic [15:0] x_step_rem_r;
    logic [15:0] y_step_int_r;
    logic [15:0] y_step_rem_r;

    logic [16:0] x_div_trial_c;
    logic [16:0] x_div_rem_next_c;
    logic [15:0] x_div_quot_next_c;
    logic        x_div_take_c;
    logic [16:0] y_div_trial_c;
    logic [16:0] y_div_rem_next_c;
    logic [15:0] y_div_quot_next_c;
    logic        y_div_take_c;

    // Next output source coordinate (relative to the ROI) and the destination
    // pixel index of the next local beat.
    logic [16:0] x_src_r;
    logic [16:0] x_err_r;
    logic [15:0] dst_x_r;
    logic [16:0] src_y_r;
    logic [16:0] y_err_r;
    logic [15:0] dst_y_r;

    logic [17:0] x_err_sum1_c;
    logic [17:0] x_err_sum2_c;
    logic [17:0] x_err_sub1_c;
    logic [17:0] x_err_sub2_c;
    logic [16:0] x_err1_c;
    logic [16:0] x_err2_c;
    logic [16:0] x_src1_c;
    logic [16:0] x_src2_c;
    logic [17:0] x_src1_ext_c;
    logic [17:0] x_src2_ext_c;
    logic        x_carry1_c;
    logic        x_carry2_c;
    logic [1:0]  issue_pixels_c;
    logic        issue_eol_c;
    logic        issue_eof_c;

    logic [17:0] y_err_sum_c;
    logic [16:0] y_err_next_c;
    logic [17:0] y_err_sub_c;
    logic [16:0] src_y_next_c;
    logic [17:0] src_y_next_ext_c;
    logic        y_carry_c;

    // Ping-pong load control.  A load command and its data stream target the
    // bank opposite the row being displayed, allowing DDR and output to
    // overlap.  bank_row_* are relative-to-ROI source row numbers.
    logic       load_pending_r;
    logic       load_active_r;
    logic       load_target_bank_r;
    logic [16:0] load_row_r;
    logic [16:0] load_count_r;
    logic        bank_ready0_r;
    logic        bank_ready1_r;
    logic [16:0] bank_row0_r;
    logic [16:0] bank_row1_r;
    logic        cur_bank_r;
    logic        wait_bank_r;
    logic        row_wait_r;
    logic [16:0] wait_row_r;

    wire [1:0] load_keep = rd_keep;
    wire [1:0] load_pixel_count = (rd_keep == 2'b11) ? 2'd2
                                 : (rd_keep == 2'b01) ? 2'd1 : 2'd0;
    wire load_fire = load_active_r && rd_data_valid && rd_data_ready;
    wire load_we0 = load_fire && (rd_keep[0] == 1'b1)
                  && (load_count_r < MAX_LINE_PIXELS);
    wire load_we1 = load_fire && (rd_keep == 2'b11)
                  && ((load_count_r + 17'd1) < MAX_LINE_PIXELS);

    wire [LINE_ADDR_W-1:0] load_addr0 = load_count_r[LINE_ADDR_W-1:0];
    wire [16:0] load_addr1_ext = load_count_r + 17'd1;
    wire [LINE_ADDR_W-1:0] load_addr1 = load_addr1_ext[LINE_ADDR_W-1:0];

    logic        ram_re;
    logic [LINE_ADDR_W-1:0] ram_raddr0;
    logic [LINE_ADDR_W-1:0] ram_raddr1;
    logic [LINE_ADDR_W-1:0] ram_addr_hold0_r;
    logic [LINE_ADDR_W-1:0] ram_addr_hold1_r;
    logic [15:0] bank0_rdata0, bank0_rdata1;
    logic [15:0] bank1_rdata0, bank1_rdata1;

    wire [15:0] ram_rd0 = cur_bank_r ? bank1_rdata0 : bank0_rdata0;
    wire [15:0] ram_rd1 = cur_bank_r ? bank1_rdata1 : bank0_rdata1;

    // One registered output slot plus one registered RAM-read slot.  This
    // permits a new dual-read every cycle after warm-up, while a stalled
    // output freezes all payload and metadata.
    logic        rd_pending_r;
    logic [1:0]  pending_keep_r;
    logic        pending_sof_r;
    logic        pending_eol_r;
    logic        pending_eof_r;
    logic [31:0] pixel_data_r;
    logic [1:0]  pixel_keep_r;
    logic        pixel_valid_r;
    logic        pixel_sof_r;
    logic        pixel_eol_r;
    logic        pixel_eof_r;

    wire output_slot_c = !pixel_valid_r || pixel_ready;
    wire read_issue_c = (state == ST_RENDER)
                     && !row_wait_r
                     && (dst_x_r < dst_width_r)
                     && (!rd_pending_r || output_slot_c);

    wire capture_pending_c = rd_pending_r && output_slot_c;

    // Job validation is wide enough to avoid 16/32-bit wraparound.  In
    // particular, stride is independent from ROI width and the ROI address
    // need only be 2-byte aligned for RGB565.
    logic [16:0] roi_x_end_c;
    logic [16:0] roi_y_end_c;
    logic [32:0] src_row_bytes_c;
    logic [63:0] source_last_addr_c;
    logic [63:0] rd_addr_calc64_c;
    logic        job_bad_c;
    always @* begin
        roi_x_end_c = {1'b0, roi_x} + {1'b0, roi_w};
        roi_y_end_c = {1'b0, roi_y} + {1'b0, roi_h};
        src_row_bytes_c = ({17'd0, src_width} << 1);
        source_last_addr_c = {32'd0, base_addr}
                           + ({32'd0, stride_bytes}
                              * {48'd0, (src_height - 16'd1)})
                           + (({48'd0, src_width} << 1) - 64'd2);
        job_bad_c = 1'b0;
        if (src_width == 16'd0 || src_height == 16'd0
            || roi_w == 16'd0 || roi_h == 16'd0
            || dst_width == 16'd0 || dst_height == 16'd0)
            job_bad_c = 1'b1;
        if (roi_x_end_c > {1'b0, src_width}
            || roi_y_end_c > {1'b0, src_height})
            job_bad_c = 1'b1;
        if (roi_w > MAX_LINE_PIXELS)
            job_bad_c = 1'b1;
        if (base_addr[0] || stride_bytes[0])
            job_bad_c = 1'b1;
        if ({32'd0, stride_bytes} < {31'd0, src_row_bytes_c})
            job_bad_c = 1'b1;
        if (source_last_addr_c[63:32] != 32'd0)
            job_bad_c = 1'b1;
    end

    // Restoring-division next-state equations.  The 16-bit numerator is
    // shifted MSB-first for exactly sixteen cycles.
    assign x_div_trial_c = {x_div_rem_r[15:0], x_div_num_r[15]};
    assign x_div_take_c = x_div_trial_c >= {1'b0, dst_width_r};
    assign x_div_rem_next_c = x_div_take_c
                            ? x_div_trial_c - {1'b0, dst_width_r}
                            : x_div_trial_c;
    assign x_div_quot_next_c = {x_div_quot_r[14:0], x_div_take_c};
    assign y_div_trial_c = {y_div_rem_r[15:0], y_div_num_r[15]};
    assign y_div_take_c = y_div_trial_c >= {1'b0, dst_height_r};
    assign y_div_rem_next_c = y_div_take_c
                            ? y_div_trial_c - {1'b0, dst_height_r}
                            : y_div_trial_c;
    assign y_div_quot_next_c = {y_div_quot_r[14:0], y_div_take_c};

    // Horizontal floor-DDA, once for each pixel in the next beat.  No
    // division/modulo occurs in this per-beat path.
    always @* begin
        x_err_sum1_c = {1'b0, x_err_r} + {2'b00, x_step_rem_r};
        x_carry1_c = x_err_sum1_c >= {2'b00, dst_width_r};
        x_err_sub1_c = x_err_sum1_c - {2'b00, dst_width_r};
        x_err1_c = x_carry1_c ? x_err_sub1_c[16:0] : x_err_sum1_c[16:0];
        x_src1_ext_c = {1'b0, x_src_r} + {2'b00, x_step_int_r}
                      + (x_carry1_c ? 18'd1 : 18'd0);
        x_src1_c = x_src1_ext_c[16:0];

        x_err_sum2_c = {1'b0, x_err1_c} + {2'b00, x_step_rem_r};
        x_carry2_c = x_err_sum2_c >= {2'b00, dst_width_r};
        x_err_sub2_c = x_err_sum2_c - {2'b00, dst_width_r};
        x_err2_c = x_carry2_c ? x_err_sub2_c[16:0] : x_err_sum2_c[16:0];
        x_src2_ext_c = {1'b0, x_src1_c} + {2'b00, x_step_int_r}
                      + (x_carry2_c ? 18'd1 : 18'd0);
        x_src2_c = x_src2_ext_c[16:0];

        issue_pixels_c = ((dst_x_r + 16'd1) < dst_width_r) ? 2'd2 : 2'd1;
        issue_eol_c = ((dst_x_r + issue_pixels_c) >= dst_width_r);
        issue_eof_c = issue_eol_c && (dst_y_r == (dst_height_r - 16'd1));
    end

    // Vertical floor-DDA advances once per completed output row.
    always @* begin
        y_err_sum_c = {1'b0, y_err_r} + {2'b00, y_step_rem_r};
        y_carry_c = y_err_sum_c >= {2'b00, dst_height_r};
        y_err_sub_c = y_err_sum_c - {2'b00, dst_height_r};
        y_err_next_c = y_carry_c ? y_err_sub_c[16:0] : y_err_sum_c[16:0];
        src_y_next_ext_c = {1'b0, src_y_r} + {2'b00, y_step_int_r}
                         + (y_carry_c ? 18'd1 : 18'd0);
        src_y_next_c = src_y_next_ext_c[16:0];
    end

    always @* begin
        rd_addr_calc64_c = {32'd0, base_addr_r}
                         + ({32'd0, stride_bytes_r}
                            * ({47'd0, roi_y_r} + {47'd0, load_row_r}))
                         + ({48'd0, roi_x_r} << 1);
        rd_addr = rd_addr_calc64_c[31:0];
        rd_pixels = roi_w_r;
        rd_cmd_valid = load_pending_r && !load_active_r;
        rd_data_ready = load_active_r;
    end

    assign job_ready = (state == ST_IDLE) && !pixel_valid_r;
    assign pixel_valid = pixel_valid_r;
    assign pixel_data = pixel_data_r;
    assign pixel_keep = pixel_keep_r;
    assign pixel_sof = pixel_sof_r;
    assign pixel_eol = pixel_eol_r;
    assign pixel_eof = pixel_eof_r;
    assign pixel_frame_id = frame_id_r;
    assign pixel_config_id = config_id_r;
    assign error = error_r;

    assign ram_re = read_issue_c;
    always @* begin
        // The RAM template reads every cycle.  Hold the last issued address
        // on idle cycles so the registered result remains the pending beat;
        // on an issue edge the mux presents the new coordinates directly.
        ram_raddr0 = read_issue_c ? x_src_r[LINE_ADDR_W-1:0]
                                  : ram_addr_hold0_r;
        ram_raddr1 = read_issue_c
                   ? ((issue_pixels_c == 2'd2)
                      ? x_src1_c[LINE_ADDR_W-1:0]
                      : x_src_r[LINE_ADDR_W-1:0])
                   : ram_addr_hold1_r;
    end

    roi_line_ram_2r2w #(.MAX_LINE_PIXELS(MAX_LINE_PIXELS), .ADDR_WIDTH(LINE_ADDR_W))
    bank0 (
        .clk(clk),
        .we0(load_we0 && !load_target_bank_r),
        .we1(load_we1 && !load_target_bank_r),
        .waddr0(load_addr0), .waddr1(load_addr1),
        .wdata0(rd_data[15:0]), .wdata1(rd_data[31:16]),
        .re0(ram_re && !cur_bank_r), .re1(ram_re && !cur_bank_r),
        .raddr0(ram_raddr0), .raddr1(ram_raddr1),
        .rdata0(bank0_rdata0), .rdata1(bank0_rdata1)
    );

    roi_line_ram_2r2w #(.MAX_LINE_PIXELS(MAX_LINE_PIXELS), .ADDR_WIDTH(LINE_ADDR_W))
    bank1 (
        .clk(clk),
        .we0(load_we0 && load_target_bank_r),
        .we1(load_we1 && load_target_bank_r),
        .waddr0(load_addr0), .waddr1(load_addr1),
        .wdata0(rd_data[15:0]), .wdata1(rd_data[31:16]),
        .re0(ram_re && cur_bank_r), .re1(ram_re && cur_bank_r),
        .raddr0(ram_raddr0), .raddr1(ram_raddr1),
        .rdata0(bank1_rdata0), .rdata1(bank1_rdata1)
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            state              <= ST_IDLE;
            error_r            <= 1'b0;
            base_addr_r        <= 32'd0;
            stride_bytes_r     <= 32'd0;
            src_width_r        <= 16'd0;
            src_height_r       <= 16'd0;
            roi_x_r            <= 16'd0;
            roi_y_r            <= 16'd0;
            roi_w_r            <= 16'd0;
            roi_h_r            <= 16'd0;
            dst_width_r        <= 16'd0;
            dst_height_r       <= 16'd0;
            frame_id_r         <= 32'd0;
            config_id_r        <= 32'd0;
            div_count_r        <= 5'd0;
            x_div_num_r        <= 16'd0;
            x_div_rem_r        <= 17'd0;
            x_div_quot_r       <= 16'd0;
            y_div_num_r        <= 16'd0;
            y_div_rem_r        <= 17'd0;
            y_div_quot_r       <= 16'd0;
            x_step_int_r       <= 16'd0;
            x_step_rem_r       <= 16'd0;
            y_step_int_r       <= 16'd0;
            y_step_rem_r       <= 16'd0;
            x_src_r            <= 17'd0;
            x_err_r            <= 17'd0;
            dst_x_r            <= 16'd0;
            src_y_r            <= 17'd0;
            y_err_r            <= 17'd0;
            dst_y_r            <= 16'd0;
            load_pending_r     <= 1'b0;
            load_active_r      <= 1'b0;
            load_target_bank_r <= 1'b0;
            load_row_r         <= 17'd0;
            load_count_r       <= 17'd0;
            bank_ready0_r      <= 1'b0;
            bank_ready1_r      <= 1'b0;
            bank_row0_r        <= 17'd0;
            bank_row1_r        <= 17'd0;
            cur_bank_r         <= 1'b0;
            wait_bank_r        <= 1'b0;
            row_wait_r         <= 1'b0;
            wait_row_r         <= 17'd0;
            rd_pending_r       <= 1'b0;
            ram_addr_hold0_r   <= {LINE_ADDR_W{1'b0}};
            ram_addr_hold1_r   <= {LINE_ADDR_W{1'b0}};
            pending_keep_r     <= 2'b00;
            pending_sof_r      <= 1'b0;
            pending_eol_r      <= 1'b0;
            pending_eof_r      <= 1'b0;
            pixel_data_r       <= 32'd0;
            pixel_keep_r       <= 2'b00;
            pixel_valid_r      <= 1'b0;
            pixel_sof_r        <= 1'b0;
            pixel_eol_r        <= 1'b0;
            pixel_eof_r        <= 1'b0;
            done               <= 1'b0;
        end else begin
            done <= 1'b0;

            if (state != ST_IDLE && load_active_r && rd_error)
                error_r <= 1'b1;

            // A line command is held stable until the reader accepts it.
            if (rd_cmd_valid && rd_cmd_ready) begin
                load_pending_r <= 1'b0;
                load_active_r <= 1'b1;
                load_count_r <= 17'd0;
                if (load_target_bank_r)
                    bank_ready1_r <= 1'b0;
                else
                    bank_ready0_r <= 1'b0;
            end

            // Each accepted reader beat writes one or two pixels.  A malformed
            // keep is recorded and consumed, avoiding a permanent handshake
            // stall while keeping valid data untouched.
            if (load_fire) begin
                if (rd_keep != 2'b01 && rd_keep != 2'b11)
                    error_r <= 1'b1;
                if (rd_keep == 2'b11
                    && ((load_count_r + 17'd2) > {1'b0, roi_w_r}))
                    error_r <= 1'b1;
                if (rd_keep == 2'b01
                    && ((load_count_r + 17'd1) > {1'b0, roi_w_r}))
                    error_r <= 1'b1;

                if (load_keep == 2'b11)
                    load_count_r <= load_count_r + 17'd2;
                else if (load_keep == 2'b01)
                    load_count_r <= load_count_r + 17'd1;

                if (load_keep == 2'b01 || load_keep == 2'b11) begin
                    if ((load_count_r + load_pixel_count) >= {1'b0, roi_w_r}) begin
                        load_active_r <= 1'b0;
                        if (load_target_bank_r) begin
                            bank_ready1_r <= 1'b1;
                            bank_row1_r <= load_row_r;
                        end else begin
                            bank_ready0_r <= 1'b1;
                            bank_row0_r <= load_row_r;
                        end
                    end
                end
            end

            // Two-stage synchronous-RAM output pipeline.  Capture and issue
            // may happen together, which is the steady-state one-beat/clock
            // path for two pixels per beat.
            if (capture_pending_c) begin
                pixel_data_r <= (pending_keep_r == 2'b01) ? {16'd0, ram_rd0} : {ram_rd1, ram_rd0};
                pixel_keep_r <= pending_keep_r;
                pixel_sof_r <= pending_sof_r;
                pixel_eol_r <= pending_eol_r;
                pixel_eof_r <= pending_eof_r;
                pixel_valid_r <= 1'b1;
            end else if (pixel_valid_r && pixel_ready) begin
                pixel_valid_r <= 1'b0;
            end

            if (read_issue_c) begin
                ram_addr_hold0_r <= x_src_r[LINE_ADDR_W-1:0];
                ram_addr_hold1_r <= (issue_pixels_c == 2'd2)
                                  ? x_src1_c[LINE_ADDR_W-1:0]
                                  : x_src_r[LINE_ADDR_W-1:0];
                rd_pending_r <= 1'b1;
                pending_keep_r <= (issue_pixels_c == 2'd2) ? 2'b11 : 2'b01;
                pending_sof_r <= (dst_x_r == 16'd0 && dst_y_r == 16'd0);
                pending_eol_r <= issue_eol_c;
                pending_eof_r <= issue_eof_c;
                dst_x_r <= dst_x_r + issue_pixels_c;
                if (issue_pixels_c == 2'd2) begin
                    x_src_r <= x_src2_c;
                    x_err_r <= x_err2_c;
                end else begin
                    x_src_r <= x_src1_c;
                    x_err_r <= x_err1_c;
                end
            end else if (capture_pending_c) begin
                rd_pending_r <= 1'b0;
            end

            // A valid row's final output beat is the only normal completion
            // point.  The current output slot is already stable until this
            // handshake, including all ID and flag fields.
            if (pixel_valid_r && pixel_ready && pixel_eof_r) begin
                done <= 1'b1;
                state <= ST_IDLE;
                pixel_valid_r <= 1'b0;
                load_pending_r <= 1'b0;
                load_active_r <= 1'b0;
                rd_pending_r <= 1'b0;
            end else if (pixel_valid_r && pixel_ready && pixel_eol_r
                         && (dst_y_r < (dst_height_r - 16'd1))) begin
                // The vertical DDA advances exactly once per accepted output
                // row, not when a read is issued.  A changed source row waits
                // for its prefetched bank; a repeated row reuses the current
                // bank without another DDR command.
                src_y_r <= src_y_next_c;
                y_err_r <= y_err_next_c;
                dst_y_r <= dst_y_r + 16'd1;
                dst_x_r <= 16'd0;
                x_src_r <= 17'd0;
                x_err_r <= 17'd0;
                if (src_y_next_c != src_y_r) begin
                    wait_bank_r <= ~cur_bank_r;
                    wait_row_r <= src_y_next_c;
                    if ((cur_bank_r && bank_ready0_r
                         && bank_row0_r == src_y_next_c)
                        || (!cur_bank_r && bank_ready1_r
                            && bank_row1_r == src_y_next_c)) begin
                        cur_bank_r <= ~cur_bank_r;
                        row_wait_r <= 1'b0;
                        state <= ST_RENDER;
                    end else begin
                        row_wait_r <= 1'b1;
                        state <= ST_WAIT_ROW;
                        if (!load_active_r && !load_pending_r) begin
                            load_pending_r <= 1'b1;
                            load_target_bank_r <= ~cur_bank_r;
                            load_row_r <= src_y_next_c;
                        end
                    end
                end else begin
                    state <= ST_RENDER;
                end
            end

            if (state == ST_WAIT_ROW) begin
                if ((!wait_bank_r && bank_ready0_r && bank_row0_r == wait_row_r)
                    || (wait_bank_r && bank_ready1_r && bank_row1_r == wait_row_r)) begin
                    cur_bank_r <= wait_bank_r;
                    row_wait_r <= 1'b0;
                    state <= ST_RENDER;
                end
            end

            // Schedule the next changed source row while the current row is
            // still being emitted.  The check against bank_row avoids rereads
            // when a vertical enlargement repeats a row.
            if (state == ST_RENDER && !load_active_r && !load_pending_r
                && (dst_y_r < (dst_height_r - 16'd1))
                && (src_y_next_c != src_y_r)
                && ((!cur_bank_r && !(bank_ready1_r
                                      && bank_row1_r == src_y_next_c))
                    || (cur_bank_r && !(bank_ready0_r
                                        && bank_row0_r == src_y_next_c)))) begin
                load_pending_r <= 1'b1;
                load_target_bank_r <= ~cur_bank_r;
                load_row_r <= src_y_next_c;
            end

            case (state)
                ST_IDLE: begin
                    pixel_valid_r <= 1'b0;
                    if (job_valid && job_ready) begin
                        frame_id_r <= frame_id;
                        config_id_r <= config_id;
                        if (job_bad_c) begin
                            error_r <= 1'b1;
                            done <= 1'b1;
                        end else begin
                            error_r <= 1'b0;
                            base_addr_r <= base_addr;
                            stride_bytes_r <= stride_bytes;
                            src_width_r <= src_width;
                            src_height_r <= src_height;
                            roi_x_r <= roi_x;
                            roi_y_r <= roi_y;
                            roi_w_r <= roi_w;
                            roi_h_r <= roi_h;
                            dst_width_r <= dst_width;
                            dst_height_r <= dst_height;
                            div_count_r <= 5'd0;
                            x_div_num_r <= roi_w;
                            x_div_rem_r <= 17'd0;
                            x_div_quot_r <= 16'd0;
                            y_div_num_r <= roi_h;
                            y_div_rem_r <= 17'd0;
                            y_div_quot_r <= 16'd0;
                            x_step_int_r <= 16'd0;
                            x_step_rem_r <= 16'd0;
                            y_step_int_r <= 16'd0;
                            y_step_rem_r <= 16'd0;
                            x_src_r <= 17'd0;
                            x_err_r <= 17'd0;
                            dst_x_r <= 16'd0;
                            src_y_r <= 17'd0;
                            y_err_r <= 17'd0;
                            dst_y_r <= 16'd0;
                            load_pending_r <= 1'b0;
                            load_active_r <= 1'b0;
                            bank_ready0_r <= 1'b0;
                            bank_ready1_r <= 1'b0;
                            cur_bank_r <= 1'b0;
                            row_wait_r <= 1'b0;
                            rd_pending_r <= 1'b0;
                            pixel_valid_r <= 1'b0;
                            state <= ST_DIVIDE;
                        end
                    end
                end

                ST_DIVIDE: begin
                    pixel_valid_r <= 1'b0;
                    x_div_num_r <= {x_div_num_r[14:0], 1'b0};
                    x_div_rem_r <= x_div_rem_next_c;
                    x_div_quot_r <= x_div_quot_next_c;
                    y_div_num_r <= {y_div_num_r[14:0], 1'b0};
                    y_div_rem_r <= y_div_rem_next_c;
                    y_div_quot_r <= y_div_quot_next_c;
                    if (div_count_r == 5'd15) begin
                        x_step_int_r <= x_div_quot_next_c;
                        x_step_rem_r <= x_div_rem_next_c[15:0];
                        y_step_int_r <= y_div_quot_next_c;
                        y_step_rem_r <= y_div_rem_next_c[15:0];
                        load_pending_r <= 1'b1;
                        load_target_bank_r <= 1'b0;
                        load_row_r <= 17'd0;
                        state <= ST_WAIT_INITIAL;
                    end else begin
                        div_count_r <= div_count_r + 5'd1;
                    end
                end

                ST_WAIT_INITIAL: begin
                    pixel_valid_r <= 1'b0;
                    if (!load_active_r && !load_pending_r) begin
                        // The only way out is the initial line's final beat;
                        // keep this branch as a harmless guard for malformed
                        // readers that terminate without returning pixels.
                        if (error_r)
                            state <= ST_IDLE;
                    end
                    if (bank_ready0_r && !load_active_r) begin
                        state <= ST_RENDER;
                        cur_bank_r <= 1'b0;
                        src_y_r <= 17'd0;
                        y_err_r <= 17'd0;
                        dst_y_r <= 16'd0;
                        dst_x_r <= 16'd0;
                        x_src_r <= 17'd0;
                        x_err_r <= 17'd0;
                    end
                end

                ST_RENDER: begin
                    // Main work is handled by the pipeline and row-completion
                    // blocks above.
                end

                ST_WAIT_ROW: begin
                    pixel_valid_r <= 1'b0;
                end

                default: state <= ST_IDLE;
            endcase
        end
    end
endmodule

`default_nettype wire
