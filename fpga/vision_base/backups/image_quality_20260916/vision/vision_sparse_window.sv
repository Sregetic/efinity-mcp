// Sparse-valid window: coordinates accompany pixels; gaps do not advance state.
module vision_sparse_window #(parameter W=240,BPP=8)(input clk,rst_n,valid,input[7:0]x,y,input[BPP-1:0]data,
 output reg oval,output reg[7:0]ox,oy,output reg[9*BPP-1:0]window);
reg[BPP-1:0]l1[0:W-1],l2[0:W-1];reg[BPP-1:0]q1,q2,p,t0,t1,m0,m1,b0,b1;
reg d=0;reg[7:0]xx=0,yy=0;
always @(posedge clk)begin
 if(valid)begin q1<=l1[x];q2<=l2[x];l1[x]<=data;l2[x]<=l1[x];p<=data;xx<=x;yy<=y;end
 d<=valid;oval<=d;ox<=xx;oy<=yy;
 if(!rst_n)begin d<=0;oval<=0;end
 if(d)begin
  if(xx==0)begin t0<=0;t1<=q2;m0<=0;m1<=q1;b0<=0;b1<=p;end
  else begin t0<=t1;t1<=q2;m0<=m1;m1<=q1;b0<=b1;b1<=p;end
  window<={t0,t1,q2,m0,m1,q1,b0,b1,p};
 end
end
endmodule
