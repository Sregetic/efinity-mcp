// Reconstruct the accepted Canny graph on its 4x HDMI grid. Each coarse edge
// is a node; segments join only existing 8-connected neighbors. No live RGB
// is mixed with the retained Canny frame. Detection remains W x H.
module vision_canny_raster #(parameter W=480,H=270,CW=9)(
 input clk,rst_n,vblank,de,input[11:0]x,y,input bitmap,ready,
 output[CW-1:0]fetch_x,fetch_y,output pixel,
 output reg[31:0]coarse_edges,display_edges,output[7:0]coverage
);
 wire[CW:0]rx={1'b0,x[10:2]}+2,ry={1'b0,y[10:2]}+1;
 assign fetch_x=rx[CW-1:0],fetch_y=ry[CW-1:0];
 reg rq=0,vq=0;reg[CW-1:0]qx=0,qy=0;
 reg[1:0]ux=0,uy=0;reg[CW-1:0]tx=0,ty=0;
 always @(posedge clk)begin
  rq<=de&&x[1:0]==0&&y[1:0]==0&&rx<W&&ry<H;
  qx<=fetch_x;qy<=fetch_y;vq<=de;ux<=x[1:0];uy<=y[1:0];tx<=x[10:2];ty<=y[10:2];
  if(!rst_n)begin rq<=0;vq<=0;ux<=0;uy<=0;tx<=0;ty<=0;end
 end
 wire wv;wire[CW-1:0]wx,wy;wire[8:0]neighbors;
 vision_sparse_window #(.W(W),.BPP(1),.CW(CW)) window0(
  clk,rst_n,rq,qx,qy,bitmap,wv,wx,wy,neighbors);
 reg[8:0]rows[0:W-1],row_q=0,fresh=0,tile=0;
 wire[CW-1:0]cache_x=!de?0:(x[1:0]==3?x[10:2]+1'b1:x[10:2]);
 always @(posedge clk)begin
  if(cache_x<W)row_q<=rows[cache_x];
  if(wv)begin rows[wx-1'b1]<=neighbors;fresh<=neighbors;end
  // Fresh window arrives at phase3; first-row cache read/write can collide.
  // The remaining three rows reuse the completed cache instead.
  if(de&&x[1:0]==0)tile<=y[1:0]==0?fresh:row_q;
  if(!rst_n)begin row_q<=0;fresh<=0;tile<=0;end
 end
 wire center=tile[4],nw=tile[8],n=tile[7],ne=tile[6],w=tile[5];
 wire e=tile[3],sw=tile[2],s=tile[1],se=tile[0];
 wire node=ux==2&&uy==2;
 wire horizontal=uy==2&&((w&&ux<=2)||(e&&ux>=2));
 wire vertical=ux==2&&((n&&uy<=2)||(s&&uy>=2));
 wire descending=ux==uy&&((nw&&ux<=2)||(se&&ux>=2));
 wire ascending={1'b0,ux}+{1'b0,uy}==4&&((ne&&ux>=2)||(sw&&ux<=2));
 // NE/SW neighbor connections also cross the top-left corner of this cell.
 wire bridge=n&&w&&ux==0&&uy==0;
 wire in_canvas=ready&&vq&&tx>=2&&ty>=2&&tx<W-2&&ty<H-2;
 assign pixel=in_canvas&&
              ((center&&(node||horizontal||vertical||descending||ascending))||bridge);
 // Quarter coverage beside diagonal segments; recognition keeps the binary
 // graph. Reuse the same nine nodes without another line or frame buffer.
 wire near_descending=((ux+3'd1==uy)||(uy+3'd1==ux))&&
   ((nw&&ux<=2&&uy<=2)||(se&&ux>=2&&uy>=2));
 wire[2:0]sum_xy={1'b0,ux}+{1'b0,uy};
 wire near_ascending=(sum_xy==3||sum_xy==5)&&
   ((ne&&ux>=2&&uy<=2)||(sw&&ux<=2&&uy>=2));
 wire halo=(center&&(near_descending||near_ascending))||(n&&w&&sum_xy==1);
 assign coverage=pixel?8'd255:((in_canvas&&halo)?8'd64:8'd0);
 reg[31:0]coarse_count=0,display_count=0;
 always @(posedge clk)begin
  if(!rst_n)begin coarse_count<=0;display_count<=0;coarse_edges<=0;display_edges<=0;end
  else if(vblank)begin coarse_edges<=coarse_count;display_edges<=display_count;coarse_count<=0;display_count<=0;end
  else begin
   if(rq&&bitmap&&ready)coarse_count<=coarse_count+1'b1;
   if(pixel)display_count<=display_count+1'b1;
  end
 end
endmodule
