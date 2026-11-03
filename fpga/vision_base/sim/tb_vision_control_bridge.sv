`timescale 1ns/1ps
module tb_vision_control_bridge;
reg clk=0,video_clk=0;always #5 clk=~clk;always #3.367 video_clk=~video_clk;
reg rst_n=0,vs=0,cmd_event=0;reg[2:0]keys_n=7;reg[7:0]cmd_op=0,paddr=0;reg[23:0]cmd_value=0;
reg back_n=1;reg flash_miso=0;wire[3:0]flash_gpio;
reg psel=0,penable=0,pwrite=0;reg[31:0]pwdata=0;wire[31:0]prdata;wire pready,pslverror;
wire geometry_selection_bank;wire[27:0]target_classes;wire[2:0]geometry_selection;wire[1:0]recognition_model;wire geometry_enable,recognition_enable;wire[23:0]ui_state;wire[2:0]mode,history_index;wire median_en,motion_enable;wire[1:0]memory_mode;wire[10:0]sobel_threshold,canny_threshold,threshold;
reg job_ready=0,capture_done=0,capture_error=0,source_hold_valid=0,render_done=0,render_error=0,render_pending=0,vblank=0,scan_busy=0;
reg[31:0]capture_count=0;wire job_valid,enable,freeze_source;wire[31:0]job_config_id;
wire[15:0]roi_x,roi_y,roi_w,roi_h,dst_w,dst_h,display_x,display_y;
wire config_busy,commit_rejected,config_error;wire[31:0]requested_id,committed_id,rejected_id;
vision_control_bridge #(.DEBOUNCE(3),.LONG_PRESS(20)) dut(.*);
task wr(input[7:0]a,input[31:0]v);begin
 @(negedge clk);paddr=a;pwdata=v;psel=1;pwrite=1;penable=0;
 @(negedge clk);penable=1;do @(posedge clk);while(!pready);
 @(negedge clk);psel=0;penable=0;pwrite=0;
end endtask
task rd(input[7:0]a,output[31:0]v);begin
 @(negedge clk);paddr=a;psel=1;pwrite=0;penable=0;
 @(negedge clk);penable=1;@(posedge clk);v=prdata;
 @(negedge clk);psel=0;penable=0;
end endtask
task command(input[7:0]op,input[23:0]v);begin
 @(negedge video_clk);cmd_op=op;cmd_value=v;cmd_event=1;
 @(negedge video_clk);cmd_event=0;repeat(3)@(negedge video_clk);
end endtask
task frame;begin @(negedge video_clk);vs=1;repeat(3)@(negedge video_clk);vs=0;repeat(4)@(negedge clk);end endtask
reg[31:0]v;integer i;
initial begin
 repeat(6)@(negedge clk);rst_n=1;repeat(8)@(negedge clk);
 if(flash_gpio!=2)$fatal(1,"Flash pads enabled at reset");
 wr('h48,5);wr('h4c,1);if(flash_gpio!=13)$fatal(1,"Flash APB outputs/enable");
 flash_miso=1;repeat(3)@(negedge clk);rd('h50,v);if(v!=8)$fatal(1,"Flash input synchronization");
 wr('h48,2);wr('h4c,0);if(flash_gpio!=2)$fatal(1,"Flash pad release");
 rd(0,v);if(v!=32'h26103005)$fatal(1,"model-control capability");
 // Burst retained while CPU is busy; ignored diagnostics do not fill the queue.
 command(1,5);command('h28,96);command('h29,48);command('h7e,20);
 repeat(8)@(negedge clk);
 rd(4,v);if(v!=32'h01000005)$fatal(1,"event order1");
 rd(4,v);if(v!=32'h28000060)$fatal(1,"event order2");
 rd(4,v);if(v!=32'h29000030)$fatal(1,"event order3");
 rd(4,v);if(v!=0)$fatal(1,"diagnostic leaked into queue");
 command('h63,2);repeat(8)@(negedge clk);rd(4,v);if(v!=32'h63000002)$fatal(1,"model selection event lost");
 @(negedge video_clk);keys_n[1]=0;@(negedge video_clk);keys_n[1]=1;repeat(8)@(negedge clk);
 rd(4,v);if(v)$fatal(1,"bounce accepted");
 repeat(3)begin
  @(negedge video_clk);keys_n[1]=0;repeat(8)@(negedge video_clk);keys_n[1]=1;repeat(9)@(negedge clk);
  rd(4,v);if(v!=32'hff000002)$fatal(1,"short key event");
 end
 // KEY1 is debounced and emits the old back event, never a functional reset.
 @(negedge video_clk);back_n=0;@(negedge video_clk);back_n=1;repeat(8)@(negedge clk);
 rd(4,v);if(v)$fatal(1,"KEY1 bounce accepted");
 @(negedge video_clk);back_n=0;repeat(8)@(negedge video_clk);back_n=1;repeat(9)@(negedge clk);
 rd(4,v);if(v!=32'hff000008)$fatal(1,"KEY1 short did not emit back");
 @(negedge video_clk);back_n=0;repeat(30)@(negedge video_clk);
 rd(4,v);if(v!=32'hff000008)$fatal(1,"KEY1 hold did not emit one back");
 repeat(30)@(negedge video_clk);back_n=1;repeat(9)@(negedge clk);
 rd(4,v);if(v)$fatal(1,"KEY1 hold repeated or emitted another event on release");
 @(negedge video_clk);keys_n[0]=0;repeat(30)@(negedge video_clk);keys_n[0]=1;repeat(9)@(negedge clk);
 rd(4,v);if(v)$fatal(1,"long KEY0 still emitted back or confirm");
 @(negedge video_clk);keys_n[0]=0;repeat(8)@(negedge video_clk);keys_n[0]=1;repeat(9)@(negedge clk);
 rd(4,v);if(v!=32'hff000001)$fatal(1,"short KEY0 confirm changed");
 for(i=1;i<3;i++)begin
  @(negedge video_clk);keys_n[i]=0;repeat(30)@(negedge video_clk);keys_n[i]=1;repeat(9)@(negedge clk);
  rd(4,v);if(v!=(32'hff000000|(1<<(i+3))))$fatal(1,"KEY2/3 long freeze/history changed");
  rd(4,v);if(v)$fatal(1,"long KEY2/3 repeated short on release");
 end
 wr('h54,28'h080c101);wr('h44,(1<<22)|(14<<15)|(6<<19)|(3<<11)|1408);wr(8,5|(1<<3)|(1<<4)|(96<<9)|(48<<20));repeat(8)@(negedge video_clk);
 if(ui_state!=0)$fatal(1,"menu changed before VS");
 if(mode!=3||sobel_threshold!=128)$fatal(1,"feature changed before VS");
 if(target_classes||geometry_selection||geometry_selection_bank)$fatal(1,"target snapshot changed before VS");
 rd('h0c,v);if(!(v&1))$fatal(1,"missing pending atomic commit");frame;
 if(mode!=5||!median_en||threshold!=48||sobel_threshold!=96||memory_mode!=1)$fatal(1,"atomic settings");
 if(ui_state!=((3<<11)|1408)||recognition_model!=2||!geometry_enable||!recognition_enable)$fatal(1,"menu/settings not atomic");
 if(target_classes!=28'h080c101||geometry_selection!=6||!geometry_selection_bank)$fatal(1,"target snapshot/index not atomic with UI");
 wr('h44,32'hcc0483c0);wr(8,5|(1<<3)|(1<<4)|(96<<9)|(48<<20));
 repeat(8)@(negedge video_clk);if(ui_state!=((3<<11)|1408))$fatal(1,"sidebar changed outside VS");frame;
 if(ui_state!=24'hcc03c0||recognition_model!=1||geometry_enable||!recognition_enable)$fatal(1,"sidebar selection/edit/value CDC mixed");
 wr(8,32'h80000000|5|(1<<3)|(1<<4)|(96<<9)|(48<<20));
 repeat(8)@(negedge video_clk);if(motion_enable)$fatal(1,"motion enable changed before VS");frame;
 if(!motion_enable||mode!=5||threshold!=48||memory_mode!=1)$fatal(1,"motion atomic enable changed video");
 wr('h44,(0<<15)|32'h80004001);wr(8,5|(1<<3)|(1<<4)|(96<<9)|(48<<20));
 repeat(8)@(negedge video_clk);if(!motion_enable)$fatal(1,"motion disable changed before VS");frame;
 if(motion_enable||ui_state!=24'h804001)$fatal(1,"motion item high bit/UI CDC");
 repeat(8)@(negedge clk);if(!freeze_source)$fatal(1,"freeze CDC");
 wr('h20,(13<<12)|7);wr('h24,(37<<12)|45);wr('h28,(80<<12)|64);wr('h2c,(8<<12)|12);
 wr('h34,17);wr('h3c,17);wr('h38,1);wr('h30,7);
 repeat(8)@(negedge clk);if(!job_valid||job_config_id!=17||roi_x!=13||roi_h!=45||!config_busy)$fatal(1,"held render job");
 job_ready=1;repeat(3)@(negedge clk);job_ready=0;
 if(job_valid||committed_id!=17||display_x!=0)$fatal(1,"job accept/premature display position");
 render_pending=1;vblank=1;scan_busy=1;repeat(3)@(negedge clk);if(display_x!=0)$fatal(1,"position changed during scan");
 scan_busy=0;repeat(3)@(negedge clk);if(display_x!=8||display_y!=12)$fatal(1,"frame publication position");
 render_pending=0;vblank=0;render_done=1;render_error=1;@(negedge clk);render_done=0;
 if(!config_error||rejected_id!=17)$fatal(1,"render error binding");
 wr('h30,4);if(enable||config_error)$fatal(1,"disable/clear");
 // A stopped CPU is an actual overflow case; make it observable.
 for(i=0;i<20;i++)command(1,i);repeat(8)@(negedge clk);
 rd('h0c,v);if(!(v>>31))$fatal(1,"queue overflow concealed");
 rst_n=0;repeat(6)@(negedge clk);rst_n=1;repeat(8)@(negedge clk);
 for(i=0;i<16;i++)command(1,i);
 repeat(3)begin
  @(negedge video_clk);keys_n[1]=0;repeat(8)@(negedge video_clk);keys_n[1]=1;repeat(9)@(negedge clk);
 end
 rd('h0c,v);if(!(v>>31))$fatal(1,"repeated key loss in full queue concealed");
 $display("PASS tb_vision_control_bridge ordered events, bounce/short/long keys, VS atomic commit, freeze CDC, held render/position, tagged error and overflow");$finish;
end
initial begin #300000;$fatal(1,"bridge watchdog");end
endmodule
