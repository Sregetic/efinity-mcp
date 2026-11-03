// Four registered stages, initiation interval = one pixel/clock.
// S1 weighted sides; S2 signed gradients; S3 magnitude/direction terms;
// S4 threshold and quantized direction. Metadata follows the same four stages.
module vision_sobel #(parameter META=1)(input clk,input[71:0]w,input[META-1:0]meta,
 output reg[10:0]mag,output reg[1:0]direction,output reg[META-1:0]out_meta,
 input[10:0]threshold,output reg edge_pixel);
wire[7:0]p0=w[71:64],p1=w[63:56],p2=w[55:48],p3=w[47:40],p5=w[31:24],p6=w[23:16],p7=w[15:8],p8=w[7:0];
reg[9:0]left1=0,right1=0,top1=0,bottom1=0;
reg signed[10:0]gx2=0,gy2=0;
wire[10:0]ax2=gx2[10]?-gx2:gx2,ay2=gy2[10]?-gy2:gy2;
reg[10:0]mag3=0;
reg[18:0]ax256_3=0,ay256_3=0;
reg[17:0]ax106_3=0,ay106_3=0;
reg signs3=0;
reg[META-1:0]m1=0,m2=0,m3=0;
reg[10:0]t1=0,t2=0,t3=0;
always @(posedge clk)begin
 left1<={2'b0,p0}+{1'b0,p3,1'b0}+{2'b0,p6};
 right1<={2'b0,p2}+{1'b0,p5,1'b0}+{2'b0,p8};
 top1<={2'b0,p0}+{1'b0,p1,1'b0}+{2'b0,p2};
 bottom1<={2'b0,p6}+{1'b0,p7,1'b0}+{2'b0,p8};
 m1<=meta;t1<=threshold;
 gx2<=$signed({1'b0,right1})-$signed({1'b0,left1});
 gy2<=$signed({1'b0,bottom1})-$signed({1'b0,top1});
 m2<=m1;t2<=t1;
 mag3<=ax2+ay2;signs3<=gx2[10]^gy2[10];
 ax256_3<={ax2,8'b0};ay256_3<={ay2,8'b0};
 ax106_3<=ax2*18'd106;ay106_3<=ay2*18'd106;
 m3<=m2;t3<=t2;
 mag<=mag3;edge_pixel<=mag3!=0&&mag3>=t3;out_meta<=m3;
 // tan(22.5 degrees) approximated by the existing exact ratio 106/256.
 if(ay256_3<{1'b0,ax106_3})direction<=0;
 else if(ax256_3<{1'b0,ay106_3})direction<=2;
 else direction<=signs3?3:1;
end
endmodule
