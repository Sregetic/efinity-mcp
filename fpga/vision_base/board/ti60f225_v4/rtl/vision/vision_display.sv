module vision_display #(parameter WIDTH=1920,HEIGHT=1080,LOCAL_MOTION_ENABLE=0)(input clk,rst_n,de,hs,vs,input[7:0]r,g,b,input[2:0]mode,input[10:0]threshold,input median_en,
 input[1:0]memory_mode,input[2:0]history_index,
 input canny_pixel,input canny_ready,output[11:0]cx,cy,
 output reg ode,ohs,ovs,output reg[7:0]orr,ogg,obb,
 output[10:0]debug_mag,output debug_edge,
 output[31:0]motion_observation,motion_status,motion_h,motion_v,motion_dropped,
 output[47:0]motion_box,output[15:0]motion_active);
wire fd0,fh0,fv0,border0;wire[11:0]x0,y0;wire[7:0]fr0,fg0,fb0,gray0;wire[10:0]mag0;wire[1:0]dir;
vision_frontend #(.WIDTH(WIDTH))front(clk,rst_n,de,hs,vs,r,g,b,median_en,fd0,fh0,fv0,border0,x0,y0,fr0,fg0,fb0,gray0,mag0,dir);
wire[11:0]mx0,my0,mx1,my1;
generate if(LOCAL_MOTION_ENABLE)begin:local_motion
 vision_local_motion_tap #(.WIDTH(WIDTH),.HEIGHT(HEIGHT))tap(
  .clk(clk),.rst_n(rst_n),.de(fd0),.vs(fv0),.x(x0),.y(y0),
  .gray((border0||x0<4||y0<4)?8'd0:gray0),.config_bit(median_en),
  .observation_id(motion_observation),.status(motion_status),.horizontal_response(motion_h),.vertical_response(motion_v),
  .roi_x0(mx0),.roi_y0(my0),.roi_x1(mx1),.roi_y1(my1),.active_sites(motion_active),.dropped_frames(motion_dropped));
end else begin:no_local_motion
 assign motion_observation=0;assign motion_status=0;assign motion_h=0;assign motion_v=0;
 assign motion_dropped=0;assign motion_active=0;assign mx0=0;assign my0=0;assign mx1=0;assign my1=0;
end endgenerate
assign motion_box={mx0,my0,mx1,my1};

// Hold one coherent display snapshot at frame boundary. This adds no video delay.
reg motion_vs_q=0;reg[31:0]hud_status=0,hud_observation=0;
reg[47:0]hud_box=0;reg[15:0]hud_sites=0;
always @(posedge clk)begin
 motion_vs_q<=fv0;
 if(!rst_n)begin motion_vs_q<=0;hud_status<=0;hud_observation<=0;hud_box<=0;hud_sites<=0;end
 else if(fv0&&!motion_vs_q)begin
  hud_status<=motion_status;hud_observation<=motion_observation;
  hud_box<={mx0,my0,mx1,my1};hud_sites<=motion_active;
 end
end
wire[2:0]readout_direction;wire readout_held;
vision_motion_readout readout(.clk(clk),.rst_n(rst_n),.frame_tick(fv0&&!motion_vs_q),
 .status(motion_status),.observation(motion_observation),.horizontal(motion_h),.vertical(motion_v),
 .active_sites(motion_active),.show_direction(readout_direction),.held(readout_held));
reg[2:0]hud_direction=0;reg hud_held=0;
always @(posedge clk)begin
 if(!rst_n)begin hud_direction<=0;hud_held<=0;end
 else if(fv0&&!motion_vs_q)begin hud_direction<=readout_direction;hud_held<=readout_held;end
end
wire[11:0]hx0=hud_box[47:36],hy0=hud_box[35:24],hx1=hud_box[23:12],hy1=hud_box[11:0];
wire motion_osd_active,motion_osd_ink;wire[23:0]motion_osd_color;
vision_motion_osd motion_hud(.x(x0),.y(y0),.status(hud_status),.observation(hud_observation),.active_sites(hud_sites),.show_direction(hud_direction),.held(hud_held),
 .active(motion_osd_active),.ink(motion_osd_ink),.color(motion_osd_color));
reg hud_active_q=0,hud_ink_q=0;reg[23:0]hud_color_q=0;
always @(posedge clk)begin
 hud_active_q<=motion_osd_active;hud_ink_q<=motion_osd_ink;hud_color_q<=motion_osd_color;
 if(!rst_n)begin hud_active_q<=0;hud_ink_q<=0;hud_color_q<=0;end
end

reg fd=0,fh=0,fv=0,border=1;reg[11:0]x=0,y=0;reg[7:0]fr=0,fg=0,fb=0,gray=0;reg[10:0]mag=0;
always @(posedge clk)begin {fd,fh,fv,border,x,y,fr,fg,fb,gray,mag}<={fd0,fh0,fv0,(border0||x0<4||y0<4),x0,y0,fr0,fg0,fb0,gray0,mag0};end
wire edge_on=!border && mag>=threshold;wire osd,ink;
vision_osd osd0(x,y,mode,threshold,median_en,memory_mode,history_index,canny_ready,osd,ink);
assign cx=x0;assign cy=y0;reg[10:0]dm=0;reg dedge=0;assign debug_mag=dm;assign debug_edge=dedge;
reg[23:0]pixel;
always @*begin
 case(mode)
 0:pixel={fr,fg,fb};
 1:pixel={gray,gray,gray};
 2:pixel={24{edge_on}};
 3:pixel=(x<960)?{gray,gray,gray}:{24{edge_on}};
 4:pixel=edge_on?24'hff3030:{fr,fg,fb};
 5:pixel={24{canny_pixel&&canny_ready}};
 6:pixel=(canny_pixel&&canny_ready)?24'hff3030:{fr,fg,fb};
 default:pixel=(x<960)?{fr,fg,fb}:{gray,gray,gray};
 endcase
 if(border)pixel=0;
 if(mode==3&&x>=958&&x<=961)pixel=24'h00ff80;
 // Previous complete raster ROI, observational only; no work is gated.
 if(LOCAL_MOTION_ENABLE&&mode==7&&hud_status[2]&&
    x>=hx0&&x<hx1&&y>=hy0&&y<hy1&&
    (x<hx0+2||x+2>=hx1||y<hy0+2||y+2>=hy1))pixel=24'h40ffd0;
 if(LOCAL_MOTION_ENABLE&&mode==7&&hud_active_q)pixel=hud_ink_q?hud_color_q:24'h101820;
 if(osd)pixel=ink?24'hffff80:24'h101010;
end
always @(posedge clk)begin
 ode<=fd;ohs<=fh;ovs<=fv;dm<=mag;dedge<=edge_on;{orr,ogg,obb}<=fd?pixel:24'd0;
 if(!rst_n)begin ode<=0;ohs<=0;ovs<=0;{orr,ogg,obb}<=0;end
end
endmodule
