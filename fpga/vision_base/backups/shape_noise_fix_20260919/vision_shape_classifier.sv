// Adapted from the attachment's frame-area/bounding-box classifier.
// One filled, high-contrast object inside a uniform-background ROI. No frame RAM.
// Class 1=circle, 2=axis-aligned rectangle, 3=other. Invalid -> class 0.
// Four 16x16 corner patches provide a previous-frame background estimate.
// Coordinates/result belong to the preceding displayed frame (not zero latency).
module vision_shape_classifier #(
 parameter X0=320,Y0=180,X1=1600,Y1=900,
 parameter MIN_AREA=256,MIN_SIZE=16,BG_SPREAD=48
)(input clk,rst_n,de,vs,input[11:0]x,y,input[7:0]gray,diff_threshold,
 output reg[1:0]shape_class,output reg shape_valid,
 output reg[11:0]box_x0,box_y0,box_x1,box_y1,
 output reg[7:0]background,output reg[3:0]reject_flags);
reg vq=0,bg_valid=0;reg[7:0]thr=48,bg_min=255,bg_max=0;
reg[17:0]bg_sum=0;reg[10:0]bg_count=0;
reg[20:0]area=0;reg[11:0]xmin=4095,ymin=4095,xmax=0,ymax=0;
reg touched=0,prev_fg=0,row_seen=0;reg[1:0]runs=0;
reg[11:0]rows=0,multi_rows=0;
wire roi=(x>=X0&&x<X1&&y>=Y0&&y<Y1);
wire patch=roi&&((x<X0+16)||(x>=X1-16))&&((y<Y0+16)||(y>=Y1-16));
wire[7:0]delta=gray>=background?gray-background:background-gray;
wire fg=roi&&bg_valid&&delta>=thr;
wire edge_roi=x==X0||x==X1-1||y==Y0||y==Y1-1;
reg[2:0]pending=0;reg[20:0]a=0;reg[12:0]w=0,h=0;
reg[25:0]box_area=0;reg round_aspect=0;reg[3:0]flags=0;
wire[15:0]w8={3'b0,w}<<3,h8={3'b0,h}<<3;
wire[15:0]w7=w8-{3'b0,w},h7=h8-{3'b0,h};
always @(posedge clk)begin
 vq<=vs;
 if(!rst_n)begin
  vq<=0;bg_valid<=0;background<=0;bg_sum<=0;bg_count<=0;bg_min<=255;bg_max<=0;thr<=48;
  area<=0;xmin<=4095;ymin<=4095;xmax<=0;ymax<=0;touched<=0;
  prev_fg<=0;row_seen<=0;runs<=0;rows<=0;multi_rows<=0;
  pending<=0;a<=0;w<=0;h<=0;box_area<=0;round_aspect<=0;flags<=0;
  shape_class<=0;shape_valid<=0;box_x0<=0;box_y0<=0;box_x1<=0;box_y1<=0;reject_flags<=0;
 end else if(vs&&!vq)begin
  // Capture completed-frame statistics. Publish only after the arithmetic pipeline.
  pending<=3'b001;a<=area;w<={1'b0,xmax}-{1'b0,xmin}+1'b1;h<={1'b0,ymax}-{1'b0,ymin}+1'b1;
  flags<={(!bg_valid||bg_count!=1024||(bg_max-bg_min)>BG_SPREAD),
           (multi_rows>(rows>>3)),touched,(area<MIN_AREA||xmin>xmax||ymin>ymax)};
  box_x0<=xmin;box_y0<=ymin;box_x1<=xmax;box_y1<=ymax;
  shape_valid<=0;shape_class<=0;
  if(bg_count==1024)background<=bg_sum[17:10];
  bg_valid<=bg_count==1024&&(bg_max-bg_min)<=BG_SPREAD;
  thr<=diff_threshold==0?8'd1:diff_threshold;
  bg_sum<=0;bg_count<=0;bg_min<=255;bg_max<=0;
  area<=0;xmin<=4095;ymin<=4095;xmax<=0;ymax<=0;touched<=0;
  prev_fg<=0;row_seen<=0;runs<=0;rows<=0;multi_rows<=0;
 end else begin
  pending<={pending[1:0],1'b0};
  if(pending[0])begin box_area<=w*h;round_aspect<=w8>=h7&&h8>=w7;end
  if(pending[1])begin
   reject_flags<=flags|((w<MIN_SIZE||h<MIN_SIZE)?4'b0001:4'b0000);
   shape_valid<=flags==0&&w>=MIN_SIZE&&h>=MIN_SIZE;
   if(flags!=0||w<MIN_SIZE||h<MIN_SIZE)shape_class<=0;
   else if({5'b0,a}>=(box_area-(box_area>>3)))shape_class<=2;
   else if(round_aspect&&{5'b0,a}>=((box_area>>1)+(box_area>>3)+(box_area>>4))&&
           {5'b0,a}<=((box_area>>1)+(box_area>>2)+(box_area>>4)+(box_area>>5)))shape_class<=1;
   else shape_class<=3;
  end
  if(de&&roi)begin
   if(patch)begin
    bg_sum<=bg_sum+gray;bg_count<=bg_count+1'b1;
    if(gray<bg_min)bg_min<=gray;if(gray>bg_max)bg_max<=gray;
   end
   prev_fg<=fg;
   if(fg)begin
    area<=area+1'b1;row_seen<=1;
    if(!prev_fg||x==X0)begin if(runs!=3)runs<=runs+1'b1;end
    if(x<xmin)xmin<=x;if(x>xmax)xmax<=x;if(y<ymin)ymin<=y;if(y>ymax)ymax<=y;
    if(edge_roi)touched<=1;
   end
   if(x==X1-1)begin
    if(row_seen||fg)rows<=rows+1'b1;
    if(runs>=2)multi_rows<=multi_rows+1'b1;
    prev_fg<=0;row_seen<=0;runs<=0;
   end
  end
 end
end
endmodule
