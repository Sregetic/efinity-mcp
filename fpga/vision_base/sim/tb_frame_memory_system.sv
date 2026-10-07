`timescale 1ns/1ps
module tb_frame_memory_system;
 reg clk=0,rst_n=0;always #5 clk=~clk;
 wire capture_abort=0,scan_enable=1;
 wire scan_urgent=0;
 wire source_hold_valid;
 wire release_source=0;
 wire[31:0]source_hold_frame_id,source_hold_config_id;
 reg capture_valid=0,capture_pixel_valid=0,capture_pixel_sof=0,capture_pixel_eol=0,capture_pixel_eof=0;
 wire capture_ready,capture_pixel_ready,capture_done,capture_error;
 reg[31:0]capture_config_id=10,capture_pixel_data=0;
 reg[15:0]src_width=32,src_height=8;reg[31:0]src_stride_bytes=80;
 reg job_valid=0,freeze_source=0,vblank=0;wire job_ready;
 reg[31:0]job_config_id=100;reg[15:0]roi_x=3,roi_y=2,roi_w=13,roi_h=4,dst_width=16,dst_height=8;
 reg[31:0]dst_stride_bytes=48;
 reg analysis_acquire_valid=0,analysis_release=0;wire analysis_acquire_ready,analysis_hold_valid;
 wire[1:0]analysis_hold_bank;wire[31:0]analysis_hold_frame_id,analysis_hold_config_id;
 wire display_valid;wire[31:0]display_base,display_frame_id,display_config_id,display_stride_bytes,last_cycles,deadline_misses;
 wire[15:0]display_width,display_height;
 wire render_done,render_error,render_busy,render_pending;
 wire scan_pixel_valid,scan_pixel_sof,scan_pixel_eol,scan_pixel_eof,scan_busy,scan_done,scan_error;
 wire[31:0]scan_pixel_data,scan_pixel_frame_id,scan_pixel_config_id;wire[1:0]scan_pixel_keep;
 integer cycle=0;always @(posedge clk)cycle<=cycle+1;
 wire scan_pixel_ready=cycle%5!=0;
 reg[5:0] legacy_arid=0;
 reg[31:0] legacy_araddr=0;
 reg[7:0] legacy_arlen=0;
 reg[2:0] legacy_arsize=0;
 reg[1:0] legacy_arburst=0;
 reg legacy_arvalid=0;
 wire legacy_arready;
 wire[127:0] legacy_rdata;
 wire[1:0] legacy_rresp;
 wire[5:0] legacy_rid;
 wire legacy_rlast;
 wire legacy_rvalid;
 reg legacy_rready=0;
 reg[5:0] legacy_awid=0;
 reg[31:0] legacy_awaddr=0;
 reg[7:0] legacy_awlen=0;
 reg[2:0] legacy_awsize=0;
 reg[1:0] legacy_awburst=0;
 reg legacy_awvalid=0;
 wire legacy_awready;
 reg[127:0] legacy_wdata=0;
 reg[15:0] legacy_wstrb=0;
 reg legacy_wlast=0;
 reg legacy_wvalid=0;
 wire legacy_wready;
 wire[1:0] legacy_bresp;
 wire[5:0] legacy_bid;
 wire legacy_bvalid;
 reg legacy_bready=0;
 reg[5:0] cpu_arid=0;
 reg[31:0] cpu_araddr=0;
 reg[7:0] cpu_arlen=0;
 reg[2:0] cpu_arsize=0;
 reg[1:0] cpu_arburst=0;
 reg cpu_arvalid=0;
 wire cpu_arready;
 wire[127:0] cpu_rdata;
 wire[1:0] cpu_rresp;
 wire[5:0] cpu_rid;
 wire cpu_rlast;
 wire cpu_rvalid;
 reg cpu_rready=0;
 reg[5:0] cpu_awid=0;
 reg[31:0] cpu_awaddr=0;
 reg[7:0] cpu_awlen=0;
 reg[2:0] cpu_awsize=0;
 reg[1:0] cpu_awburst=0;
 reg cpu_awvalid=0;
 wire cpu_awready;
 reg[127:0] cpu_wdata=0;
 reg[15:0] cpu_wstrb=0;
 reg cpu_wlast=0;
 reg cpu_wvalid=0;
 wire cpu_wready;
 wire[1:0] cpu_bresp;
 wire[5:0] cpu_bid;
 wire cpu_bvalid;
 reg cpu_bready=0;
 wire[5:0] m_axi_arid;
 wire[31:0] m_axi_araddr;
 wire[7:0] m_axi_arlen;
 wire[2:0] m_axi_arsize;
 wire[1:0] m_axi_arburst;
 wire m_axi_arvalid;
 reg m_axi_arready=0;
 reg[127:0] m_axi_rdata=0;
 reg[1:0] m_axi_rresp=0;
 reg[5:0] m_axi_rid=0;
 reg m_axi_rlast=0;
 reg m_axi_rvalid=0;
 wire m_axi_rready;
 wire[5:0] m_axi_awid;
 wire[31:0] m_axi_awaddr;
 wire[7:0] m_axi_awlen;
 wire[2:0] m_axi_awsize;
 wire[1:0] m_axi_awburst;
 wire m_axi_awvalid;
 reg m_axi_awready=0;
 wire[127:0] m_axi_wdata;
 wire[15:0] m_axi_wstrb;
 wire m_axi_wlast;
 wire m_axi_wvalid;
 reg m_axi_wready=0;
 reg[1:0] m_axi_bresp=0;
 reg[5:0] m_axi_bid=0;
 reg m_axi_bvalid=0;
 wire m_axi_bready;
 wire direct_scan=0;wire[1:0]memory_mode=0;wire[2:0]history_index=0;wire[2:0]history_count;wire[31:0]capture_frame_id;wire scan_source_mode;
 frame_memory_system #(.CPU_ENABLED(1),.MAX_LINE_PIXELS(1920),.SOURCE_BASE(0),.RESULT_BASE(32'h01000000),.BANK_SHIFT(22)) dut(.compute_acquire_valid(1'b0),.compute_latest(1'b0),.compute_release(1'b0),.compute_request_frame_id(32'd0),.compute_acquire_ready(),.compute_missing(),.compute_hold_valid(),.compute_hold_bank(),.compute_hold_frame_id(),.compute_hold_config_id(),.dma_arid(6'd0),.dma_awid(6'd0),.dma_araddr(32'd0),.dma_awaddr(32'd0),.dma_arlen(8'd0),.dma_awlen(8'd0),.dma_arsize(3'd0),.dma_awsize(3'd0),.dma_arburst(2'd0),.dma_awburst(2'd0),.dma_arvalid(1'd0),.dma_awvalid(1'd0),.dma_rready(1'd0),.dma_wdata(128'd0),.dma_wstrb(16'd0),.dma_wlast(1'd0),.dma_wvalid(1'd0),.dma_bready(1'd0),.dma_arready(),.dma_rdata(),.dma_rresp(),.dma_rlast(),.dma_rvalid(),.dma_awready(),.dma_wready(),.dma_bresp(),.dma_bvalid(),.*);
 reg[7:0]mem[0:33554431];
 reg rd_active=0,wr_active=0;integer ra=0,rc=0,wa=0,wc=0,bd=0;
 reg[5:0]rid=0,bid=0;reg inject_r=0,inject_b=0;integer arb_reads=0,arb_writes=0;
 integer k;
 always @*begin m_axi_arready=!rd_active&&!m_axi_rvalid&&cycle%3!=0;
  m_axi_awready=!wr_active&&!m_axi_bvalid&&bd==0&&cycle%7!=0;
  m_axi_wready=wr_active&&cycle%4!=0;
 end
 always @(posedge clk)if(rst_n)begin
  if(m_axi_arvalid&&m_axi_arready)begin
   if(m_axi_araddr[3:0]||m_axi_arburst!=1||m_axi_arsize!=4||m_axi_araddr[11:0]+(m_axi_arlen+1)*16>4096)$fatal(1,"AR boundary");
   rd_active<=1;ra<=m_axi_araddr;rc<=m_axi_arlen+1;rid<=m_axi_arid;arb_reads<=arb_reads+1;
  end
  if(m_axi_rvalid&&m_axi_rready)begin m_axi_rvalid<=0;ra<=ra+16;rc<=rc-1;if(rc==1)rd_active<=0;end
  if(rd_active&&(!m_axi_rvalid||m_axi_rready)&&!(m_axi_rvalid&&rc==1)&&cycle%6!=0)begin
   for(k=0;k<16;k=k+1)m_axi_rdata[8*k+:8]<=mem[ra+(m_axi_rvalid?16:0)+k];
   m_axi_rvalid<=1;m_axi_rlast<=rc==(m_axi_rvalid?2:1);m_axi_rid<=rid;m_axi_rresp<=inject_r&&rid==0?2:0;
  end
  if(m_axi_awvalid&&m_axi_awready)begin
   if(m_axi_awaddr[3:0]||m_axi_awburst!=1||m_axi_awsize!=4||m_axi_awaddr[11:0]+(m_axi_awlen+1)*16>4096)$fatal(1,"AW boundary");
   wr_active<=1;wa<=m_axi_awaddr;wc<=m_axi_awlen+1;bid<=m_axi_awid;arb_writes<=arb_writes+1;
  end
  if(m_axi_wvalid&&m_axi_wready)begin
   if(m_axi_wlast!=(wc==1))$fatal(1,"W interleave/last");
   for(k=0;k<16;k=k+1)if(m_axi_wstrb[k])mem[wa+k]<=m_axi_wdata[8*k+:8];
   wa<=wa+16;wc<=wc-1;if(wc==1)begin wr_active<=0;bd<=8;end
  end
  if(bd>0)begin bd<=bd-1;if(bd==1)begin m_axi_bvalid<=1;m_axi_bid<=bid;m_axi_bresp<=inject_b&&bid==0?2:0;end end
  if(m_axi_bvalid&&m_axi_bready)m_axi_bvalid<=0;
 end
 // A continuously competing background RAW-like client exercises arbitration.
 reg legacy_enable=0;integer legacy_rs=0,legacy_ws=0,legacy_nr=0,legacy_nb=0,legacy_beat=0;
 always @*begin
  legacy_arid=6'd3;legacy_araddr=32'h01900000;legacy_arlen=3;legacy_arsize=4;legacy_arburst=1;
  legacy_arvalid=legacy_enable&&legacy_rs==0;legacy_rready=1;
  legacy_awid=6'd3;legacy_awaddr=32'h01901000;legacy_awlen=3;legacy_awsize=4;legacy_awburst=1;
  legacy_awvalid=legacy_enable&&legacy_ws==0;legacy_wvalid=legacy_ws==1;
  legacy_wdata={4{32'h10325476}};legacy_wstrb=16'hffff;legacy_wlast=legacy_beat==3;legacy_bready=1;
 end
 integer q;
 always @(posedge clk)if(rst_n)begin
  if(legacy_arvalid&&legacy_arready)legacy_rs<=1;
  if(legacy_rvalid&&legacy_rready)begin
   if(legacy_rid!=3||legacy_rresp!=0)$fatal(1,"legacy R routing");
   for(q=0;q<16;q=q+1)if(legacy_rdata[q*8+:8]!==8'h5a)$fatal(1,"legacy R content");
   if(legacy_rlast)begin legacy_rs<=0;legacy_nr<=legacy_nr+1;end
  end
  if(legacy_awvalid&&legacy_awready)begin legacy_ws<=1;legacy_beat<=0;end
  if(legacy_wvalid&&legacy_wready)begin legacy_beat<=legacy_beat+1;if(legacy_wlast)legacy_ws<=2;end
  if(legacy_bvalid&&legacy_bready)begin
   if(legacy_bid!=3||legacy_bresp!=0)$fatal(1,"legacy B routing");
   legacy_ws<=0;legacy_nb<=legacy_nb+1;
  end
 end
 reg cpu_enable=0;integer cpu_rs=0,cpu_ws=0,cpu_nr=0,cpu_nb=0,cpu_beat=0;
 always @*begin
  cpu_arid=6'd13;cpu_araddr=32'h01902000;cpu_arlen=3;cpu_arsize=4;cpu_arburst=1;
  cpu_arvalid=cpu_enable&&cpu_rs==0;cpu_rready=1;
  cpu_awid=6'd13;cpu_awaddr=32'h01903000;cpu_awlen=3;cpu_awsize=4;cpu_awburst=1;
  cpu_awvalid=cpu_enable&&cpu_ws==0;cpu_wvalid=cpu_ws==1;
  cpu_wdata={4{32'h67452301}};cpu_wstrb=16'h000f<<(cpu_beat*4);cpu_wlast=cpu_beat==3;cpu_bready=1;
 end
 integer cq;
 always @(posedge clk)if(rst_n)begin
  if(cpu_arvalid&&cpu_arready)cpu_rs<=1;
  if(cpu_rvalid&&cpu_rready)begin
   if(cpu_rid!=13||cpu_rresp!=0)$fatal(1,"legacy R routing");
   for(cq=0;cq<16;cq=cq+1)if(cpu_rdata[cq*8+:8]!==8'ha5)$fatal(1,"legacy R content");
   if(cpu_rlast)begin cpu_rs<=0;cpu_nr<=cpu_nr+1;end
  end
  if(cpu_awvalid&&cpu_awready)begin cpu_ws<=1;cpu_beat<=0;end
  if(cpu_wvalid&&cpu_wready)begin cpu_beat<=cpu_beat+1;if(cpu_wlast)cpu_ws<=2;end
  if(cpu_bvalid&&cpu_bready)begin
   if(cpu_bid!=13||cpu_bresp!=0)$fatal(1,"legacy B routing");
   cpu_ws<=0;cpu_nb<=cpu_nb+1;
  end
 end
 function automatic[15:0]value(input integer frame,x,y);value=(frame<<12)^(y<<6)^x;endfunction
 task capture(input integer frame,input bit fail);integer x,y,w,h,ss;begin
  w=src_width;h=src_height;ss=src_stride_bytes;
  inject_b=fail;capture_config_id=10+frame;
  @(negedge clk);capture_valid=1;
  do @(posedge clk);while(!capture_ready);
  @(negedge clk);capture_valid=0;
  // Change the shared input during the writer launch; only the request copy counts.
  src_width=40;src_height=9;src_stride_bytes=96;
  @(negedge clk);src_width=w;src_height=h;src_stride_bytes=ss;
  for(y=0;y<h;y=y+1)for(x=0;x<w;x=x+2)begin
   capture_pixel_valid=1;capture_pixel_data={value(frame,x+1,y),value(frame,x,y)};
   capture_pixel_sof=x==0&&y==0;capture_pixel_eol=x==w-2;capture_pixel_eof=x==w-2&&y==h-1;
   do @(posedge clk);while(!capture_pixel_ready);
   @(negedge clk);
  end
  capture_pixel_valid=0;
  wait(capture_done);#1;if(capture_error!==fail)$fatal(1,"capture error publication");
  @(negedge clk);inject_b=0;
 end endtask
 task render(input integer cfg,input bit fail);begin
  job_config_id=cfg;inject_r=fail;
  @(negedge clk);job_valid=1;do @(posedge clk);while(!job_ready);
  @(negedge clk);job_valid=0;wait(render_done);#1;
  if(render_error!==fail||render_pending===fail)$fatal(1,"render publication/error");
  @(negedge clk);inject_r=0;
 end endtask
 integer sx=0,sy=0,scanned=0,expected_frame=1,expected_cfg=100,expected_source=1;
 always @(posedge clk)if(scan_pixel_valid&&scan_pixel_ready)begin
  if(scan_pixel_keep!=3||scan_pixel_frame_id!=expected_frame||scan_pixel_config_id!=expected_cfg)$fatal(1,"scan metadata");
  if(scan_pixel_sof!=(sx==0&&sy==0)||scan_pixel_eol!=(sx==dst_width-2)||scan_pixel_eof!=(sx==dst_width-2&&sy==dst_height-1))$fatal(1,"scan markers");
  if(scan_pixel_data[15:0]!==value(expected_source,roi_x+sx*roi_w/dst_width,roi_y+sy*roi_h/dst_height)||
     scan_pixel_data[31:16]!==value(expected_source,roi_x+(sx+1)*roi_w/dst_width,roi_y+sy*roi_h/dst_height))$fatal(1,"scan pixel x%0d y%0d got%h",sx,sy,scan_pixel_data);
  scanned<=scanned+2;
  if(sx==dst_width-2)begin sx<=0;sy<=sy+1;end else sx<=sx+2;
 end
 task publish_scan;integer before_n;begin
  before_n=scanned;sx=0;sy=0;
  @(negedge clk);vblank=1;@(negedge clk);vblank=0;
  wait(scan_done);#1;
  if(scan_error||scanned-before_n!=dst_width*dst_height)$fatal(1,"scan drain");
  @(negedge clk);
 end endtask
 initial begin
  for(k=32'h01900000;k<32'h01902000;k=k+1)mem[k]=8'h5a;
  for(k=32'h01902000;k<32'h01904000;k=k+1)mem[k]=8'ha5;
  repeat(5)@(negedge clk);rst_n=1;legacy_enable=1;cpu_enable=1;
  capture(1,0);freeze_source=1;render(100,0);fork publish_scan;capture(2,0);join
  expected_cfg=101;roi_x=5;roi_w=11;render(101,0);publish_scan;
  if(display_frame_id!=1)$fatal(1,"frozen source changed");
  freeze_source=0;expected_cfg=102;expected_frame=2;expected_source=2;render(102,0);publish_scan;
  capture(3,1);expected_cfg=103;render(103,0);publish_scan;
  if(display_frame_id!=2)$fatal(1,"failed capture became latest");
  render(104,1);if(display_config_id!=103)$fatal(1,"failed render published");
  // Reject a capture that would cross its leased source bank.
  src_height=65535;src_stride_bytes=32'hffff0000;@(negedge clk);capture_valid=1;
  do @(posedge clk);while(!capture_ready);
  #1;if(!capture_done||!capture_error||dut.engine.control.pool.writer_active_q)$fatal(1,"capture bank boundary");
  @(negedge clk);capture_valid=0;src_height=8;src_stride_bytes=80;
  if($test$plusargs("FULL"))begin
   src_width=1920;src_height=1080;src_stride_bytes=3840;
   roi_x=0;roi_y=0;roi_w=1920;roi_h=1080;dst_width=1920;dst_height=1080;dst_stride_bytes=3840;
   expected_source=4;expected_frame=4;expected_cfg=105;capture(4,0);render(105,0);publish_scan;
   $display("SYSTEM FULL1920x1080 shared-bus render_cycles=%0d deadline_misses=%0d",last_cycles,deadline_misses);
  end
  if(legacy_nr<10||legacy_nb<10||cpu_nr<10||cpu_nb<10)$fatal(1,"background starved");
  for(k=0;k<64;k=k+1)begin
   if(k%16/4==k/16)begin
    if(mem[32'h01903000+k]!==8'(32'h67452301>>(8*(k%4))))$fatal(1,"CPU word strobe lane");
   end else if(mem[32'h01903000+k]!==8'ha5)$fatal(1,"CPU overwrote a masked byte");
  end
  if(dut.engine.control.pool.writer_active_q||dut.engine.control.pool.display_hold_valid_q)$fatal(1,"lease not released");
  $display("PASS tb_frame_memory_system capture/ROI/freeze/scan %0d pixels, read/write error nonpublication, legacy R=%0d B=%0d CPU R=%0d B=%0d shared AXI",scanned,legacy_nr,legacy_nb,cpu_nr,cpu_nb);$finish;
 end
 initial begin #100000000;$fatal(1,"system watchdog");end
endmodule
