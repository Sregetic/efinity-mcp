// Full Canny stages on480x270 analysis frame; HDMI raster remains1920x1080.
module vision_canny #(parameter MIN_COMPONENT=32,W=480,H=270,CONTOUR_RASTER=0,STABLE_NMS=0)(input clk,rst_n,de,hs,vs,input[7:0]r,g,b,input[10:0]high_threshold,
 input[11:0]display_x,display_y,output edge_pixel,output ready,busy,fault,output[31:0]completed,
 input display_de,probe_hold,probe_req,input[11:0]probe_address,
 output probe_ack,output[31:0]probe_data,output[11:0]probe_read_address,output probe_busy,
 input median_en,output[7:0]noise_mean,output noise_valid,output[10:0]effective_threshold,
 input raster_de,output[31:0]coarse_edges,display_edges,analysis_cycles,analysis_passes,analysis_weak,output[7:0]edge_coverage,output capture_start);
reg[11:0]x=0,y=0;reg dq=0,vq=0;wire vblank=vs&&!vq;
always @(posedge clk)begin
 dq<=de;vq<=vs;if(!rst_n)begin x<=0;y<=0;dq<=0;vq<=0;end
 else begin if(vblank)y<=0;else if(dq&&!de)y<=y+1'b1;if(de)x<=x+1'b1;else x<=0;end
end
reg median_q=0;wire median_change=vblank&&(median_en!=median_q);
always @(posedge clk)begin if(!rst_n)median_q<=0;else if(vblank)median_q<=median_en;end
wire processing_rst=rst_n&&!median_change;
wire capture;assign capture_start=processing_rst&&capture&&de&&x==0&&y==0;reg sample=0;reg[8:0]sx=0,sy=0;reg[7:0]gs=0;
// Anti-aliasing: true 4x4 area average before 480x270 analysis.
reg[15:0]luma=0;reg[11:0]xq=0,yq=0;reg deq=0;
reg[9:0]hsum=0;reg[11:0]vertical[0:W-1];reg[11:0]vqsum=0;
wire[9:0]row_sum=hsum+{2'b0,luma[15:8]};
wire[12:0]area_sum={1'b0,vqsum}+{3'b0,row_sum}+13'd8;
always @(posedge clk)begin
 luma<=r*16'd77+g*16'd150+b*16'd29+16'd128;xq<=x;yq<=y;deq<=de;sample<=0;
 if(deq)begin
  if(xq[1:0]==0)hsum<={2'b0,luma[15:8]};else hsum<=row_sum;
  if(xq[1:0]==1)vqsum<=vertical[xq[10:2]];
  if(xq[1:0]==3)begin
   vertical[xq[10:2]]<=(yq[1:0]==0)?{2'b0,row_sum}:vqsum+row_sum;
   if(yq[1:0]==3)begin sample<=capture;sx<=xq[10:2];sy<=yq[10:2];gs<=area_sum[11:4];end
  end
 end
 if(!rst_n)begin sample<=0;deq<=0;hsum<=0;end
end
wire dv,calibrated;wire[8:0]dx,dy;wire[7:0]dgray;wire[10:0]noise_floor;
vision_canny_denoise #(.W(W),.H(H)) denoise(clk,processing_rst,sample,sx,sy,gs,median_q,dv,dx,dy,dgray,noise_mean,noise_floor,noise_valid,calibrated);
reg[10:0]frame_hi=128;
wire[10:0]requested_hi=high_threshold<16?11'd16:high_threshold;
always @(posedge clk)begin
 if(!processing_rst)frame_hi<=128;
 else if(dv&&dx==0&&dy==0)frame_hi<=(median_q&&noise_floor>requested_hi)?noise_floor:requested_hi;
end
assign effective_threshold=frame_hi;
wire avalid;wire[8:0]ax,ay;wire[71:0]aw;
vision_sparse_window #(.W(W),.CW(9)) gauss_window(clk,processing_rst,dv,dx,dy,dgray,avalid,ax,ay,aw);
wire[11:0]sum=aw[71:64]+({4'b0,aw[63:56]}<<1)+aw[55:48]+({4'b0,aw[47:40]}<<1)+({4'b0,aw[39:32]}<<2)+({4'b0,aw[31:24]}<<1)+aw[23:16]+({4'b0,aw[15:8]}<<1)+aw[7:0]+8;
reg gv=0;reg[8:0]gx=0,gy=0;reg[7:0]gdata=0;
always @(posedge clk)begin gv<=avalid;gx<=ax;gy<=ay;gdata<=(ax<2||ay<2)?0:sum[11:4];end
wire bvalid;wire[8:0]bx,by;wire[71:0]bw;
vision_sparse_window #(.W(W),.CW(9)) sobel_window(clk,processing_rst,gv,gx,gy,gdata,bvalid,bx,by,bw);
wire[10:0]mag;wire[1:0]dir;wire[18:0]bm;
vision_sobel #(.META(19)) grad(clk,bw,{bx,by,bvalid},mag,dir,bm,11'd0,);
wire nv,kept,history_pixel;wire[8:0]nx,ny;wire[10:0]cm;
wire[8:0]history_shift=median_q?9'd3:9'd2;
wire[8:0]history_x=bm[18:10]-history_shift,history_y=bm[9:1]-history_shift;
vision_canny_nms #(.W(W),.STABLE(STABLE_NMS)) nms0(clk,processing_rst,bm[0],bm[18:10],bm[9:1],
 mag,dir,history_pixel,frame_hi,median_q,calibrated,nv,nx,ny,cm,kept);
wire[10:0]hi=frame_hi;
wire[1:0]classification=!kept?0:(cm>=hi?2:(cm>=(hi>>1)?1:0));
wire[8:0]shift=(median_q?9'd4:9'd3)+9'(STABLE_NMS);
wire cv=nv&&nx>=shift&&ny>=shift;
wire last=nv&&nx==W-1&&ny==H-1;
wire[8:0]outx=nx-shift,outy=ny-shift;
// Stable NMS adds one window; right/bottom padding grows by one coarse pixel.
// The remaining right/bottom padding is always zero. No per-frame full clear.
wire hyst_ready,coarse_pixel;wire[8:0]fetch_x,fetch_y;
generate if(CONTOUR_RASTER)begin:raster
 vision_canny_raster #(.W(W),.H(H)) raster0(.clk(clk),.rst_n(processing_rst),.vblank(vblank),.de(raster_de),
  .x(display_x),.y(display_y),.bitmap(coarse_pixel),.ready(ready),.fetch_x(fetch_x),.fetch_y(fetch_y),
  .pixel(edge_pixel),.coarse_edges(coarse_edges),.display_edges(display_edges),.coverage(edge_coverage));
end else begin:bitmap_display
 assign fetch_x=display_x[10:2],fetch_y=display_y[10:2],edge_pixel=coarse_pixel,coarse_edges=0,display_edges=0,edge_coverage={8{coarse_pixel}};
end endgenerate
assign ready=hyst_ready&&(!median_q||(noise_valid&&completed>=2));
wire reject_noisy_frame=median_q&&calibrated&&noise_valid&&noise_floor>frame_hi;
vision_hysteresis_sweep #(.W(W),.H(H),.REUSE_CAPTURE_MAP(1),.MIN_COMPONENT(MIN_COMPONENT),.PROBE(1),.ALLOW_DISCARD(1),.HISTORY(STABLE_NMS)) hyst(.clk(clk),.rst_n(processing_rst),.vblank(vblank&&!probe_hold),.class_valid(cv),.class_x(outx),.class_y(outy),.classification(classification),.class_last(last),
 .display_x(fetch_x),.display_y(fetch_y),.capture_enable(capture),.ready(hyst_ready),.busy(busy),.pixel(coarse_pixel),.completed(completed),.fault(fault),.debug_state(),.debug_queue(),
 .display_de(display_de),.probe_req(probe_req),.probe_address(probe_address),.probe_ack(probe_ack),.probe_data(probe_data),.probe_read_address(probe_read_address),.probe_busy(probe_busy),.frame_discard(reject_noisy_frame),.last_cycles(analysis_cycles),.sweep_passes(analysis_passes),.weak_visits(analysis_weak),.history_x(history_x),.history_y(history_y),.history_pixel(history_pixel));
endmodule

// Previous accepted pixels are position hints, never new strong seeds. Only
// near-equal current peaks (<=8 gradient units) can stay at their old location.
// A second sparse window suppresses a competing strict peak only after the
// neighbor's anchor passed its own two-sided peak check. This avoids gaps.
module vision_canny_nms #(parameter W=480,STABLE=1)(
 input clk,rst_n,valid,input[8:0]x,y,input[10:0]mag,input[1:0]dir,input history_pixel,
 input[10:0]hi,input median_en,calibrated,
 output oval,output[8:0]ox,oy,output[10:0]magnitude,output kept);
wire iv;wire[8:0]ix,iy;wire[13:0]id;
generate if(STABLE)begin:history_align
 reg v=0;reg[8:0]xx=0,yy=0;reg[10:0]m=0;reg[1:0]d=0;
 always @(posedge clk)begin v<=valid;xx<=x;yy<=y;m<=mag;d<=dir;if(!rst_n)v<=0;end
 assign iv=v,ix=xx,iy=yy,id={m,d,history_pixel};
end else begin:no_history
 assign iv=valid,ix=x,iy=y,id={mag,dir,1'b0};
end endgenerate
wire nv;wire[8:0]nx,ny;wire[125:0]nw;
vision_sparse_window #(.W(W),.BPP(14),.CW(9)) window0(clk,rst_n,iv,ix,iy,id,nv,nx,ny,nw);
wire[13:0]center=nw[4*14+:14];wire[10:0]cm=center[13:3];reg[10:0]n1,n2;
always @*case(center[2:1])
 0:begin n1=nw[5*14+3+:11];n2=nw[3*14+3+:11];end
 1:begin n1=nw[8*14+3+:11];n2=nw[0*14+3+:11];end
 2:begin n1=nw[7*14+3+:11];n2=nw[1*14+3+:11];end
 default:begin n1=nw[6*14+3+:11];n2=nw[2*14+3+:11];end
endcase
wire eligible=nx>=(median_en?7:6)&&ny>=(median_en?7:6)&&cm!=0&&(!median_en||calibrated);
wire strict_peak=eligible&&cm>=n1&&cm>n2;
wire[11:0]margin={1'b0,cm}+12'd8;
wire anchor=eligible&&center[0]&&cm>=(hi>>1)&&margin>=n1&&margin>=n2;
generate if(STABLE)begin:stable_select
 wire sv;wire[8:0]sx,sy;wire[134:0]sw;
 vision_sparse_window #(.W(W),.BPP(15),.CW(9)) window1(clk,rst_n,nv,nx,ny,
  {cm,center[2:1],strict_peak,anchor},sv,sx,sy,sw);
 wire[14:0]c=sw[4*15+:15];reg[14:0]a,b;
 always @*case(c[3:2])
  0:begin a=sw[5*15+:15];b=sw[3*15+:15];end
  1:begin a=sw[8*15+:15];b=sw[0*15+:15];end
  2:begin a=sw[7*15+:15];b=sw[1*15+:15];end
  default:begin a=sw[6*15+:15];b=sw[2*15+:15];end
 endcase
 assign oval=sv,ox=sx,oy=sy,magnitude=c[14:4];
 assign kept=c[0]||(c[1]&&!((a[0]&&a[3:2]==c[3:2])||(b[0]&&b[3:2]==c[3:2])));
end else begin:strict_select
 assign oval=nv,ox=nx,oy=ny,magnitude=cm,kept=strict_peak;
end endgenerate
endmodule
