// Full Canny stages on480x270 analysis frame; HDMI raster remains1920x1080.
module vision_canny #(parameter MIN_COMPONENT=32,W=480,H=270,CONTOUR_RASTER=0)(input clk,rst_n,de,hs,vs,input[7:0]r,g,b,input[10:0]high_threshold,
 input[11:0]display_x,display_y,output edge_pixel,output ready,busy,fault,output[31:0]completed,
 input display_de,probe_hold,probe_req,input[11:0]probe_address,
 output probe_ack,output[31:0]probe_data,output[11:0]probe_read_address,output probe_busy,
 input median_en,output[7:0]noise_mean,output noise_valid,output[10:0]effective_threshold,
 input raster_de,output[31:0]coarse_edges,display_edges,analysis_cycles,analysis_passes,analysis_weak);
reg[11:0]x=0,y=0;reg dq=0,vq=0;wire vblank=vs&&!vq;
always @(posedge clk)begin
 dq<=de;vq<=vs;if(!rst_n)begin x<=0;y<=0;dq<=0;vq<=0;end
 else begin if(vblank)y<=0;else if(dq&&!de)y<=y+1'b1;if(de)x<=x+1'b1;else x<=0;end
end
reg median_q=0;wire median_change=vblank&&(median_en!=median_q);
always @(posedge clk)begin if(!rst_n)median_q<=0;else if(vblank)median_q<=median_en;end
wire processing_rst=rst_n&&!median_change;
wire capture;reg sample=0;reg[8:0]sx=0,sy=0;reg[7:0]gs=0;
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
wire nv;wire[8:0]nx,ny;wire[116:0]nw;
vision_sparse_window #(.W(W),.BPP(13),.CW(9)) nms_window(clk,processing_rst,bm[0],bm[18:10],bm[9:1],{mag,dir},nv,nx,ny,nw);
wire[12:0]center=nw[4*13+:13];wire[10:0]cm=center[12:2];reg[10:0]n1,n2;
always @*case(center[1:0])
 0:begin n1=nw[5*13+2+:11];n2=nw[3*13+2+:11];end
 1:begin n1=nw[8*13+2+:11];n2=nw[0*13+2+:11];end
 2:begin n1=nw[7*13+2+:11];n2=nw[1*13+2+:11];end
 default:begin n1=nw[6*13+2+:11];n2=nw[2*13+2+:11];end
endcase
wire kept=nx>=(median_q?7:6)&&ny>=(median_q?7:6)&&cm!=0&&cm>=n1&&cm>n2&&(!median_q||calibrated);
wire[10:0]hi=frame_hi;
wire[1:0]classification=!kept?0:(cm>=hi?2:(cm>=(hi>>1)?1:0));
wire cv=nv&&nx>=(median_q?4:3)&&ny>=(median_q?4:3);
wire last=nv&&nx==W-1&&ny==H-1;
wire[8:0]outx=nx-(median_q?9'd4:9'd3),outy=ny-(median_q?9'd4:9'd3);
// cv overwrites477x267 in bypass,476x266 with median. A mode change resets padding.
// The remaining right/bottom padding is always zero. No per-frame full clear.
wire hyst_ready,coarse_pixel;wire[8:0]fetch_x,fetch_y;
generate if(CONTOUR_RASTER)begin:raster
 vision_canny_raster #(.W(W),.H(H)) raster0(.clk(clk),.rst_n(processing_rst),.vblank(vblank),.de(raster_de),
  .x(display_x),.y(display_y),.bitmap(coarse_pixel),.ready(ready),.fetch_x(fetch_x),.fetch_y(fetch_y),
  .pixel(edge_pixel),.coarse_edges(coarse_edges),.display_edges(display_edges));
end else begin:bitmap_display
 assign fetch_x=display_x[10:2],fetch_y=display_y[10:2],edge_pixel=coarse_pixel,coarse_edges=0,display_edges=0;
end endgenerate
assign ready=hyst_ready&&(!median_q||(noise_valid&&completed>=2));
wire reject_noisy_frame=median_q&&calibrated&&noise_valid&&noise_floor>frame_hi;
vision_hysteresis_sweep #(.W(W),.H(H),.REUSE_CAPTURE_MAP(1),.MIN_COMPONENT(MIN_COMPONENT),.PROBE(1),.ALLOW_DISCARD(1)) hyst(.clk(clk),.rst_n(processing_rst),.vblank(vblank&&!probe_hold),.class_valid(cv),.class_x(outx),.class_y(outy),.classification(classification),.class_last(last),
 .display_x(fetch_x),.display_y(fetch_y),.capture_enable(capture),.ready(hyst_ready),.busy(busy),.pixel(coarse_pixel),.completed(completed),.fault(fault),.debug_state(),.debug_queue(),
 .display_de(display_de),.probe_req(probe_req),.probe_address(probe_address),.probe_ack(probe_ack),.probe_data(probe_data),.probe_read_address(probe_read_address),.probe_busy(probe_busy),.frame_discard(reject_noisy_frame),.last_cycles(analysis_cycles),.sweep_passes(analysis_passes),.weak_visits(analysis_weak));
endmodule
