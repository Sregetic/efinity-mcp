`timescale 1ns/1ps

// Frame ownership and metadata pool.
//
// One synchronous clock domain, one capture writer and two independent readers
// (display and analysis).  This block does not contain pixel storage.
module frame_pool #(
    parameter integer BANKS = 4,
    parameter integer BANK_ID_WIDTH = (BANKS <= 1) ? 1 : $clog2(BANKS)
) (
    input  logic                      clk,
    input  logic                      rst_n,

    // Capture writer: request a bank before writing one frame.
    input  logic                      cap_req_valid,
    output logic                      cap_req_ready,
    input  logic [31:0]               cap_req_config_id,
    output logic [BANK_ID_WIDTH-1:0]  cap_req_bank,

    // Capture writer: finish the currently active request.
    input  logic                      cap_done_valid,
    output logic                      cap_done_ready,
    input  logic [BANK_ID_WIDTH-1:0]  cap_done_bank,
    input  logic                      cap_done_ok,

    // Display reader.
    input  logic                      display_acquire_valid,
    output logic                      display_acquire_ready,
    output logic [BANK_ID_WIDTH-1:0]  display_acquire_bank,
    input  logic                      display_release,
    output logic                      display_hold_valid,
    output logic [BANK_ID_WIDTH-1:0]  display_hold_bank,
    output logic [31:0]               display_hold_frame_id,
    output logic [31:0]               display_hold_config_id,

    // Analysis reader.
    input  logic                      analysis_acquire_valid,
    output logic                      analysis_acquire_ready,
    output logic [BANK_ID_WIDTH-1:0]  analysis_acquire_bank,
    input  logic                      analysis_release,
    output logic                      analysis_hold_valid,
    output logic [BANK_ID_WIDTH-1:0]  analysis_hold_bank,
    output logic [31:0]               analysis_hold_frame_id,
    output logic [31:0]               analysis_hold_config_id,

    // State visibility for integration and assertions.
    output logic [BANKS-1:0]           ready_bitmap,
    output logic [BANKS-1:0]           display_held_bitmap,
    output logic [BANKS-1:0]           analysis_held_bitmap,
    output logic                      cap_active_valid,
    output logic [BANK_ID_WIDTH-1:0]  cap_active_bank,
    output logic [31:0]               cap_active_frame_id,
    output logic [31:0]               cap_active_config_id
);

    initial begin
        if (BANKS < 1) begin
            $fatal(1, "frame_pool BANKS must be at least 1");
        end
        if (BANK_ID_WIDTH < 1) begin
            $fatal(1, "frame_pool BANK_ID_WIDTH must be at least 1");
        end
    end

    logic [BANKS-1:0] ready_q;
    logic [BANKS-1:0] display_held_q;
    logic [BANKS-1:0] analysis_held_q;

    logic [BANKS-1:0] ready_d;
    logic [BANKS-1:0] display_held_d;
    logic [BANKS-1:0] analysis_held_d;

    logic [31:0] frame_id_q [0:BANKS-1];
    logic [31:0] config_id_q [0:BANKS-1];
    logic [31:0] frame_id_d [0:BANKS-1];
    logic [31:0] config_id_d [0:BANKS-1];

    logic                        writer_active_q;
    logic                        writer_active_d;
    logic [BANK_ID_WIDTH-1:0]    writer_bank_q;
    logic [BANK_ID_WIDTH-1:0]    writer_bank_d;
    logic [31:0]                 writer_frame_id_q;
    logic [31:0]                 writer_frame_id_d;
    logic [31:0]                 writer_config_id_q;
    logic [31:0]                 writer_config_id_d;
    logic [31:0]                 next_frame_id_q;
    logic [31:0]                 next_frame_id_d;

    logic                        display_hold_valid_q;
    logic                        display_hold_valid_d;
    logic [BANK_ID_WIDTH-1:0]    display_hold_bank_q;
    logic [BANK_ID_WIDTH-1:0]    display_hold_bank_d;
    logic [31:0]                 display_hold_frame_id_q;
    logic [31:0]                 display_hold_frame_id_d;
    logic [31:0]                 display_hold_config_id_q;
    logic [31:0]                 display_hold_config_id_d;

    logic                        analysis_hold_valid_q;
    logic                        analysis_hold_valid_d;
    logic [BANK_ID_WIDTH-1:0]    analysis_hold_bank_q;
    logic [BANK_ID_WIDTH-1:0]    analysis_hold_bank_d;
    logic [31:0]                 analysis_hold_frame_id_q;
    logic [31:0]                 analysis_hold_frame_id_d;
    logic [31:0]                 analysis_hold_config_id_q;
    logic [31:0]                 analysis_hold_config_id_d;

    // The completion channel is only ready for the currently leased writer
    // bank.  A mismatched bank therefore remains a visible, unaccepted event.
    logic cap_done_fire;
    assign cap_done_ready = writer_active_q &&
                            (cap_done_bank < BANKS) &&
                            (cap_done_bank == writer_bank_q);
    assign cap_done_fire = cap_done_valid && cap_done_ready;

    // State projected after a completion but before this cycle's new request.
    // Readers use this projection so a successful completion can be acquired
    // on the same edge as cap_done.
    logic [BANKS-1:0] ready_after_done;
    logic [31:0] frame_id_after_done [0:BANKS-1];
    logic [31:0] config_id_after_done [0:BANKS-1];

    logic                        display_candidate_valid;
    logic [BANK_ID_WIDTH-1:0]    display_candidate_bank;
    logic [31:0]                 display_candidate_frame_id;
    logic [31:0]                 display_candidate_config_id;
    logic                        analysis_candidate_valid;
    logic [BANK_ID_WIDTH-1:0]    analysis_candidate_bank;
    logic [31:0]                 analysis_candidate_frame_id;
    logic [31:0]                 analysis_candidate_config_id;

    logic display_acquire_fire;
    logic analysis_acquire_fire;
    assign display_acquire_fire = display_acquire_valid && display_acquire_ready;
    assign analysis_acquire_fire = analysis_acquire_valid && analysis_acquire_ready;

    logic [BANKS-1:0] cap_eligible;
    logic                        cap_candidate_valid;
    logic [BANK_ID_WIDTH-1:0]    cap_candidate_bank;
    logic [31:0]                 cap_candidate_frame_id;
    logic cap_req_fire;
    assign cap_req_fire = cap_req_valid && cap_req_ready;

    integer i;
    integer j;
    integer k;
    integer n;

    // Reader candidate selection.  The writer exclusion here is the current
    // writer lease, except for a completion accepted with ok=1; that frame is
    // visible as ready_after_done on this edge.
    always_comb begin
        ready_after_done = ready_q;
        for (i = 0; i < BANKS; i = i + 1) begin
            frame_id_after_done[i] = frame_id_q[i];
            config_id_after_done[i] = config_id_q[i];
        end
        if (cap_done_fire && cap_done_ok) begin
            ready_after_done[cap_done_bank] = 1'b1;
            frame_id_after_done[cap_done_bank] = writer_frame_id_q;
            config_id_after_done[cap_done_bank] = writer_config_id_q;
        end

        display_candidate_valid = 1'b0;
        display_candidate_bank = '0;
        display_candidate_frame_id = 32'd0;
        display_candidate_config_id = 32'd0;
        display_acquire_ready = 1'b0;
        display_acquire_bank = '0;

        // A held reader is deliberately not re-entrant.  release+acquire in
        // the same cycle is the one exception and means replace the lease.
        if (!(display_hold_valid_q && !display_release)) begin
            for (i = 0; i < BANKS; i = i + 1) begin
                if (ready_after_done[i] &&
                    !(writer_active_q && (writer_bank_q == i) &&
                      !(cap_done_fire && cap_done_ok))) begin
                    if (!display_candidate_valid ||
                        (frame_id_after_done[i] > display_candidate_frame_id)) begin
                        display_candidate_valid = 1'b1;
                        display_candidate_bank = i;
                        display_candidate_frame_id = frame_id_after_done[i];
                        display_candidate_config_id = config_id_after_done[i];
                    end
                end
            end
            if (display_candidate_valid) begin
                display_acquire_ready = 1'b1;
                display_acquire_bank = display_candidate_bank;
            end
        end

        analysis_candidate_valid = 1'b0;
        analysis_candidate_bank = '0;
        analysis_candidate_frame_id = 32'd0;
        analysis_candidate_config_id = 32'd0;
        analysis_acquire_ready = 1'b0;
        analysis_acquire_bank = '0;

        if (!(analysis_hold_valid_q && !analysis_release)) begin
            for (i = 0; i < BANKS; i = i + 1) begin
                if (ready_after_done[i] &&
                    !(writer_active_q && (writer_bank_q == i) &&
                      !(cap_done_fire && cap_done_ok))) begin
                    if (!analysis_candidate_valid ||
                        (frame_id_after_done[i] > analysis_candidate_frame_id)) begin
                        analysis_candidate_valid = 1'b1;
                        analysis_candidate_bank = i;
                        analysis_candidate_frame_id = frame_id_after_done[i];
                        analysis_candidate_config_id = config_id_after_done[i];
                    end
                end
            end
            if (analysis_candidate_valid) begin
                analysis_acquire_ready = 1'b1;
                analysis_acquire_bank = analysis_candidate_bank;
            end
        end
    end

    // Capture candidate selection.  First use an unpublished bank.  If all
    // available banks are published, recycle the oldest frame.  Hold/release
    // and same-cycle reader acquires are included in the ownership decision.
    always_comb begin
        cap_eligible = '0;
        for (j = 0; j < BANKS; j = j + 1) begin
            cap_eligible[j] =
                !(writer_active_q && !cap_done_fire) &&
                !(writer_active_q && cap_done_fire && cap_done_ok &&
                  (cap_done_bank == j)) &&
                !(display_held_q[j] &&
                  !(display_release && display_hold_valid_q &&
                    (display_hold_bank_q == j))) &&
                !(analysis_held_q[j] &&
                  !(analysis_release && analysis_hold_valid_q &&
                    (analysis_hold_bank_q == j))) &&
                !(display_acquire_fire && (display_candidate_bank == j)) &&
                !(analysis_acquire_fire && (analysis_candidate_bank == j));
        end

        cap_candidate_valid = 1'b0;
        cap_candidate_bank = '0;
        cap_candidate_frame_id = 32'd0;

        // Prefer banks that are not published in the projected state.
        for (j = 0; j < BANKS; j = j + 1) begin
            if (!cap_candidate_valid && cap_eligible[j] &&
                !ready_after_done[j]) begin
                cap_candidate_valid = 1'b1;
                cap_candidate_bank = j;
                cap_candidate_frame_id = frame_id_after_done[j];
            end
        end

        // If no empty bank exists, recycle the oldest eligible published bank.
        if (!cap_candidate_valid) begin
            for (j = 0; j < BANKS; j = j + 1) begin
                if (cap_eligible[j] && ready_after_done[j]) begin
                    if (!cap_candidate_valid ||
                        (frame_id_after_done[j] < cap_candidate_frame_id)) begin
                        cap_candidate_valid = 1'b1;
                        cap_candidate_bank = j;
                        cap_candidate_frame_id = frame_id_after_done[j];
                    end
                end
            end
        end

        cap_req_ready = cap_candidate_valid;
        cap_req_bank = '0;
        if (cap_candidate_valid) begin
            cap_req_bank = cap_candidate_bank;
        end
    end

    // Single next-state block.  The order is intentional and is mirrored in
    // docs/frame_pool.md: completion, release, acquire, then new cap request.
    always_comb begin
        ready_d = ready_q;
        display_held_d = display_held_q;
        analysis_held_d = analysis_held_q;
        writer_active_d = writer_active_q;
        writer_bank_d = writer_bank_q;
        writer_frame_id_d = writer_frame_id_q;
        writer_config_id_d = writer_config_id_q;
        next_frame_id_d = next_frame_id_q;
        display_hold_valid_d = display_hold_valid_q;
        display_hold_bank_d = display_hold_bank_q;
        display_hold_frame_id_d = display_hold_frame_id_q;
        display_hold_config_id_d = display_hold_config_id_q;
        analysis_hold_valid_d = analysis_hold_valid_q;
        analysis_hold_bank_d = analysis_hold_bank_q;
        analysis_hold_frame_id_d = analysis_hold_frame_id_q;
        analysis_hold_config_id_d = analysis_hold_config_id_q;
        for (k = 0; k < BANKS; k = k + 1) begin
            frame_id_d[k] = frame_id_q[k];
            config_id_d[k] = config_id_q[k];
        end

        // 1. Complete the old writer lease.  A bad frame is released but not
        // published; its old metadata is intentionally left unreferenced.
        if (cap_done_fire) begin
            writer_active_d = 1'b0;
            ready_d[cap_done_bank] = 1'b0;
            if (cap_done_ok) begin
                ready_d[cap_done_bank] = 1'b1;
                frame_id_d[cap_done_bank] = writer_frame_id_q;
                config_id_d[cap_done_bank] = writer_config_id_q;
            end
        end

        // 2. Release existing reader leases.
        if (display_release && display_hold_valid_q) begin
            display_held_d[display_hold_bank_q] = 1'b0;
            display_hold_valid_d = 1'b0;
        end
        if (analysis_release && analysis_hold_valid_q) begin
            analysis_held_d[analysis_hold_bank_q] = 1'b0;
            analysis_hold_valid_d = 1'b0;
        end

        // 3. Acquire the selected latest frame.  The projected metadata makes
        // a successful cap_done+acquire pair a well-defined same-edge event.
        if (display_acquire_fire) begin
            display_held_d[display_candidate_bank] = 1'b1;
            display_hold_valid_d = 1'b1;
            display_hold_bank_d = display_candidate_bank;
            display_hold_frame_id_d = display_candidate_frame_id;
            display_hold_config_id_d = display_candidate_config_id;
        end
        if (analysis_acquire_fire) begin
            analysis_held_d[analysis_candidate_bank] = 1'b1;
            analysis_hold_valid_d = 1'b1;
            analysis_hold_bank_d = analysis_candidate_bank;
            analysis_hold_frame_id_d = analysis_candidate_frame_id;
            analysis_hold_config_id_d = analysis_candidate_config_id;
        end

        // 4. Start a new writer lease.  cap_candidate excludes any reader
        // acquire target, and a successful completion bank, on this edge.
        if (cap_req_fire) begin
            ready_d[cap_candidate_bank] = 1'b0;
            writer_active_d = 1'b1;
            writer_bank_d = cap_candidate_bank;
            writer_frame_id_d = next_frame_id_q;
            writer_config_id_d = cap_req_config_id;
            next_frame_id_d = next_frame_id_q + 32'd1;
        end
    end

    // Synchronous active-low reset: references and metadata are reset, while
    // this module owns no frame memory to clear.
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            ready_q <= '0;
            display_held_q <= '0;
            analysis_held_q <= '0;
            writer_active_q <= 1'b0;
            writer_bank_q <= '0;
            writer_frame_id_q <= 32'd0;
            writer_config_id_q <= 32'd0;
            next_frame_id_q <= 32'd1;
            display_hold_valid_q <= 1'b0;
            display_hold_bank_q <= '0;
            display_hold_frame_id_q <= 32'd0;
            display_hold_config_id_q <= 32'd0;
            analysis_hold_valid_q <= 1'b0;
            analysis_hold_bank_q <= '0;
            analysis_hold_frame_id_q <= 32'd0;
            analysis_hold_config_id_q <= 32'd0;
            for (n = 0; n < BANKS; n = n + 1) begin
                frame_id_q[n] <= 32'd0;
                config_id_q[n] <= 32'd0;
            end
        end else begin
            ready_q <= ready_d;
            display_held_q <= display_held_d;
            analysis_held_q <= analysis_held_d;
            writer_active_q <= writer_active_d;
            writer_bank_q <= writer_bank_d;
            writer_frame_id_q <= writer_frame_id_d;
            writer_config_id_q <= writer_config_id_d;
            next_frame_id_q <= next_frame_id_d;
            display_hold_valid_q <= display_hold_valid_d;
            display_hold_bank_q <= display_hold_bank_d;
            display_hold_frame_id_q <= display_hold_frame_id_d;
            display_hold_config_id_q <= display_hold_config_id_d;
            analysis_hold_valid_q <= analysis_hold_valid_d;
            analysis_hold_bank_q <= analysis_hold_bank_d;
            analysis_hold_frame_id_q <= analysis_hold_frame_id_d;
            analysis_hold_config_id_q <= analysis_hold_config_id_d;
            for (n = 0; n < BANKS; n = n + 1) begin
                frame_id_q[n] <= frame_id_d[n];
                config_id_q[n] <= config_id_d[n];
            end
        end
    end

    assign ready_bitmap = ready_q;
    assign display_held_bitmap = display_held_q;
    assign analysis_held_bitmap = analysis_held_q;
    assign display_hold_valid = display_hold_valid_q;
    assign display_hold_bank = display_hold_bank_q;
    assign display_hold_frame_id = display_hold_frame_id_q;
    assign display_hold_config_id = display_hold_config_id_q;
    assign analysis_hold_valid = analysis_hold_valid_q;
    assign analysis_hold_bank = analysis_hold_bank_q;
    assign analysis_hold_frame_id = analysis_hold_frame_id_q;
    assign analysis_hold_config_id = analysis_hold_config_id_q;
    assign cap_active_valid = writer_active_q;
    assign cap_active_bank = writer_bank_q;
    assign cap_active_frame_id = writer_frame_id_q;
    assign cap_active_config_id = writer_config_id_q;

endmodule
