// Firmware owns control policy. Hardware retains key timing, ordered events,
// VS-only feature application and render/scan handshakes.
module vision_control_bridge #(parameter W=1920,H=1080,DEBOUNCE=2970000,LONG_PRESS=148500000)(
 input clk,rst_n,video_clk,vs,input[2:0]keys_n,
 input cmd_event,input[7:0]cmd_op,input[23:0]cmd_value,
 input[7:0]paddr,input psel,penable,pwrite,input[31:0]pwdata,
 output reg[31:0]prdata,output pready,pslverror,
 output[2:0]mode,history_index,output median_en,output[1:0]memory_mode,
 output[10:0]sobel_threshold,canny_threshold,threshold,
 input job_ready,capture_done,capture_error,source_hold_valid,render_done,render_error,render_pending,vblank,scan_busy,
 input[31:0]capture_count,
 output job_valid,enable,freeze_source,output[31:0]job_config_id,
 output[15:0]roi_x,roi_y,roi_w,roi_h,dst_w,dst_h,
 output reg[15:0]display_x,display_y,
 output config_busy,commit_rejected,output[31:0]requested_id,
 output config_error,output reg[31:0]committed_id,output[31:0]rejected_id
);
 wire[2:0]short_p,long_p;reg[5:0]key_pending=0;
 vision_keys #(.DEBOUNCE(DEBOUNCE),.LONG_PRESS(LONG_PRESS)) keys(video_clk,rst_n,keys_n,short_p,long_p);
 wire control_cmd=cmd_op>=1&&cmd_op<=5||cmd_op==8'h28||cmd_op==8'h29||cmd_op==8'h60||cmd_op>=8'h30&&cmd_op<=8'h35;
 wire cmd_valid=cmd_event&&control_cmd;
 wire in_valid=cmd_valid||key_pending!=0;wire in_ready;
 wire[31:0]in_data=cmd_valid?{cmd_op,cmd_value}:{8'hff,18'b0,key_pending};
 wire event_valid;wire[31:0]event_data;
 wire event_pop=psel&&penable&&!pwrite&&paddr==8'h04&&event_valid;
 reg overflow=0;(* async_reg="true" *)reg[1:0]overflow_sync=0;
 stream_cdc #(.WIDTH(32),.AW(4)) events(.arst_n(rst_n),.s_clk(video_clk),.s_valid(in_valid),.s_ready(in_ready),.s_data(in_data),
  .m_clk(clk),.m_valid(event_valid),.m_ready(event_pop),.m_data(event_data),.s_level(),.m_level());
 always @(posedge video_clk)begin
  if(!rst_n)begin key_pending<=0;overflow<=0;end
  else begin
   key_pending<=(in_ready&&!cmd_valid?6'b0:key_pending)|{long_p,short_p};
   if((cmd_valid&&!in_ready)||(!in_ready&&|(key_pending&{long_p,short_p})))overflow<=1;
  end
 end
 reg[30:0]settings=31'(3|(128<<9)|(128<<20));reg apply_request=0,apply_ack=0;
 (* async_reg="true" *)reg[2:0]apply_sync=0;(* async_reg="true" *)reg[1:0]ack_sync=0;
 reg[30:0]active=31'(3|(128<<9)|(128<<20));reg vq=0;
 wire apply_busy=apply_request!=ack_sync[1];
 assign mode=active[2:0],median_en=active[3],memory_mode=active[5:4],history_index=active[8:6];
 assign sobel_threshold=active[19:9],canny_threshold=active[30:20];
 assign threshold=(mode==5||mode==6)?canny_threshold:sobel_threshold;
 always @(posedge video_clk)begin
  if(!rst_n)begin apply_sync<=0;apply_ack<=0;active<=31'(3|(128<<9)|(128<<20));vq<=0;end
  else begin
   apply_sync<={apply_sync[1:0],apply_request};vq<=vs;
   if(vs&&!vq&&apply_sync[2]!=apply_ack)begin active<=settings;apply_ack<=apply_sync[2];end
  end
 end
 reg[11:0]rx=0,ry=0,rw=W,rh=H,dw=W,dh=H,dx=0,dy=0,jdx=0,jdy=0;
 reg roi_enabled=0,job_pending=0,error_latch=0;
 reg[31:0]config_id=0,requested=0,rejected=0;reg fw_busy=0,fw_rejected=0;
 (* async_reg="true" *)reg[5:0]ms=0;
 assign enable=roi_enabled,freeze_source=ms[5:4]==1,job_valid=job_pending,job_config_id=config_id;
 assign roi_x={4'b0,rx},roi_y={4'b0,ry},roi_w={4'b0,rw},roi_h={4'b0,rh},dst_w={4'b0,dw},dst_h={4'b0,dh};
 assign config_busy=fw_busy,commit_rejected=fw_rejected,requested_id=requested,config_error=error_latch,rejected_id=rejected;
 assign pready=!(psel&&penable&&pwrite&&paddr==8'h08&&apply_busy),pslverror=0;
 always @*begin
  prdata=0;
  case(paddr)
   8'h00:prdata=32'h26100802;
   8'h04:prdata=event_valid?event_data:0;
   8'h0c:prdata={overflow_sync[1],29'b0,event_valid,apply_busy};
   8'h10:prdata={20'b0,error_latch,render_pending,scan_busy,job_ready,source_hold_valid,freeze_source,roi_enabled,job_pending,fw_busy,3'b0};
   8'h14:prdata=capture_count;
   8'h18:prdata=committed_id;
  endcase
 end
 always @(posedge clk)begin
  if(!rst_n)begin
   ack_sync<=0;overflow_sync<=0;settings<=31'(3|(128<<9)|(128<<20));apply_request<=0;
   rx<=0;ry<=0;rw<=W;rh<=H;dw<=W;dh<=H;dx<=0;dy<=0;jdx<=0;jdy<=0;
   roi_enabled<=0;job_pending<=0;error_latch<=0;config_id<=0;requested<=0;rejected<=0;committed_id<=0;fw_busy<=0;fw_rejected<=0;ms<=0;display_x<=0;display_y<=0;
  end else begin
   ack_sync<={ack_sync[0],apply_ack};overflow_sync<={overflow_sync[0],overflow};ms<={ms[3:0],memory_mode};
   if(job_pending&&job_ready)begin job_pending<=0;committed_id<=config_id;jdx<=dx;jdy<=dy;end
   if(render_done&&render_error)begin error_latch<=1;rejected<=config_id;end
   if(render_pending&&vblank&&!scan_busy)begin display_x<={4'b0,jdx};display_y<={4'b0,jdy};end
   if(psel&&penable&&pwrite&&pready)case(paddr)
    8'h08:begin settings<=pwdata[30:0];apply_request<=~apply_request;end
    8'h20:begin rx<=pwdata[23:12];ry<=pwdata[11:0];end
    8'h24:begin rw<=pwdata[23:12];rh<=pwdata[11:0];end
    8'h28:begin dw<=pwdata[23:12];dh<=pwdata[11:0];end
    8'h2c:begin dx<=pwdata[23:12];dy<=pwdata[11:0];end
    8'h30:begin roi_enabled<=pwdata[0];if(pwdata[1])job_pending<=1;if(pwdata[2])error_latch<=0;if(pwdata[3])committed_id<=config_id;end
    8'h34:config_id<=pwdata;
    8'h38:begin fw_busy<=pwdata[0];fw_rejected<=pwdata[1];if(pwdata[2])error_latch<=1;end
    8'h3c:requested<=pwdata;
    8'h40:rejected<=pwdata;
   endcase
  end
 end
endmodule
