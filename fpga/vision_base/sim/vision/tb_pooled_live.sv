`timescale 1ns/1ps
module tb_pooled_live;
parameter W=64,H=48;
localparam BS=(W>64)?22:16, RB=8<<BS, LA=10<<BS;
reg clk=0,video_clk=0,rst_n=0;always #5 clk=~clk;always #3.367 video_clk=~video_clk;
reg vs=0,hs=0,de=0;reg[23:0]rgb=0;reg[31:0]raw_id=0;
wire scan_source_mode,unified_view_active;wire[2:0]pool_history_count;
assign roi_view_enable=unified_view_active&&roi_view_config!=0;
reg cam_vs=0,cam_de=0;reg[23:0]cam_rgb=0,cam_upper=0;reg[31:0]cam_id=0;
integer cx,cy,cam_frames=0;
initial begin
 wait(rst_n);
 forever begin
  @(negedge video_clk);cam_vs=1;cam_id=cam_frames;cam_de=0;
  @(negedge video_clk);cam_vs=0;repeat(64)@(negedge video_clk);
  for(cy=0;cy<H;cy=cy+1)begin
   for(cx=0;cx<W;cx=cx+2)begin
    cam_de=1;cam_rgb={5'(cx),3'b0,6'(cy),2'b0,5'(cam_frames),3'b0};
    cam_upper={5'(cx+1),3'b0,6'(cy),2'b0,5'(cam_frames),3'b0};@(negedge video_clk);
   end
   cam_de=0;repeat(2)@(negedge video_clk);
   // FOV delivers six-row bursts, with time to fill its next block.
   if(cy%6==5)repeat(W>64?W*2:W*4)@(negedge video_clk);
  end
  cam_frames=cam_frames+1;repeat(W>64?W*200:W*32)@(negedge video_clk);
 end
end
reg cmd_event=0;reg[7:0]cmd_op=0;reg[23:0]cmd_value=0;reg[1:0]memory_mode=0;
integer cycle=0;always @(posedge clk)cycle<=cycle+1;
reg hold_w=0,hold_r=0;
 wire[3:0] s_axi_arid;
 wire[31:0] s_axi_araddr;
 wire[7:0] s_axi_arlen;
 wire[2:0] s_axi_arsize;
 wire[1:0] s_axi_arburst;
 wire s_axi_arvalid;
 reg s_axi_arready=0;
 reg[127:0] s_axi_rdata=0;
 reg[1:0] s_axi_rresp=0;
 reg[3:0] s_axi_rid=0;
 reg s_axi_rlast=0;
 reg s_axi_rvalid=0;
 wire s_axi_rready;
 wire[3:0] s_axi_awid;
 wire[31:0] s_axi_awaddr;
 wire[7:0] s_axi_awlen;
 wire[2:0] s_axi_awsize;
 wire[1:0] s_axi_awburst;
 wire s_axi_awvalid;
 reg s_axi_awready=0;
 wire[127:0] s_axi_wdata;
 wire[15:0] s_axi_wstrb;
 wire s_axi_wlast;
 wire s_axi_wvalid;
 reg s_axi_wready=0;
 reg[1:0] s_axi_bresp=0;
 reg[3:0] s_axi_bid=0;
 reg s_axi_bvalid=0;
 wire s_axi_bready;
wire[5:0] fb_axi_awid;
wire[31:0] fb_axi_awaddr;
wire[7:0] fb_axi_awlen;
wire[2:0] fb_axi_awsize;
wire[1:0] fb_axi_awburst;
wire fb_axi_awvalid;
wire fb_axi_awready;
wire[127:0] fb_axi_wdata;
wire[15:0] fb_axi_wstrb;
wire fb_axi_wlast;
wire fb_axi_wvalid;
wire fb_axi_wready;
wire[5:0] fb_axi_bid;
wire[1:0] fb_axi_bresp;
wire fb_axi_bvalid;
wire fb_axi_bready;
wire[5:0] fb_axi_arid;
wire[31:0] fb_axi_araddr;
wire[7:0] fb_axi_arlen;
wire[2:0] fb_axi_arsize;
wire[1:0] fb_axi_arburst;
wire fb_axi_arvalid;
wire fb_axi_arready;
wire[5:0] fb_axi_rid;
wire[127:0] fb_axi_rdata;
wire[1:0] fb_axi_rresp;
wire fb_axi_rlast;
wire fb_axi_rvalid;
wire fb_axi_rready;
wire[5:0]roi_axi_awid,roi_axi_arid;
assign s_axi_awid=roi_axi_awid[3:0],s_axi_arid=roi_axi_arid[3:0];
wire roi_enable,roi_freeze,roi_job_valid,roi_job_ready,roi_capture_valid,roi_capture_ready,roi_capture_pvalid,roi_capture_pready,roi_capture_sof,roi_capture_eol,roi_capture_eof,roi_capture_abort,roi_capture_done,roi_capture_error,roi_capture_active;
wire[31:0]roi_capture_id,roi_capture_data,roi_capture_count,roi_capture_discard,roi_job_id,roi_display_base,roi_display_frame,roi_display_config,roi_display_stride,roi_cycles,roi_misses;
wire[15:0]roi_x,roi_y,roi_w,roi_h,roi_dw,roi_dh,roi_posx,roi_posy,roi_display_width,roi_display_height;
wire roi_scan_urgent,roi_scan_enable,roi_display_valid,roi_render_done,roi_render_error,roi_render_busy,roi_render_pending,roi_scan_valid,roi_scan_ready,roi_scan_sof,roi_scan_eol,roi_scan_eof,roi_scan_busy,roi_scan_done,roi_scan_error,roi_vblank;
wire[31:0]roi_scan_data,roi_scan_frame,roi_scan_config;wire[1:0]roi_scan_keep;
wire roi_hold_valid,roi_config_busy,roi_config_error,roi_commit_rejected;wire[31:0]roi_hold_frame,roi_hold_raw,roi_commit_id,roi_requested_id,roi_rejected_id;
wire[23:0]roi_rgb;wire roi_vs,roi_hs,roi_de,roi_view_enable,roi_frame_ok,roi_config_changed;wire[31:0]roi_view_frame,roi_view_config,roi_bad_frames;
frame_memory_system #(.SOURCE_BANKS(8),.KEEP_HISTORY(1),.DIRECT_SCAN(1),.LEGACY_ENABLED(0),.MAX_LINE_PIXELS(W),.SOURCE_BASE(0),.RESULT_BASE(RB),.BANK_SHIFT(BS),.SCAN_BURST_BEATS(32)) dut(
 .clk(clk),
 .rst_n(rst_n),
 .capture_abort(roi_capture_abort),.direct_scan(!roi_enable),.memory_mode(memory_mode),.history_index(3'd0),.scan_source_mode(scan_source_mode),.history_count(pool_history_count),
 .scan_enable(roi_scan_enable),.scan_urgent(roi_scan_urgent),
 .capture_valid(roi_capture_valid),
 .capture_ready(roi_capture_ready),
 .capture_config_id(roi_capture_id),
 .src_width(16'(W)),
 .src_height(16'(H)),
 .src_stride_bytes(32'(W*2)),
 .capture_pixel_valid(roi_capture_pvalid),
 .capture_pixel_ready(roi_capture_pready),
 .capture_pixel_data(roi_capture_data),
 .capture_pixel_sof(roi_capture_sof),
 .capture_pixel_eol(roi_capture_eol),
 .capture_pixel_eof(roi_capture_eof),
 .capture_done(roi_capture_done),
 .capture_error(roi_capture_error),
 .job_valid(roi_job_valid),
 .job_ready(roi_job_ready),
 .freeze_source(roi_freeze),
 .release_source(!roi_enable||!roi_freeze),
 .job_config_id(roi_job_id),
 .roi_x(roi_x),
 .roi_y(roi_y),
 .roi_w(roi_w),
 .roi_h(roi_h),
 .dst_width(roi_dw),
 .dst_height(roi_dh),
 .dst_stride_bytes({15'b0,roi_dw,1'b0}),
 .analysis_acquire_valid(1'b0),
 .analysis_acquire_ready(),
 .analysis_release(1'b0),
 .analysis_hold_valid(),
 .analysis_hold_bank(),
 .analysis_hold_frame_id(),
 .analysis_hold_config_id(),
 .vblank(roi_vblank),
 .display_valid(roi_display_valid),
 .display_base(roi_display_base),
 .display_frame_id(roi_display_frame),
 .display_config_id(roi_display_config),
 .display_width(roi_display_width),
 .display_height(roi_display_height),
 .display_stride_bytes(roi_display_stride),
 .render_done(roi_render_done),
 .render_error(roi_render_error),
 .render_busy(roi_render_busy),
 .render_pending(roi_render_pending),
 .last_cycles(roi_cycles),
 .deadline_misses(roi_misses),
 .scan_pixel_valid(roi_scan_valid),
 .scan_pixel_ready(roi_scan_ready),
 .scan_pixel_data(roi_scan_data),
 .scan_pixel_keep(roi_scan_keep),
 .scan_pixel_sof(roi_scan_sof),
 .scan_pixel_eol(roi_scan_eol),
 .scan_pixel_eof(roi_scan_eof),
 .scan_pixel_frame_id(roi_scan_frame),
 .scan_pixel_config_id(roi_scan_config),
 .scan_busy(roi_scan_busy),
 .scan_done(roi_scan_done),
 .scan_error(roi_scan_error),
 .legacy_arid(fb_axi_arid),
 .legacy_araddr(fb_axi_araddr),
 .legacy_arlen(fb_axi_arlen),
 .legacy_arsize(fb_axi_arsize),
 .legacy_arburst(fb_axi_arburst),
 .legacy_arvalid(fb_axi_arvalid),
 .legacy_arready(fb_axi_arready),
 .legacy_rdata(fb_axi_rdata),
 .legacy_rresp(fb_axi_rresp),
 .legacy_rid(fb_axi_rid),
 .legacy_rlast(fb_axi_rlast),
 .legacy_rvalid(fb_axi_rvalid),
 .legacy_rready(fb_axi_rready),
 .legacy_awid(fb_axi_awid),
 .legacy_awaddr(fb_axi_awaddr),
 .legacy_awlen(fb_axi_awlen),
 .legacy_awsize(fb_axi_awsize),
 .legacy_awburst(fb_axi_awburst),
 .legacy_awvalid(fb_axi_awvalid),
 .legacy_awready(fb_axi_awready),
 .legacy_wdata(fb_axi_wdata),
 .legacy_wstrb(fb_axi_wstrb),
 .legacy_wlast(fb_axi_wlast),
 .legacy_wvalid(fb_axi_wvalid),
 .legacy_wready(fb_axi_wready),
 .legacy_bresp(fb_axi_bresp),
 .legacy_bid(fb_axi_bid),
 .legacy_bvalid(fb_axi_bvalid),
 .legacy_bready(fb_axi_bready),
 .m_axi_arid(roi_axi_arid),
 .m_axi_araddr(s_axi_araddr),
 .m_axi_arlen(s_axi_arlen),
 .m_axi_arsize(s_axi_arsize),
 .m_axi_arburst(s_axi_arburst),
 .m_axi_arvalid(s_axi_arvalid),
 .m_axi_arready(s_axi_arready),
 .m_axi_rdata(s_axi_rdata),
 .m_axi_rresp(s_axi_rresp),
 .m_axi_rid({2'b0,s_axi_rid}),
 .m_axi_rlast(s_axi_rlast),
 .m_axi_rvalid(s_axi_rvalid),
 .m_axi_rready(s_axi_rready),
 .m_axi_awid(roi_axi_awid),
 .m_axi_awaddr(s_axi_awaddr),
 .m_axi_awlen(s_axi_awlen),
 .m_axi_awsize(s_axi_awsize),
 .m_axi_awburst(s_axi_awburst),
 .m_axi_awvalid(s_axi_awvalid),
 .m_axi_awready(s_axi_awready),
 .m_axi_wdata(s_axi_wdata),
 .m_axi_wstrb(s_axi_wstrb),
 .m_axi_wlast(s_axi_wlast),
 .m_axi_wvalid(s_axi_wvalid),
 .m_axi_wready(s_axi_wready),
 .m_axi_bresp(s_axi_bresp),
 .m_axi_bid({2'b0,s_axi_bid}),
 .m_axi_bvalid(s_axi_bvalid),
 .m_axi_bready(s_axi_bready),
 .source_hold_valid(roi_hold_valid),
 .source_hold_frame_id(roi_hold_frame),
 .source_hold_config_id(roi_hold_raw)
);vision_roi_control #(.W(W),.H(H)) roi_control(.rst_n(rst_n),.video_clk(video_clk),.cmd_event(cmd_event),.cmd_op(cmd_op),.cmd_value(cmd_value),.memory_mode(memory_mode),.clk(clk),
 .job_ready(roi_job_ready),.capture_done(roi_capture_done),.capture_error(roi_capture_error),.source_hold_valid(roi_hold_valid),.render_done(roi_render_done),.render_error(roi_render_error),.render_pending(roi_render_pending),.vblank(roi_vblank),.scan_busy(roi_scan_busy),
 .job_valid(roi_job_valid),.enable(roi_enable),.freeze_source(roi_freeze),.job_config_id(roi_job_id),.roi_x(roi_x),.roi_y(roi_y),.roi_w(roi_w),.roi_h(roi_h),.dst_w(roi_dw),.dst_h(roi_dh),.display_x(roi_posx),.display_y(roi_posy),.config_busy(roi_config_busy),.commit_rejected(roi_commit_rejected),.requested_id(roi_requested_id),.config_error(roi_config_error),.committed_id(roi_commit_id),.rejected_id(roi_rejected_id));
vision_rgb_capture #(.W(W),.H(H),.INPUT_PPC(2),.FIFO_AW(W>64?11:8)) roi_capture(.rst_n(rst_n),.video_clk(video_clk),.vs(cam_vs),.de(cam_de),.rgb(cam_rgb),.rgb_upper(cam_upper),.source_abort(1'b0),.raw_id(cam_id),.clk(clk),.enable(1'b1),.freeze_source(1'b0),
 .capture_valid(roi_capture_valid),.capture_ready(roi_capture_ready),.capture_config_id(roi_capture_id),.capture_pixel_valid(roi_capture_pvalid),.capture_pixel_ready(roi_capture_pready),.capture_pixel_data(roi_capture_data),.capture_pixel_sof(roi_capture_sof),.capture_pixel_eol(roi_capture_eol),.capture_pixel_eof(roi_capture_eof),.capture_abort(roi_capture_abort),.capture_done(roi_capture_done),.capture_error(roi_capture_error),.active(roi_capture_active),.completed(roi_capture_count),.discarded(roi_capture_discard));
vision_rgb_scanout #(.FIFO_AW(W>64?11:6)) roi_scanout(.rst_n(rst_n),.clk(clk),.enable(1'b1),.have_result(roi_enable?roi_display_valid:pool_history_count!=0),.pixel_valid(roi_scan_valid),.pixel_ready(roi_scan_ready),.pixel_data(roi_scan_data),.pixel_eol(roi_scan_eol),.pixel_eof(roi_scan_eof),.pixel_frame_id(roi_scan_frame),.pixel_config_id(roi_scan_config),.width(scan_source_mode?16'(W):roi_display_width),.height(scan_source_mode?16'(H):roi_display_height),.pos_x(scan_source_mode?16'd0:roi_posx),.pos_y(scan_source_mode?16'd0:roi_posy),.scan_done(roi_scan_done),.scan_error(roi_scan_error),.vblank(roi_vblank),.scan_enable(roi_scan_enable),.read_urgent(roi_scan_urgent),
 .video_clk(video_clk),.vs(vs),.hs(hs),.de(de),.rgb(rgb),.view_rgb(roi_rgb),.view_vs(roi_vs),.view_hs(roi_hs),.view_de(roi_de),.view_enabled(unified_view_active),.frame_ok(roi_frame_ok),.config_changed(roi_config_changed),.view_frame_id(roi_view_frame),.view_config_id(roi_view_config),.bad_frames(roi_bad_frames));
 reg[127:0]mem[0:((LA+8191)>>4)];
 reg rd_active=0,wr_active=0;integer ra=0,rc=0,wa=0,wc=0,bd=0;
 reg[3:0]rid=0,bid=0;reg inject_r=0,inject_b=0;integer arb_reads=0,arb_writes=0;
 integer k;
 always @*begin s_axi_arready=!rd_active&&!s_axi_rvalid&&cycle%3!=0;
  s_axi_awready=!wr_active&&!s_axi_bvalid&&bd==0&&cycle%7!=0;
  s_axi_wready=wr_active&&cycle%4!=0&&!hold_w;
 end
 always @(posedge clk)if(rst_n)begin
  if(s_axi_arvalid&&s_axi_arready)begin
   if(s_axi_araddr[3:0]||s_axi_arburst!=1||s_axi_arsize!=4||s_axi_araddr[11:0]+(s_axi_arlen+1)*16>4096)$fatal(1,"AR boundary");
   rd_active<=1;ra<=s_axi_araddr;rc<=s_axi_arlen+1;rid<=s_axi_arid;arb_reads<=arb_reads+1;
  end
  if(s_axi_rvalid&&s_axi_rready)begin s_axi_rvalid<=0;ra<=ra+16;rc<=rc-1;if(rc==1)rd_active<=0;end
  if(rd_active&&(!s_axi_rvalid||s_axi_rready)&&!(s_axi_rvalid&&rc==1)&&cycle%6!=0&&!hold_r)begin
   s_axi_rdata<=mem[(ra+(s_axi_rvalid?16:0))>>4];
   s_axi_rvalid<=1;s_axi_rlast<=rc==(s_axi_rvalid?2:1);s_axi_rid<=rid;s_axi_rresp<=inject_r&&rid==0?2:0;
  end
  if(s_axi_awvalid&&s_axi_awready)begin
   if(s_axi_awaddr[3:0]||s_axi_awburst!=1||s_axi_awsize!=4||s_axi_awaddr[11:0]+(s_axi_awlen+1)*16>4096)$fatal(1,"AW boundary");
   wr_active<=1;wa<=s_axi_awaddr;wc<=s_axi_awlen+1;bid<=s_axi_awid;arb_writes<=arb_writes+1;
  end
  if(s_axi_wvalid&&s_axi_wready)begin
   if(s_axi_wlast!=(wc==1))$fatal(1,"W interleave/last");
   if(s_axi_wstrb!==16'hffff)$fatal(1,"frame writer byte mask");
   mem[wa>>4]<=s_axi_wdata;
   wa<=wa+16;wc<=wc-1;if(wc==1)begin wr_active<=0;bd<=8;end
  end
  if(bd>0)begin bd<=bd-1;if(bd==1)begin s_axi_bvalid<=1;s_axi_bid<=bid;s_axi_bresp<=inject_b&&bid==0?2:0;end end
  if(s_axi_bvalid&&s_axi_bready)s_axi_bvalid<=0;
 end

reg legacy_wait=0;integer legacy_reads=0,legacy_gap=0;
assign fb_axi_arid=6'd3,fb_axi_araddr=LA,fb_axi_arlen=W>64?127:3,fb_axi_arsize=4,fb_axi_arburst=1;
assign fb_axi_arvalid=1'b0,fb_axi_rready=1;
assign fb_axi_awid=3,fb_axi_awaddr=0,fb_axi_awlen=0,fb_axi_awsize=4,fb_axi_awburst=1,fb_axi_awvalid=0;
assign fb_axi_wdata=0,fb_axi_wstrb=0,fb_axi_wlast=0,fb_axi_wvalid=0,fb_axi_bready=1;
always @(posedge clk)if(rst_n)begin
 if(legacy_gap>0)legacy_gap<=legacy_gap-1;
 if(fb_axi_arvalid&&fb_axi_arready)begin legacy_wait<=1;legacy_gap<=W>64?1280:0;end
 if(fb_axi_rvalid)begin
  if(fb_axi_rid!=3||fb_axi_rdata!=={16{8'h5a}})$fatal(1,"legacy bus changed");
  if(fb_axi_rlast)begin legacy_wait<=0;legacy_reads<=legacy_reads+1;end
 end
end
// Independent reference for shared-range packed16 linear RGB.
function automatic[15:0]paint(input integer f,x,y);
 integer r,g,b;begin r=(x&31)*8;g=(y&63)*4;b=(f&31)*8;
 if(r<64&&g<64&&b<64)paint={1'b0,5'(r/2),5'(g/2),5'(b/2)};
 else paint={1'b1,5'((r*31+127)/255),5'((g*31+127)/255),5'((b*31+127)/255)};end
endfunction
function automatic[23:0]expand(input[15:0]v);expand=v[15]?{v[14:10],v[14:12],v[9:5],v[9:7],v[4:0],v[4:2]}:{2'b0,v[14:10],1'b0,2'b0,v[9:5],1'b0,2'b0,v[4:0],1'b0};endfunction
integer vx,vy,video_frames=0;
initial begin
 forever begin
  @(negedge video_clk);vs=1;de=0;raw_id=video_frames;
  repeat(W>64?11000:128)@(negedge video_clk);vs=0;repeat(W>64?88000:896)@(negedge video_clk);
  for(vy=0;vy<H;vy=vy+1)begin
   for(vx=0;vx<W;vx=vx+1)begin de=1;rgb={5'(vx),3'b0,6'(vy),2'b0,5'(video_frames),3'b0};@(negedge video_clk);end
   de=0;hs=1;repeat(16)@(negedge video_clk);hs=0;repeat(W>64?264:176)@(negedge video_clk);
  end
  video_frames=video_frames+1;
  if(W>64)$display("field%0d good%0d cap%0d discard%0d history%0d cfg%0d bad%0d",video_frames,good_frames,roi_capture_count,roi_capture_discard,pool_history_count,roi_view_config,roi_bad_frames);
 end
end
integer raw_by_frame[0:4095];
always @(posedge clk)if(roi_capture_done&&!roi_capture_error)raw_by_frame[dut.engine.control.pool.cap_active_frame_id]=roi_capture_id;
integer out_x=0,out_y=0,checks=0,good_frames=0,rx,ry,rw,rh,dw,dh,dx,dy,sx,sy,source_raw;
reg ov=0,od=0;reg[23:0]want;reg[31:0]field_cfg=0,frozen_id=0;
reg checking=1,check_field=0;
always @(negedge video_clk)begin
 #0.001;
 
 if(roi_vs&&!ov)begin out_x=0;out_y=0;check_field=0;end
 if(od&&!roi_de)begin out_x=0;out_y=out_y+1;end
 if(roi_de)begin
  if(out_x==0&&out_y==0)begin
   field_cfg=roi_view_config;check_field=checking&&unified_view_active&&roi_scanout.meta_valid&&!roi_scanout.failed;
  end
  if(check_field&&!roi_scanout.failed&&checking)begin
   if(field_cfg!=roi_view_config)$fatal(1,"config changed in active frame");
   case(field_cfg)
    0,1:begin rx=0;ry=0;rw=W;rh=H;dw=W;dh=H;dx=0;dy=0;end
    2:begin if(W>64)begin rx=480;ry=270;rw=960;rh=540;dw=W;dh=H;dx=0;dy=0;end else begin rx=5;ry=7;rw=21;rh=15;dw=40;dh=24;dx=8;dy=12;end end
    3:begin if(W>64)begin rx=608;ry=334;rw=960;rh=540;dw=W;dh=H;dx=0;dy=0;end else begin rx=24;ry=15;rw=24;rh=20;dw=16;dh=16;dx=40;dy=2;end end
    4:begin rx=3;ry=4;rw=49;rh=37;dw=W;dh=H;dx=0;dy=0;end
    6,8:begin rx=0;ry=0;rw=W;rh=H;dw=W;dh=H;dx=0;dy=0;end
    default:$fatal(1,"rejected config published %0d",field_cfg);
   endcase
   want=0;
   if(out_x>=dx&&out_x<dx+dw&&out_y>=dy&&out_y<dy+dh)begin
    sx=rx+(out_x-dx)*rw/dw;sy=ry+(out_y-dy)*rh/dh;source_raw=raw_by_frame[roi_view_frame];want=expand(paint(source_raw,sx,sy));
   end
   if(roi_rgb!==want)$fatal(1,"pixel cfg%0d frame%0d x%0d y%0d got%h want%h raw%0d meta%b started%b phase%b xy%0d/%0d size%0d/%0d pos%0d/%0d mv%b tag%0d enabled%b good%b",field_cfg,roi_view_frame,out_x,out_y,roi_rgb,want,source_raw,roi_scanout.meta_valid,roi_scanout.started,roi_scanout.phase,roi_scanout.x,roi_scanout.y,roi_scanout.w,roi_scanout.h,roi_scanout.dx,roi_scanout.dy,roi_scanout.mv,roi_scanout.kind,roi_enable,roi_frame_ok);
   checks=checks+1;if(out_x==W-1&&out_y==H-1)good_frames=good_frames+1;
  end
  out_x=out_x+1;
 end
 ov=roi_vs;od=roi_de;
end

task command(input[7:0]op,input[23:0]value);begin
 @(negedge video_clk);cmd_event=1;cmd_op=op;cmd_value=value;@(negedge video_clk);cmd_event=0;repeat(4)@(negedge video_clk);
end endtask
task configure(input integer x,y,w,h,ow,oh,px,py);begin
 command('h30,(x<<12)|y);command('h31,(w<<12)|h);command('h32,(ow<<12)|oh);command('h33,(px<<12)|py);command('h34,1);command('h35,0);
end endtask
task wait_frames(input integer id);integer start;begin
 wait(roi_view_config==id&&roi_frame_ok);start=good_frames;wait(good_frames>=start+(W>64?1:2));
 if(roi_bad_frames||roi_capture_discard||roi_config_error)$fatal(1,"normal ROI frame fault");
 $display("ROI cfg%0d held%0d/%0d view%0d pixels%0d",id,roi_hold_frame,roi_hold_raw,roi_view_frame,checks);
end endtask
initial begin
 for(k=0;k<128;k=k+1)mem[(LA>>4)+k]={16{8'h5a}};
 repeat(8)@(negedge clk);rst_n=1;
 wait(roi_frame_ok&&roi_view_config==0);wait(good_frames>=2);
 if(roi_bad_frames||roi_capture_discard)$fatal(1,"plain source scan fault");
 if(W>64)begin
  configure(0,0,W,H,W,H,0,0);wait_frames(1);
  @(negedge video_clk);memory_mode=1;wait(roi_hold_valid&&roi_freeze&&!roi_render_busy&&!roi_render_pending);frozen_id=roi_hold_frame;
  configure(480,270,960,540,W,H,0,0);wait_frames(2);if(roi_view_frame!=frozen_id)$fatal(1,"full zoom source changed");
  configure(608,334,960,540,W,H,0,0);wait_frames(3);if(roi_view_frame!=frozen_id)$fatal(1,"full pan source changed");
  $display("PASS pooled RGB1080p full %0d pixels, %0d whole frames, native148.5/100MHz CDC + shared DDR, live/frozen zoom/pan",checks,good_frames);$finish;
 end
 configure(0,0,W,H,W,H,0,0);wait_frames(1);
 @(negedge video_clk);memory_mode=1;wait(roi_hold_valid&&roi_freeze&&!roi_render_busy&&!roi_render_pending);frozen_id=roi_hold_frame;
 configure(5,7,21,15,40,24,8,12);wait_frames(2);if(roi_view_frame!=frozen_id)$fatal(1,"freeze changed source");
 configure(24,15,24,20,16,16,40,2);wait_frames(3);if(roi_view_frame!=frozen_id)$fatal(1,"pan changed frozen source");
 configure(3,4,49,37,W,H,0,0);wait_frames(4);if(roi_view_frame!=frozen_id)$fatal(1,"scale changed frozen source");
 configure(0,0,W,H,W,H,1,0);wait(roi_rejected_id==5);repeat(200)@(negedge clk);
 if(!roi_config_error||roi_commit_id!=4||roi_view_config!=4)$fatal(1,"invalid canvas disguised as applied");
 configure(0,0,W,H,W,H,0,0);wait_frames(6);if(roi_view_frame!=frozen_id)$fatal(1,"rerender changed source");
 command('h34,0);command('h35,0);wait(!roi_enable&&!roi_view_enable);
 @(negedge video_clk);memory_mode=0;wait(!roi_hold_valid);repeat(4)@(posedge vs);
 @(negedge video_clk);memory_mode=1;configure(0,0,W,H,W,H,0,0);wait_frames(8);
 if(roi_view_frame==frozen_id)$fatal(1,"re-entering ROI froze stale RGB cache");frozen_id=roi_view_frame;
 @(negedge video_clk);memory_mode=0;wait(roi_view_frame>frozen_id);wait(!roi_render_busy&&!roi_render_pending);
 checking=0;wait(roi_capture_active);hold_w=1;repeat(2200)@(negedge clk);hold_w=0;wait(roi_capture_discard!=0);wait(roi_frame_ok&&!roi_scanout.failed);
 hold_r=1;repeat(3000)@(negedge clk);hold_r=0;wait(roi_bad_frames!=0);repeat(3)@(posedge vs);checking=1;
 wait(roi_frame_ok&&!roi_scanout.failed);repeat(3)@(posedge vs);
 if(checks<10*W*H)$fatal(1,"coverage");
 $display("PASS pooled RGB live %0d pixels, %0d full frames; scale/pan/placement, frozen-source rerender, atomic configs, invalid config, overflow abort and scan starvation recovery",checks,good_frames);$finish;
end
initial begin #(W>64?300000000:10000000);$fatal(1,"watchdog cap%0d scan%0d cfg%0d frames%0d good%0d bad%0d meta%b start%b failed%b drain%b done%b mv%b mr%b kind%0d xy%0d/%0d size%0d/%0d mode%b busy%b",roi_capture.state,roi_scanout.header,roi_view_config,video_frames,good_frames,roi_bad_frames,roi_scanout.meta_valid,roi_scanout.started,roi_scanout.failed,roi_scanout.draining,roi_scanout.transport_done,roi_scanout.mv,roi_scanout.mr,roi_scanout.kind,roi_scanout.x,roi_scanout.y,roi_scanout.w,roi_scanout.h,scan_source_mode,roi_scan_busy);end
endmodule
