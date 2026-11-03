// Camera-domain2PPC grayscale/median/Sobel branch before DDR.
// Four rolling grayscale rows; no DDR transaction or whole-frame wait.
module vision_line_direct #(parameter WIDTH=1920)(
 input clk,rst_n,de,hs,vs,input[15:0]pixels,input median_en,input[10:0]threshold,
 output ode,ohs,ovs,output[11:0]x,y,output[15:0]gray,output[1:0]edges,
 output[21:0]magnitudes);
 reg vq=0,median_q=0;reg[10:0]threshold_q=128;
 always @(posedge clk)begin
  vq<=vs;if(!rst_n)begin vq<=0;median_q<=0;threshold_q<=128;end
  else if(vs&&!vq)begin median_q<=median_en;threshold_q<=threshold;end
 end
 wire wd,wh,wv,wb;wire[11:0]wx,wy;wire[71:0]w0,w1;
 vision_window3_pair #(.WIDTH(WIDTH)) first_window(clk,rst_n,de,hs,vs,pixels,wd,wh,wv,wb,wx,wy,w0,w1);
 wire[7:0]median0,median1;wire[35:0]m0,m1;
 vision_median9 #(.META(36)) med0(clk,w0,{wx,wy,wb,w0[39:32],wd,wh,wv},median0,m0);
 vision_median9 #(.META(36)) med1(clk,w1,{wx+12'd1,wy,wb,w1[39:32],wd,wh,wv},median1,m1);
 wire filter=median_q&&!m0[11];
 wire[15:0]filtered={filter?median1:m1[10:3],filter?median0:m0[10:3]};
 wire sd,sh,sv,sb;wire[11:0]sx,sy;wire[71:0]s0,s1;
 vision_window3_pair #(.WIDTH(WIDTH)) second_window(clk,rst_n,m0[2],m0[1],m0[0],filtered,sd,sh,sv,sb,sx,sy,s0,s1);
 wire[35:0]a0,a1;wire e0,e1;wire[1:0]direction0,direction1;
 vision_sobel #(.META(36)) grad0(clk,s0,{sx,sy,sb,s0[39:32],sd,sh,sv},magnitudes[10:0],direction0,a0,threshold_q,e0);
 vision_sobel #(.META(36)) grad1(clk,s1,{sx+12'd1,sy,sb,s1[39:32],sd,sh,sv},magnitudes[21:11],direction1,a1,threshold_q,e1);
 assign {x,y}=a0[35:12];assign {ode,ohs,ovs}=a0[2:0];
 wire border=a0[11]||x<4||y<4;
 assign gray=border?16'd0:{a1[10:3],a0[10:3]},edges=border?2'd0:{e1,e0};
endmodule
