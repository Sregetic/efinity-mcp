// Full Canny stages on480x270 analysis frame; HDMI raster remains1920x1080.
module vision_canny(input clk,rst_n,de,hs,vs,input[7:0]r,g,b,input[10:0]high_threshold,
 input[11:0]display_x,display_y,output edge_pixel,output ready,busy,fault,output[31:0]completed);
reg[11:0]x=0,y=0;reg dq=0,vq=0;wire vblank=vs&&!vq;
always @(posedge clk)begin
 dq<=de;vq<=vs;if(!rst_n)begin x<=0;y<=0;dq<=0;vq<=0;end
 else begin if(vblank)y<=0;else if(dq&&!de)y<=y+1'b1;if(de)x<=x+1'b1;else x<=0;end
end
wire capture;reg sample=0;reg[8:0]sx=0,sy=0;reg[7:0]gs=0;
// Anti-aliasing: true 4x4 area average before 480x270 analysis.
reg[15:0]luma=0;reg[11:0]xq=0,yq=0;reg deq=0;
reg[9:0]hsum=0;reg[11:0]vertical[0:479];reg[11:0]vqsum=0;
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
wire avalid;wire[8:0]ax,ay;wire[71:0]aw;
vision_sparse_window #(.W(480),.CW(9)) gauss_window(clk,rst_n,sample,sx,sy,gs,avalid,ax,ay,aw);
wire[11:0]sum=aw[71:64]+({4'b0,aw[63:56]}<<1)+aw[55:48]+({4'b0,aw[47:40]}<<1)+({4'b0,aw[39:32]}<<2)+({4'b0,aw[31:24]}<<1)+aw[23:16]+({4'b0,aw[15:8]}<<1)+aw[7:0]+8;
reg gv=0;reg[8:0]gx=0,gy=0;reg[7:0]gdata=0;
always @(posedge clk)begin gv<=avalid;gx<=ax;gy<=ay;gdata<=(ax<2||ay<2)?0:sum[11:4];end
wire bvalid;wire[8:0]bx,by;wire[71:0]bw;
vision_sparse_window #(.W(480),.CW(9)) sobel_window(clk,rst_n,gv,gx,gy,gdata,bvalid,bx,by,bw);
wire[10:0]mag;wire[1:0]dir;wire[18:0]bm;
vision_sobel #(.META(19)) grad(clk,bw,{bx,by,bvalid},mag,dir,bm);
wire nv;wire[8:0]nx,ny;wire[116:0]nw;
vision_sparse_window #(.W(480),.BPP(13),.CW(9)) nms_window(clk,rst_n,bm[0],bm[18:10],bm[9:1],{mag,dir},nv,nx,ny,nw);
wire[12:0]center=nw[4*13+:13];wire[10:0]cm=center[12:2];reg[10:0]n1,n2;
always @*case(center[1:0])
 0:begin n1=nw[5*13+2+:11];n2=nw[3*13+2+:11];end
 1:begin n1=nw[8*13+2+:11];n2=nw[0*13+2+:11];end
 2:begin n1=nw[7*13+2+:11];n2=nw[1*13+2+:11];end
 default:begin n1=nw[6*13+2+:11];n2=nw[2*13+2+:11];end
endcase
wire kept=nx>=6&&ny>=6&&cm!=0&&cm>=n1&&cm>n2;
wire[10:0]hi=high_threshold<16?11'd16:high_threshold;
wire[1:0]classification=!kept?0:(cm>=hi?2:(cm>=(hi>>1)?1:0));
wire cv=nv&&nx>=3&&ny>=3;
wire last=nv&&nx==479&&ny==269;
wire[8:0]outx=nx-3,outy=ny-3;
vision_hysteresis_sweep hyst(.clk(clk),.rst_n(rst_n),.vblank(vblank),.class_valid(cv),.class_x(outx),.class_y(outy),.classification(classification),.class_last(last),
 .display_x(display_x[10:2]),.display_y(display_y[10:2]),.capture_enable(capture),.ready(ready),.busy(busy),.pixel(edge_pixel),.completed(completed),.fault(fault),.debug_state(),.debug_queue());
endmodule
