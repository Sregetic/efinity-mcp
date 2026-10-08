module vision_display #(parameter EDGE_STRENGTH=1,FUSION=0)(input clk,rst_n,de,hs,vs,input[7:0]r,g,b,input[2:0]mode,input[10:0]threshold,input median_en,
 input[1:0]memory_mode,input[2:0]history_index,
 input canny_pixel,input canny_ready,output[11:0]cx,cy,
 output reg ode,ohs,ovs,output reg[7:0]orr,ogg,obb,
 output[10:0]debug_mag,output debug_edge,
 input shape_enable,input[7:0]shape_threshold,output[63:0]shape_status,output coordinate_de,input[10:0]canny_effective_threshold,canny_requested_threshold,input[7:0]canny_coverage,
 input analysis_enabled,analysis_context_changed,input[31:0]frame_id,render_config_id,analysis_context,
 input[287:0]analysis_result,input analysis_match,input[15:0]analysis_age,
 output reg geometry_done,output reg[31:0]geometry_frame,geometry_config,geometry_context);
wire fd0,fh0,fv0,border0;wire[11:0]x0,y0;wire[7:0]fr0,fg0,fb0,gray0;wire[10:0]mag0;wire[1:0]dir;
wire edge0;reg edge1=0;
vision_frontend front(clk,rst_n,de,hs,vs,r,g,b,median_en,fd0,fh0,fv0,border0,x0,y0,fr0,fg0,fb0,gray0,mag0,dir,threshold,edge0);
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
vision_shape_classifier shape0(.clk(clk),.rst_n(rst_n&&!(FUSION&&analysis_context_changed)),.de(fd),.vs(fv),.x(x),.y(y),.gray(shape_gray),.diff_threshold(shape_threshold),
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
wire shape_guide=((x==640||x==1279)&&(y>=300&&y<780)&&y[3])||((y==300||y==779)&&(x>=640&&x<1280)&&x[3]);
vision_osd osd0(x,y,mode,(mode==5||mode==6)?canny_effective_threshold:threshold,median_en,memory_mode,history_index,canny_ready,shape_class,shape_current,shape_show,osd,ink,canny_requested_threshold,
 (FUSION&&analysis_enabled),analysis_result,analysis_match,analysis_age,clk);
// RGB/gradient metadata represents the center after two 3x3 windows.
assign cx=x0>=2?x0-2:0;assign cy=y0>=2?y0-2:0;
assign coordinate_de=fd0&&x0>=2&&y0>=2;reg[10:0]dm=0;reg dedge=0;assign debug_mag=dm;assign debug_edge=dedge;
reg[23:0]pixel;
// Continuous reference-style strength uses the existing full-resolution
// gradient. Threshold still gates it; classification stays a binary mask.
wire[7:0]sobel_level=edge_on?(EDGE_STRENGTH?(mag>510?8'd255:mag[8:1]):8'd255):8'd0;
wire[7:0]canny_level=canny_ready?(EDGE_STRENGTH?canny_coverage:{8{canny_pixel}}):8'd0;
wire[23:0]canny_overlay=canny_level==255?24'hff3030:
 canny_level==64?{(fr-(fr>>2)+8'd63),(fg-(fg>>2)+8'd12),(fb-(fb>>2)+8'd12)}:{fr,fg,fb};
always @*begin
 case(mode)
 0:pixel={fr,fg,fb};
 1:pixel={gray,gray,gray};
 2:pixel={sobel_level,sobel_level,sobel_level};
 3:pixel=(x<960)?{gray,gray,gray}:{sobel_level,sobel_level,sobel_level};
 4:pixel=edge_on?24'hff3030:{fr,fg,fb};
 5:pixel={canny_level,canny_level,canny_level};
 6:pixel=canny_overlay;
 default:pixel=shape_enable?(shape_box?((shape_class==1)?24'h20ff40:(shape_class==2)?24'h3090ff:24'hffe020):(shape_guide?24'h808080:{fr,fg,fb})):((x<960)?{fr,fg,fb}:{gray,gray,gray});
 endcase
 if(border)pixel=0;
 if(mode==3&&x>=958&&x<=961)pixel=24'h00ff80;
 if(shape_show&&shape_box)pixel=(shape_class==1)?24'h20ff40:(shape_class==2)?24'h3090ff:24'hffe020;
 if(FUSION&&analysis_enabled&&analysis_match&&analysis_result[0]&&
 ((x>=analysis_result[203:192]&&x<=analysis_result[235:224]&&(y==analysis_result[219:208]||y==analysis_result[251:240]))||
  (y>=analysis_result[219:208]&&y<=analysis_result[251:240]&&(x==analysis_result[203:192]||x==analysis_result[235:224]))))pixel=24'h00ffff;
end
reg[23:0]pixel_q=0;reg fd_q=0,fh_q=0,fv_q=0,edge_q=0;reg[10:0]mag_q=0;
always @(posedge clk)begin
 {fd_q,fh_q,fv_q,mag_q,edge_q,pixel_q}<={fd,fh,fv,mag,edge_on,pixel};
 ode<=fd_q;ohs<=fh_q;ovs<=fv_q;dm<=mag_q;dedge<=edge_q;
 {orr,ogg,obb}<=fd_q?(osd?(ink?24'hffff80:24'h101010):pixel_q):24'd0;
 if(!rst_n)begin fd_q<=0;fh_q<=0;fv_q<=0;ode<=0;ohs<=0;ovs<=0;{orr,ogg,obb}<=0;end
end
endmodule
