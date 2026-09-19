module vision_sobel #(parameter META=1)(input clk,input[71:0]w,input[META-1:0]meta,
 output reg[10:0]mag,output reg[1:0]direction,output reg[META-1:0]out_meta);
wire[7:0]p0=w[71:64],p1=w[63:56],p2=w[55:48],p3=w[47:40],p4=w[39:32],p5=w[31:24],p6=w[23:16],p7=w[15:8],p8=w[7:0];
wire signed[11:0]gx=$signed({4'b0,p2})+($signed({4'b0,p5})<<<1)+$signed({4'b0,p8})-$signed({4'b0,p0})-($signed({4'b0,p3})<<<1)-$signed({4'b0,p6});
wire signed[11:0]gy=$signed({4'b0,p6})+($signed({4'b0,p7})<<<1)+$signed({4'b0,p8})-$signed({4'b0,p0})-($signed({4'b0,p1})<<<1)-$signed({4'b0,p2});
wire[11:0]ax=gx[11]?-gx:gx,ay=gy[11]?-gy:gy;
reg[11:0]ax1=0,ay1=0;reg signs=0;reg[META-1:0]m1=0;
always @(posedge clk)begin
 ax1<=ax;ay1<=ay;signs<=gx[11]^gy[11];m1<=meta;
 mag<=ax1+ay1;out_meta<=m1;
 // tan22.5 approx 106/256, using shift/add constant multipliers.
 if({ay1,8'b0}<ax1*20'd106)direction<=0;
 else if({ax1,8'b0}<ay1*20'd106)direction<=2;
 else direction<=signs?3:1;
end
endmodule
