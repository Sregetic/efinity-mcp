`timescale 1ns/1ps
module tb_analysis_dma;
 reg clk=0,rst_n=0;always #5 clk=~clk;
 reg[7:0]paddr=0;reg psel=0,penable=0,pwrite=0;reg[31:0]pwdata=0;wire[31:0]prdata;wire pready,pslverror;
 wire compute_acquire_valid,compute_latest,compute_release;wire[31:0]compute_request_frame_id;
 wire compute_missing=compute_request_frame_id==32'hdeadbeef;
 wire compute_acquire_ready=!compute_missing&&!compute_hold_valid;reg compute_hold_valid=0;
 wire[3:0]arid,awid;wire[31:0]araddr,awaddr;wire[7:0]arlen,awlen;wire[2:0]arsize,awsize;wire[1:0]arburst,awburst;
 wire arv,awr,rr,wr,wl,br;reg arvready=0,awrready=0,wready=0;reg[127:0]rdata=0;reg rv=0,rl=1,bv=0;reg[1:0]rresp=0,bresp=0;
 wire[127:0]wdata;wire[15:0]wstrb;wire wv;
 reg inject_read_error=0,inject_write_error=0;integer tick=0,read_delay=-1,write_delay=-1,wleft=0,wi=0,base_word=0,reads=0,writes=0,release_count=0;
 reg[31:0]read_addr=0;reg active_write=0;
 reg[15:0]expected_x=13,expected_y=7,expected_w=37,expected_h=45;
 vision_analysis_dma #(.SOURCE_BASE(32'h00100000)) dut(.clk(clk),.rst_n(rst_n),.paddr(paddr),.psel(psel),.penable(penable),.pwrite(pwrite),.pwdata(pwdata),.prdata(prdata),.pready(pready),.pslverror(pslverror),
 .compute_acquire_valid(compute_acquire_valid),.compute_latest(compute_latest),.compute_release(compute_release),.compute_request_frame_id(compute_request_frame_id),.compute_acquire_ready(compute_acquire_ready),.compute_missing(compute_missing),.compute_hold_valid(compute_hold_valid),.compute_hold_bank(3'd0),.compute_hold_frame_id(32'd119),.compute_hold_config_id(32'd227),
 .m_axi_arid(arid),.m_axi_araddr(araddr),.m_axi_arlen(arlen),.m_axi_arsize(arsize),.m_axi_arburst(arburst),.m_axi_arvalid(arv),.m_axi_arready(arvready),.m_axi_rdata(rdata),.m_axi_rresp(rresp),.m_axi_rlast(rl),.m_axi_rvalid(rv),.m_axi_rready(rr),
 .m_axi_awid(awid),.m_axi_awaddr(awaddr),.m_axi_awlen(awlen),.m_axi_awsize(awsize),.m_axi_awburst(awburst),.m_axi_awvalid(awr),.m_axi_awready(awrready),.m_axi_wdata(wdata),.m_axi_wstrb(wstrb),.m_axi_wlast(wl),.m_axi_wvalid(wv),.m_axi_wready(wready),.m_axi_bresp(bresp),.m_axi_bvalid(bv),.m_axi_bready(br));
 function automatic[15:0]packed_pixel(input integer x,y);begin packed_pixel={(x+y)%2==1,5'(x),5'(y),5'(x+y)};end endfunction
 function automatic integer gray(input integer x,y);integer r,g,b;begin
  r=x%32;g=y%32;b=(x+y)%32;
  if((x+y)%2)begin r=r*8+r/4;g=g*8+g/4;b=b*8+b/4;end else begin r=r*2;g=g*2;b=b*2;end
  gray=(77*r+150*g+29*b)/256;
 end endfunction
 integer i,sx,sy,pix,expected,addr_offset;
 always @(posedge clk)begin
  if(!rst_n)begin tick<=0;compute_hold_valid<=0;end else begin
   tick<=tick+1;
   if(compute_acquire_valid&&compute_acquire_ready)compute_hold_valid<=1;
   if(compute_release)begin compute_hold_valid<=0;release_count<=release_count+1;end
   if(arv&&arvready)begin
    if(!compute_hold_valid||read_delay>=0||rv||arlen!=0||arsize!=4||arburst!=1)$fatal(1,"read protocol or lease");
    read_addr<=araddr;read_delay<=2+tick%7;reads<=reads+1;
   end
   if(read_delay>0)read_delay<=read_delay-1;
   if(read_delay==0)begin
    for(i=0;i<8;i++)begin addr_offset=read_addr-32'h00100000+2*i;rdata[i*16+:16]<=packed_pixel((addr_offset%3840)/2,addr_offset/3840);end
    rv<=1;rresp<=inject_read_error?2:0;read_delay<=-1;
   end
   if(rv&&rr)rv<=0;
   if(awr&&awrready)begin
    if(active_write||awsize!=4||awburst!=1||awlen>3)$fatal(1,"write address protocol");
    active_write<=1;wleft<=awlen+1;wi<=0;base_word<=((awaddr&32'hffff)/16);
   end
   if(wv&&wready)begin
    if(!active_write||wstrb!=16'hffff||wl!=(wleft==1))$fatal(1,"write data protocol");
    if(!inject_read_error&&!inject_write_error)for(i=0;i<8;i++)begin
     pix=(base_word+wi)*8+i;sx=expected_x+(pix%32)*expected_w/32;sy=expected_y+(pix/32)*expected_h/32;expected=gray(sx,sy);
     if(wdata[i*16+:16]!==16'(expected))$fatal(1,"tensor pixel%0d got%0d expected%0d",pix,wdata[i*16+:16],expected);
    end
    writes<=writes+1;wi<=wi+1;wleft<=wleft-1;
    if(wleft==1)begin active_write<=0;write_delay<=4;end
   end
   if(write_delay>0)write_delay<=write_delay-1;
   if(write_delay==0)begin bv<=1;bresp<=inject_write_error?2:0;write_delay<=-1;end
   if(bv&&br)bv<=0;
  end
 end
 always @(negedge clk)begin arvready=tick%5!=1;awrready=tick%7!=2;wready=tick%5!=2;end
 task write_reg(input[7:0]addr,input[31:0]data,input integer expect_error);begin
  @(negedge clk);paddr=addr;pwdata=data;psel=1;penable=1;pwrite=1;#1;if(pslverror!==1'(expect_error))$fatal(1,"APB error contract");
  @(negedge clk);psel=0;penable=0;pwrite=0;
 end endtask
 task wait_done(input integer error_code);integer timeout;begin
  timeout=0;paddr=4;
  while(!prdata[1])begin @(negedge clk);timeout++;if(timeout>200000)$fatal(1,"DMA timeout state%0d pixel%0d lease%0d",dut.state,dut.pixel_index,dut.lease);end
  if(prdata[2]!=(error_code!=0))$fatal(1,"completion error flag");paddr=8'h24;#1;if(prdata!=error_code)$fatal(1,"fault code got%0d expected%0d",prdata,error_code);
  repeat(3)@(negedge clk);if(compute_hold_valid)$fatal(1,"source lease retained after publication");
 end endtask
 initial begin
  repeat(4)@(negedge clk);rst_n=1;
  write_reg(8'h14,{16'd7,16'd13},0);write_reg(8'h18,{16'd45,16'd37},0);write_reg(0,5,0);
  write_reg(0,5,1);write_reg(8'h14,0,0); // Shadow changes do not alter the active ROI.
  wait_done(0);if(reads!=1024||writes!=128)$fatal(1,"tensor extent reads%0d writes%0d",reads,writes);
  paddr=8'h0c;#1;if(prdata!=119)$fatal(1,"source frame tag");paddr=8'h10;#1;if(prdata!=227)$fatal(1,"source config tag");
  paddr=8'h30;#1;if(prdata!={16'd7,16'd13})$fatal(1,"active ROI tag changed by shadow write");
  paddr=8'h34;#1;if(prdata!={16'd45,16'd37})$fatal(1,"active ROI extent tag");
  write_reg(0,2,0);paddr=8'h1c;#1;if(prdata!=32'h07610000)$fatal(1,"double buffer ownership");
  write_reg(8'h14,{16'd7,16'd13},0);inject_read_error=1;write_reg(0,5,0);wait_done(3);inject_read_error=0;write_reg(0,2,0);
  inject_write_error=1;write_reg(0,5,0);wait_done(4);inject_write_error=0;write_reg(0,2,0);
  write_reg(8'h08,32'hdeadbeef,0);write_reg(0,1,0);wait_done(1);write_reg(0,2,0);
  write_reg(8'h18,0,0);write_reg(0,5,0);wait_done(2);write_reg(0,2,0);
  write_reg(8'h18,{16'd45,16'd37},0);write_reg(8'h08,119,0);
  write_reg(0,13,0);paddr=4;
  wait(prdata[1]);repeat(100)@(negedge clk);
  if(!compute_hold_valid||!dut.lease||arv||awr)$fatal(1,"RGB lease must hold without tensor DMA");
  paddr=8'h38;#1;if(prdata!=32'h00100000)$fatal(1,"RGB source base");
  paddr=8'h0c;#1;if(prdata!=119)$fatal(1,"RGB source frame");
  write_reg(0,2,0);repeat(2)@(negedge clk);if(compute_hold_valid)$fatal(1,"RGB ACK failed to release");
  $display("PASS tb_analysis_dma:1024 nearest gray pixels, nonaligned ROI, tags, backpressure, double buffer, busy rejection, stale/invalid/read/write faults and lease release");$finish;
 end
 initial begin #5000000;$fatal(1,"global timeout");end
endmodule
