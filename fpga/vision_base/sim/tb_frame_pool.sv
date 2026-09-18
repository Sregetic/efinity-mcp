`timescale 1ns/1ps

module tb_frame_pool;
    logic clk;
    logic rst_n;

    logic cap_req_valid;
    logic cap_req_ready;
    logic [31:0] cap_req_config_id;
    logic [1:0] cap_req_bank;
    logic cap_done_valid;
    logic cap_done_ready;
    logic [1:0] cap_done_bank;
    logic cap_done_ok;

    logic display_acquire_valid;
    logic display_acquire_ready;
    logic [1:0] display_acquire_bank;
    logic display_release;
    logic display_hold_valid;
    logic [1:0] display_hold_bank;
    logic [31:0] display_hold_frame_id;
    logic [31:0] display_hold_config_id;

    logic analysis_acquire_valid;
    logic analysis_acquire_ready;
    logic [1:0] analysis_acquire_bank;
    logic analysis_release;
    logic analysis_hold_valid;
    logic [1:0] analysis_hold_bank;
    logic [31:0] analysis_hold_frame_id;
    logic [31:0] analysis_hold_config_id;

    logic [3:0] ready_bitmap;
    logic [3:0] display_held_bitmap;
    logic [3:0] analysis_held_bitmap;
    logic cap_active_valid;
    logic [1:0] cap_active_bank;
    logic [31:0] cap_active_frame_id;
    logic [31:0] cap_active_config_id;

    // A second instance exercises the non-power-of-two BANKS=3 parameter.
    logic rst3_n;
    logic cap3_req_valid;
    logic cap3_req_ready;
    logic [31:0] cap3_req_config_id;
    logic [1:0] cap3_req_bank;
    logic cap3_done_valid;
    logic cap3_done_ready;
    logic [1:0] cap3_done_bank;
    logic cap3_done_ok;
    logic display3_acquire_valid;
    logic display3_acquire_ready;
    logic [1:0] display3_acquire_bank;
    logic display3_release;
    logic display3_hold_valid;
    logic [1:0] display3_hold_bank;
    logic [31:0] display3_hold_frame_id;
    logic [31:0] display3_hold_config_id;
    logic analysis3_acquire_valid;
    logic analysis3_acquire_ready;
    logic [1:0] analysis3_acquire_bank;
    logic analysis3_release;
    logic analysis3_hold_valid;
    logic [1:0] analysis3_hold_bank;
    logic [31:0] analysis3_hold_frame_id;
    logic [31:0] analysis3_hold_config_id;
    logic [2:0] ready3_bitmap;
    logic [2:0] display3_held_bitmap;
    logic [2:0] analysis3_held_bitmap;
    logic cap3_active_valid;
    logic [1:0] cap3_active_bank;
    logic [31:0] cap3_active_frame_id;
    logic [31:0] cap3_active_config_id;

    frame_pool #(.BANKS(4)) dut (
        .clk(clk), .rst_n(rst_n),
        .cap_req_valid(cap_req_valid), .cap_req_ready(cap_req_ready),
        .cap_req_config_id(cap_req_config_id), .cap_req_bank(cap_req_bank),
        .cap_done_valid(cap_done_valid), .cap_done_ready(cap_done_ready),
        .cap_done_bank(cap_done_bank), .cap_done_ok(cap_done_ok),
        .display_acquire_valid(display_acquire_valid),
        .display_acquire_ready(display_acquire_ready),
        .display_acquire_bank(display_acquire_bank),
        .display_release(display_release),
        .display_hold_valid(display_hold_valid),
        .display_hold_bank(display_hold_bank),
        .display_hold_frame_id(display_hold_frame_id),
        .display_hold_config_id(display_hold_config_id),
        .analysis_acquire_valid(analysis_acquire_valid),
        .analysis_acquire_ready(analysis_acquire_ready),
        .analysis_acquire_bank(analysis_acquire_bank),
        .analysis_release(analysis_release),
        .analysis_hold_valid(analysis_hold_valid),
        .analysis_hold_bank(analysis_hold_bank),
        .analysis_hold_frame_id(analysis_hold_frame_id),
        .analysis_hold_config_id(analysis_hold_config_id),
        .ready_bitmap(ready_bitmap),
        .display_held_bitmap(display_held_bitmap),
        .analysis_held_bitmap(analysis_held_bitmap),
        .cap_active_valid(cap_active_valid),
        .cap_active_bank(cap_active_bank),
        .cap_active_frame_id(cap_active_frame_id),
        .cap_active_config_id(cap_active_config_id)
    );

    frame_pool #(.BANKS(3)) dut3 (
        .clk(clk), .rst_n(rst3_n),
        .cap_req_valid(cap3_req_valid), .cap_req_ready(cap3_req_ready),
        .cap_req_config_id(cap3_req_config_id), .cap_req_bank(cap3_req_bank),
        .cap_done_valid(cap3_done_valid), .cap_done_ready(cap3_done_ready),
        .cap_done_bank(cap3_done_bank), .cap_done_ok(cap3_done_ok),
        .display_acquire_valid(display3_acquire_valid),
        .display_acquire_ready(display3_acquire_ready),
        .display_acquire_bank(display3_acquire_bank),
        .display_release(display3_release),
        .display_hold_valid(display3_hold_valid),
        .display_hold_bank(display3_hold_bank),
        .display_hold_frame_id(display3_hold_frame_id),
        .display_hold_config_id(display3_hold_config_id),
        .analysis_acquire_valid(analysis3_acquire_valid),
        .analysis_acquire_ready(analysis3_acquire_ready),
        .analysis_acquire_bank(analysis3_acquire_bank),
        .analysis_release(analysis3_release),
        .analysis_hold_valid(analysis3_hold_valid),
        .analysis_hold_bank(analysis3_hold_bank),
        .analysis_hold_frame_id(analysis3_hold_frame_id),
        .analysis_hold_config_id(analysis3_hold_config_id),
        .ready_bitmap(ready3_bitmap),
        .display_held_bitmap(display3_held_bitmap),
        .analysis_held_bitmap(analysis3_held_bitmap),
        .cap_active_valid(cap3_active_valid),
        .cap_active_bank(cap3_active_bank),
        .cap_active_frame_id(cap3_active_frame_id),
        .cap_active_config_id(cap3_active_config_id)
    );

    always #5 clk = ~clk;

    task automatic reset_all;
        begin
            rst_n = 1'b0;
            rst3_n = 1'b0;
            cap_req_valid = 1'b0;
            cap_req_config_id = 32'd0;
            cap_done_valid = 1'b0;
            cap_done_bank = 2'd0;
            cap_done_ok = 1'b0;
            display_acquire_valid = 1'b0;
            display_release = 1'b0;
            analysis_acquire_valid = 1'b0;
            analysis_release = 1'b0;
            cap3_req_valid = 1'b0;
            cap3_req_config_id = 32'd0;
            cap3_done_valid = 1'b0;
            cap3_done_bank = 2'd0;
            cap3_done_ok = 1'b0;
            display3_acquire_valid = 1'b0;
            display3_release = 1'b0;
            analysis3_acquire_valid = 1'b0;
            analysis3_release = 1'b0;
            repeat (2) @(posedge clk);
            #1;
            if (ready_bitmap !== 4'b0000 || display_hold_valid ||
                analysis_hold_valid || cap_active_valid) begin
                $fatal(1, "reset did not clear BANKS=4 references");
            end
            if (ready3_bitmap !== 3'b000 || display3_hold_valid ||
                analysis3_hold_valid || cap3_active_valid) begin
                $fatal(1, "reset did not clear BANKS=3 references");
            end
            rst_n = 1'b1;
            rst3_n = 1'b1;
            @(negedge clk);
        end
    endtask

    // Start a writer lease and return its bank/frame metadata.  Completion is
    // deliberately separate so callers can test same-edge completion events.
    task automatic start_capture4(
        input [31:0] cfg,
        output [1:0] bank,
        output [31:0] frame
    );
        begin
            cap_req_config_id = cfg;
            cap_req_valid = 1'b1;
            #1;
            if (!cap_req_ready) $fatal(1, "BANKS=4 capture request was not ready");
            bank = cap_req_bank;
            @(posedge clk);
            #1;
            if (!cap_active_valid || cap_active_bank !== bank ||
                cap_active_config_id !== cfg) begin
                $fatal(1, "capture request metadata was not locked");
            end
            frame = cap_active_frame_id;
            @(negedge clk);
            cap_req_valid = 1'b0;
        end
    endtask

    task automatic finish_capture4(
        input [1:0] bank,
        input [31:0] expected_frame,
        input [31:0] cfg,
        input        ok
    );
        begin
            cap_done_bank = bank;
            cap_done_ok = ok;
            cap_done_valid = 1'b1;
            #1;
            if (!cap_done_ready) $fatal(1, "BANKS=4 completion was not ready");
            @(posedge clk);
            #1;
            if (cap_active_valid) $fatal(1, "completion did not release writer");
            if (ok) begin
                if (!ready_bitmap[bank] || dut.frame_id_q[bank] !== expected_frame ||
                    dut.config_id_q[bank] !== cfg) begin
                    $fatal(1, "good completion metadata was not published");
                end
            end else if (ready_bitmap[bank]) begin
                $fatal(1, "bad frame was published");
            end
            @(negedge clk);
            cap_done_valid = 1'b0;
            cap_done_ok = 1'b0;
        end
    endtask

    task automatic start_capture3(
        input [31:0] cfg,
        output [1:0] bank,
        output [31:0] frame
    );
        begin
            cap3_req_config_id = cfg;
            cap3_req_valid = 1'b1;
            #1;
            if (!cap3_req_ready) $fatal(1, "BANKS=3 capture request was not ready");
            bank = cap3_req_bank;
            @(posedge clk);
            #1;
            if (!cap3_active_valid || cap3_active_bank !== bank ||
                cap3_active_config_id !== cfg) begin
                $fatal(1, "BANKS=3 capture metadata was not locked");
            end
            frame = cap3_active_frame_id;
            @(negedge clk);
            cap3_req_valid = 1'b0;
        end
    endtask

    task automatic finish_capture3(
        input [1:0] bank,
        input [31:0] expected_frame,
        input [31:0] cfg,
        input        ok
    );
        begin
            cap3_done_bank = bank;
            cap3_done_ok = ok;
            cap3_done_valid = 1'b1;
            #1;
            if (!cap3_done_ready) $fatal(1, "BANKS=3 completion was not ready");
            @(posedge clk);
            #1;
            if (cap3_active_valid) $fatal(1, "BANKS=3 completion did not release writer");
            if (ok) begin
                if (!ready3_bitmap[bank] || dut3.frame_id_q[bank] !== expected_frame ||
                    dut3.config_id_q[bank] !== cfg) begin
                    $fatal(1, "BANKS=3 completion metadata was not published");
                end
            end else if (ready3_bitmap[bank]) begin
                $fatal(1, "BANKS=3 bad frame was published");
            end
            @(negedge clk);
            cap3_done_valid = 1'b0;
            cap3_done_ok = 1'b0;
        end
    endtask

    logic [1:0] b1;
    logic [1:0] b2;
    logic [1:0] b3;
    logic [1:0] b4;
    logic [1:0] b5;
    logic [1:0] b6;
    logic [1:0] b7;
    logic [1:0] b8;
    logic [31:0] f1;
    logic [31:0] f2;
    logic [31:0] f3;
    logic [31:0] f4;
    logic [31:0] f5;
    logic [31:0] f6;
    logic [31:0] f7;
    logic [31:0] f8;
    logic [1:0] c3b1;
    logic [1:0] c3b2;
    logic [1:0] c3b3;
    logic [1:0] c3b4;
    logic [1:0] c3b5;
    logic [31:0] c3f1;
    logic [31:0] c3f2;
    logic [31:0] c3f3;
    logic [31:0] c3f4;
    logic [31:0] c3f5;

    initial begin
        clk = 1'b0;
        reset_all();

        // No frame is available immediately after reset: acquire must wait.
        display_acquire_valid = 1'b1;
        #1;
        if (display_acquire_ready) $fatal(1, "empty pool asserted display ready");
        display_acquire_valid = 1'b0;

        // Continuous capture fills all four banks while readers are idle.
        start_capture4(32'd11, b1, f1);
        if (f1 !== 32'd1) $fatal(1, "first frame id is not 1");
        finish_capture4(b1, f1, 32'd11, 1'b1);
        start_capture4(32'd22, b2, f2);
        if (f2 !== 32'd2) $fatal(1, "second frame id is not 2");

        // A published frame remains readable while a different bank is being
        // written.  The writer's full-frame latency must not block readers.
        @(negedge clk);
        display_acquire_valid = 1'b1;
        analysis_acquire_valid = 1'b1;
        #1;
        if (!display_acquire_ready || !analysis_acquire_ready ||
            display_acquire_bank !== b1 || analysis_acquire_bank !== b1) begin
            $fatal(1, "active writer blocked readers from acquiring frame A");
        end
        @(posedge clk);
        #1;
        if (!display_hold_valid || !analysis_hold_valid ||
            display_hold_bank !== b1 || analysis_hold_bank !== b1 ||
            display_hold_frame_id !== f1 || analysis_hold_frame_id !== f1 ||
            display_hold_config_id !== 32'd11 || analysis_hold_config_id !== 32'd11) begin
            $fatal(1, "readers failed to hold frame A during writer activity");
        end
        @(negedge clk);
        display_acquire_valid = 1'b0;
        analysis_acquire_valid = 1'b0;

        finish_capture4(b2, f2, 32'd22, 1'b1);

        // Both readers replace frame A with the newest frame and share it.
        @(negedge clk);
        display_release = 1'b1;
        analysis_release = 1'b1;
        display_acquire_valid = 1'b1;
        analysis_acquire_valid = 1'b1;
        #1;
        if (!display_acquire_ready || !analysis_acquire_ready ||
            display_acquire_bank !== b2 || analysis_acquire_bank !== b2) begin
            $fatal(1, "readers did not select newest common frame");
        end
        @(posedge clk);
        #1;
        if (!display_hold_valid || !analysis_hold_valid ||
            display_hold_bank !== b2 || analysis_hold_bank !== b2 ||
            display_hold_frame_id !== f2 || analysis_hold_frame_id !== f2 ||
            display_hold_config_id !== 32'd22 || analysis_hold_config_id !== 32'd22) begin
            $fatal(1, "two-reader shared lease or metadata is wrong");
        end
        @(negedge clk);
        display_acquire_valid = 1'b0;
        analysis_acquire_valid = 1'b0;
        display_release = 1'b0;
        analysis_release = 1'b0;

        // The held bank remains frozen while capture continues in other banks.
        start_capture4(32'd33, b3, f3);
        if (b3 === b2) $fatal(1, "writer selected display/analysis held bank");
        finish_capture4(b3, f3, 32'd33, 1'b1);
        start_capture4(32'd44, b4, f4);
        if (b4 === b2 || b4 === b3) $fatal(1, "writer reused a protected bank");
        finish_capture4(b4, f4, 32'd44, 1'b1);
        start_capture4(32'd55, b5, f5);
        // All banks are published here; b1 is the oldest eligible frame.
        if (b5 !== b1) $fatal(1, "oldest-frame recycling policy selected wrong bank");
        finish_capture4(b5, f5, 32'd55, 1'b1);
        if (display_hold_bank !== b2 || display_hold_frame_id !== f2 ||
            analysis_hold_bank !== b2 || analysis_hold_frame_id !== f2) begin
            $fatal(1, "reader freeze changed while capture continued");
        end

        // release+acquire in one cycle replaces only display's lease.
        @(negedge clk);
        display_release = 1'b1;
        display_acquire_valid = 1'b1;
        #1;
        if (!display_acquire_ready || display_acquire_bank !== b5) begin
            $fatal(1, "display release+acquire did not select latest frame");
        end
        @(posedge clk);
        #1;
        if (!display_hold_valid || display_hold_bank !== b5 ||
            display_hold_frame_id !== f5 || display_hold_config_id !== 32'd55) begin
            $fatal(1, "display release+acquire lease is wrong");
        end
        @(negedge clk);
        display_release = 1'b0;
        display_acquire_valid = 1'b0;

        // Release both readers before testing completion+read in one edge.
        @(negedge clk);
        display_release = 1'b1;
        analysis_release = 1'b1;
        @(posedge clk);
        #1;
        if (display_hold_valid || analysis_hold_valid) $fatal(1, "reader release failed");
        @(negedge clk);
        display_release = 1'b0;
        analysis_release = 1'b0;

        start_capture4(32'd66, b6, f6);
        if (f6 !== 32'd6 || b6 !== b2) $fatal(1, "frame six allocation is wrong");

        // A completion for a different bank is not acknowledged or consumed.
        @(negedge clk);
        cap_done_bank = b6 ^ 2'b01;
        cap_done_ok = 1'b1;
        cap_done_valid = 1'b1;
        #1;
        if (cap_done_ready || !cap_active_valid || cap_active_bank !== b6) begin
            $fatal(1, "mismatched completion generated an ACK");
        end
        @(negedge clk);
        cap_done_valid = 1'b0;

        // A good completion is visible to both readers on the same edge.
        cap_done_bank = b6;
        cap_done_ok = 1'b1;
        cap_done_valid = 1'b1;
        display_acquire_valid = 1'b1;
        analysis_acquire_valid = 1'b1;
        #1;
        if (!cap_done_ready || !display_acquire_ready || !analysis_acquire_ready ||
            display_acquire_bank !== b6 || analysis_acquire_bank !== b6) begin
            $fatal(1, "completion+read same-edge handshake is wrong");
        end
        @(posedge clk);
        #1;
        if (cap_active_valid || !display_hold_valid || !analysis_hold_valid ||
            display_hold_bank !== b6 || analysis_hold_bank !== b6 ||
            display_hold_frame_id !== f6 || analysis_hold_frame_id !== f6 ||
            display_hold_config_id !== 32'd66 || analysis_hold_config_id !== 32'd66) begin
            $fatal(1, "completion+read same-edge state is wrong");
        end
        @(negedge clk);
        cap_done_valid = 1'b0;
        cap_done_ok = 1'b0;
        display_acquire_valid = 1'b0;
        analysis_acquire_valid = 1'b0;

        // Bad frame consumes a request id but is never published.
        @(negedge clk);
        display_release = 1'b1;
        analysis_release = 1'b1;
        @(posedge clk);
        #1;
        @(negedge clk);
        display_release = 1'b0;
        analysis_release = 1'b0;
        start_capture4(32'd77, b7, f7);
        if (f7 !== 32'd7) $fatal(1, "bad-frame request did not consume frame id seven");
        finish_capture4(b7, f7, 32'd77, 1'b0);
        display_acquire_valid = 1'b1;
        #1;
        // The bad bank is unpublished; the observable selected frame is six.
        if (!display_acquire_ready || display_acquire_bank === b7) begin
            $fatal(1, "bad frame became an acquire candidate");
        end
        @(posedge clk);
        #1;
        if (display_hold_frame_id !== f6 || display_hold_config_id !== 32'd66) begin
            $fatal(1, "acquire selected bad-frame metadata");
        end
        @(negedge clk);
        display_acquire_valid = 1'b0;
        display_release = 1'b1;
        @(posedge clk);
        #1;
        @(negedge clk);
        display_release = 1'b0;
        start_capture4(32'd88, b8, f8);
        if (f8 !== 32'd8 || b8 !== b7) $fatal(1, "post-bad-frame reuse is wrong");
        finish_capture4(b8, f8, 32'd88, 1'b1);
        if (!ready_bitmap[b8] || dut.frame_id_q[b8] !== 32'd8 ||
            dut.config_id_q[b8] !== 32'd88) begin
            $fatal(1, "post-bad-frame frame/config association is wrong");
        end

        // BANKS=3: fill, hold two distinct frames, and prove completion does
        // not silently reuse the just-completed bank in the same cycle.
        start_capture3(32'd101, c3b1, c3f1);
        if (c3f1 !== 32'd1) $fatal(1, "BANKS=3 first frame id is not 1");
        finish_capture3(c3b1, c3f1, 32'd101, 1'b1);
        start_capture3(32'd102, c3b2, c3f2);
        finish_capture3(c3b2, c3f2, 32'd102, 1'b1);
        start_capture3(32'd103, c3b3, c3f3);
        finish_capture3(c3b3, c3f3, 32'd103, 1'b1);

        @(negedge clk);
        display3_acquire_valid = 1'b1;
        #1;
        if (!display3_acquire_ready || display3_acquire_bank !== c3b3) begin
            $fatal(1, "BANKS=3 display did not acquire newest frame");
        end
        @(posedge clk);
        #1;
        @(negedge clk);
        display3_acquire_valid = 1'b0;
        start_capture3(32'd104, c3b4, c3f4);
        if (c3b4 === c3b3) $fatal(1, "BANKS=3 writer overwrote display hold");
        finish_capture3(c3b4, c3f4, 32'd104, 1'b1);

        @(negedge clk);
        analysis3_acquire_valid = 1'b1;
        #1;
        if (!analysis3_acquire_ready || analysis3_acquire_bank !== c3b4 ||
            analysis3_acquire_bank === c3b3) begin
            $fatal(1, "BANKS=3 analysis did not hold a distinct newest frame");
        end
        @(posedge clk);
        #1;
        @(negedge clk);
        analysis3_acquire_valid = 1'b0;
        start_capture3(32'd105, c3b5, c3f5);

        // With display and analysis holding two banks, completion of the
        // third bank must not be overwritten by a simultaneous new request.
        @(negedge clk);
        cap3_done_bank = c3b5;
        cap3_done_ok = 1'b1;
        cap3_done_valid = 1'b1;
        cap3_req_config_id = 32'd106;
        cap3_req_valid = 1'b1;
        #1;
        if (!cap3_done_ready) $fatal(1, "BANKS=3 completion was not ready");
        if (cap3_req_ready) $fatal(1, "BANKS=3 reused completion bank in same cycle");
        if (!display3_hold_valid || !analysis3_hold_valid ||
            display3_hold_bank === analysis3_hold_bank) begin
            $fatal(1, "BANKS=3 distinct reader leases were lost");
        end
        @(posedge clk);
        #1;
        if (cap3_active_valid || !ready3_bitmap[c3b5] ||
            display3_hold_valid !== 1'b1 || analysis3_hold_valid !== 1'b1) begin
            $fatal(1, "BANKS=3 completion state is wrong");
        end
        @(negedge clk);
        cap3_done_valid = 1'b0;
        cap3_req_valid = 1'b0;
        cap3_done_ok = 1'b0;

        $display("PASS tb_frame_pool");
        $finish;
    end
endmodule
