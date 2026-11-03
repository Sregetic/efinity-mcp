`timescale 1ns/1ps
// On-board feature extractor -> encoder, borrowing the actual hysteresis port.
module tb_flyhash_bitmap;
 localparam W=480,H=270,N=W*H,WORDS=N/32;
 reg clk=0,rst_n=0,cmd_event=0;always #5 clk=~clk;
 reg[7:0]cmd_op=0;reg[23:0]cmd_value=0;
 reg[31:0]frame_id=1,config_id=17,stream_errors=0;
 wire[255:0]hash;wire[31:0]status,result_frame_id,result_config_id,result_epoch,epoch;
 wire bitmap_req,bitmap_busy,bitmap_ready,bitmap_valid;wire[11:0]bitmap_address;
 wire[31:0]bitmap_data;reg req=0,pending=0;reg[11:0]address=0;
 wire ack,probe_busy;wire[11:0]read_address;
 assign bitmap_ready=!probe_busy&&req==ack,bitmap_valid=pending&&bitmap_ready;
 always @(posedge clk)begin
  if(!rst_n)begin req<=0;address<=0;pending<=0;end
  else if(bitmap_req&&bitmap_ready)begin req<=~req;address<=bitmap_address;pending<=1;end
  else if(bitmap_valid||!bitmap_busy)pending<=0;
 end
 reg vb=0,cv=0,last=0,de=0;reg[8:0]x=0,y=0,dx=0,dy=0;reg[1:0]c=0;
 wire cap,ready,hbusy,pixel,fault;wire[3:0]hstate;
 vision_hysteresis_sweep #(.W(W),.H(H),.MIN_COMPONENT(1),.REUSE_CAPTURE_MAP(1),.PROBE(1))hyst(
  .clk(clk),.rst_n(rst_n),.vblank(vb),.class_valid(cv),.class_x(x),.class_y(y),.classification(c),.class_last(last),
  .display_x(dx),.display_y(dy),.capture_enable(cap),.ready(ready),.busy(hbusy),.pixel(pixel),.completed(epoch),.fault(fault),.debug_state(hstate),.debug_queue(),
  .display_de(de),.probe_req(req),.probe_address(address),.probe_ack(ack),.probe_data(bitmap_data),.probe_read_address(read_address),.probe_busy(probe_busy),.frame_discard(1'b0),
  .last_cycles(),.sweep_passes(),.weak_visits());
 vision_flyhash_control #(.PROJECTION_FILE("models/flyhash_projection.mem"))control(
  .clk(clk),.rst_n(rst_n),.cmd_event(cmd_event),.cmd_op(cmd_op),.cmd_value(cmd_value),.context_valid(ready),
  .frame_id(frame_id),.config_id(config_id),.epoch(epoch),.stream_errors(stream_errors),
  .hash(hash),.status(status),.result_frame_id(result_frame_id),.result_config_id(result_config_id),.result_epoch(result_epoch),
  .bitmap_req(bitmap_req),.bitmap_busy(bitmap_busy),.bitmap_ready(bitmap_ready),.bitmap_address(bitmap_address),.bitmap_valid(bitmap_valid),.bitmap_data(bitmap_data),.feature_quarter(2'b0),.feature_probe());
 reg[31:0]words[0:8*WORDS-1];reg[255:0]gold[0:7];integer f=0,i,clock_count=0,active_checks=0;
 reg check_display=0;
 always @(negedge clk)begin
  clock_count=clock_count+1;de=clock_count%528<W;dx=clock_count%528;dy=(clock_count/528)%H;
 end
 always @(posedge clk)if(rst_n&&ready&&de&&check_display)begin
  #1;if(pixel!==words[f*WORDS+(dy*W+dx)/32][(dy*W+dx)%32])$fatal(1,"active display disturbed");
  active_checks=active_checks+1;
 end
 initial begin
  $readmemh("results/project_light_20261005/features_480x270.words.mem",words);
  $readmemh("results/project_light_20261005/features_480x270.hash.mem",gold);
  repeat(4)@(negedge clk);rst_n=1;wait(hstate==1);@(negedge clk);vb=1;@(negedge clk);vb=0;
  for(f=0;f<8;f=f+1)begin
   // Suppress display comparison while the next test's plane is being captured.
   check_display=0;
   for(i=0;i<N;i=i+1)begin @(negedge clk);cv=1;x=i%W;y=i/W;c=words[f*WORDS+i/32][i%32]?2:0;last=i==N-1;end
   @(negedge clk);cv=0;last=0;wait(hstate==8);@(negedge clk);vb=1;@(negedge clk);vb=0;check_display=1;
   frame_id=f+1;config_id=f+17;cmd_op='h54;cmd_event=1;@(negedge clk);cmd_event=0;
   wait(status[31]&&!status[30]);#1;
   if(hash!==gold[f]||status[28]||status[26:20]!=64||status[12:0]!=4877||result_frame_id!=f+1||result_config_id!=f+17||result_epoch!=f+1)$fatal(1,"automatic encoding frame%0d",f);
   $display("PASS automatic bitmap frame%0d hash%h",f,hash);
  end
  $display("PASS full bitmap/FlyHash8 planes, exact host hash, source/config/epoch, active pixel checks%0d",active_checks);$finish;
 end
 initial begin #1000000000;$fatal(1,"bitmap watchdog");end
endmodule
