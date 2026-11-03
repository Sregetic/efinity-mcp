module vision_display #(parameter EDGE_STRENGTH=1,FUSION=0,LOCAL_MOTION_ENABLE=0,WIDTH=1920,HEIGHT=1080)(input clk,rst_n,de,hs,vs,input[7:0]r,g,b,input[2:0]mode,input[10:0]threshold,input median_en,
 input[1:0]memory_mode,input[2:0]history_index,
 input canny_pixel,input canny_ready,output[11:0]cx,cy,
 output reg ode,ohs,ovs,output reg[7:0]orr,ogg,obb,
 output[10:0]debug_mag,output debug_edge,
 input shape_enable,input[7:0]shape_threshold,output[63:0]shape_status,output coordinate_de,input[10:0]canny_effective_threshold,canny_requested_threshold,input[7:0]canny_coverage,
 input analysis_enabled,analysis_context_changed,input[31:0]frame_id,render_config_id,analysis_context,
 input[351:0]analysis_result,input analysis_match,analysis_identity_match,input[15:0]analysis_age,
 output reg geometry_done,output reg[31:0]geometry_frame,geometry_config,geometry_context,input[23:0]ui_state,
 input motion_enable,output[2:0]motion_direction,output motion_held);
wire fd0,fh0,fv0,border0;wire[11:0]x0,y0;wire[7:0]fr0,fg0,fb0,gray0;wire[10:0]mag0;wire[1:0]dir;
wire edge0;reg edge1=0;
vision_frontend #(.WIDTH(WIDTH)) front(clk,rst_n,de,hs,vs,r,g,b,median_en,fd0,fh0,fv0,border0,x0,y0,fr0,fg0,fb0,gray0,mag0,dir,threshold,edge0);
generate if(LOCAL_MOTION_ENABLE)begin:motion
 wire[31:0]observation,status,horizontal,vertical;wire[15:0]sites;
 wire live_reset=rst_n&&motion_enable&&memory_mode==0;reg vq=0;
 always @(posedge clk)vq<=live_reset?fv0:1'b0;
 // Observe pre-edge grayscale only; never gate video, DDR or ROI tasks.
 vision_local_motion_tap #(.WIDTH(WIDTH),.HEIGHT(HEIGHT)) tap(
  .clk(clk),.rst_n(live_reset),.de(fd0),.vs(fv0),.x(x0),.y(y0),.gray(gray0),.config_bit(median_en),
  .observation_id(observation),.status(status),.horizontal_response(horizontal),.vertical_response(vertical),
  .active_sites(sites),.roi_x0(),.roi_y0(),.roi_x1(),.roi_y1(),.dropped_frames());
 vision_motion_readout readout(.clk(clk),.rst_n(live_reset),.frame_tick(fv0&&!vq),
  .status(status),.observation(observation),.horizontal(horizontal),.vertical(vertical),.active_sites(sites),
  .show_direction(motion_direction),.held(motion_held));
end else begin:no_motion
 assign motion_direction=0,motion_held=0;
end endgenerate
reg fd=0,fh=0,fv=0,border=1;reg[11:0]x=0,y=0;reg[7:0]fr=0,fg=0,fb=0,gray=0;reg[10:0]mag=0;
always @(posedge clk)begin {fd,fh,fv,border,x,y,fr,fg,fb,gray,mag}<={fd0,fh0,fv0,(border0||x0<4||y0<4),x0,y0,fr0,fg0,fb0,gray0,mag0};end
always @(posedge clk)edge1<=edge0;
wire edge_on=!border && edge1;wire osd,ink;
wire shape_done;reg[31:0]capture_frame=0,capture_config=0,capture_context=0;
wire[1:0]shape_class;wire shape_valid;wire[11:0]sx0,sy0,sx1,sy1;wire[7:0]shape_bg;wire[3:0]shape_flags;
wire shape_show=shape_enable&&mode>=2;
wire detection_edge=(mode==5||mode==6)?(canny_pixel&&canny_ready):edge_on;
// Edge modes recognize the displayed edge mask, not the RGB image behind it.
wire[7:0]shape_gray=(FUSION&&analysis_enabled)?gray:(mode>=2&&mode<=6)?{8{detection_edge}}:gray;
vision_shape_classifier #(.X0(4),.Y0(4),.X1(WIDTH),.Y1(HEIGHT)) shape0(.clk(clk),.rst_n(rst_n&&!(FUSION&&analysis_context_changed)),.de(fd),.vs(fv),.x(x),.y(y),.gray(shape_gray),.diff_threshold(shape_threshold),
 .shape_class(shape_class),.shape_valid(shape_valid),.box_x0(sx0),.box_y0(sy0),.box_x1(sx1),.box_y1(sy1),.background(shape_bg),.reject_flags(shape_flags),.result_done(shape_done));
assign shape_status={shape_enable,shape_valid,shape_class,shape_bg,shape_flags,sx0,sy0,sx1,sy1};
always @(posedge clk)begin
 geometry_done<=shape_done;
 if(!rst_n)begin geometry_done<=0;capture_frame<=0;capture_config<=0;capture_context<=0;geometry_frame<=0;geometry_config<=0;geometry_context<=0;end
 else begin
  if(fd&&x==0&&y==0)begin capture_frame<=frame_id;capture_config<=render_config_id;capture_context<=analysis_context;end
  if(shape_done)begin geometry_frame<=capture_frame;geometry_config<=capture_config;geometry_context<=capture_context;end
 end
end
wire shape_current=shape_valid&&(!(FUSION&&analysis_enabled)||
 (geometry_frame==frame_id&&geometry_config==render_config_id&&geometry_context==analysis_context));
wire shape_box=shape_current&&((x>=sx0&&x<=sx1&&(y==sy0||y==sy1))||(y>=sy0&&y<=sy1&&(x==sx0||x==sx1)));
vision_osd osd0(x,y,mode,mode==7?{3'b0,shape_threshold}:(mode==5||mode==6)?canny_effective_threshold:threshold,median_en,memory_mode,history_index,canny_ready,shape_class,shape_current,shape_show,osd,ink,canny_requested_threshold,
 (FUSION&&analysis_enabled),analysis_result,analysis_identity_match,analysis_age,clk,ui_state);
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
 default:pixel=shape_enable?(shape_box?((shape_class==1)?24'h20ff40:(shape_class==2)?24'h3090ff:24'hffe020):{fr,fg,fb}):((x<960)?{fr,fg,fb}:{gray,gray,gray});
 endcase
 if(border)begin pixel=0;blend=0;end
 if(mode==3&&x>=958&&x<=961)pixel=24'h00ff80;
 if(shape_show&&shape_box)begin pixel=(shape_class==1)?24'h20ff40:(shape_class==2)?24'h3090ff:24'hffe020;blend=0;end
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
