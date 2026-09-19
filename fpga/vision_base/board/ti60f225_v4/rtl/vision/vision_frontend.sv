module vision_frontend #(parameter WIDTH=1920)(input clk,rst_n,de,hs,vs,input[7:0]r,g,b,input median_en,
 output fde,fhs,fvs,output fborder,output[11:0]fx,fy,output[7:0]fr,fg,fb,gray,
 output[10:0]magnitude,output[1:0]direction,input[10:0]threshold,output edge_pixel);
reg[15:0]luma_sum=0;reg[23:0]rgb1=0;reg d1=0,h1=0,v1=0;
always @(posedge clk)begin
 luma_sum<=r*16'd77+g*16'd150+b*16'd29+16'd128;rgb1<={r,g,b};d1<=de;h1<=hs;v1<=vs;
 if(!rst_n)begin d1<=0;h1<=0;v1<=0;end
end
wire wd,wh,wv,wb;wire[11:0]wx,wy;wire[287:0]w;
vision_window3 #(.WIDTH(WIDTH),.BPP(32)) win1(clk,rst_n,d1,h1,v1,{rgb1,luma_sum[15:8]},wd,wh,wv,wb,wx,wy,w);
wire[71:0]wg;genvar k;generate for(k=0;k<9;k=k+1)begin:extract assign wg[k*8+:8]=w[k*32+:8];end endgenerate
wire[7:0]median;wire[59:0]mm;
vision_median9 #(.META(60)) med9(clk,wg,{wx,wy,wb,w[4*32+:32],wd,wh,wv},median,mm);
wire[31:0]mp={mm[34:11],((median_en && !mm[35])?median:mm[10:3])};
wire sd,sh,sv,sb;wire[11:0]sx,sy;wire[287:0]sw;
vision_window3 #(.WIDTH(WIDTH),.BPP(32)) win2(clk,rst_n,mm[2],mm[1],mm[0],mp,sd,sh,sv,sb,sx,sy,sw);
wire[71:0]sg;generate for(k=0;k<9;k=k+1)begin:extract2 assign sg[k*8+:8]=sw[k*32+:8];end endgenerate
wire[59:0]sm;
vision_sobel #(.META(60)) sobel(clk,sg,{sx,sy,sb,sw[4*32+:32],sd,sh,sv},magnitude,direction,sm,threshold,edge_pixel);
assign {fx,fy,fborder,fr,fg,fb,gray,fde,fhs,fvs}=sm;
endmodule
