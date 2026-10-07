`timescale 1ns/1ps
// Source leases and atomic result publication. All inputs are in clk domain.
// vblank is a one-cycle pulse from the scanout adapter, not an async VS signal.
module frame_render_control #(
    parameter integer BANKS=4,
    parameter integer KEEP_HISTORY=0,COMPUTE_ENABLED=0,
    parameter integer BANK_BITS=$clog2(BANKS),
    parameter integer FRAME_BUDGET_CYCLES=1666667
)(
    input wire clk,rst_n,
    input wire cap_req_valid, output wire cap_req_ready,
    input wire [31:0] cap_req_config_id,
    output wire [BANK_BITS-1:0] cap_req_bank,
    input wire cap_done_valid, output wire cap_done_ready,
    input wire [BANK_BITS-1:0] cap_done_bank, input wire cap_done_ok,
    input wire compute_acquire_valid,compute_latest,compute_release,
    input wire[31:0]compute_request_frame_id,
    output wire compute_acquire_ready,compute_missing,compute_hold_valid,
    output wire[BANK_BITS-1:0]compute_hold_bank,
    output wire[31:0]compute_hold_frame_id,compute_hold_config_id,
    input wire analysis_acquire_valid, output wire analysis_acquire_ready,
    input wire analysis_release,
    output wire analysis_hold_valid,
    output wire [BANK_BITS-1:0] analysis_hold_bank,
    output wire [31:0] analysis_hold_frame_id,analysis_hold_config_id,
    input wire pin_history,display_use_analysis,input wire[2:0]display_age,analysis_age,
    output wire[2:0]history_count,output wire[31:0]capture_frame_id,
    input wire job_valid,output wire job_ready,
    input wire job_config_ok,freeze_source,release_source,
    input wire [31:0] job_config_id,
    output wire run_valid,input wire run_ready,
    output wire [BANK_BITS-1:0] run_source_bank,
    output wire [31:0] run_frame_id,
    output reg [31:0] run_config_id,
    output reg run_result_bank,
    input wire scaler_done,scaler_error,writer_done,writer_error,
    input wire vblank,
    output reg display_valid,display_bank,
    output reg [31:0] display_frame_id,display_config_id,
    output reg done,error,
    output wire busy,output reg pending,
    output reg [31:0] last_cycles,deadline_misses,
    output wire source_hold_valid,
    output wire [BANK_BITS-1:0] source_hold_bank,
    output wire[31:0]source_hold_frame_id,source_hold_config_id
);
    localparam IDLE=0, RELEASE=1, ACQUIRE=2, LAUNCH=3, RUN=4;
    reg [2:0] state;
    reg freeze_q,scale_finished,write_finished,failed;
    reg [31:0] cycles,pending_frame,pending_config;
    reg pending_bank;
    wire acquire_ready;
    wire [31:0] source_frame;
    assign source_hold_frame_id=source_frame;
    wire finish = state==RUN && (scale_finished || scaler_done)
                              && (write_finished || writer_done);
    wire source_release = state==RELEASE || (finish && !freeze_q) || (state==IDLE&&release_source);
    frame_pool #(.BANKS(BANKS),.BANK_ID_WIDTH(BANK_BITS),.KEEP_HISTORY(KEEP_HISTORY),.COMPUTE_ENABLED(COMPUTE_ENABLED)) pool (
        .clk(clk),.rst_n(rst_n),.pin_history(pin_history),.display_use_analysis(display_use_analysis),
        .display_age(display_age),.analysis_age(analysis_age),.history_count(history_count),
        .cap_req_valid(cap_req_valid),.cap_req_ready(cap_req_ready),
        .cap_req_config_id(cap_req_config_id),.cap_req_bank(cap_req_bank),
        .cap_done_valid(cap_done_valid),.cap_done_ready(cap_done_ready),
        .cap_done_bank(cap_done_bank),.cap_done_ok(cap_done_ok),
        .display_acquire_valid(state==ACQUIRE),.display_acquire_ready(acquire_ready),
        .display_acquire_bank(),.display_release(source_release),
        .display_hold_valid(source_hold_valid),.display_hold_bank(source_hold_bank),
        .display_hold_frame_id(source_frame),.display_hold_config_id(source_hold_config_id),
                .compute_acquire_valid(compute_acquire_valid),.compute_latest(compute_latest),.compute_release(compute_release),
        .compute_request_frame_id(compute_request_frame_id),.compute_acquire_ready(compute_acquire_ready),.compute_missing(compute_missing),
        .compute_hold_valid(compute_hold_valid),.compute_hold_bank(compute_hold_bank),
        .compute_hold_frame_id(compute_hold_frame_id),.compute_hold_config_id(compute_hold_config_id),
.analysis_acquire_valid(analysis_acquire_valid),
        .analysis_acquire_ready(analysis_acquire_ready),.analysis_acquire_bank(),
        .analysis_release(analysis_release),.analysis_hold_valid(analysis_hold_valid),
        .analysis_hold_bank(analysis_hold_bank),
        .analysis_hold_frame_id(analysis_hold_frame_id),
        .analysis_hold_config_id(analysis_hold_config_id),
        .ready_bitmap(),.display_held_bitmap(),.analysis_held_bitmap(),
        .cap_active_valid(),.cap_active_bank(),.cap_active_frame_id(capture_frame_id),.cap_active_config_id()
    );
    assign run_source_bank=source_hold_bank;
    assign run_frame_id=source_frame;
    assign run_valid=state==LAUNCH;
    assign job_ready=state==IDLE && !pending;
    assign busy=state!=IDLE || pending;
    always @(posedge clk) begin
        if(!rst_n) begin
            state<=IDLE;freeze_q<=0;scale_finished<=0;write_finished<=0;failed<=0;
            cycles<=0;last_cycles<=0;deadline_misses<=0;
            pending<=0;pending_bank<=0;pending_frame<=0;pending_config<=0;
            display_valid<=0;display_bank<=0;display_frame_id<=0;display_config_id<=0;
            run_config_id<=0;run_result_bank<=0;done<=0;error<=0;
        end else begin
            done<=0;
            if(pending && vblank) begin
                display_valid<=1;display_bank<=pending_bank;
                display_frame_id<=pending_frame;display_config_id<=pending_config;
                pending<=0;
            end
            case(state)
                IDLE: if(job_valid && job_ready) begin
                    error<=0;run_config_id<=job_config_id;freeze_q<=freeze_source;
                    run_result_bank<=display_valid ? !display_bank : 1'b0;
                    if(!job_config_ok) begin done<=1;error<=1;end
                    else if(source_hold_valid && freeze_source) state<=LAUNCH;
                    else if(source_hold_valid) state<=RELEASE;
                    else state<=ACQUIRE;
                end
                RELEASE: state<=ACQUIRE;
                ACQUIRE: if(acquire_ready) state<=LAUNCH;
                LAUNCH: if(run_ready) begin
                    state<=RUN;cycles<=0;scale_finished<=0;write_finished<=0;failed<=0;
                end
                RUN: begin
                    cycles<=cycles+1;
                    if(scaler_done) begin scale_finished<=1;failed<=failed | scaler_error;end
                    if(writer_done) begin write_finished<=1;failed<=failed | writer_error | (scaler_done && scaler_error);end
                    if(finish) begin
                        state<=IDLE;done<=1;last_cycles<=cycles+1;
                        error<=failed | (scaler_done && scaler_error) | (writer_done && writer_error);
                        if(cycles+1>FRAME_BUDGET_CYCLES) deadline_misses<=deadline_misses+1;
                        if(!(failed | (scaler_done && scaler_error) | (writer_done && writer_error))) begin
                            pending<=1;pending_bank<=run_result_bank;
                            pending_frame<=source_frame;pending_config<=run_config_id;
                        end
                    end
                end
                default: state<=IDLE;
            endcase
        end
    end
endmodule
