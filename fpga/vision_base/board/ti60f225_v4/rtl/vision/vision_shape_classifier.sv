// One filled or closed-outline, high-contrast object in a uniform-background ROI.
// Row spans fill the silhouette; up to two 8-connected runs describe an outline.
// ponytail: single object, axis-aligned rectangle; general contours need CCL/fitting.
// Class 1=circle, 2=axis-aligned rectangle, 3=other. Invalid -> class 0.
// Four 16x16 corner patches provide a previous-frame background estimate.
// Coordinates/result belong to the preceding displayed frame (not zero latency).
module vision_shape_classifier #(
 parameter X0=640,Y0=300,X1=1280,Y1=780,
 parameter MIN_AREA=256,MIN_SIZE=16,BG_SPREAD=48
)(input clk,rst_n,de,vs,input[11:0]x,y,input[7:0]gray,diff_threshold,
 output reg[1:0]shape_class,output reg shape_valid,
 output reg[11:0]box_x0,box_y0,box_x1,box_y1,
 output reg[7:0]background,output reg[3:0]reject_flags,output reg result_done=0);
reg vq=0,bg_valid=0;reg[7:0]thr=48,bg_min=255,bg_max=0;
reg[15:0]patch_sum0=0,patch_sum1=0,patch_sum2=0,patch_sum3=0;
function automatic[7:0]min8(input[7:0]a,b);begin min8=a<b?a:b;end endfunction
function automatic[7:0]max8(input[7:0]a,b);begin max8=a>b?a:b;end endfunction
wire[7:0]patch_lo=min8(min8(patch_sum0[15:8],patch_sum1[15:8]),min8(patch_sum2[15:8],patch_sum3[15:8]));
wire[7:0]patch_hi=max8(max8(patch_sum0[15:8],patch_sum1[15:8]),max8(patch_sum2[15:8],patch_sum3[15:8]));
reg[17:0]bg_sum=0;reg[10:0]bg_count=0;
reg[20:0]area=0;reg[11:0]xmin=4095,ymin=4095,xmax=0,ymax=0;
reg touched=0,prev_fg=0,row_seen=0,bad_topology=0;reg[1:0]runs=0,previous_runs=0;
reg[11:0]rows=0,row_first=0,row_last=0,left_end=0,right_start=0;
reg[11:0]previous_y=0,previous_first=0,previous_left_end=0,previous_right_start=0,previous_last=0;
wire roi=(x>=X0&&x<X1&&y>=Y0&&y<Y1);
wire patch=roi&&((x<X0+16)||(x>=X1-16))&&((y<Y0+16)||(y>=Y1-16));
wire[7:0]delta=gray>=background?gray-background:background-gray;
wire fg=roi&&!patch&&bg_valid&&delta>=thr;
wire edge_roi=x==X0||x==X1-1||y==Y0||y==Y1-1;
// Separate edge/background decision from row topology; both carry the same pixel.
reg de_q=0,vs_q=0,roi_q=0,patch_q=0,fg_q=0,edge_roi_q=0;
reg[11:0]x_q=0,y_q=0;reg[7:0]gray_q=0;
always @(posedge clk)begin
 {de_q,vs_q,roi_q,patch_q,fg_q,edge_roi_q,x_q,y_q,gray_q}<={de,vs,roi,patch,fg,edge_roi,x,y,gray};
 if(!rst_n)begin de_q<=0;vs_q<=0;fg_q<=0;end
end
wire run_start=fg_q&&(!prev_fg||x_q==X0);
wire[1:0]next_runs=(run_start&&runs!=3)?runs+2'd1:runs;
wire[11:0]current_first=row_seen?row_first:x_q;
wire[11:0]current_last=fg_q?x_q:row_last;
wire[11:0]current_left_end=(fg_q&&next_runs==1)?x_q:left_end;
wire[11:0]current_right_start=(run_start&&runs==1)?x_q:right_start;
function automatic connected(input[11:0]a0,a1,b0,b1);
 begin connected=({1'b0,a0}<={1'b0,b1}+13'd1)&&({1'b0,b0}<={1'b0,a1}+13'd1);end
endfunction
wire ll=connected(current_first,current_left_end,previous_first,previous_left_end);
wire lr=previous_runs==2&&connected(current_first,current_left_end,previous_right_start,previous_last);
wire rl=next_runs==2&&connected(current_right_start,current_last,previous_first,previous_left_end);
wire rr=next_runs==2&&previous_runs==2&&connected(current_right_start,current_last,previous_right_start,previous_last);
reg[2:0]pending=0;reg[20:0]a=0;reg[12:0]w=0,h=0;
reg[25:0]box_area=0;reg round_aspect=0;reg[3:0]flags=0;
wire[15:0]w8={3'b0,w}<<3,h8={3'b0,h}<<3;
wire[15:0]w7=w8-{3'b0,w},h7=h8-{3'b0,h};
always @(posedge clk)begin
 vq<=vs_q;result_done<=rst_n&&pending[1];
 if(!rst_n)begin
  vq<=0;bg_valid<=0;background<=0;patch_sum0<=0;patch_sum1<=0;patch_sum2<=0;patch_sum3<=0;bg_sum<=0;bg_count<=0;bg_min<=255;bg_max<=0;thr<=48;
  area<=0;xmin<=4095;ymin<=4095;xmax<=0;ymax<=0;touched<=0;
  prev_fg<=0;row_seen<=0;runs<=0;rows<=0;bad_topology<=0;previous_runs<=0;
  row_first<=0;row_last<=0;left_end<=0;right_start<=0;
  previous_y<=0;previous_first<=0;previous_left_end<=0;previous_right_start<=0;previous_last<=0;
  pending<=0;a<=0;w<=0;h<=0;box_area<=0;round_aspect<=0;flags<=0;
  shape_class<=0;shape_valid<=0;box_x0<=0;box_y0<=0;box_x1<=0;box_y1<=0;reject_flags<=0;
 end else if(vs_q&&!vq)begin
  // Capture completed-frame statistics. Publish only after the arithmetic pipeline.
  pending<=3'b001;a<=area;w<={1'b0,xmax}-{1'b0,xmin}+1'b1;h<={1'b0,ymax}-{1'b0,ymin}+1'b1;
  flags<={(!bg_valid||bg_count!=1024||(patch_hi-patch_lo)>BG_SPREAD),
           (bad_topology||(rows!=0&&previous_runs!=1)),touched,(area<MIN_AREA||xmin>xmax||ymin>ymax)};
  box_x0<=xmin;box_y0<=ymin;box_x1<=xmax;box_y1<=ymax;
  shape_valid<=0;shape_class<=0;
  if(bg_count==1024)background<=bg_sum[17:10];
  bg_valid<=bg_count==1024&&(patch_hi-patch_lo)<=BG_SPREAD;
  thr<=diff_threshold==0?8'd1:diff_threshold;
  patch_sum0<=0;patch_sum1<=0;patch_sum2<=0;patch_sum3<=0;bg_sum<=0;bg_count<=0;bg_min<=255;bg_max<=0;
  area<=0;xmin<=4095;ymin<=4095;xmax<=0;ymax<=0;touched<=0;
  prev_fg<=0;row_seen<=0;runs<=0;rows<=0;bad_topology<=0;previous_runs<=0;
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
  if(de_q&&roi_q)begin
   if(patch_q)begin
    case({(y_q>=Y1-16),(x_q>=X1-16)})
     0:patch_sum0<=patch_sum0+gray_q;1:patch_sum1<=patch_sum1+gray_q;
     2:patch_sum2<=patch_sum2+gray_q;3:patch_sum3<=patch_sum3+gray_q;
    endcase
    bg_sum<=bg_sum+gray_q;bg_count<=bg_count+1'b1;
    if(gray_q<bg_min)bg_min<=gray_q;if(gray_q>bg_max)bg_max<=gray_q;
   end
   prev_fg<=fg_q;
   if(fg_q)begin
    row_seen<=1;row_last<=x_q;
    if(!row_seen)row_first<=x_q;
    if(next_runs==1)left_end<=x_q;
    if(run_start)begin runs<=next_runs;if(runs==1)right_start<=x_q;end
    if(x_q<xmin)xmin<=x_q;if(x_q>xmax)xmax<=x_q;if(y_q<ymin)ymin<=y_q;if(y_q>ymax)ymax<=y_q;
    if(edge_roi_q)touched<=1;
   end
   if(x_q==X1-1)begin
    if(row_seen||fg_q)begin
     area<=area+({1'b0,current_last}-{1'b0,current_first}+13'd1);
     rows<=rows+1'b1;
     // Both directions matter: a side that stops before merging is an open contour.
     if(next_runs>2 || (rows==0&&next_runs!=1) ||
        (rows!=0&&(y_q!=previous_y+1'b1 || !(ll||lr) ||
                   (next_runs==2&&!(rl||rr)) || !(ll||rl) ||
                   (previous_runs==2&&!(lr||rr)))))bad_topology<=1;
     previous_y<=y_q;previous_runs<=next_runs;
     previous_first<=current_first;previous_left_end<=current_left_end;
     previous_right_start<=current_right_start;previous_last<=current_last;
    end
    prev_fg<=0;row_seen<=0;runs<=0;
   end
  end
 end
end
endmodule

