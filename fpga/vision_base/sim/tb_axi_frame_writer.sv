`timescale 1ns/1ps

// Protocol and memory scoreboard for axi_frame_writer.
// Run the default bounded regression with:
//   iverilog -g2012 -Wall -s tb_axi_frame_writer -o tb.vvp \
//       rtl/axi_frame_writer.sv sim/tb_axi_frame_writer.sv
//   vvp tb.vvp
// Add +FULL=1 for the 1920x1080 2PPC frame-budget case.
module tb_axi_frame_writer #(
    parameter integer TB_MAX_BURST_BEATS = 16
);
    localparam integer MEM_BYTES = 8 * 1024 * 1024;
    localparam integer FRAME_BUDGET_CYCLES = 1666667;
    localparam [7:0] PAD_BYTE = 8'ha5;

    reg clk = 1'b0;
    reg rst_n = 1'b0;
    always #5 clk = ~clk;

    reg        job_valid = 1'b0;
    wire       job_ready;
    reg [31:0] base_addr = 32'd0;
    reg [15:0] dst_width = 16'd0;
    reg [15:0] dst_height = 16'd0;
    reg [31:0] stride_bytes = 32'd0;

    reg        source_active = 1'b0;
    integer    source_index = 0;
    integer    source_total_beats = 0;
    integer    source_row_beats = 0;
    integer    marker_bad = 0;
    wire       pixel_valid;
    wire       pixel_ready;
    reg [31:0] pixel_data;
    reg [1:0]  pixel_keep;
    reg        pixel_sof;
    reg        pixel_eol;
    reg        pixel_eof;

    wire       busy;
    wire       done;
    wire       error;

    wire [3:0]   m_axi_awid;
    wire [31:0]  m_axi_awaddr;
    wire [7:0]   m_axi_awlen;
    wire [2:0]   m_axi_awsize;
    wire [1:0]   m_axi_awburst;
    wire         m_axi_awvalid;
    reg          m_axi_awready = 1'b0;
    wire [127:0] m_axi_wdata;
    wire [15:0]  m_axi_wstrb;
    wire         m_axi_wlast;
    wire         m_axi_wvalid;
    reg          m_axi_wready = 1'b0;
    reg [1:0]    m_axi_bresp = 2'b00;
    reg          m_axi_bvalid = 1'b0;
    wire         m_axi_bready;

    axi_frame_writer #(
        .MAX_BURST_BEATS(TB_MAX_BURST_BEATS)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .abort(1'b0),
        .job_valid(job_valid),
        .job_ready(job_ready),
        .base_addr(base_addr),
        .dst_width(dst_width),
        .dst_height(dst_height),
        .stride_bytes(stride_bytes),
        .pixel_valid(pixel_valid),
        .pixel_ready(pixel_ready),
        .pixel_data(pixel_data),
        .pixel_keep(pixel_keep),
        .pixel_sof(pixel_sof),
        .pixel_eol(pixel_eol),
        .pixel_eof(pixel_eof),
        .busy(busy),
        .done(done),
        .error(error),
        .m_axi_awid(m_axi_awid),
        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awlen(m_axi_awlen),
        .m_axi_awsize(m_axi_awsize),
        .m_axi_awburst(m_axi_awburst),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_awready(m_axi_awready),
        .m_axi_wdata(m_axi_wdata),
        .m_axi_wstrb(m_axi_wstrb),
        .m_axi_wlast(m_axi_wlast),
        .m_axi_wvalid(m_axi_wvalid),
        .m_axi_wready(m_axi_wready),
        .m_axi_bresp(m_axi_bresp),
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_bready(m_axi_bready)
    );

    function automatic [15:0] ref_pixel;
        input integer pixel_number;
        begin
            ref_pixel = (pixel_number * 16'h0137)
                        ^ (pixel_number >> 2)
                        ^ 16'h5a3c;
        end
    endfunction

    function automatic [31:0] source_word;
        input integer beat_number;
        begin
            source_word = {ref_pixel(beat_number * 2 + 1),
                           ref_pixel(beat_number * 2)};
        end
    endfunction

    function automatic [127:0] expected_wdata;
        input [31:0] address;
        integer row_number;
        integer byte_in_row;
        integer first_pixel;
        integer word_index;
        begin
            row_number = (address - case_base) / case_stride;
            byte_in_row = address - (case_base + row_number * case_stride);
            first_pixel = row_number * case_width + (byte_in_row / 2);
            expected_wdata = 128'd0;
            for (word_index = 0; word_index < 4; word_index = word_index + 1) begin
                expected_wdata[word_index * 32 +: 16] =
                    ref_pixel(first_pixel + word_index * 2);
                expected_wdata[word_index * 32 + 16 +: 16] =
                    ref_pixel(first_pixel + word_index * 2 + 1);
            end
        end
    endfunction

    reg [7:0] memory [0:MEM_BYTES-1];

    // Current case configuration, used by both source and memory scoreboards.
    reg [31:0] case_base;
    integer case_width;
    integer case_height;
    integer case_stride;
    integer case_valid;
    integer inject_b_error;
    integer ideal_bus;
    integer bus_hold_until;

    // AXI write-channel scoreboard state.
    reg         aw_inflight;
    integer     w_remaining;
    reg [31:0]  write_address;
    reg         b_pending;
    integer     b_delay;
    reg         last_b_expected;
    reg         last_b_seen;
    integer     score_total_beats;
    reg [31:0]  score_address;
    integer     score_row_beats;
    integer     score_rows;
    integer     score_burst_len;
    integer     score_burst_row_remaining;
    integer     score_burst_rows;
    integer     commands;
    integer     write_beats;

    // Stable-under-stall snapshots.
    reg         previous_pixel_stall;
    reg [31:0]  previous_pixel_data;
    reg [1:0]   previous_pixel_keep;
    reg         previous_pixel_sof;
    reg         previous_pixel_eol;
    reg         previous_pixel_eof;
    reg         previous_aw_stall;
    reg [3:0]   previous_awid;
    reg [31:0]  previous_awaddr;
    reg [7:0]   previous_awlen;
    reg [2:0]   previous_awsize;
    reg [1:0]   previous_awburst;
    reg         previous_w_stall;
    reg [127:0] previous_wdata;
    reg [15:0]  previous_wstrb;
    reg         previous_wlast;
    reg         pixel_stall_seen;
    reg         aw_stall_seen;
    reg         w_stall_seen;

    integer cycle;
    integer k;

    assign pixel_valid = source_active && (source_index < source_total_beats);

    // The producer holds every field stable while valid is stalled.  Marker
    // corruption is intentional in one regression case; the writer must
    // still drain the dimension-known number of input beats.
    always @* begin
        pixel_data = 32'd0;
        pixel_keep = 2'b00;
        pixel_sof = 1'b0;
        pixel_eol = 1'b0;
        pixel_eof = 1'b0;
        if (pixel_valid) begin
            pixel_data = source_word(source_index);
            pixel_keep = 2'b11;
            pixel_sof = (source_index == 0);
            pixel_eol = ((source_index % source_row_beats) == source_row_beats - 1);
            pixel_eof = (source_index == source_total_beats - 1);
            if (marker_bad != 0) begin
                if (source_index == 0)
                    pixel_keep = 2'b01;
                if (source_index == source_row_beats - 1)
                    pixel_eol = ~pixel_eol;
            end
        end
    end

    task automatic clear_region;
        input [31:0] region_base;
        input integer region_stride;
        input integer region_height;
        integer address;
        begin
            for (address = region_base;
                 address < region_base + region_stride * region_height;
                 address = address + 1)
                memory[address] = PAD_BYTE;
        end
    endtask

    task automatic check_memory;
        integer row_number;
        integer pixel_number;
        integer address;
        reg [15:0] expected_pixel;
        begin
            for (row_number = 0; row_number < case_height; row_number = row_number + 1) begin
                for (pixel_number = 0; pixel_number < case_width; pixel_number = pixel_number + 1) begin
                    address = case_base + row_number * case_stride + pixel_number * 2;
                    expected_pixel = ref_pixel(row_number * case_width + pixel_number);
                    if (memory[address] !== expected_pixel[7:0])
                        $fatal(1, "Low byte mismatch row=%0d pixel=%0d", row_number, pixel_number);
                    if (memory[address + 1] !== expected_pixel[15:8])
                        $fatal(1, "High byte mismatch row=%0d pixel=%0d", row_number, pixel_number);
                end
                for (address = case_base + row_number * case_stride + case_width * 2;
                     address < case_base + row_number * case_stride + case_stride;
                     address = address + 1) begin
                    if (memory[address] !== PAD_BYTE)
                        $fatal(1, "Padding overwritten row=%0d address=%h", row_number, address);
                end
            end
        end
    endtask

    // Drive deterministic but non-continuous ready signals.  The bounded bus
    // hold on one case fills the small FIFO and exercises pixel_ready=0.
    always @(negedge clk) begin
        cycle = cycle + 1;
        if (ideal_bus != 0) begin
            m_axi_awready = !aw_inflight && !b_pending && !m_axi_bvalid &&
                            (cycle >= bus_hold_until);
            m_axi_wready = aw_inflight && (cycle >= bus_hold_until);
        end else begin
            m_axi_awready = !aw_inflight && !b_pending && !m_axi_bvalid &&
                            (cycle >= bus_hold_until) && (cycle % 5 != 0);
            m_axi_wready = aw_inflight && (cycle >= bus_hold_until) &&
                           (cycle % 4 != 1);
        end
    end

    // Source index and AXI memory model.  The model accepts at most one
    // burst, but AW, W and B each have their own handshake and hold state.
    always @(posedge clk) begin
        if (!rst_n) begin
            source_index <= 0;
            aw_inflight <= 1'b0;
            w_remaining <= 0;
            write_address <= 32'd0;
            b_pending <= 1'b0;
            b_delay <= 0;
            m_axi_bvalid <= 1'b0;
            m_axi_bresp <= 2'b00;
            last_b_expected <= 1'b0;
            last_b_seen <= 1'b0;
            score_total_beats <= 0;
            score_address <= 32'd0;
            score_row_beats <= 0;
            score_rows <= 0;
            commands <= 0;
            write_beats <= 0;
            previous_pixel_stall <= 1'b0;
            previous_aw_stall <= 1'b0;
            previous_w_stall <= 1'b0;
            pixel_stall_seen <= 1'b0;
            aw_stall_seen <= 1'b0;
            w_stall_seen <= 1'b0;
        end else begin
            if (previous_pixel_stall &&
                (!pixel_valid || pixel_data !== previous_pixel_data ||
                 pixel_keep !== previous_pixel_keep || pixel_sof !== previous_pixel_sof ||
                 pixel_eol !== previous_pixel_eol || pixel_eof !== previous_pixel_eof))
                $fatal(1, "Pixel payload changed while stalled");
            if (previous_aw_stall &&
                (!m_axi_awvalid || m_axi_awid !== previous_awid ||
                 m_axi_awaddr !== previous_awaddr || m_axi_awlen !== previous_awlen ||
                 m_axi_awsize !== previous_awsize || m_axi_awburst !== previous_awburst))
                $fatal(1, "AW payload changed while stalled");
            if (previous_w_stall &&
                (!m_axi_wvalid || m_axi_wdata !== previous_wdata ||
                 m_axi_wstrb !== previous_wstrb || m_axi_wlast !== previous_wlast))
                $fatal(1, "W payload changed while stalled");

            previous_pixel_stall <= pixel_valid && !pixel_ready;
            previous_pixel_data <= pixel_data;
            previous_pixel_keep <= pixel_keep;
            previous_pixel_sof <= pixel_sof;
            previous_pixel_eol <= pixel_eol;
            previous_pixel_eof <= pixel_eof;
            previous_aw_stall <= m_axi_awvalid && !m_axi_awready;
            previous_awid <= m_axi_awid;
            previous_awaddr <= m_axi_awaddr;
            previous_awlen <= m_axi_awlen;
            previous_awsize <= m_axi_awsize;
            previous_awburst <= m_axi_awburst;
            previous_w_stall <= m_axi_wvalid && !m_axi_wready;
            previous_wdata <= m_axi_wdata;
            previous_wstrb <= m_axi_wstrb;
            previous_wlast <= m_axi_wlast;
            if (pixel_valid && !pixel_ready)
                pixel_stall_seen <= 1'b1;
            if (m_axi_awvalid && !m_axi_awready)
                aw_stall_seen <= 1'b1;
            if (m_axi_wvalid && !m_axi_wready)
                w_stall_seen <= 1'b1;

            if (pixel_valid && pixel_ready)
                source_index <= source_index + 1;

            if (m_axi_awvalid && m_axi_awready) begin
                integer expected_len;
                integer page_limit;
                if (!case_valid)
                    $fatal(1, "Invalid job emitted an AW");
                if (aw_inflight || b_pending || m_axi_bvalid)
                    $fatal(1, "Overlapping AXI write burst");
                if (m_axi_awid !== 0 || m_axi_awsize !== 3'd4 || m_axi_awburst !== 2'b01)
                    $fatal(1, "Invalid AW attributes");
                if (m_axi_awaddr[3:0] !== 0)
                    $fatal(1, "AW address is not 16-byte aligned");
                if (m_axi_awaddr !== score_address)
                    $fatal(1, "AW address mismatch got=%h expected=%h",
                           m_axi_awaddr, score_address);
                page_limit = (4096 - (score_address & 32'hfff)) / 16;
                expected_len = TB_MAX_BURST_BEATS;
                if (score_total_beats < expected_len)
                    expected_len = score_total_beats;
                if (score_row_beats < expected_len)
                    expected_len = score_row_beats;
                if (page_limit < expected_len)
                    expected_len = page_limit;
                if ((m_axi_awlen + 1) !== expected_len)
                    $fatal(1, "AW length mismatch addr=%h got=%0d expected=%0d",
                           m_axi_awaddr, m_axi_awlen + 1, expected_len);
                if (({1'b0, m_axi_awaddr[11:0]} + (m_axi_awlen + 1) * 16) > 4096)
                    $fatal(1, "Burst crossed 4 KiB");

                aw_inflight <= 1'b1;
                w_remaining <= m_axi_awlen + 1;
                write_address <= m_axi_awaddr;
                score_burst_len <= m_axi_awlen + 1;
                score_burst_row_remaining <= score_row_beats;
                score_burst_rows <= score_rows;
                commands <= commands + 1;
            end

            if (m_axi_wvalid && m_axi_wready) begin
                if (!aw_inflight)
                    $fatal(1, "W accepted before AW");
                if (m_axi_wstrb !== 16'hffff)
                    $fatal(1, "WSTRB is not full-word");
                if (m_axi_wdata !== expected_wdata(write_address))
                    $fatal(1, "W data mismatch address=%h data=%h expected=%h",
                           write_address, m_axi_wdata, expected_wdata(write_address));
                if (m_axi_wlast !== (w_remaining == 1))
                    $fatal(1, "WLAST mismatch remaining=%0d", w_remaining);
                for (k = 0; k < 16; k = k + 1)
                    if (m_axi_wstrb[k])
                        memory[write_address + k] <= m_axi_wdata[k * 8 +: 8];
                write_beats <= write_beats + 1;
                if (w_remaining == 1) begin
                    aw_inflight <= 1'b0;
                    b_pending <= 1'b1;
                    b_delay <= ideal_bus != 0 ? 0 : 2;
                    last_b_expected <= (score_total_beats == score_burst_len);
                    score_total_beats <= score_total_beats - score_burst_len;
                    if (score_burst_row_remaining == score_burst_len) begin
                        if (score_burst_rows > 1) begin
                            score_address <= score_address + score_burst_len * 16 +
                                             case_stride - case_width * 2;
                            score_row_beats <= case_width / 8;
                            score_rows <= score_burst_rows - 1;
                        end else begin
                            score_address <= score_address + score_burst_len * 16;
                            score_row_beats <= 0;
                            score_rows <= 0;
                        end
                    end else begin
                        score_address <= score_address + score_burst_len * 16;
                        score_row_beats <= score_burst_row_remaining - score_burst_len;
                    end
                end else begin
                    w_remaining <= w_remaining - 1;
                    write_address <= write_address + 16;
                end
            end

            if (b_pending && !m_axi_bvalid) begin
                if (b_delay == 0) begin
                    m_axi_bvalid <= 1'b1;
                    m_axi_bresp <= inject_b_error != 0 ? 2'b10 : 2'b00;
                end else begin
                    b_delay <= b_delay - 1;
                end
            end
            if (m_axi_bvalid && m_axi_bready) begin
                m_axi_bvalid <= 1'b0;
                b_pending <= 1'b0;
                if (last_b_expected)
                    last_b_seen <= 1'b1;
            end
        end
    end

    // A done pulse is only meaningful after the final B handshake.  This
    // check is intentionally outside the DUT so an early done cannot hide.
    always @(negedge clk) begin
        if (done && case_valid && !last_b_seen)
            $fatal(1, "done asserted before final B response");
    end

    task automatic run_valid_case;
        input integer width;
        input integer height;
        input integer stride;
        input [31:0]  address;
        input integer bad_markers;
        input integer bad_bresp;
        input integer ideal;
        input integer hold_cycles;
        integer before_commands;
        integer before_write_beats;
        integer start_cycle;
        integer budget;
        begin
            case_base = address;
            case_width = width;
            case_height = height;
            case_stride = stride;
            case_valid = 1;
            inject_b_error = bad_bresp;
            ideal_bus = ideal;
            bus_hold_until = cycle + hold_cycles;
            clear_region(address, stride, height);

            source_row_beats = width / 2;
            source_total_beats = source_row_beats * height;
            source_index = 0;
            source_active = 1'b0;
            marker_bad = bad_markers;
            pixel_stall_seen = 1'b0;
            aw_stall_seen = 1'b0;
            w_stall_seen = 1'b0;
            score_address = address;
            score_row_beats = width / 8;
            score_rows = height;
            score_total_beats = (width / 8) * height;
            last_b_seen = 1'b0;
            before_commands = commands;
            before_write_beats = write_beats;

            @(negedge clk);
            while (!job_ready)
                @(negedge clk);
            base_addr = address;
            dst_width = width;
            dst_height = height;
            stride_bytes = stride;
            job_valid = 1'b1;
            @(posedge clk);
            @(negedge clk);
            job_valid = 1'b0;
            source_active = 1'b1;
            start_cycle = cycle;
            budget = (ideal != 0) ? FRAME_BUDGET_CYCLES : 5000000;
            while (!done) begin
                @(negedge clk);
                if (cycle - start_cycle > budget)
                    $fatal(1, "Case timeout width=%0d height=%0d cycles=%0d state=%0d active=%b in_rem=%0d out_rem=%0d fifo=%0d plan=%0d awv=%b wv=%b bv=%b pending=%b delay=%0d awin=%b",
                           width, height, cycle - start_cycle, dut.state, dut.active,
                           dut.input_beats_remaining, dut.out_beats_remaining,
                           dut.fifo_count, dut.planned_burst_len,
                           m_axi_awvalid, m_axi_wvalid, m_axi_bvalid,
                           b_pending, b_delay, aw_inflight);
            end
            source_active = 1'b0;
            if (!last_b_seen)
                $fatal(1, "done without final B handshake");
            if (hold_cycles != 0 && !pixel_stall_seen)
                $fatal(1, "FIFO hold case did not exercise pixel backpressure");
            if (error !== ((bad_markers != 0) || (bad_bresp != 0)))
                $fatal(1, "Error result mismatch markers=%0d bresp=%0d error=%b",
                       bad_markers, bad_bresp, error);
            check_memory();
            $display("CASE frame_writer width=%0d height=%0d stride=%0d bursts=%0d wbeats=%0d cycles=%0d error=%0d",
                     width, height, stride, commands - before_commands,
                     write_beats - before_write_beats,
                     cycle - start_cycle, error);
            case_valid = 0;
            inject_b_error = 0;
            marker_bad = 0;
            @(negedge clk);
        end
    endtask

    task automatic run_invalid_case;
        input integer width;
        input integer height;
        input integer stride;
        input [31:0]  address;
        integer before_commands;
        begin
            case_valid = 0;
            inject_b_error = 0;
            ideal_bus = 0;
            bus_hold_until = cycle;
            source_active = 1'b0;
            before_commands = commands;
            @(negedge clk);
            while (!job_ready)
                @(negedge clk);
            base_addr = address;
            dst_width = width;
            dst_height = height;
            stride_bytes = stride;
            job_valid = 1'b1;
            @(posedge clk);
            @(negedge clk);
            job_valid = 1'b0;
            if (!done)
                $fatal(1, "Invalid case did not complete immediately");
            if (error !== 1'b1)
                $fatal(1, "Invalid case error was not asserted");
            if (commands != before_commands)
                $fatal(1, "Invalid case emitted AXI traffic");
            if (pixel_ready !== 1'b0 || busy !== 1'b0)
                $fatal(1, "Invalid case exposed active pixel/job state");
            $display("CASE frame_writer invalid width=%0d height=%0d stride=%0d base=%h",
                     width, height, stride, address);
            @(negedge clk);
        end
    endtask

    integer full_mode;
    initial begin
        full_mode = $test$plusargs("FULL");
        cycle = 0;
        case_valid = 0;
        inject_b_error = 0;
        ideal_bus = 0;
        bus_hold_until = 0;
        repeat (4) @(negedge clk);
        rst_n = 1'b1;

        // Small, aligned RGB565 cases, including page-crossing row starts.
        run_valid_case(16, 3, 64, 32'h00000ff0, 0, 0, 0, 0);
        run_valid_case(32, 4, 128, 32'h00002000, 0, 0, 0, 0);
        run_valid_case(64, 3, 256, 32'h00002ff0, 0, 0, 0, 0);
        run_valid_case(96, 2, 256, 32'h00003ff0, 0, 0, 0, 0);
        run_valid_case(192, 2, 512, 32'h00004ff0, 0, 0, 0, 0);
        // The hold period fills FIFO_DEPTH and forces pixel_ready backpressure.
        run_valid_case(256, 3, 768, 32'h00005ff0, 0, 0, 0, 320);
        run_valid_case(32, 3, 128, 32'h00007000, 1, 0, 0, 0);
        run_valid_case(64, 3, 256, 32'h00007ff0, 0, 1, 0, 0);

        // Configuration rejection: no AW, W or B transaction is emitted.
        run_invalid_case(20, 2, 64, 32'h00009000);  // width not 8-pixel multiple
        run_invalid_case(16, 2, 32, 32'h00009008);  // base not 16-byte aligned
        run_invalid_case(32, 2, 48, 32'h00009000);  // stride not aligned and too short
        run_invalid_case(0, 2, 16, 32'h00009000);   // zero width
        run_invalid_case(16, 2, 16, 32'hfffffff0);  // 32-bit address overflow

        if (full_mode != 0) begin
            // Ideal bus only: this is a cycle-budget measurement, not a
            // board FPS claim.  4096-byte stride leaves explicit padding.
            run_valid_case(1920, 1080, 4096, 32'h00100000, 0, 0, 1, 0);
            if (cycle > FRAME_BUDGET_CYCLES + 200000)
                $fatal(1, "Unexpected cumulative FULL runtime");
        end

        $display("PASS tb_axi_frame_writer");
        $finish;
    end

    initial begin
        #200000000;
        $fatal(1, "Timeout");
    end
endmodule
