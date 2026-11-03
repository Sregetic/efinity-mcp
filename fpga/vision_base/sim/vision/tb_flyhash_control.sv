`timescale 1ns/1ps
module tb_flyhash_control;
 reg clk=0,rst_n=0,cmd_event=0,context_valid=1;always #5 clk=~clk;
 reg[7:0]cmd_op=0;reg[23:0]cmd_value=0;
 reg[31:0]frame_id=28,config_id=8,epoch=24,stream_errors=0;
 wire[255:0]hash;wire[31:0]status,result_frame_id,result_config_id,result_epoch;
 wire bitmap_req,bitmap_busy;wire[11:0]bitmap_address;
 reg bitmap_ready=0,bitmap_valid=0;reg[31:0]bitmap_data=0;
 reg[1:0]feature_quarter=0;wire[127:0]feature_probe;
 vision_flyhash_control #(.PROJECTION_FILE("models/flyhash_projection.mem"))dut(.*);
 task command(input[7:0]op,input[23:0]value);
  begin @(negedge clk);cmd_op=op;cmd_value=value;cmd_event=1;@(negedge clk);cmd_event=0;end
 endtask
 integer i;
 initial begin
  repeat(4)@(negedge clk);rst_n=1;
  command('h50,0);
  for(i=0;i<64;i=i+1)command('h51,(i<<8));
  wait(status[31]);#1;
  if(hash!=256'h1fff||result_frame_id!=28||result_config_id!=8||result_epoch!=24||status[30]||status[28]||status[26:20]!=64||status[19:13]!=1||status[12:0]!=4877)$fatal(1,"encoder result contract");
  // An old label remains explicitly tagged until a new task starts.
  @(negedge clk);frame_id=29;command('h50,0);command('h51,8'h12);
  command('h51,8'h34); // duplicate index0 instead of1
  if(!status[28]||status[31]||status[30])$fatal(1,"out-of-order feature accepted");
  command('h50,0);command('h51,8'h12);
  @(negedge clk);config_id=9;@(negedge clk);
  if(!status[28]||status[31]||status[30])$fatal(1,"changed frame task accepted");
  command('h50,0);command('h51,8'h12);
  @(negedge clk);stream_errors=1;@(negedge clk);
  if(!status[28]||status[31]||status[30])$fatal(1,"scan fault accepted");
  command('h52,0);if(status[28]||status[30]||status[31])$fatal(1,"abort did not clear task");
  context_valid=0;command('h50,0);
  if(!status[28]||status[30])$fatal(1,"unleased source accepted");
 context_valid=1;command('h50,0);command('h51,8'h55);command('h52,0);
  if(status[30]||status[31]||status[28])$fatal(1,"LOAD abort");
  // Automatic extraction shares the same tagged job and error cancellation.
  command('h54,0);
  if(!bitmap_busy||status[29])$fatal(1,"automatic port ownership");
  command('h51,8'h55);
  if(!status[28]||status[30]||bitmap_busy)$fatal(1,"manual feed collided with automatic extraction");
  command('h54,0);@(negedge clk);epoch=25;@(negedge clk);
  if(!status[28]||status[30]||bitmap_busy)$fatal(1,"automatic context loss");
  command('h54,0);command('h52,0);
  if(status[28]||status[30]||bitmap_busy)$fatal(1,"automatic abort");
  $display("PASS tb_flyhash_control frame/config/epoch,64 features,4877 compute clocks,duplicate index,changed context,invalid lease,abort");$finish;
 end
 initial begin #1000000;$fatal(1,"control watchdog");end
endmodule
