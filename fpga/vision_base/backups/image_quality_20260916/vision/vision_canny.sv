// Full Canny stages on240x135 analysis frame; HDMI raster remains1920x1080.
module vision_canny(input clk,rst_n,de,hs,vs,input[7:0]r,g,b,input[10:0]high_threshold,
 input[11:0]display_x,display_y,output edge_pixel,output ready,busy,fault,output[31:0]completed);
reg[11:0]x=0,y=0;reg dq=0,vq=0;wire vblank=vs&&!vq;
always @(posedge clk)begin
 dq<=de;vq<=vs;if(!rst_n)begin x<=0;y<=0;dq<=0;vq<=0;end
 else begin if(vblank)y<=0;else if(dq&&!de)y<=y+1'b1;if(de)x<=x+1'b1;else x<=0;end
end
wire capture;reg sample=0;reg[7:0]sx=0,sy=0;reg[15:0]gs=0;
always @(posedge clk)begin
 sample<=capture&&de&&x[2:0]==0&&y[2:0]==0;sx<=x[10:3];sy<=y[10:3];gs<=r*16'd77+g*16'd150+b*16'd29+128;
 if(!rst_n)sample<=0;
end
wire avalid;wire[7:0]ax,ay;wire[71:0]aw;
vision_sparse_window gauss_window(clk,rst_n,sample,sx,sy,gs[15:8],avalid,ax,ay,aw);
wire[11:0]sum=aw[71:64]+({4'b0,aw[63:56]}<<1)+aw[55:48]+({4'b0,aw[47:40]}<<1)+({4'b0,aw[39:32]}<<2)+({4'b0,aw[31:24]}<<1)+aw[23:16]+({4'b0,aw[15:8]}<<1)+aw[7:0]+8;
reg gv=0;reg[7:0]gx=0,gy=0,gdata=0;
always @(posedge clk)begin gv<=avalid;gx<=ax;gy<=ay;gdata<=(ax<2||ay<2)?0:sum[11:4];end
wire bvalid;wire[7:0]bx,by;wire[71:0]bw;
vision_sparse_window sobel_window(clk,rst_n,gv,gx,gy,gdata,bvalid,bx,by,bw);
wire[10:0]mag;wire[1:0]dir;wire[16:0]bm;
vision_sobel #(.META(17)) grad(clk,bw,{bx,by,bvalid},mag,dir,bm);
wire nv;wire[7:0]nx,ny;wire[116:0]nw;
vision_sparse_window #(.BPP(13)) nms_window(clk,rst_n,bm[0],bm[16:9],bm[8:1],{mag,dir},nv,nx,ny,nw);
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
wire last=nv&&nx==239&&ny==134;
wire[7:0]outx=nx-3,outy=ny-3;
vision_hysteresis hyst(.clk(clk),.rst_n(rst_n),.vblank(vblank),.class_valid(cv),.class_x(outx),.class_y(outy),.classification(classification),.class_last(last),
 .display_x(display_x[10:3]),.display_y(display_y[10:3]),.capture_enable(capture),.ready(ready),.busy(busy),.pixel(edge_pixel),.completed(completed),.fault(fault),.debug_state(),.debug_queue());
endmodule
