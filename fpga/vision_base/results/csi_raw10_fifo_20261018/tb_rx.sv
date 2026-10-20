`timescale 1ns/1ps
module tb_rx;
reg clk=0,byte_clk=0,pixel_clk=0,pixel_enable=1,rst=0;
always #5 clk=~clk;
always #7.143 byte_clk=~byte_clk;
always #6.734 if(pixel_enable)pixel_clk=~pixel_clk;else pixel_clk=0;
reg[3:0]sync_hs=0,valid_hs=0,stop_hs=15;
reg[31:0]data_hs=0;
wire[63:0]pixels[0:1];wire[3:0]ppc[0:1];wire[31:0]debug[0:1];
wire[1:0]valid,hs,vs;wire[5:0]dtype[0:1];wire[15:0]wc[0:1];
`define PORTS(K) .reset_n(rst),.clk(clk),.reset_byte_HS_n(rst),.clk_byte_HS(byte_clk),.reset_pixel_n(rst),.clk_pixel(pixel_clk), \
 .RxUlpsClkNot(1'b1),.RxUlpsActiveClkNot(1'b1),.RxClkEsc(4'b0),.RxErrEsc(4'b0),.RxErrControl(4'b0),.RxErrSotSyncHS(4'b0), \
 .RxUlpsEsc(4'b0),.RxUlpsActiveNot(4'hf),.RxSkewCalHS(4'b0),.RxStopState(stop_hs),.RxSyncHS(sync_hs), \
 .RxDataHS0(data_hs[7:0]),.RxDataHS1(data_hs[15:8]),.RxDataHS2(data_hs[23:16]),.RxDataHS3(data_hs[31:24]), \
 .RxDataHS4(8'b0),.RxDataHS5(8'b0),.RxDataHS6(8'b0),.RxDataHS7(8'b0), \
 .RxValidHS0(valid_hs[0]),.RxValidHS1(valid_hs[1]),.RxValidHS2(valid_hs[2]),.RxValidHS3(valid_hs[3]), \
 .RxValidHS4(1'b0),.RxValidHS5(1'b0),.RxValidHS6(1'b0),.RxValidHS7(1'b0), \
 .axi_clk(clk),.axi_reset_n(rst),.axi_awaddr(6'b0),.axi_awvalid(1'b0),.axi_wdata(32'b0),.axi_wvalid(1'b0),.axi_bready(1'b1), \
 .axi_araddr(6'b0),.axi_arvalid(1'b0),.axi_rready(1'b1),.hsync_vc0(hs[K]),.vsync_vc0(vs[K]), \
 .pixel_data(pixels[K]),.pixel_per_clk(ppc[K]),.pixel_data_valid(valid[K]),.datatype(dtype[K]),.word_count(wc[K]), \
 .mipi_debug_in(32'b0),.mipi_debug_out(debug[K])
csi_base base(`PORTS(0));
csi_new changed(`PORTS(1));
integer expected[0:200000],issued=0,received=0,cycles=0,lines=0;
reg[7:0]packet[0:8191];integer n;
function automatic[7:0]ecc(input[23:0]d);
 begin
  ecc=0;
  ecc[0]=^(d&24'hf12cb7);ecc[1]=^(d&24'hf2555b);ecc[2]=^(d&24'h749a6d);
  ecc[3]=^(d&24'hb8e38e);ecc[4]=^(d&24'hdf03f0);ecc[5]=^(d&24'heffc00);
 end
endfunction
function automatic[15:0]crc_byte(input[15:0]old,input[7:0]b);
 reg[15:0]v;integer i;begin v=old;for(i=0;i<8;i=i+1)v=(v>>1)^((v[0]^b[i])?16'h8408:16'h0);crc_byte=v;end
endfunction
task automatic send_packet;
 integer i;
 begin
  repeat(8)@(negedge byte_clk);
  stop_hs=0;sync_hs=15;valid_hs=0;data_hs=32'hb8b8b8b8;
  @(negedge byte_clk);sync_hs=0;
  for(i=0;i<n;i=i+4)begin
   valid_hs=15;data_hs={packet[i+3],packet[i+2],packet[i+1],packet[i]};@(negedge byte_clk);sync_hs=0;
  end
  valid_hs=0;data_hs=0;repeat(16)@(negedge byte_clk);stop_hs=15;
 end
endtask
task automatic short_packet(input[5:0]dt,input[15:0]v);
 begin packet[0]={2'b0,dt};packet[1]=v[7:0];packet[2]=v[15:8];packet[3]=ecc({v,2'b0,dt});n=4;send_packet();end
endtask
task automatic long_packet(input integer width,row,frame,input bit bad);
 integer x,k,basep,p[0:3];reg[15:0]crc;reg[15:0]bytes;
 begin
  bytes=width*10/8;packet[0]=8'h2b;packet[1]=bytes[7:0];packet[2]=bytes[15:8];packet[3]=ecc({bytes,8'h2b});n=4;
  for(x=0;x<width;x=x+4)begin
   for(k=0;k<4;k=k+1)begin p[k]=((x+k)*7+row*19+frame*131)&1023;expected[issued]=p[k];issued=issued+1;packet[n+k]=p[k]>>2;end
   packet[n+4]={p[3][1:0],p[2][1:0],p[1][1:0],p[0][1:0]};n=n+5;
  end
  crc=16'hffff;for(x=4;x<n;x=x+1)crc=crc_byte(crc,packet[x]);if(bad)crc=crc^1;
  packet[n]=crc[7:0];packet[n+1]=crc[15:8];packet[n+2]=0;packet[n+3]=0;n=n+2;
  while(n%4!=0)begin packet[n]=0;n=n+1;end
  send_packet();lines=lines+1;
 end
endtask
always @(posedge pixel_clk)begin
 #0.01;cycles=cycles+1;
 if(rst)begin
  if(valid[0]!==valid[1]||hs[0]!==hs[1]||vs[0]!==vs[1])$fatal(1,"sync difference cycle%0d",cycles);
  if(valid[0])begin
   if(ppc[0]!==ppc[1]||ppc[0]!=4||pixels[0][39:0]!==pixels[1][39:0])$fatal(1,"RAW10 new/old difference");
   for(integer i=0;i<4;i=i+1)begin
    if(received>=issued||pixels[0][10*i+:10]!==expected[received][9:0])$fatal(1,"pixel%0d actual%0d expected%0d debug%h",received,pixels[0][10*i+:10],expected[received],debug[0]);
    received=received+1;
   end
  end
 end
end
task automatic drain;
 begin
  pixel_enable=1;
  fork
   begin wait(received==issued);repeat(100)@(posedge byte_clk);end
   begin #100000;$fatal(1,"drain timeout issued%0d received%0d debug%h/%h datatype%h wordcount%0d",issued,received,debug[0],debug[1],dtype[0],wc[0]);end
  join_any
  disable fork;
 end
endtask
initial begin
 #100;rst=1;repeat(100)@(negedge byte_clk);
 for(integer frame=0;frame<4;frame=frame+1)begin
  short_packet(0,frame);repeat(100)@(negedge byte_clk);
  for(integer row=0;row<8;row=row+1)begin
   pixel_enable=1;
   long_packet(frame%2==0?1920:2560,row,frame,0);drain();
  end
  short_packet(1,frame);repeat(200)@(negedge byte_clk);
  if((debug[0]&32'h1c)||(debug[1]&32'h1c))$fatal(1,"CRC/ECC failure %h %h",debug[0],debug[1]);
 end
 short_packet(0,4);long_packet(1920,0,4,1);drain();short_packet(1,4);repeat(200)@(negedge byte_clk);
 if(!debug[0][2]||!debug[1][2])$fatal(1,"corrupt CRC not detected %h %h",debug[0],debug[1]);
 $display("PASS RAW10 receiver pixels=%0d lines=%0d cycles=%0d, old/new exact, 1920/2560 widths, paused pixel clock, CRC failure",received,lines,cycles);$finish;
end
initial begin #5000000;$fatal(1,"receiver watchdog");end
endmodule
