module vision_display #(parameter EDGE_STRENGTH=1,FUSION=0,LOCAL_MOTION_ENABLE=0,WIDTH=1920,HEIGHT=1080,EXTERNAL_GEOMETRY=0)(input clk,rst_n,de,hs,vs,input[7:0]r,g,b,input[2:0]mode,input[10:0]threshold,input median_en,
 input[1:0]memory_mode,input[2:0]history_index,
 input canny_pixel,input canny_ready,output[11:0]cx,cy,
 output reg ode,ohs,ovs,output reg[7:0]orr,ogg,obb,
 output[10:0]debug_mag,output debug_edge,
 input shape_enable,output[63:0]shape_status,output coordinate_de,input[10:0]canny_effective_threshold,canny_requested_threshold,input[7:0]canny_coverage,
 input analysis_enabled,analysis_context_changed,input[31:0]frame_id,render_config_id,analysis_context,
 input[351:0]analysis_result,input analysis_match,analysis_identity_match,input[15:0]analysis_age,
 output reg geometry_done,output reg[31:0]geometry_frame,geometry_config,geometry_context,input[23:0]ui_state,
 input motion_enable,output[2:0]motion_direction,output motion_held,
 input geometry_rst_n,geometry_source_valid,geometry_changed,canny_capture_start,input[31:0]canny_completed,geometry_source_errors,
 input geometry_cpu_clk,geometry_cpu_rst_n,input[7:0]geometry_paddr,input geometry_psel,geometry_penable,geometry_pwrite,input[31:0]geometry_pwdata,
 output[31:0]geometry_prdata,output geometry_pready,geometry_bitmap_hold,geometry_raw_read,
 input geometry_enable,output geometry_result_current,input[2:0]geometry_selection,input geometry_selection_bank);
wire fd0,fh0,fv0,border0;wire[11:0]x0,y0;wire[7:0]fr0,fg0,fb0,gray0;wire[10:0]mag0;wire[1:0]dir;
wire edge0;reg edge1=0;
wire track_activity;wire[3:0]track_motion;wire[23:0]track_motion_xy,track_motion_br;
vision_frontend #(.WIDTH(WIDTH)) front(clk,rst_n,de,hs,vs,r,g,b,median_en,fd0,fh0,fv0,border0,x0,y0,fr0,fg0,fb0,gray0,mag0,dir,threshold,edge0);
generate if(LOCAL_MOTION_ENABLE)begin:motion
 wire[31:0]observation,status,horizontal,vertical;wire[15:0]sites;
 reg[31:0]motion_config=0;
 always @(posedge clk)if(fv0)motion_config<=render_config_id;
 wire live_reset=rst_n&&(motion_enable||track_activity)&&memory_mode==0&&motion_config==render_config_id&&!analysis_context_changed&&!geometry_changed;reg vq=0;
 wire[11:0]mx0,my0,mx1,my1;
 always @(posedge clk)vq<=live_reset?fv0:1'b0;
 // Observe pre-edge grayscale only; never gate video, DDR or ROI tasks.
 vision_local_motion_tap #(.WIDTH(WIDTH),.HEIGHT(HEIGHT)) tap(
  .clk(clk),.rst_n(live_reset),.de(fd0),.vs(fv0),.x(x0),.y(y0),.gray(gray0),.config_bit(median_en),
  .observation_id(observation),.status(status),.horizontal_response(horizontal),.vertical_response(vertical),
  .active_sites(sites),.roi_x0(mx0),.roi_y0(my0),.roi_x1(mx1),.roi_y1(my1),.dropped_frames());
 assign track_motion={live_reset&&status[2:0]==7&&!status[6]&&sites!=0,status[5:3]};
 assign track_motion_xy={my0,mx0},track_motion_br={my1,mx1};
 vision_motion_readout readout(.clk(clk),.rst_n(live_reset),.frame_tick(fv0&&!vq),
  .status(status),.observation(observation),.horizontal(horizontal),.vertical(vertical),.active_sites(sites),
  .show_direction(motion_direction),.held(motion_held));
end else begin:no_motion
 assign motion_direction=0,motion_held=0;
 assign track_motion=0,track_motion_xy=0,track_motion_br=0;
end endgenerate
reg fd=0,fh=0,fv=0,border=1;reg[11:0]x=0,y=0;reg[7:0]fr=0,fg=0,fb=0,gray=0;reg[10:0]mag=0;
always @(posedge clk)begin {fd,fh,fv,border,x,y,fr,fg,fb,gray,mag}<={fd0,fh0,fv0,(border0||x0<4||y0<4),x0,y0,fr0,fg0,fb0,gray0,mag0};end
always @(posedge clk)edge1<=edge0;
wire edge_on=!border && edge1;wire osd,ink;
reg[31:0]capture_frame=0,capture_config=0,capture_context=0;
wire use_m7=EXTERNAL_GEOMETRY&&geometry_enable&&shape_enable;
wire geo_current,geo_published,geo_primary_we,geo_meta_we,geo_mark;wire[2:0]geo_count;wire[1:0]geo_meta_index;
wire[15:0]geo_counts;wire[6:0]geo_symbol;wire[37:0]geo_primary_data;wire[31:0]geo_meta_data;wire[23:0]geo_color;
wire[11:0]geo_right={1'b0,geo_primary_data[17:9],2'b0}+12'd5,geo_bottom={1'b0,geo_primary_data[8:0],2'b0}+12'd5;
generate if(EXTERNAL_GEOMETRY)begin:m7_geometry
 vision_geometry_m7 detector(.clk(clk),.rst_n(geometry_rst_n),.de(fd),.vs(fv),.x(x),.y(y),.enabled(use_m7),
  .frozen(memory_mode!=0),.source_valid(geometry_source_valid),.invalidated(analysis_context_changed||geometry_changed),
  .capture_start(canny_capture_start),.canny_ready(canny_ready),.capture_frame(capture_frame),.view_frame(frame_id),.view_config(render_config_id),.view_context(analysis_context),
  .canny_completed(canny_completed),.source_errors(geometry_source_errors),.result_frame(geometry_frame),
  .bitmap_hold(geometry_bitmap_hold),.raw_bitmap_enable(geometry_raw_read),
  .cpu_clk(geometry_cpu_clk),.cpu_rst_n(geometry_cpu_rst_n),.paddr(geometry_paddr),.psel(geometry_psel),.penable(geometry_penable),.pwrite(geometry_pwrite),.pwdata(geometry_pwdata),
  .prdata(geometry_prdata),.pready(geometry_pready),.current(geo_current),.count(geo_count),.published(geo_published),
  .primary_we(geo_primary_we),.primary_data(geo_primary_data),.meta_we(geo_meta_we),.meta_index(geo_meta_index),.meta_data(geo_meta_data),
  .mark(geo_mark),.color(geo_color),.counts(geo_counts),.symbol(geo_symbol),.edge_threshold(canny_requested_threshold),.selection(geometry_selection),.selection_bank(geometry_selection_bank),
  .motion_hint(track_motion),.motion_xy(track_motion_xy),.motion_br(track_motion_br),.tracking(track_activity));
end else begin:no_m7_geometry
 assign geometry_bitmap_hold=0,geometry_raw_read=0,geometry_prdata=0,geometry_pready=1;
 assign track_activity=0;
 assign geo_symbol=0,geo_counts=0,geo_current=0,geo_count=0,geo_published=0,geo_primary_we=0,geo_primary_data=0,geo_meta_we=0,geo_meta_index=0,geo_meta_data=0,geo_mark=0,geo_color=0;
end endgenerate
reg[1:0]shape_class=0;reg shape_valid=0;reg[11:0]sx0=0,sy0=0,sx1=0,sy1=0;
wire shape_show=use_m7;
assign geometry_result_current=geo_current;
assign shape_status={use_m7,shape_valid,shape_class,12'd0,sx0,sy0,sx1,sy1};
always @(posedge clk)begin
 geometry_done<=use_m7?geo_published:(fd&&x==0&&y==0);
 if(use_m7&&canny_capture_start)begin capture_frame<=frame_id;capture_config<=render_config_id;capture_context<=analysis_context;end
 if(use_m7)begin
  if(geo_meta_we)case(geo_meta_index)0:geometry_frame<=geo_meta_data;1:geometry_config<=geo_meta_data;2:geometry_context<=geo_meta_data;endcase
  if(geo_primary_we)begin
   shape_class<=geo_primary_data[37:36]==0?2'd3:geo_primary_data[37:36];
   sx0<={1'b0,geo_primary_data[35:27],2'b10};sy0<={1'b0,geo_primary_data[26:18],2'b10};
   sx1<=geo_right>=WIDTH?12'(WIDTH-1):geo_right;sy1<=geo_bottom>=HEIGHT?12'(HEIGHT-1):geo_bottom;
  end
  if(geo_published)shape_valid<=geo_count!=0;
 end else begin
  // Fixed-ROI AI needs a fresh source identity, never an implicit target detector.
  shape_valid<=0;shape_class<=0;sx0<=0;sy0<=0;sx1<=0;sy1<=0;
  if(fd&&x==0&&y==0)begin geometry_frame<=frame_id;geometry_config<=render_config_id;geometry_context<=analysis_context;end
 end
 if(analysis_context_changed)shape_valid<=0;
 if(!rst_n)begin geometry_done<=0;capture_frame<=0;capture_config<=0;capture_context<=0;geometry_frame<=0;geometry_config<=0;geometry_context<=0;shape_valid<=0;shape_class<=0;end
end
wire shape_current=use_m7&&geo_current&&geo_count!=0;
vision_osd #(.M7_FACE(EXTERNAL_GEOMETRY)) osd0(x,y,mode,(mode==5||mode==6)?canny_effective_threshold:threshold,median_en,memory_mode,history_index,canny_ready,shape_class,shape_current,shape_show,osd,ink,canny_requested_threshold,
 (FUSION&&analysis_enabled),analysis_result,analysis_identity_match,analysis_age,clk,ui_state,geo_counts,geo_symbol,28'd0);
// RGB/gradient metadata represents the center after two 3x3 windows.
assign cx=x0>=2?x0-2:0;assign cy=y0>=2?y0-2:0;
assign coordinate_de=fd0&&x0>=2&&y0>=2;reg[10:0]dm=0;reg dedge=0;assign debug_mag=dm;assign debug_edge=dedge;
reg[23:0]pixel;reg blend;
// Keep weak accepted edges visible; the detection threshold and mask are unchanged.
wire[7:0]sobel_level=edge_on?(EDGE_STRENGTH?(mag>255?8'd255:{1'b1,mag[7:1]}):8'd255):8'd0;
wire[7:0]canny_level=canny_ready?(EDGE_STRENGTH?canny_coverage:{8{canny_pixel}}):8'd0;
wire[8:0]coverage_rounded={1'b0,canny_level}+9'd4;
wire[5:0]coverage_alpha=coverage_rounded[8:3];
function automatic[7:0]blend_edge(input[7:0]background,foreground,input[5:0]alpha);
 reg[13:0]sum;begin
  sum=background*(6'd32-alpha)+foreground*alpha+14'd16;blend_edge=sum[12:5];
 end
endfunction
always @*begin
 blend=0;
 case(mode)
 0:pixel={fr,fg,fb};
 1:pixel={gray,gray,gray};
 2:pixel={sobel_level,sobel_level,sobel_level};
 3:pixel=(x<960)?{gray,gray,gray}:{sobel_level,sobel_level,sobel_level};
 4:pixel=edge_on?24'hff3030:{fr,fg,fb};
 5:pixel={canny_level,canny_level,canny_level};
 6:begin pixel={fr,fg,fb};blend=1;end
 default:pixel={fr,fg,fb};
 endcase
 if(border)begin pixel=0;blend=0;end
 if(mode==3&&x>=958&&x<=961)pixel=24'h00ff80;
 if(use_m7&&geo_mark)begin pixel=geo_color;blend=0;end
 if(FUSION&&analysis_enabled&&analysis_match&&analysis_result[0]&&
 ((x>=analysis_result[203:192]&&x<=analysis_result[235:224]&&(y==analysis_result[219:208]||y==analysis_result[251:240]))||
  (y>=analysis_result[219:208]&&y<=analysis_result[251:240]&&(x==analysis_result[203:192]||x==analysis_result[235:224]))))begin pixel=24'h00ffff;blend=0;end
end
reg[23:0]pixel_q=0;reg fd_q=0,fh_q=0,fv_q=0,edge_q=0;reg[10:0]mag_q=0;
reg[5:0]alpha_q=0;reg blend_q=0;
// Use the existing pixel register to separate contour arithmetic from blending.
wire[23:0]canny_overlay={blend_edge(pixel_q[23:16],8'd255,alpha_q),
 blend_edge(pixel_q[15:8],8'd48,alpha_q),blend_edge(pixel_q[7:0],8'd48,alpha_q)};
wire[23:0]shown_pixel=blend_q?canny_overlay:pixel_q;
always @(posedge clk)begin
 {fd_q,fh_q,fv_q,mag_q,edge_q,pixel_q}<={fd,fh,fv,mag,edge_on,pixel};
 {alpha_q,blend_q}<={coverage_alpha,blend};
 ode<=fd_q;ohs<=fh_q;ovs<=fv_q;dm<=mag_q;dedge<=edge_q;
 {orr,ogg,obb}<=fd_q?(osd?(ink?24'hffff80:24'h101010):shown_pixel):24'd0;
 if(!rst_n)begin fd_q<=0;fh_q<=0;fv_q<=0;ode<=0;ohs<=0;ovs<=0;{orr,ogg,obb}<=0;end
end
endmodule
