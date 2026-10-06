// DDR result stream -> fixed HDMI raster. Four header words carry immutable
// frame/config/size/placement before 2PPC packed16 RGB pixels. A late/starved frame is
// explicitly counted and drained to EOF, never continued at a shifted position.
module vision_rgb_scanout #(parameter FIFO_AW=10)(
 input rst_n,clk,input enable,have_result,
 input pixel_valid,output pixel_ready,input[31:0]pixel_data,
 input pixel_eol,pixel_eof,input[31:0]pixel_frame_id,pixel_config_id,
 input[15:0]width,height,pos_x,pos_y,input scan_done,scan_error,
 output vblank,scan_enable,read_urgent,
 input video_clk,vs,hs,de,input[23:0]rgb,
 output[23:0]view_rgb,output view_vs,view_hs,view_de,
 output reg view_enabled,frame_ok,config_changed,
 output reg[31:0]view_frame_id,view_config_id,bad_frames
);
 reg[2:0]header=0;reg final_error=0;wire sv,sr,mv,mr;reg[34:0]sd;wire[34:0]md;
 wire[2:0]kind=md[34:32];wire metadata=kind>=3&&kind<=6;
 always @*case(header)
  0:sd={3'd3,pixel_frame_id};1:sd={3'd4,pixel_config_id};
  2:sd={3'd5,width,height};3:sd={3'd6,pos_x,pos_y};
  6:sd={3'd7,31'd0,final_error};
  default:sd={(pixel_eof?3'd2:(pixel_eol?3'd1:3'd0)),pixel_data};
 endcase
 assign sv=header==6||(header<=4&&pixel_valid),pixel_ready=header==4&&sr;
 always @(posedge clk)begin
  if(!rst_n)begin header<=0;final_error<=0;end
  else begin
   if(sv&&sr)begin
    if(header==6)header<=0;else if(header!=4)header<=header+1'b1;else if(pixel_eof)header<=5;
   end
   // The reader reports its final line response after the EOF handshake.
   if(header==5&&scan_done)begin final_error<=scan_error;header<=6;end
  end
 end
 wire[FIFO_AW:0]fifo_level;
 stream_cdc #(.WIDTH(35),.AW(FIFO_AW)) fifo(rst_n,clk,sv,sr,sd,video_clk,mv,mr,md,fifo_level,);
 assign read_urgent=fifo_level<(1<<(FIFO_AW-1));
 reg blank_toggle=0;reg[2:0]bs=0;reg bseen=0;reg[1:0]view_sync=0;
 always @(posedge clk)begin
  bs<={bs[1:0],blank_toggle};bseen<=bs[2];view_sync<={view_sync[0],view_enabled};
  if(!rst_n)begin bs<=0;bseen<=0;view_sync<=0;end
 end
 assign vblank=bs[2]!=bseen;
 // A disable command may cross just after VS. Continue scanning until the
 // frame-latched video selector has also left ROI, so that field stays whole.
 assign scan_enable=enable||view_sync[1];
 reg[2:0]es=0,rs=0;reg vq=0,dq=0,transport_done=1,meta_valid=0,started=0,failed=0,draining=0,phase=0;
 reg[11:0]x=0,y=0;reg[15:0]w=0,h=0,dx=0,dy=0,upper=0;reg[2:0]upper_kind=0;
 reg[31:0]fid=0,cid=0;
 reg[23:0]out_rgb=0;reg out_vs=0,out_hs=0,out_de=0;
 wire in_box=de&&meta_valid&&x>=dx&&{4'b0,x}<dx+w&&y>=dy&&{4'b0,y}<dy+h;
 wire first_position=x==dx&&y==dy;
 wire consume=in_box&&!failed&&!phase&&(started||first_position);
 assign mr=metadata||kind==7||draining||consume;
 wire[15:0]p=phase?upper:md[15:0];
 // Match capture's shared range and equal RGB channel precision.
 wire[23:0]expanded=p[15]?{p[14:10],p[14:12],p[9:5],p[9:7],p[4:0],p[4:2]}:
  {2'b0,p[14:10],1'b0,2'b0,p[9:5],1'b0,2'b0,p[4:0],1'b0};
 assign view_rgb=view_enabled?out_rgb:rgb;
 assign view_vs=view_enabled?out_vs:vs,view_hs=view_enabled?out_hs:hs,view_de=view_enabled?out_de:de;
 task fail_frame;begin
  if(!failed)bad_frames<=bad_frames+1'b1;
  failed<=1;frame_ok<=0;draining<=1;phase<=0;
 end endtask
 always @(posedge video_clk)begin
  es<={es[1:0],enable};rs<={rs[1:0],have_result};vq<=vs;dq<=de;
  out_vs<=vs;out_hs<=hs;out_de<=de;out_rgb<=0;
  config_changed<=0;
  if(!rst_n)begin
   es<=0;rs<=0;vq<=0;dq<=0;blank_toggle<=0;view_enabled<=0;
   transport_done<=1;meta_valid<=0;started<=0;failed<=0;draining<=0;phase<=0;
   x<=0;y<=0;w<=0;h<=0;dx<=0;dy<=0;fid<=0;cid<=0;upper<=0;upper_kind<=0;
   out_rgb<=0;out_vs<=0;out_hs<=0;out_de<=0;view_frame_id<=0;view_config_id<=0;frame_ok<=0;bad_frames<=0;config_changed<=0;
  end else begin
   if(vs&&!vq)begin
    x<=0;y<=0;phase<=0;started<=0;failed<=0;frame_ok<=0;view_enabled<=es[2];
    if(view_enabled!=es[2])config_changed<=1;
    if(transport_done)blank_toggle<=~blank_toggle;
    else if(!draining)fail_frame();
   end else begin
    if(de)x<=x+1'b1;else x<=0;
    if(dq&&!de)y<=y+1'b1;
   end
   if(mv&&metadata)case(kind)
    3:fid<=md[31:0];4:cid<=md[31:0];5:begin w<=md[31:16];h<=md[15:0];end
    6:begin dx<=md[31:16];dy<=md[15:0];meta_valid<=1;transport_done<=0;
     if(cid!=view_config_id)config_changed<=1;
     view_frame_id<=fid;view_config_id<=cid;
    end
   endcase
   if(mv&&kind==7)begin
    draining<=0;transport_done<=1;meta_valid<=0;
    if(md[0])begin frame_ok<=0;if(!failed)bad_frames<=bad_frames+1'b1;end
   end
   if(de&&x==0&&y==0&&view_enabled&&rs[2]&&!meta_valid&&!draining)fail_frame();
   if(in_box&&!failed&&!draining)begin
    if(!started&&!first_position)fail_frame();
    else if(phase)begin
     out_rgb<=expanded;phase<=0;
     if(upper_kind==2)meta_valid<=0;
    end else if(mv&&kind<=2)begin
     out_rgb<=expanded;upper<=md[31:16];upper_kind<=kind;phase<=1;
     if(!started)begin started<=1;frame_ok<=1;end
    end else fail_frame();
   end
  end
 end
endmodule
