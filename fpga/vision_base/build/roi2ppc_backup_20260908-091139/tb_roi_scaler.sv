`timescale 1ns/1ps
`default_nettype none

module tb_roi_scaler;
    localparam integer MAX_LINE_PIXELS = 2560;

    logic        clk;
    logic        rst_n;
    logic        job_valid;
    logic        job_ready;
    logic [31:0] base_addr;
    logic [15:0] src_width;
    logic [15:0] src_height;
    logic [31:0] stride_bytes;
    logic [15:0] roi_x;
    logic [15:0] roi_y;
    logic [15:0] roi_w;
    logic [15:0] roi_h;
    logic [15:0] dst_width;
    logic [15:0] dst_height;
    logic [31:0] frame_id;
    logic [31:0] config_id;

    logic        pixel_valid;
    logic        pixel_ready;
    logic [15:0] pixel_data;
    logic        pixel_sof;
    logic        pixel_eol;
    logic        pixel_eof;
    logic [31:0] pixel_frame_id;
    logic [31:0] pixel_config_id;
    logic        done;
    logic        error;

    logic        rd_cmd_valid;
    logic        rd_cmd_ready;
    logic [31:0] rd_addr;
    logic [15:0] rd_pixels;
    logic        rd_data_valid;
    logic        rd_data_ready;
    logic [15:0] rd_data;

    roi_scaler #(
        .MAX_LINE_PIXELS(MAX_LINE_PIXELS)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .job_valid(job_valid),
        .job_ready(job_ready),
        .base_addr(base_addr),
        .src_width(src_width),
        .src_height(src_height),
        .stride_bytes(stride_bytes),
        .roi_x(roi_x),
        .roi_y(roi_y),
        .roi_w(roi_w),
        .roi_h(roi_h),
        .dst_width(dst_width),
        .dst_height(dst_height),
        .frame_id(frame_id),
        .config_id(config_id),
        .pixel_valid(pixel_valid),
        .pixel_ready(pixel_ready),
        .pixel_data(pixel_data),
        .pixel_sof(pixel_sof),
        .pixel_eol(pixel_eol),
        .pixel_eof(pixel_eof),
        .pixel_frame_id(pixel_frame_id),
        .pixel_config_id(pixel_config_id),
        .done(done),
        .error(error),
        .rd_cmd_valid(rd_cmd_valid),
        .rd_cmd_ready(rd_cmd_ready),
        .rd_addr(rd_addr),
        .rd_pixels(rd_pixels),
        .rd_data_valid(rd_data_valid),
        .rd_data_ready(rd_data_ready),
        .rd_data(rd_data)
    );

    always #5 clk = ~clk;

    // Case description used by both the scoreboard and the synthetic DDR.
    integer case_no;
    integer case_base_i;
    integer case_src_w_i;
    integer case_src_h_i;
    integer case_stride_i;
    integer case_roi_x_i;
    integer case_roi_y_i;
    integer case_roi_w_i;
    integer case_roi_h_i;
    integer case_dst_w_i;
    integer case_dst_h_i;
    integer case_frame_i;
    integer case_config_i;
    integer active_case;

    integer pixel_count;
    integer expected_x;
    integer expected_y;
    integer pixel_errors;
    integer flag_errors;
    integer id_errors;
    integer command_count;
    integer command_errors;
    integer stall_errors;
    integer command_hold_errors;
    integer test_cycle;
    integer accept_cycle;
    integer finish_cycle;

    function automatic [15:0] source_pattern(input integer sx, input integer sy);
        integer v;
        begin
            // Deliberately non-solid pattern so x/y mixups and ROI offsets show.
            v = ((sx * 16'h0137) ^ (sy * 16'h028d)
                 ^ ((sx + 3 * sy) << 5) ^ (sx * sy));
            source_pattern = v[15:0];
        end
    endfunction

    function automatic integer expected_source_x(input integer ox);
        begin
            expected_source_x = case_roi_x_i
                              + ((ox * case_roi_w_i) / case_dst_w_i);
        end
    endfunction

    function automatic integer expected_source_y(input integer oy);
        begin
            expected_source_y = case_roi_y_i
                              + ((oy * case_roi_h_i) / case_dst_h_i);
        end
    endfunction

    // Output backpressure: the stream has real hold periods but is mostly open.
    integer ready_phase;
    always @(negedge clk) begin
        ready_phase = ready_phase + 1;
        pixel_ready <= ((ready_phase % 9) != 0) && ((ready_phase % 17) != 0);
    end

    // Synthetic one-command-in-flight DDR line responder. It inserts command
    // wait cycles, response latency, and response gaps while honoring ready/valid.
    localparam integer MEM_IDLE = 0;
    localparam integer MEM_WAIT = 1;
    localparam integer MEM_SEND = 2;
    integer mem_state;
    integer mem_wait_count;
    integer mem_gap_count;
    integer mem_index;
    integer mem_len;
    integer mem_row;
    integer mem_x0;
    integer mem_addr_i;
    integer delta_i;
    integer command_row_i;
    integer command_x_i;
    integer last_command_row_i;
    logic [31:0] mem_addr_r;
    logic        pixel_stall_seen;
    logic [15:0] pixel_stall_data;
    logic        pixel_stall_sof;
    logic        pixel_stall_eol;
    logic        pixel_stall_eof;
    logic [31:0] pixel_stall_frame;
    logic [31:0] pixel_stall_config;
    logic        command_hold_seen;
    logic [31:0] command_hold_addr;
    logic [15:0] command_hold_pixels;

    assign rd_cmd_ready = (mem_state == MEM_IDLE)
                        && ((test_cycle % 4) != 0);

    always @(posedge clk) begin
        if (!rst_n) begin
            mem_state <= MEM_IDLE;
            mem_wait_count <= 0;
            mem_gap_count <= 0;
            mem_index <= 0;
            mem_len <= 0;
            mem_row <= 0;
            mem_x0 <= 0;
            mem_addr_r <= 32'd0;
            rd_data_valid <= 1'b0;
            rd_data <= 16'd0;
            command_count <= 0;
            command_errors <= 0;
            last_command_row_i <= -1;
        end else begin
            if (mem_state == MEM_IDLE) begin
                rd_data_valid <= 1'b0;
                if (rd_cmd_valid && rd_cmd_ready) begin
                    mem_state <= MEM_WAIT;
                    mem_wait_count <= 1 + (command_count % 3);
                    mem_gap_count <= 0;
                    mem_index <= 0;
                    mem_len <= rd_pixels;
                    mem_addr_r <= rd_addr;

                    // Decode and check the byte-addressed, padded-row command.
                    delta_i = rd_addr - case_base_i;
                    if (case_stride_i <= 0 || delta_i < 0
                        || (delta_i % case_stride_i) != (case_roi_x_i * 2)
                        || (delta_i % 2) != 0) begin
                        command_errors = command_errors + 1;
                        $display("ERROR command address case=%0d addr=%08h base=%08h stride=%0d", case_no, rd_addr, case_base_i, case_stride_i);
                        command_row_i = -1;
                        command_x_i = -1;
                    end else begin
                        command_row_i = delta_i / case_stride_i;
                        command_x_i = (delta_i % case_stride_i) / 2;
                        if (command_row_i < case_roi_y_i
                            || command_row_i >= case_roi_y_i + case_roi_h_i
                            || command_x_i != case_roi_x_i
                            || rd_pixels != case_roi_w_i) begin
                            command_errors = command_errors + 1;
                            $display("ERROR command fields case=%0d row=%0d x=%0d pixels=%0d", case_no, command_row_i, command_x_i, rd_pixels);
                        end
                        if (last_command_row_i > command_row_i) begin
                            command_errors = command_errors + 1;
                            $display("ERROR command row regressed case=%0d prev=%0d now=%0d", case_no, last_command_row_i, command_row_i);
                        end
                        last_command_row_i = command_row_i;
                    end
                    mem_row <= command_row_i;
                    mem_x0 <= command_x_i;
                    command_count = command_count + 1;
                end
            end else if (mem_state == MEM_WAIT) begin
                rd_data_valid <= 1'b0;
                if (mem_wait_count == 0) begin
                    mem_state <= MEM_SEND;
                    rd_data <= source_pattern(mem_x0, mem_row);
                    rd_data_valid <= 1'b1;
                    mem_gap_count <= 0;
                end else begin
                    mem_wait_count <= mem_wait_count - 1;
                end
            end else begin
                // MEM_SEND: hold valid/data through any DUT backpressure.
                if (rd_data_valid && rd_data_ready) begin
                    if (mem_index == mem_len - 1) begin
                        rd_data_valid <= 1'b0;
                        mem_state <= MEM_IDLE;
                        mem_index <= 0;
                    end else begin
                        mem_index <= mem_index + 1;
                        mem_gap_count <= 1 + ((mem_index + mem_row) % 3 == 0);
                        rd_data_valid <= 1'b0;
                    end
                end else if (!rd_data_valid) begin
                    if (mem_gap_count == 0) begin
                        rd_data <= source_pattern(mem_x0 + mem_index, mem_row);
                        rd_data_valid <= 1'b1;
                    end else begin
                        mem_gap_count <= mem_gap_count - 1;
                    end
                end
            end
        end
    end

    // A cycle counter drives deterministic command/ready variation and gives
    // each case a bounded progress report.
    always @(posedge clk) begin
        if (!rst_n) begin
            test_cycle <= 0;
        end else begin
            test_cycle <= test_cycle + 1;
        end
    end

    // Compare only accepted output transfers. Values and flags are sampled
    // before the DUT's nonblocking updates on the same edge.
    always @(posedge clk) begin
        if (rst_n && active_case && pixel_valid && pixel_ready) begin
            if (pixel_data !== source_pattern(expected_source_x(expected_x),
                                              expected_source_y(expected_y))) begin
                pixel_errors = pixel_errors + 1;
                if (pixel_errors <= 5) begin
                    $display("ERROR pixel case=%0d out=(%0d,%0d) got=%04h exp=%04h src=(%0d,%0d)",
                             case_no, expected_x, expected_y, pixel_data,
                             source_pattern(expected_source_x(expected_x), expected_source_y(expected_y)),
                             expected_source_x(expected_x), expected_source_y(expected_y));
                end
            end
            if (pixel_sof !== (expected_x == 0 && expected_y == 0)) begin
                flag_errors = flag_errors + 1;
                $display("ERROR SOF case=%0d out=(%0d,%0d) got=%b", case_no, expected_x, expected_y, pixel_sof);
            end
            if (pixel_eol !== (expected_x == case_dst_w_i - 1)) begin
                flag_errors = flag_errors + 1;
                if (flag_errors <= 8) $display("ERROR EOL case=%0d out=(%0d,%0d) got=%b", case_no, expected_x, expected_y, pixel_eol);
            end
            if (pixel_eof !== (expected_x == case_dst_w_i - 1
                               && expected_y == case_dst_h_i - 1)) begin
                flag_errors = flag_errors + 1;
                if (flag_errors <= 8) $display("ERROR EOF case=%0d out=(%0d,%0d) got=%b", case_no, expected_x, expected_y, pixel_eof);
            end
            if (pixel_frame_id !== case_frame_i
                || pixel_config_id !== case_config_i) begin
                id_errors = id_errors + 1;
                if (id_errors <= 5) $display("ERROR ID case=%0d got frame=%08h config=%08h", case_no, pixel_frame_id, pixel_config_id);
            end

            pixel_count = pixel_count + 1;
            if (expected_x == case_dst_w_i - 1) begin
                expected_x = 0;
                expected_y = expected_y + 1;
            end else begin
                expected_x = expected_x + 1;
            end
        end
    end

    // Explicitly prove that a stalled output and a stalled row command hold
    // every payload/flag field stable, rather than relying only on ordering.
    always @(posedge clk) begin
        if (!rst_n) begin
            pixel_stall_seen <= 1'b0;
            command_hold_seen <= 1'b0;
        end else begin
            if (pixel_valid && !pixel_ready) begin
                if (pixel_stall_seen) begin
                    if (pixel_data !== pixel_stall_data
                        || pixel_sof !== pixel_stall_sof
                        || pixel_eol !== pixel_stall_eol
                        || pixel_eof !== pixel_stall_eof
                        || pixel_frame_id !== pixel_stall_frame
                        || pixel_config_id !== pixel_stall_config) begin
                        stall_errors = stall_errors + 1;
                        $display("ERROR stalled pixel changed case=%0d", case_no);
                    end
                end else begin
                    pixel_stall_seen <= 1'b1;
                    pixel_stall_data <= pixel_data;
                    pixel_stall_sof <= pixel_sof;
                    pixel_stall_eol <= pixel_eol;
                    pixel_stall_eof <= pixel_eof;
                    pixel_stall_frame <= pixel_frame_id;
                    pixel_stall_config <= pixel_config_id;
                end
            end else begin
                pixel_stall_seen <= 1'b0;
            end

            if (rd_cmd_valid && !rd_cmd_ready) begin
                if (command_hold_seen) begin
                    if (rd_addr !== command_hold_addr
                        || rd_pixels !== command_hold_pixels) begin
                        command_hold_errors = command_hold_errors + 1;
                        $display("ERROR stalled command changed case=%0d", case_no);
                    end
                end else begin
                    command_hold_seen <= 1'b1;
                    command_hold_addr <= rd_addr;
                    command_hold_pixels <= rd_pixels;
                end
            end else begin
                command_hold_seen <= 1'b0;
            end
        end
    end

    task automatic set_job_inputs(
        input integer p_base,
        input integer p_src_w,
        input integer p_src_h,
        input integer p_stride,
        input integer p_roi_x,
        input integer p_roi_y,
        input integer p_roi_w,
        input integer p_roi_h,
        input integer p_dst_w,
        input integer p_dst_h,
        input integer p_frame,
        input integer p_config
    );
        begin
            base_addr = p_base;
            src_width = p_src_w;
            src_height = p_src_h;
            stride_bytes = p_stride;
            roi_x = p_roi_x;
            roi_y = p_roi_y;
            roi_w = p_roi_w;
            roi_h = p_roi_h;
            dst_width = p_dst_w;
            dst_height = p_dst_h;
            frame_id = p_frame;
            config_id = p_config;
        end
    endtask

    task automatic mutate_job_inputs;
        begin
            // Deliberately change every field after the handshake. The active
            // job must continue using its locked copy.
            set_job_inputs(32'h00f0_0002, 99, 97, 202, 7, 8, 5, 4, 3, 2,
                           32'hdead_beef, 32'hcafe_f00d);
        end
    endtask

    task automatic run_case(
        input integer p_no,
        input integer p_base,
        input integer p_src_w,
        input integer p_src_h,
        input integer p_stride,
        input integer p_roi_x,
        input integer p_roi_y,
        input integer p_roi_w,
        input integer p_roi_h,
        input integer p_dst_w,
        input integer p_dst_h
    );
        integer start_count;
        begin
            case_no = p_no;
            case_base_i = p_base;
            case_src_w_i = p_src_w;
            case_src_h_i = p_src_h;
            case_stride_i = p_stride;
            case_roi_x_i = p_roi_x;
            case_roi_y_i = p_roi_y;
            case_roi_w_i = p_roi_w;
            case_roi_h_i = p_roi_h;
            case_dst_w_i = p_dst_w;
            case_dst_h_i = p_dst_h;
            case_frame_i = 32'h1000 + p_no;
            case_config_i = 32'h2000 + p_no;
            pixel_count = 0;
            expected_x = 0;
            expected_y = 0;
            pixel_errors = 0;
            flag_errors = 0;
            id_errors = 0;
            command_count = 0;
            command_errors = 0;
            stall_errors = 0;
            command_hold_errors = 0;
            last_command_row_i = -1;
            accept_cycle = test_cycle;
            active_case = 1;

            set_job_inputs(p_base, p_src_w, p_src_h, p_stride,
                           p_roi_x, p_roi_y, p_roi_w, p_roi_h,
                           p_dst_w, p_dst_h, case_frame_i, case_config_i);
            job_valid = 1'b1;
            while (!job_ready) @(posedge clk);
            @(posedge clk);
            @(negedge clk);
            job_valid = 1'b0;
            mutate_job_inputs();

            while (!done) @(posedge clk);
            finish_cycle = test_cycle;
            active_case = 0;
            start_count = p_dst_w * p_dst_h;
            if (pixel_count != start_count) begin
                $display("ERROR case=%0d pixel count got=%0d expected=%0d", p_no, pixel_count, start_count);
                $fatal(1);
            end
            if (expected_y != p_dst_h || expected_x != 0) begin
                $display("ERROR case=%0d scoreboard endpoint out=(%0d,%0d)", p_no, expected_x, expected_y);
                $fatal(1);
            end
            if (pixel_errors != 0 || flag_errors != 0 || id_errors != 0
                || command_errors != 0 || stall_errors != 0
                || command_hold_errors != 0) begin
                $display("ERROR case=%0d pixels=%0d flags=%0d ids=%0d commands=%0d stalls=%0d cmd_holds=%0d", p_no, pixel_errors, flag_errors, id_errors, command_errors, stall_errors, command_hold_errors);
                $fatal(1);
            end
            $display("PASS case=%0d pixels=%0d commands=%0d cycles=%0d", p_no, pixel_count, command_count, finish_cycle - accept_cycle);
        end
    endtask

    task automatic run_invalid_case(
        input integer p_no,
        input integer p_base,
        input integer p_src_w,
        input integer p_src_h,
        input integer p_stride,
        input integer p_roi_x,
        input integer p_roi_y,
        input integer p_roi_w,
        input integer p_roi_h,
        input integer p_dst_w,
        input integer p_dst_h
    );
        begin
            case_no = p_no;
            case_base_i = p_base;
            case_src_w_i = p_src_w;
            case_src_h_i = p_src_h;
            case_stride_i = p_stride;
            case_roi_x_i = p_roi_x;
            case_roi_y_i = p_roi_y;
            case_roi_w_i = p_roi_w;
            case_roi_h_i = p_roi_h;
            case_dst_w_i = p_dst_w;
            case_dst_h_i = p_dst_h;
            case_frame_i = 32'h3000 + p_no;
            case_config_i = 32'h4000 + p_no;
            pixel_count = 0;
            command_count = 0;
            command_errors = 0;
            active_case = 0;
            set_job_inputs(p_base, p_src_w, p_src_h, p_stride,
                           p_roi_x, p_roi_y, p_roi_w, p_roi_h,
                           p_dst_w, p_dst_h, case_frame_i, case_config_i);
            job_valid = 1'b1;
            while (!job_ready) @(posedge clk);
            @(posedge clk);
            @(negedge clk);
            job_valid = 1'b0;
            mutate_job_inputs();
            while (!done) @(posedge clk);
            if (!error) begin
                $display("ERROR invalid case=%0d did not raise error", p_no);
                $fatal(1);
            end
            if (command_count != 0) begin
                $display("ERROR invalid case=%0d issued %0d commands", p_no, command_count);
                $fatal(1);
            end
            $display("PASS invalid case=%0d no_memory_read=1", p_no);
        end
    endtask

    task automatic run_full_case;
        begin
            run_case(90, 32'h0100_0000, 1280, 720, 2560,
                     0, 0, 1280, 720, 1920, 1080);
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        job_valid = 1'b0;
        pixel_ready = 1'b1;
        ready_phase = 0;
        test_cycle = 0;
        active_case = 0;
        case_no = 0;
        case_base_i = 0;
        case_src_w_i = 0;
        case_src_h_i = 0;
        case_stride_i = 0;
        case_roi_x_i = 0;
        case_roi_y_i = 0;
        case_roi_w_i = 0;
        case_roi_h_i = 0;
        case_dst_w_i = 0;
        case_dst_h_i = 0;
        case_frame_i = 0;
        case_config_i = 0;
        #22;
        @(negedge clk);
        rst_n = 1'b1;

        // 2x horizontal and vertical enlargement; repeated source samples.
        run_case(1, 32'h0001_0000, 4, 3, 12, 0, 0, 2, 2, 4, 4);
        // Integer shrink, including source row/column skipping.
        run_case(2, 32'h0002_0000, 8, 6, 20, 1, 1, 6, 4, 3, 2);
        // Non-integer ratios in both axes; exact floor mapping is checked.
        run_case(3, 32'h0003_0000, 7, 5, 18, 1, 1, 5, 3, 4, 2);
        // Moved ROI with explicit per-row padding in stride.
        run_case(4, 32'h0004_0000, 9, 6, 24, 2, 2, 4, 3, 7, 5);
        // Error paths: odd base, odd stride, ROI bounds, and cache width.
        run_invalid_case(5, 32'h0005_0001, 8, 4, 16, 0, 0, 2, 2, 2, 2);
        run_invalid_case(6, 32'h0006_0000, 8, 4, 17, 0, 0, 2, 2, 2, 2);
        run_invalid_case(7, 32'h0007_0000, 8, 4, 16, 7, 0, 2, 2, 2, 2);
        run_invalid_case(8, 32'h0008_0000, 3000, 2, 6000, 0, 0, 2561, 1, 2, 2);

        if ($test$plusargs("FULL")) begin
            run_full_case();
        end else begin
            $display("INFO FULL case skipped (run with +FULL=1 for 1280x720->1920x1080)");
        end

        $display("PASS tb_roi_scaler");
        $finish;
    end

    initial begin
        // A malformed handshake or arithmetic bug should not leave CI waiting.
        if ($test$plusargs("FULL")) begin
            #100_000_000;
        end else begin
            #2_000_000;
        end
        $display("ERROR tb timeout");
        $fatal(1);
    end

endmodule

`default_nettype wire
