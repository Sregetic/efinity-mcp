`timescale 1ns/1ps
module tb_compute_lease;
 reg clk=0,rst_n=0;always #5 clk=~clk;
 reg cap_req_valid=0,cap_done_valid=0;reg[31:0]cap_req_config_id=0;reg[2:0]cap_done_bank=0;
 wire cap_req_ready,cap_done_ready;wire[2:0]cap_req_bank;wire[31:0]active_frame;
 reg display_acquire_valid=0,analysis_acquire_valid=0,compute_acquire_valid=0,compute_latest=0,compute_release=0;
 reg[31:0]compute_request_frame_id=0;
 wire compute_acquire_ready,compute_missing,compute_hold_valid;wire[2:0]compute_hold_bank;wire[31:0]compute_hold_frame_id,compute_hold_config_id;
 frame_pool #(.BANKS(8),.BANK_ID_WIDTH(3),.KEEP_HISTORY(1),.COMPUTE_ENABLED(1)) dut(
 .clk(clk),.rst_n(rst_n),.cap_req_valid(cap_req_valid),.cap_req_ready(cap_req_ready),.cap_req_config_id(cap_req_config_id),.cap_req_bank(cap_req_bank),
 .cap_done_valid(cap_done_valid),.cap_done_ready(cap_done_ready),.cap_done_bank(cap_done_bank),.cap_done_ok(1'b1),
 .display_acquire_valid(display_acquire_valid),.display_acquire_ready(),.display_acquire_bank(),.display_release(1'b0),.display_hold_valid(),.display_hold_bank(),.display_hold_frame_id(),.display_hold_config_id(),
 .analysis_acquire_valid(analysis_acquire_valid),.analysis_acquire_ready(),.analysis_acquire_bank(),.analysis_release(1'b0),.analysis_hold_valid(),.analysis_hold_bank(),.analysis_hold_frame_id(),.analysis_hold_config_id(),
 .compute_acquire_valid(compute_acquire_valid),.compute_latest(compute_latest),.compute_release(compute_release),.compute_request_frame_id(compute_request_frame_id),
 .compute_acquire_ready(compute_acquire_ready),.compute_missing(compute_missing),.compute_hold_valid(compute_hold_valid),.compute_hold_bank(compute_hold_bank),.compute_hold_frame_id(compute_hold_frame_id),.compute_hold_config_id(compute_hold_config_id),
 .pin_history(1'b0),.display_use_analysis(1'b0),.display_age(3'd0),.analysis_age(3'd0),.history_count(),.ready_bitmap(),.display_held_bitmap(),.analysis_held_bitmap(),
 .cap_active_valid(),.cap_active_bank(),.cap_active_frame_id(active_frame),.cap_active_config_id());
 task publish(input integer id);begin
  @(negedge clk);cap_req_config_id=id+100;cap_req_valid=1;#1;
  if(!cap_req_ready)$fatal(1,"capture blocked");
  if(compute_hold_valid&&cap_req_bank==compute_hold_bank)$fatal(1,"writer stole compute source");
  cap_done_bank=cap_req_bank;@(negedge clk);cap_req_valid=0;repeat(2)@(negedge clk);
  if(active_frame!=id)$fatal(1,"capture frame id");cap_done_valid=1;@(negedge clk);cap_done_valid=0;
 end endtask
 integer i;
 initial begin
  repeat(3)@(negedge clk);rst_n=1;
  for(i=1;i<=8;i++)publish(i);
  @(negedge clk);compute_request_frame_id=2;compute_acquire_valid=1;#1;if(!compute_acquire_ready||compute_missing)$fatal(1,"exact frame lookup");
  display_acquire_valid=1;analysis_acquire_valid=1;@(negedge clk);compute_acquire_valid=0;display_acquire_valid=0;analysis_acquire_valid=0;
  if(!compute_hold_valid||compute_hold_frame_id!=2||compute_hold_config_id!=102)$fatal(1,"tagged compute lease");
  for(i=9;i<=28;i++)publish(i);
  if(compute_hold_frame_id!=2)$fatal(1,"held metadata changed");
  @(negedge clk);compute_release=1;@(negedge clk);compute_release=0;compute_request_frame_id=3;compute_acquire_valid=1;#1;
  if(!compute_missing||compute_acquire_ready)$fatal(1,"stale exact frame silently changed to latest");
  compute_latest=1;#1;if(!compute_acquire_ready)$fatal(1,"latest compute unavailable");@(negedge clk);compute_acquire_valid=0;
  if(compute_hold_frame_id!=28)$fatal(1,"latest frame tag");
  $display("PASS tb_compute_lease: exact/latest/stale, independent display+scan and20 concurrent captures without source overwrite");$finish;
 end
 initial begin #1000000;$fatal(1,"timeout");end
endmodule
