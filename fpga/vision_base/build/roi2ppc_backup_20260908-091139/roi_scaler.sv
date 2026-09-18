`default_nettype none
`timescale 1ns/1ps

module roi_scaler #(
    parameter integer MAX_LINE_PIXELS = 2560
) (
    input  wire        clk,
    input  wire        rst_n,

    input  wire        job_valid,
    output logic        job_ready,
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
    input  wire        pixel_ready,
    output logic [15:0] pixel_data,
    output logic        pixel_sof,
    output logic        pixel_eol,
    output logic        pixel_eof,
    output logic [31:0] pixel_frame_id,
    output logic [31:0] pixel_config_id,

    output logic        done,
    output logic        error,

    output logic        rd_cmd_valid,
    input  wire        rd_cmd_ready,
    output logic [31:0] rd_addr,
    output logic [15:0] rd_pixels,
    input  wire        rd_data_valid,
    output logic        rd_data_ready,
    input  wire [15:0] rd_data
);

    localparam logic [2:0] ST_IDLE = 3'd0;
    localparam logic [2:0] ST_LOAD_CMD = 3'd1;
    localparam logic [2:0] ST_LOAD_DATA = 3'd2;
    localparam logic [2:0] ST_OUTPUT = 3'd3;
    localparam logic [2:0] ST_DIVIDE = 3'd4;

    logic [2:0] state;

    logic [15:0] line_buf [0:MAX_LINE_PIXELS-1];
    logic [16:0] line_rd_addr;
    logic        line_rd_en;
    logic [15:0] line_rd_data;

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

    // Config-stage quotient/remainder. Two 16-round restoring dividers run in
    // parallel during ST_DIVIDE; no variable / or % operator is needed.
    logic [15:0] x_step_int_r;
    logic [15:0] x_step_rem_r;
    logic [15:0] y_step_int_r;
    logic [15:0] y_step_rem_r;

    logic [4:0]  div_count_r;
    logic [15:0] x_div_num_r;
    logic [16:0] x_div_rem_r;
    logic [15:0] x_div_quot_r;
    logic [15:0] y_div_num_r;
    logic [16:0] y_div_rem_r;
    logic [15:0] y_div_quot_r;

    logic [16:0] x_div_trial_c;
    logic [16:0] x_div_rem_next_c;
    logic [15:0] x_div_quot_next_c;
    logic        x_div_take_c;
    logic [16:0] y_div_trial_c;
    logic [16:0] y_div_rem_next_c;
    logic [15:0] y_div_quot_next_c;
    logic        y_div_take_c;

    // Current source coordinate for the output pixel and its residual.
    logic [16:0] src_x_rel_r;
    logic [16:0] src_y_rel_r;
    logic [16:0] x_err_r;
    logic [16:0] y_err_r;
    logic [15:0] out_x_r;
    logic [15:0] out_y_r;
    logic [15:0] line_wr_index_r;

    logic [16:0] roi_x_end_c;
    logic [16:0] roi_y_end_c;
    logic [32:0] src_row_bytes_c;
    logic [63:0] source_last_addr_c;
    logic        job_bad_c;

    logic [16:0] row_index_c;
    logic [63:0] rd_addr_calc64;

    logic [17:0] x_err_sum_c;
    logic [17:0] x_err_next_ext_c;
    logic [16:0] x_err_next_c;
    logic        x_carry_c;
    logic [17:0] src_x_next_ext_c;
    logic [16:0] src_x_next_c;

    logic [17:0] y_err_sum_c;
    logic [17:0] y_err_next_ext_c;
    logic [16:0] y_err_next_c;
    logic        y_carry_c;
    logic [17:0] src_y_next_ext_c;
    logic [16:0] src_y_next_c;

    assign job_ready = (state == ST_IDLE);

    assign rd_cmd_valid = (state == ST_LOAD_CMD);
    assign rd_addr = rd_addr_calc64[31:0];
    assign rd_pixels = roi_w_r;
    assign rd_data_ready = (state == ST_LOAD_DATA);

    // Keep the line-buffer read port independent from the control FSM. The
    // address is requested for the first pixel while the output slot is empty,
    // and for the next pixel only when the current slot is being accepted.
    // This makes the one-cycle synchronous RAM read explicit and keeps the
    // registered data stable throughout output backpressure.
    assign line_rd_en = (state == ST_OUTPUT)
                      && (!pixel_valid
                          || (pixel_ready
                              && out_x_r != (dst_width_r - 16'd1)));
    assign line_rd_addr = !pixel_valid ? src_x_rel_r : src_x_next_c;
    assign pixel_data = line_rd_data;

    // Dedicated synchronous write port. The FSM only advances the write
    // index; the RAM write itself is kept out of the FSM process.
    always_ff @(posedge clk) begin
        if (state == ST_LOAD_DATA && rd_data_valid && rd_data_ready) begin
            line_buf[line_wr_index_r] <= rd_data;
        end
    end

    // Dedicated synchronous read port. line_rd_data intentionally has no
    // reset so the inferred RAM/register follows the target memory primitive.
    always_ff @(posedge clk) begin
        if (line_rd_en) begin
            line_rd_data <= line_buf[line_rd_addr];
        end
    end

    // A 17-bit row index is sufficient for the checked source/ROI bounds.
    assign row_index_c = {1'b0, roi_y_r} + src_y_rel_r;
    always @* begin
        rd_addr_calc64 = {32'd0, base_addr_r};
        rd_addr_calc64 = rd_addr_calc64
                       + ({32'd0, stride_bytes_r} * {47'd0, row_index_c});
        rd_addr_calc64 = rd_addr_calc64 + ({48'd0, roi_x_r} << 1);
    end

    // One restoring-division bit per cycle, MSB first. The same 16-cycle
    // divider is duplicated for Y so the two ratios finish together.
    assign x_div_trial_c = {x_div_rem_r[15:0], x_div_num_r[15]};
    assign x_div_take_c = (x_div_trial_c >= {1'b0, dst_width_r});
    assign x_div_rem_next_c = x_div_take_c
                            ? x_div_trial_c - {1'b0, dst_width_r}
                            : x_div_trial_c;
    assign x_div_quot_next_c = {x_div_quot_r[14:0], x_div_take_c};

    assign y_div_trial_c = {y_div_rem_r[15:0], y_div_num_r[15]};
    assign y_div_take_c = (y_div_trial_c >= {1'b0, dst_height_r});
    assign y_div_rem_next_c = y_div_take_c
                            ? y_div_trial_c - {1'b0, dst_height_r}
                            : y_div_trial_c;
    assign y_div_quot_next_c = {y_div_quot_r[14:0], y_div_take_c};

    // Coordinate advance implements floor(n * roi/dst) without a divide per pixel.
    assign x_err_sum_c = {1'b0, x_err_r} + {2'b00, x_step_rem_r};
    assign x_carry_c = (x_err_sum_c >= {2'b00, dst_width_r});
    assign x_err_next_ext_c = x_carry_c
                            ? x_err_sum_c - {2'b00, dst_width_r}
                            : x_err_sum_c;
    assign x_err_next_c = x_err_next_ext_c[16:0];
    assign src_x_next_ext_c = {1'b0, src_x_rel_r}
                            + {2'b00, x_step_int_r}
                            + (x_carry_c ? 18'd1 : 18'd0);
    assign src_x_next_c = src_x_next_ext_c[16:0];

    assign y_err_sum_c = {1'b0, y_err_r} + {2'b00, y_step_rem_r};
    assign y_carry_c = (y_err_sum_c >= {2'b00, dst_height_r});
    assign y_err_next_ext_c = y_carry_c
                            ? y_err_sum_c - {2'b00, dst_height_r}
                            : y_err_sum_c;
    assign y_err_next_c = y_err_next_ext_c[16:0];
    assign src_y_next_ext_c = {1'b0, src_y_rel_r}
                            + {2'b00, y_step_int_r}
                            + (y_carry_c ? 18'd1 : 18'd0);
    assign src_y_next_c = src_y_next_ext_c[16:0];

    // Job validation is evaluated only at the job handshake. The extra width
    // on these expressions prevents 16/32-bit wraparound in the checks.
    always @* begin
        roi_x_end_c = {1'b0, roi_x} + {1'b0, roi_w};
        roi_y_end_c = {1'b0, roi_y} + {1'b0, roi_h};
        src_row_bytes_c = {16'd0, src_width, 1'b0};
        source_last_addr_c = {32'd0, base_addr}
                           + ({32'd0, stride_bytes}
                              * {48'd0, (src_height - 16'd1)})
                           + (({48'd0, src_width} << 1) - 64'd2);

        job_bad_c = 1'b0;
        if (src_width == 16'd0 || src_height == 16'd0) begin
            job_bad_c = 1'b1;
        end
        if (roi_w == 16'd0 || roi_h == 16'd0) begin
            job_bad_c = 1'b1;
        end
        if (dst_width == 16'd0 || dst_height == 16'd0) begin
            job_bad_c = 1'b1;
        end
        if (roi_x_end_c > {1'b0, src_width}
            || roi_y_end_c > {1'b0, src_height}) begin
            job_bad_c = 1'b1;
        end
        if (roi_w > MAX_LINE_PIXELS) begin
            job_bad_c = 1'b1;
        end
        if (base_addr[0] != 1'b0 || stride_bytes[0] != 1'b0) begin
            job_bad_c = 1'b1;
        end
        if ({32'd0, stride_bytes} < {31'd0, src_row_bytes_c}) begin
            job_bad_c = 1'b1;
        end
        if (source_last_addr_c[63:32] != 32'd0) begin
            job_bad_c = 1'b1;
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state <= ST_IDLE;
            base_addr_r <= 32'd0;
            stride_bytes_r <= 32'd0;
            src_width_r <= 16'd0;
            src_height_r <= 16'd0;
            roi_x_r <= 16'd0;
            roi_y_r <= 16'd0;
            roi_w_r <= 16'd0;
            roi_h_r <= 16'd0;
            dst_width_r <= 16'd0;
            dst_height_r <= 16'd0;
            frame_id_r <= 32'd0;
            config_id_r <= 32'd0;
            x_step_int_r <= 16'd0;
            x_step_rem_r <= 16'd0;
            y_step_int_r <= 16'd0;
            y_step_rem_r <= 16'd0;
            div_count_r <= 5'd0;
            x_div_num_r <= 16'd0;
            x_div_rem_r <= 17'd0;
            x_div_quot_r <= 16'd0;
            y_div_num_r <= 16'd0;
            y_div_rem_r <= 17'd0;
            y_div_quot_r <= 16'd0;
            src_x_rel_r <= 17'd0;
            src_y_rel_r <= 17'd0;
            x_err_r <= 17'd0;
            y_err_r <= 17'd0;
            out_x_r <= 16'd0;
            out_y_r <= 16'd0;
            line_wr_index_r <= 16'd0;
            pixel_valid <= 1'b0;
            pixel_sof <= 1'b0;
            pixel_eol <= 1'b0;
            pixel_eof <= 1'b0;
            pixel_frame_id <= 32'd0;
            pixel_config_id <= 32'd0;
            done <= 1'b0;
            error <= 1'b0;
        end else begin
            // done is a pulse; error is sticky until the next job/reset.
            done <= 1'b0;

            case (state)
                ST_IDLE: begin
                    pixel_valid <= 1'b0;
                    if (job_valid && job_ready) begin
                        frame_id_r <= frame_id;
                        config_id_r <= config_id;
                        pixel_frame_id <= frame_id;
                        pixel_config_id <= config_id;

                        if (job_bad_c) begin
                            // Invalid jobs never enter either memory state.
                            error <= 1'b1;
                            done <= 1'b1;
                        end else begin
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

                            // Start two 16-round restoring dividers. The
                            // quotient/remainder is captured before any row
                            // command is issued.
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

                            src_x_rel_r <= 17'd0;
                            src_y_rel_r <= 17'd0;
                            x_err_r <= 17'd0;
                            y_err_r <= 17'd0;
                            out_x_r <= 16'd0;
                            out_y_r <= 16'd0;
                            line_wr_index_r <= 16'd0;
                            pixel_valid <= 1'b0;
                            error <= 1'b0;
                            state <= ST_DIVIDE;
                        end
                    end
                end

                ST_DIVIDE: begin
                    pixel_valid <= 1'b0;
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
                        line_wr_index_r <= 16'd0;
                        state <= ST_LOAD_CMD;
                    end else begin
                        div_count_r <= div_count_r + 5'd1;
                    end
                end

                ST_LOAD_CMD: begin
                    pixel_valid <= 1'b0;
                    if (rd_cmd_valid && rd_cmd_ready) begin
                        line_wr_index_r <= 16'd0;
                        state <= ST_LOAD_DATA;
                    end
                end

                ST_LOAD_DATA: begin
                    pixel_valid <= 1'b0;
                    if (rd_data_valid && rd_data_ready) begin
                        if (line_wr_index_r == (roi_w_r - 16'd1)) begin
                            line_wr_index_r <= 16'd0;
                            state <= ST_OUTPUT;
                        end else begin
                            line_wr_index_r <= line_wr_index_r + 16'd1;
                        end
                    end
                end

                ST_OUTPUT: begin
                    if (!pixel_valid) begin
                        // line_rd_data is loaded by the independent synchronous
                        // read port on the preceding clock edge.
                        pixel_sof <= (out_x_r == 16'd0 && out_y_r == 16'd0);
                        pixel_eol <= (out_x_r == (dst_width_r - 16'd1));
                        pixel_eof <= (out_x_r == (dst_width_r - 16'd1)
                                      && out_y_r == (dst_height_r - 16'd1));
                        pixel_valid <= 1'b1;
                    end else if (pixel_ready) begin
                        if (out_x_r == (dst_width_r - 16'd1)
                            && out_y_r == (dst_height_r - 16'd1)) begin
                            // The final pixel is complete only on this handshake.
                            pixel_valid <= 1'b0;
                            done <= 1'b1;
                            state <= ST_IDLE;
                        end else if (out_x_r == (dst_width_r - 16'd1)) begin
                            // End of output line. A changed source row gets a new
                            // command; an unchanged row reuses the line cache.
                            pixel_valid <= 1'b0;
                            out_x_r <= 16'd0;
                            out_y_r <= out_y_r + 16'd1;
                            src_x_rel_r <= 17'd0;
                            x_err_r <= 17'd0;
                            src_y_rel_r <= src_y_next_c;
                            y_err_r <= y_err_next_c;
                            if (src_y_next_c != src_y_rel_r) begin
                                state <= ST_LOAD_CMD;
                            end else begin
                                state <= ST_OUTPUT;
                            end
                        end else begin
                            // Keep valid asserted and advance the source
                            // coordinate. line_rd_en requests src_x_next_c in
                            // parallel, so line_rd_data becomes the next pixel
                            // after this accepted-pixel edge.
                            out_x_r <= out_x_r + 16'd1;
                            src_x_rel_r <= src_x_next_c;
                            x_err_r <= x_err_next_c;
                            pixel_sof <= 1'b0;
                            pixel_eol <= ((out_x_r + 16'd1)
                                          == (dst_width_r - 16'd1));
                            pixel_eof <= ((out_x_r + 16'd1)
                                          == (dst_width_r - 16'd1)
                                          && out_y_r == (dst_height_r - 16'd1));
                            pixel_valid <= 1'b1;
                        end
                    end
                end

                default: begin
                    state <= ST_IDLE;
                    pixel_valid <= 1'b0;
                end
            endcase
        end
    end

endmodule

`default_nettype wire
