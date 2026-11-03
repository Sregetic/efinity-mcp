`timescale 1ns/1ps

// Frame ownership and metadata pool.
//
// One capture writer, display/scan leases and an optional compute lease.
// No pixel storage; compute can bind an exact frame without stealing scan.
module frame_pool #(
    parameter integer BANKS = 4,
    parameter integer KEEP_HISTORY = 0,
    parameter integer COMPUTE_ENABLED = 0,
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

    input logic compute_acquire_valid,compute_latest,compute_release,
    input logic[31:0]compute_request_frame_id,
    output logic compute_acquire_ready,compute_missing,compute_hold_valid,
    output logic[BANK_ID_WIDTH-1:0]compute_hold_bank,
    output logic[31:0]compute_hold_frame_id,compute_hold_config_id,
    input logic pin_history,display_use_analysis,
    input logic [2:0] display_age,analysis_age,
    output logic [2:0] history_count,

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
    logic compute_valid_q;
    logic[BANK_ID_WIDTH-1:0]compute_bank_q,compute_candidate_bank;
    logic[31:0]compute_frame_q,compute_config_q;
    logic compute_candidate_valid;
    wire compute_fire=COMPUTE_ENABLED&&compute_acquire_valid&&compute_acquire_ready;
    assign display_acquire_fire = display_acquire_valid && display_acquire_ready;
    assign analysis_acquire_fire = analysis_acquire_valid && analysis_acquire_ready;

    logic [BANKS-1:0] cap_eligible;
    logic                        cap_candidate_valid;
    logic [BANK_ID_WIDTH-1:0]    cap_candidate_bank;
    logic [31:0]                 cap_candidate_frame_id;
    logic cap_req_fire;
    assign cap_req_fire = cap_req_valid && cap_req_ready;

    logic [BANKS-1:0] reader_eligible,newest,cap_empty,cap_winner;
    logic [BANK_ID_WIDTH-1:0] latest_bank;
    logic [31:0] latest_frame,latest_config;
    integer rj,cj;
    integer i;
    integer j;
    integer k;
    integer n;

    task automatic choose_compute(input logic want_latest,input logic[31:0]wanted_frame,input logic slot_free);
    integer cc;
    begin

        compute_candidate_valid=0;compute_candidate_bank=0;
        if(COMPUTE_ENABLED)begin
            if(want_latest)begin compute_candidate_valid=|reader_eligible;compute_candidate_bank=latest_bank;end
            else for(cc=0;cc<BANKS;cc=cc+1)
                if(reader_eligible[cc]&&((cap_done_fire&&cap_done_ok&&cap_done_bank==cc)?writer_frame_id_q==wanted_frame:frame_id_q[cc]==wanted_frame))begin
                    compute_candidate_valid=1;compute_candidate_bank=BANK_ID_WIDTH'(cc);
                end
        end
        compute_acquire_ready=COMPUTE_ENABLED&&compute_candidate_valid&&slot_free;
        compute_missing=COMPUTE_ENABLED&&!compute_candidate_valid&&slot_free;
    end endtask

    generate if(!KEEP_HISTORY)begin:latest_only
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

        // Parallel comparison matrix avoids a serial chain of 32-bit
        // max comparators feeding the capture ownership decision.
        for (i=0;i<BANKS;i=i+1) begin
            reader_eligible[i] = ready_after_done[i] &&
                !(writer_active_q && writer_bank_q==i && !(cap_done_fire && cap_done_ok));
        end
        for (i=0;i<BANKS;i=i+1) begin
            newest[i]=reader_eligible[i];
            for (rj=0;rj<BANKS;rj=rj+1) begin
                if (reader_eligible[rj] &&
                    ((frame_id_after_done[rj]>frame_id_after_done[i]) ||
                     ((frame_id_after_done[rj]==frame_id_after_done[i]) && rj<i)))
                    newest[i]=1'b0;
            end
        end
        latest_bank='0;latest_frame=0;latest_config=0;
        for(i=0;i<BANKS;i=i+1) begin
            latest_bank=latest_bank | (BANK_ID_WIDTH'(i) & {BANK_ID_WIDTH{newest[i]}});
            latest_frame=latest_frame | (frame_id_after_done[i] & {32{newest[i]}});
            latest_config=latest_config | (config_id_after_done[i] & {32{newest[i]}});
        end
        display_candidate_valid=(|newest) && !(display_hold_valid_q && !display_release);
        analysis_candidate_valid=(|newest) && !(analysis_hold_valid_q && !analysis_release);
        display_candidate_bank=latest_bank;
        analysis_candidate_bank=latest_bank;
        display_candidate_frame_id=latest_frame;
        analysis_candidate_frame_id=latest_frame;
        display_candidate_config_id=latest_config;
        analysis_candidate_config_id=latest_config;
        display_acquire_ready=display_candidate_valid;
        analysis_acquire_ready=analysis_candidate_valid;
        display_acquire_bank=display_candidate_valid ? latest_bank : '0;
        analysis_acquire_bank=analysis_candidate_valid ? latest_bank : '0;
        choose_compute(compute_latest,compute_request_frame_id,!compute_valid_q||compute_release);
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
                !(analysis_acquire_fire && (analysis_candidate_bank == j)) &&
                !(compute_valid_q && !compute_release && compute_bank_q==j) &&
                !(compute_fire && compute_candidate_bank==j);
        end

        cap_empty=cap_eligible & ~ready_after_done;
        for(j=0;j<BANKS;j=j+1) begin
            cap_winner[j]=cap_eligible[j];
            if(|cap_empty) begin
                cap_winner[j]=cap_empty[j];
                for(cj=0;cj<BANKS;cj=cj+1)
                    if(cj<j && cap_empty[cj]) cap_winner[j]=1'b0;
            end else begin
                for(cj=0;cj<BANKS;cj=cj+1) begin
                    if(cap_eligible[cj] &&
                       ((frame_id_after_done[cj]<frame_id_after_done[j]) ||
                        ((frame_id_after_done[cj]==frame_id_after_done[j]) && cj<j)))
                        cap_winner[j]=1'b0;
                end
            end
        end
        cap_candidate_valid=|cap_winner;
        cap_candidate_bank='0;
        cap_candidate_frame_id=0;
        for(j=0;j<BANKS;j=j+1) begin
            cap_candidate_bank=cap_candidate_bank | (BANK_ID_WIDTH'(j) & {BANK_ID_WIDTH{cap_winner[j]}});
            cap_candidate_frame_id=cap_candidate_frame_id | (frame_id_after_done[j] & {32{cap_winner[j]}});
        end
        cap_req_ready=cap_candidate_valid;
        cap_req_bank=cap_candidate_bank;
    end

    assign history_count=0;
    end else begin:history_pool
    // Completion order is chronological with the single writer. Keep a bank
    // permutation instead of an 8x8 matrix of 32-bit history comparators.
    logic [BANK_ID_WIDTH-1:0] order_q[0:BANKS-1],order_after[0:BANKS-1];
    logic [BANKS-1:0] pinned,eligible_order,latest_order;
    integer q,p,rank_count,chosen_display_age,chosen_analysis_age,old_position;
    always_comb begin
        old_position=0;
        for(q=0;q<BANKS;q=q+1)begin
            order_after[q]=order_q[q];
            if(order_q[q]==cap_done_bank)old_position=q;
        end
        if(cap_done_fire&&cap_done_ok)begin
            order_after[0]=cap_done_bank;
            for(q=1;q<BANKS;q=q+1)
                if(q<=old_position)order_after[q]=order_q[q-1];
        end
        ready_after_done=ready_q;
        for(q=0;q<BANKS;q=q+1)begin
            frame_id_after_done[q]=frame_id_q[q];config_id_after_done[q]=config_id_q[q];
        end
        if(cap_done_fire&&cap_done_ok)begin
            ready_after_done[cap_done_bank]=1;
            frame_id_after_done[cap_done_bank]=writer_frame_id_q;
            config_id_after_done[cap_done_bank]=writer_config_id_q;
        end
        for(q=0;q<BANKS;q=q+1)
            reader_eligible[q]=ready_after_done[q]&&
                !(writer_active_q&&writer_bank_q==q&&!(cap_done_fire&&cap_done_ok));
        rank_count=0;
        for(q=0;q<BANKS;q=q+1)if(reader_eligible[q])rank_count=rank_count+1;
        history_count=3'(rank_count>6?6:rank_count);
        chosen_display_age=display_age<history_count?display_age:0;
        chosen_analysis_age=analysis_age<history_count?analysis_age:0;
        // Latest selection does not need the serial age counter.
        for(q=0;q<BANKS;q=q+1)eligible_order[q]=reader_eligible[order_after[q]];
        for(q=0;q<BANKS;q=q+1)begin
            latest_order[q]=eligible_order[q];
            for(p=0;p<BANKS;p=p+1)if(p<q&&eligible_order[p])latest_order[q]=0;
        end
        latest_bank=0;
        for(q=0;q<BANKS;q=q+1)latest_bank=latest_bank|(order_after[q]&{BANK_ID_WIDTH{latest_order[q]}});
        display_candidate_bank=0;analysis_candidate_bank=0;pinned=0;rank_count=0;
        for(q=0;q<BANKS;q=q+1)if(eligible_order[q])begin
            if(rank_count==chosen_display_age)display_candidate_bank=order_after[q];
            if(rank_count==chosen_analysis_age)analysis_candidate_bank=order_after[q];
            if(rank_count<6)pinned[order_after[q]]=1;
            rank_count=rank_count+1;
        end
        if(display_use_analysis&&analysis_hold_valid_q)display_candidate_bank=analysis_hold_bank_q;
        display_candidate_valid=rank_count!=0&&!(display_hold_valid_q&&!display_release);
        analysis_candidate_valid=rank_count!=0&&!(analysis_hold_valid_q&&!analysis_release);
        display_candidate_frame_id=((cap_done_fire&&cap_done_ok&&cap_done_bank==display_candidate_bank)?writer_frame_id_q:frame_id_q[display_candidate_bank]);
        display_candidate_config_id=((cap_done_fire&&cap_done_ok&&cap_done_bank==display_candidate_bank)?writer_config_id_q:config_id_q[display_candidate_bank]);
        analysis_candidate_frame_id=((cap_done_fire&&cap_done_ok&&cap_done_bank==analysis_candidate_bank)?writer_frame_id_q:frame_id_q[analysis_candidate_bank]);
        analysis_candidate_config_id=((cap_done_fire&&cap_done_ok&&cap_done_bank==analysis_candidate_bank)?writer_config_id_q:config_id_q[analysis_candidate_bank]);
        latest_frame=((cap_done_fire&&cap_done_ok&&cap_done_bank==latest_bank)?writer_frame_id_q:frame_id_q[latest_bank]);latest_config=((cap_done_fire&&cap_done_ok&&cap_done_bank==latest_bank)?writer_config_id_q:config_id_q[latest_bank]);
        display_acquire_ready=display_candidate_valid;analysis_acquire_ready=analysis_candidate_valid;
        display_acquire_bank=display_candidate_valid?display_candidate_bank:'0;
        analysis_acquire_bank=analysis_candidate_valid?analysis_candidate_bank:'0;
        choose_compute(compute_latest,compute_request_frame_id,!compute_valid_q||compute_release);
        cap_eligible='0;
        for(q=0;q<BANKS;q=q+1)begin
            cap_eligible[q]=!(writer_active_q&&!cap_done_fire)&&
                !(writer_active_q&&cap_done_fire&&cap_done_ok&&cap_done_bank==q)&&
                !(display_held_q[q]&&!(display_release&&display_hold_valid_q&&display_hold_bank_q==q))&&
                !(analysis_held_q[q]&&!(analysis_release&&analysis_hold_valid_q&&analysis_hold_bank_q==q))&&
                !(display_acquire_fire&&display_candidate_bank==q)&&
                !(analysis_acquire_fire&&analysis_candidate_bank==q)&&!(pin_history&&pinned[q])&&
                !(compute_valid_q&&!compute_release&&compute_bank_q==q)&&
                !(compute_fire&&compute_candidate_bank==q);
        end
        cap_empty=cap_eligible&~ready_after_done;
        cap_candidate_valid=|cap_eligible;cap_candidate_bank=0;cap_candidate_frame_id=0;
        if(|cap_empty)begin
            // Same deterministic lowest-empty-bank policy as the original pool.
            for(q=BANKS-1;q>=0;q=q-1)if(cap_empty[q])cap_candidate_bank=BANK_ID_WIDTH'(q);
        end else begin
            for(q=0;q<BANKS;q=q+1)if(cap_eligible[order_after[q]])cap_candidate_bank=order_after[q];
        end
        cap_req_ready=cap_candidate_valid;cap_req_bank=cap_candidate_bank;
    end
    always_ff @(posedge clk)begin
        if(!rst_n)for(integer n=0;n<BANKS;n=n+1)order_q[n]<=BANK_ID_WIDTH'(n);
        else if(cap_done_fire&&cap_done_ok)for(integer n=0;n<BANKS;n=n+1)order_q[n]<=order_after[n];
    end
    end endgenerate

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

    always_ff @(posedge clk)begin
        if(!rst_n)begin compute_valid_q<=0;compute_bank_q<=0;compute_frame_q<=0;compute_config_q<=0;end
        else if(COMPUTE_ENABLED)begin
            if(compute_release)compute_valid_q<=0;
            if(compute_fire)begin
                compute_valid_q<=1;compute_bank_q<=compute_candidate_bank;
                compute_frame_q<=((cap_done_fire&&cap_done_ok&&cap_done_bank==compute_candidate_bank)?writer_frame_id_q:frame_id_q[compute_candidate_bank]);
                compute_config_q<=((cap_done_fire&&cap_done_ok&&cap_done_bank==compute_candidate_bank)?writer_config_id_q:config_id_q[compute_candidate_bank]);
            end
        end
    end
    assign compute_hold_valid=compute_valid_q,compute_hold_bank=compute_bank_q;
    assign compute_hold_frame_id=compute_frame_q,compute_hold_config_id=compute_config_q;
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
