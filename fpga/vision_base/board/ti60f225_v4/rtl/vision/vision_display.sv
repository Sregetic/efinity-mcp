module vision_display(input clk,rst_n,de,hs,vs,input[7:0]r,g,b,input[2:0]mode,input[10:0]threshold,input median_en,
 input[1:0]memory_mode,input[2:0]history_index,
 input canny_pixel,input canny_ready,output[11:0]cx,cy,
 output reg ode,ohs,ovs,output reg[7:0]orr,ogg,obb,
 output[10:0]debug_mag,output debug_edge,
 input shape_enable,input[7:0]shape_threshold,output[63:0]shape_status,output coordinate_de,input[10:0]canny_effective_threshold,canny_requested_threshold);
wire fd0,fh0,fv0,border0;wire[11:0]x0,y0;wire[7:0]fr0,fg0,fb0,gray0;wire[10:0]mag0;wire[1:0]dir;
wire edge0;reg edge1=0;
vision_frontend front(clk,rst_n,de,hs,vs,r,g,b,median_en,fd0,fh0,fv0,border0,x0,y0,fr0,fg0,fb0,gray0,mag0,dir,threshold,edge0);
reg fd=0,fh=0,fv=0,border=1;reg[11:0]x=0,y=0;reg[7:0]fr=0,fg=0,fb=0,gray=0;reg[10:0]mag=0;
always @(posedge clk)begin {fd,fh,fv,border,x,y,fr,fg,fb,gray,mag}<={fd0,fh0,fv0,(border0||x0<4||y0<4),x0,y0,fr0,fg0,fb0,gray0,mag0};end
always @(posedge clk)edge1<=edge0;
wire edge_on=!border && edge1;wire osd,ink;
wire[1:0]shape_class;wire shape_valid;wire[11:0]sx0,sy0,sx1,sy1;wire[7:0]shape_bg;wire[3:0]shape_flags;
wire shape_show=shape_enable&&mode>=2;
wire detection_edge=(mode==5||mode==6)?(canny_pixel&&canny_ready):edge_on;
// Edge modes recognize the displayed edge mask, not the RGB image behind it.
wire[7:0]shape_gray=(mode>=2&&mode<=6)?{8{detection_edge}}:gray;
vision_shape_classifier shape0(.clk(clk),.rst_n(rst_n),.de(fd),.vs(fv),.x(x),.y(y),.gray(shape_gray),.diff_threshold(shape_threshold),
 .shape_class(shape_class),.shape_valid(shape_valid),.box_x0(sx0),.box_y0(sy0),.box_x1(sx1),.box_y1(sy1),.background(shape_bg),.reject_flags(shape_flags));
assign shape_status={shape_enable,shape_valid,shape_class,shape_bg,shape_flags,sx0,sy0,sx1,sy1};
wire shape_box=shape_valid&&((x>=sx0&&x<=sx1&&(y==sy0||y==sy1))||(y>=sy0&&y<=sy1&&(x==sx0||x==sx1)));
wire shape_guide=((x==640||x==1279)&&(y>=300&&y<780)&&y[3])||((y==300||y==779)&&(x>=640&&x<1280)&&x[3]);
vision_osd osd0(x,y,mode,(mode==5||mode==6)?canny_effective_threshold:threshold,median_en,memory_mode,history_index,canny_ready,shape_class,shape_valid,shape_show,osd,ink,canny_requested_threshold);
// RGB/gradient metadata represents the center after two 3x3 windows.
assign cx=x0>=2?x0-2:0;assign cy=y0>=2?y0-2:0;
assign coordinate_de=fd0&&x0>=2&&y0>=2;reg[10:0]dm=0;reg dedge=0;assign debug_mag=dm;assign debug_edge=dedge;
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
 default:pixel=shape_enable?(shape_box?((shape_class==1)?24'h20ff40:(shape_class==2)?24'h3090ff:24'hffe020):(shape_guide?24'h808080:{fr,fg,fb})):((x<960)?{fr,fg,fb}:{gray,gray,gray});
 endcase
 if(border)pixel=0;
 if(mode==3&&x>=958&&x<=961)pixel=24'h00ff80;
 if(shape_show&&shape_box)pixel=(shape_class==1)?24'h20ff40:(shape_class==2)?24'h3090ff:24'hffe020;
 if(osd)pixel=ink?24'hffff80:24'h101010;
end
always @(posedge clk)begin
 ode<=fd;ohs<=fh;ovs<=fv;dm<=mag;dedge<=edge_on;{orr,ogg,obb}<=fd?pixel:24'd0;
 if(!rst_n)begin ode<=0;ohs<=0;ovs<=0;{orr,ogg,obb}<=0;end
end
endmodule
