// Staged geometric commands -> one outstanding bundled CDC commit -> render.
// X/Y/W/H and canvas placement are captured together; results carry config ID.
module vision_roi_control #(parameter W=1920,H=1080)(
 input rst_n,video_clk,cmd_event,input[7:0]cmd_op,input[23:0]cmd_value,
 input[1:0]memory_mode,input clk,job_ready,capture_done,capture_error,
 input source_hold_valid,render_done,render_error,render_pending,vblank,scan_busy,
 output job_valid,output enable,freeze_source,
 output[31:0]job_config_id,
 output[15:0]roi_x,roi_y,roi_w,roi_h,dst_w,dst_h,
 output reg[15:0]display_x,display_y,
 output config_busy,commit_rejected,output[31:0]requested_id,
 output reg config_error,output reg[31:0]committed_id,rejected_id
);
 reg[11:0]px=0,py=0,pw=W,ph=H,ox=0,oy=0,ow=W,oh=H;reg pe=0;
 reg[128:0]mailbox=0;reg request=0,ack=0;reg[31:0]serial=0;
 reg[2:0]as=0,qs=0;reg[5:0]ms=0;reg video_reject=0;
 assign config_busy=request!=as[2];
 assign commit_rejected=video_reject,requested_id=serial;
 always @(posedge video_clk)begin
  as<={as[1:0],ack};
  if(!rst_n)begin px<=0;py<=0;pw<=W;ph<=H;ox<=0;oy<=0;ow<=W;oh<=H;pe<=0;mailbox<=0;request<=0;serial<=0;as<=0;video_reject<=0;end
  else if(cmd_event)case(cmd_op)
   8'h30:begin px<=cmd_value[23:12];py<=cmd_value[11:0];end
   8'h31:begin pw<=cmd_value[23:12];ph<=cmd_value[11:0];end
   8'h32:begin ow<=cmd_value[23:12];oh<=cmd_value[11:0];end
   8'h33:begin ox<=cmd_value[23:12];oy<=cmd_value[11:0];end
   8'h34:pe<=cmd_value[0];
   8'h35:if(!config_busy)begin
    serial<=serial+1'b1;mailbox<={serial+32'd1,pe,px,py,pw,ph,ox,oy,ow,oh};request<=~request;video_reject<=0;
   end else video_reject<=1;
  endcase
 end
 wire incoming=qs[2]!=ack;
 wire[31:0]new_id=mailbox[128:97];wire new_enable=mailbox[96];
 wire[15:0]nx={4'b0,mailbox[95:84]},ny={4'b0,mailbox[83:72]},nw={4'b0,mailbox[71:60]},nh={4'b0,mailbox[59:48]},
  ndx={4'b0,mailbox[47:36]},ndy={4'b0,mailbox[35:24]},ndw={4'b0,mailbox[23:12]},ndh={4'b0,mailbox[11:0]};
 // Address/ROI validity belongs to the existing engine. This boundary owns
 // only the physical canvas extent, which that generic engine does not know.
 wire canvas_bad={1'b0,ndx}+{1'b0,ndw}>W||{1'b0,ndy}+{1'b0,ndh}>H;
 reg enabled=0,config_good=0,dirty=0,prev_freeze=0,warming=0;
 reg[15:0]ax=0,ay=0,aw=W,ah=H,adx=0,ady=0,adw=W,adh=H,jdx=0,jdy=0;reg[31:0]jcfg=0;
 wire commit_job=incoming&&new_enable&&!canvas_bad&&enabled&&!warming;
 wire auto_job=enabled&&config_good&&((freeze_source&&!source_hold_valid)||(!freeze_source&&dirty));
 assign job_valid=commit_job||(!incoming&&auto_job);
 assign enable=enabled,freeze_source=ms[5:4]==1;
 assign job_config_id=incoming?new_id:committed_id;
 assign roi_x=incoming?nx:ax,roi_y=incoming?ny:ay,roi_w=incoming?nw:aw,roi_h=incoming?nh:ah;
 assign dst_w=incoming?ndw:adw,dst_h=incoming?ndh:adh;
 always @(posedge clk)begin
  qs<={qs[1:0],request};ms<={ms[3:0],memory_mode};prev_freeze<=freeze_source;
  if(!rst_n)begin
   qs<=0;ms<=0;ack<=0;enabled<=0;config_good<=0;dirty<=0;prev_freeze<=0;warming<=0;config_error<=0;committed_id<=0;rejected_id<=0;jcfg<=0;
   ax<=0;ay<=0;aw<=W;ah<=H;adx<=0;ady<=0;adw<=W;adh<=H;jdx<=0;jdy<=0;display_x<=0;display_y<=0;
  end else begin
   // Re-entering ROI after bypass must capture a fresh full original frame,
   // rather than freeze an old RGB bank left over from an earlier session.
   if(incoming&&new_enable&&!canvas_bad&&!enabled)begin enabled<=1;warming<=1;end
   if(capture_done&&!capture_error)warming<=0;
   if(render_done&&render_error)begin config_error<=1;config_good<=0;rejected_id<=jcfg;end
   if(job_valid&&job_ready)begin
    dirty<=0;jdx<=incoming?ndx:adx;jdy<=incoming?ndy:ady;jcfg<=job_config_id;
    if(incoming)begin
     ack<=qs[2];enabled<=1;config_good<=1;committed_id<=new_id;config_error<=0;
     ax<=nx;ay<=ny;aw<=nw;ah<=nh;adx<=ndx;ady<=ndy;adw<=ndw;adh<=ndh;
    end
   end
   if(incoming&&(!new_enable||canvas_bad))begin
    ack<=qs[2];
    if(canvas_bad&&new_enable)begin config_error<=1;rejected_id<=new_id;end
    else begin enabled<=0;warming<=0;config_error<=0;committed_id<=new_id;end
   end
   if((capture_done&&!capture_error)||freeze_source!=prev_freeze)dirty<=1;
   if(render_pending&&vblank&&!scan_busy)begin display_x<=jdx;display_y<=jdy;end
  end
 end
endmodule
