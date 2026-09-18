module vision_display(input clk,rst_n,de,hs,vs,input[7:0]r,g,b,input[2:0]mode,input[10:0]threshold,input median_en,
 input[1:0]memory_mode,input[2:0]history_index,
 input canny_pixel,input canny_ready,output[11:0]cx,cy,
 output reg ode,ohs,ovs,output reg[7:0]orr,ogg,obb,
 output[10:0]debug_mag,output debug_edge);
wire fd0,fh0,fv0,border0;wire[11:0]x0,y0;wire[7:0]fr0,fg0,fb0,gray0;wire[10:0]mag0;wire[1:0]dir;
vision_frontend front(clk,rst_n,de,hs,vs,r,g,b,median_en,fd0,fh0,fv0,border0,x0,y0,fr0,fg0,fb0,gray0,mag0,dir);
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
 if(osd)pixel=ink?24'hffff80:24'h101010;
end
always @(posedge clk)begin
 ode<=fd;ohs<=fh;ovs<=fv;dm<=mag;dedge<=edge_on;{orr,ogg,obb}<=fd?pixel:24'd0;
 if(!rst_n)begin ode<=0;ohs<=0;ovs<=0;{orr,ogg,obb}<=0;end
end
endmodule
