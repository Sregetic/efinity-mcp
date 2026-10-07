`timescale 1ns/1ps
// Explicit compute lease -> 32x32 nearest samples -> DDR uint16 gray tensor.
// Each low byte is gray; CPU owns a published buffer until ACK. No full line RAM.
module vision_analysis_dma #(parameter BANK_BITS=3,BANK_SHIFT=22,
 parameter[31:0]SOURCE_BASE=0,INPUT0=32'h07600000,INPUT1=32'h07610000)(
 input clk,rst_n,input[7:0]paddr,input psel,penable,pwrite,input[31:0]pwdata,
 output reg[31:0]prdata,output pready,output pslverror,
 output compute_acquire_valid,compute_latest,compute_release,output[31:0]compute_request_frame_id,
 input compute_acquire_ready,compute_missing,compute_hold_valid,input[BANK_BITS-1:0]compute_hold_bank,
 input[31:0]compute_hold_frame_id,compute_hold_config_id,
 output[3:0]m_axi_arid,output[31:0]m_axi_araddr,output[7:0]m_axi_arlen,
 output[2:0]m_axi_arsize,output[1:0]m_axi_arburst,output m_axi_arvalid,input m_axi_arready,
 input[127:0]m_axi_rdata,input[1:0]m_axi_rresp,input m_axi_rlast,m_axi_rvalid,output m_axi_rready,
 output[3:0]m_axi_awid,output[31:0]m_axi_awaddr,output[7:0]m_axi_awlen,
 output[2:0]m_axi_awsize,output[1:0]m_axi_awburst,output m_axi_awvalid,input m_axi_awready,
 output[127:0]m_axi_wdata,output[15:0]m_axi_wstrb,output m_axi_wlast,m_axi_wvalid,input m_axi_wready,
 input[1:0]m_axi_bresp,input m_axi_bvalid,output m_axi_bready
);
 localparam IDLE=0,ACQUIRE=1,READ_ADDR=2,READ_DATA=3,WRITE_ADDR=4,WRITE_DATA=5,WRITE_RESP=6,PUBLISHED=7;
 reg[2:0]state=IDLE;reg bank=0,latest=1,failed=0,lease=0;
 reg[15:0]cfg_x=640,cfg_y=300,cfg_w=640,cfg_h=480,rx=0,ry=0,rw=0,rh=0;
 reg[31:0]request_frame=0,requested_frame=0,frame=0,source_config_id=0,cycles=0,last_cycles=0,count=0;
 reg[9:0]pixel_index=0;reg[15:0]xp=0,yp=0;reg[63:0]gray_pack=0;reg[7:0]fault=0;
 wire bus_write=psel&&penable&&pwrite;wire start=bus_write&&paddr==0&&pwdata[0],ack=bus_write&&paddr==0&&pwdata[1];
 wire busy=state!=IDLE&&state!=PUBLISHED;
 wire bad_roi=cfg_w==0||cfg_h==0||{1'b0,cfg_x}+{1'b0,cfg_w}>1920||{1'b0,cfg_y}+{1'b0,cfg_h}>1080;
 assign pready=1,pslverror=psel&&penable&&((start&&state!=IDLE)||(ack&&state!=PUBLISHED));
 assign compute_acquire_valid=state==ACQUIRE,compute_latest=latest,compute_request_frame_id=requested_frame;
 assign compute_release=lease&&state==PUBLISHED;
 wire[31:0]input_base=bank?INPUT1:INPUT0;
 always @*begin
  prdata=0;
  case(paddr)
   8'h04:prdata={28'd0,bank,failed,state==PUBLISHED,busy};
   8'h08:prdata=request_frame;8'h0c:prdata=frame;8'h10:prdata=source_config_id;
   8'h14:prdata={cfg_y,cfg_x};8'h18:prdata={cfg_h,cfg_w};8'h1c:prdata=input_base;
   8'h20:prdata=last_cycles;8'h24:prdata={24'd0,fault};8'h28:prdata=count;8'h2c:prdata=3;
   8'h30:prdata={ry,rx};8'h34:prdata={rh,rw};
   default:begin end
  endcase
 end
 wire[15:0]sx=rx+(xp>>5),sy=ry+(yp>>5);
 wire[31:0]read_address=SOURCE_BASE+(32'(compute_hold_bank)<<BANK_SHIFT)+32'(sy)*32'd3840+{15'd0,sx,1'b0};
 wire[15:0]selected_pixel=m_axi_rdata[16*read_address[3:1]+:16];
 wire[23:0]rgb;vision_packed_rgb unpack(.pixel(selected_pixel),.rgb(rgb));
 wire[15:0]luma=77*rgb[23:16]+150*rgb[15:8]+29*rgb[7:0];
 assign m_axi_arid=0,m_axi_araddr={read_address[31:4],4'd0},m_axi_arlen=0,m_axi_arsize=4,m_axi_arburst=1;
 assign m_axi_arvalid=state==READ_ADDR,m_axi_rready=state==READ_DATA;
 assign m_axi_awid=0,m_axi_awaddr=input_base+{21'd0,pixel_index[9:3],4'd0},m_axi_awlen=0,m_axi_awsize=4,m_axi_awburst=1;
 assign m_axi_awvalid=state==WRITE_ADDR,m_axi_wvalid=state==WRITE_DATA,m_axi_wstrb=16'hffff,m_axi_wlast=1,m_axi_bready=state==WRITE_RESP;
 genvar g;generate for(g=0;g<8;g=g+1)begin:gray_lanes
  assign m_axi_wdata[g*16+:16]={8'd0,gray_pack[g*8+:8]};
 end endgenerate
 // One read then one single-beat write per eight samples. Fixed tensor size
 // removes the generic line FIFO/scaler/frame-writer counters and buffers.
 always @(posedge clk)begin
  if(!rst_n)begin state<=IDLE;bank<=0;failed<=0;fault<=0;lease<=0;cfg_x<=640;cfg_y<=300;cfg_w<=640;cfg_h<=480;request_frame<=0;cycles<=0;last_cycles<=0;count<=0;frame<=0;source_config_id<=0;pixel_index<=0;xp<=0;yp<=0;end
  else begin
   if(bus_write)case(paddr)
    8'h08:request_frame<=pwdata;8'h14:begin cfg_x<=pwdata[15:0];cfg_y<=pwdata[31:16];end
    8'h18:begin cfg_w<=pwdata[15:0];cfg_h<=pwdata[31:16];end
    default:begin end
   endcase
   if(busy)cycles<=cycles+1'b1;
   if(compute_release)lease<=0;
   case(state)
    IDLE:if(start&&!pslverror)begin
     rx<=cfg_x;ry<=cfg_y;rw<=cfg_w;rh<=cfg_h;latest<=pwdata[2];requested_frame<=request_frame;
     cycles<=0;failed<=bad_roi;fault<=bad_roi?2:0;
     if(bad_roi)begin state<=PUBLISHED;last_cycles<=0;end else state<=ACQUIRE;
    end
    ACQUIRE:if(compute_missing)begin failed<=1;fault<=1;state<=PUBLISHED;last_cycles<=cycles;end
     else if(compute_acquire_ready)begin
      lease<=1;
      state<=READ_ADDR;pixel_index<=0;xp<=0;yp<=0;
     end
    READ_ADDR:begin
     // The lease metadata is stable from acquisition through the final response.
     frame<=compute_hold_frame_id;source_config_id<=compute_hold_config_id;
     if(m_axi_arready)state<=READ_DATA;
    end
    READ_DATA:if(m_axi_rvalid&&m_axi_rlast)begin
     if(m_axi_rresp!=0)begin failed<=1;fault<=3;last_cycles<=cycles;state<=PUBLISHED;end
     else begin
      gray_pack[pixel_index[2:0]*8+:8]<=luma[15:8];
      if(pixel_index[2:0]==7)state<=WRITE_ADDR;
      else begin pixel_index<=pixel_index+1'b1;xp<=xp+rw;state<=READ_ADDR;end
     end
    end
    WRITE_ADDR:if(m_axi_awready)state<=WRITE_DATA;
    WRITE_DATA:if(m_axi_wready)state<=WRITE_RESP;
    WRITE_RESP:if(m_axi_bvalid)begin
     if(m_axi_bresp!=0||pixel_index==1023)begin
      failed<=m_axi_bresp!=0;fault<=m_axi_bresp!=0?4:0;last_cycles<=cycles;count<=count+1'b1;state<=PUBLISHED;
     end else begin
      pixel_index<=pixel_index+1'b1;
      if(pixel_index[4:0]==31)begin xp<=0;yp<=yp+rh;end else xp<=xp+rw;
      state<=READ_ADDR;
     end
    end
    PUBLISHED:if(ack&&!pslverror)begin state<=IDLE;bank<=!bank;end
    default:begin end
   endcase
  end
 end
endmodule
