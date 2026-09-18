`timescale 1ns/1ps
module tb_frame_render_control;
    reg clk=0;always #5 clk=~clk;
    reg rst_n=0;
    reg cap_req_valid=0,cap_done_valid=0,cap_done_ok=1;
    wire cap_req_ready,cap_done_ready;wire [1:0] cap_req_bank;
    reg [1:0] cap_done_bank=0;
    reg [31:0] cap_req_config_id=1;
    reg analysis_acquire_valid=0,analysis_release=0;
    wire analysis_acquire_ready,analysis_hold_valid;wire [1:0] analysis_hold_bank;
    wire [31:0] analysis_hold_frame_id,analysis_hold_config_id;
    reg job_valid=0,job_config_ok=1,freeze_source=0;
    reg [31:0] job_config_id=10;
    wire job_ready,run_valid;reg run_ready=0;
    wire [1:0] run_source_bank,source_hold_bank;
    wire [31:0] run_frame_id,run_config_id;
    wire run_result_bank,source_hold_valid;
    reg scaler_done=0,scaler_error=0,writer_done=0,writer_error=0,vblank=0;
    wire display_valid,display_bank,done,error,busy,pending;
    wire [31:0] display_frame_id,display_config_id,last_cycles,deadline_misses;
    frame_render_control #(.FRAME_BUDGET_CYCLES(8)) dut(.*);
    task tick;begin @(posedge clk);#1;end endtask
    task capture;
        begin
            @(negedge clk);cap_req_valid=1;
            while(!cap_req_ready) @(negedge clk);
            cap_done_bank=cap_req_bank;tick();
            @(negedge clk);cap_req_valid=0;cap_done_valid=1;tick();
            @(negedge clk);cap_done_valid=0;
        end
    endtask
    task request(input bit freeze,input integer config_number);
        begin
            @(negedge clk);job_valid=1;freeze_source=freeze;job_config_id=config_number;
            if(!job_ready)$fatal(1,"request not ready");tick();
            @(negedge clk);job_valid=0;
            wait(run_valid);#1;
        end
    endtask
    task launch;
        begin @(negedge clk);run_ready=1;tick();@(negedge clk);run_ready=0;end
    endtask
    task finish_job(input bit fail_write);
        begin
            repeat(3)tick();@(negedge clk);scaler_done=1;tick();
            @(negedge clk);scaler_done=0;
            if(pending || done)$fatal(1,"published before write response");
            repeat(3)tick();@(negedge clk);writer_done=1;writer_error=fail_write;tick();
            if(!done || error!=fail_write)$fatal(1,"completion mismatch");
            @(negedge clk);writer_done=0;writer_error=0;
        end
    endtask
    task present;
        begin @(negedge clk);vblank=1;tick();@(negedge clk);vblank=0;end
    endtask
    reg [1:0] frozen_bank;
    initial begin
        repeat(4)tick();@(negedge clk);rst_n=1;
        capture();request(1,10);
        if(run_frame_id!=1)$fatal(1,"source frame id");
        frozen_bank=run_source_bank;
        repeat(3)tick();
        if(!run_valid || run_frame_id!=1)$fatal(1,"launch backpressure");
        launch();capture();capture();
        if(source_hold_bank!=frozen_bank)$fatal(1,"capture overwrote frozen lease");
        finish_job(0);
        if(display_valid || !pending || !source_hold_valid || job_ready)$fatal(1,"publication/hold gate");
        repeat(3)tick();if(display_valid)$fatal(1,"flip outside vblank");
        present();
        if(!display_valid || display_bank!=0 || display_frame_id!=1 || display_config_id!=10)$fatal(1,"first present");
        request(1,11);
        if(run_frame_id!=1 || run_source_bank!=frozen_bank || run_result_bank!=1)$fatal(1,"freeze/result bank");
        launch();finish_job(0);present();
        if(display_bank!=1 || display_config_id!=11)$fatal(1,"second present");
        request(0,12);
        if(run_frame_id!=3)$fatal(1,"live did not acquire latest frame");
        launch();finish_job(1);
        if(pending || source_hold_valid)$fatal(1,"failed result publication or lease leak");
        present();if(display_frame_id!=1 || display_config_id!=11)$fatal(1,"failed result replaced display");
        @(negedge clk);job_config_ok=0;job_valid=1;tick();
        if(!done || !error || run_valid)$fatal(1,"invalid config");
        @(negedge clk);job_valid=0;
        if(deadline_misses==0)$fatal(1,"deadline counter");
        $display("PASS tb_frame_render_control freeze/live final-response error vblank deadline");$finish;
    end
    initial begin #100000;$fatal(1,"timeout");end
endmodule
