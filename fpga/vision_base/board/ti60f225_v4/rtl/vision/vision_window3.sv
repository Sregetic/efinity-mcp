// Same-clock streaming 3x3 window. Output represents center(x-1,y-1).
// The top/left two scan positions are marked border; all timing is delayed2 clocks.
module vision_window3 #(parameter WIDTH=1920,parameter BPP=8)(
 input clk,rst_n,de,hs,vs,input[BPP-1:0]pixel,
 output reg ode,ohs,ovs,output reg border,
 output reg[11:0]ox,oy,output reg[9*BPP-1:0]window);
reg[BPP-1:0]line1[0:WIDTH-1],line2[0:WIDTH-1];
reg[BPP-1:0]q1,q2,p0,t0,t1,m0,m1,b0,b1;
reg[11:0]x=0,y=0,x1=0,y1=0;reg dq=0,hq=0,vq=0,prev_de=0,prev_vs=0;
always @(posedge clk)begin
 if(de)begin q1<=line1[x];q2<=line2[x];line1[x]<=pixel;line2[x]<=line1[x];end
 p0<=pixel;dq<=de;hq<=hs;vq<=vs;x1<=x;y1<=y;prev_de<=de;prev_vs<=vs;
 if(!rst_n)begin x<=0;y<=0;dq<=0;vq<=0;hq<=0;ode<=0;ohs<=0;ovs<=0;prev_de<=0;prev_vs<=0;end
 else begin
  if(vs&&!prev_vs)y<=0;else if(prev_de&&!de)y<=y+1'b1;
  if(de)x<=x+1'b1;else x<=0;
  ode<=dq;ohs<=hq;ovs<=vq;ox<=x1;oy<=y1;border<=x1<2||y1<2;
  if(dq)begin
   if(x1==0)begin t0<=0;t1<=q2;m0<=0;m1<=q1;b0<=0;b1<=p0;end
   else begin t0<=t1;t1<=q2;m0<=m1;m1<=q1;b0<=b1;b1<=p0;end
   window<={t0,t1,q2,m0,m1,q1,b0,b1,p0};
  end
 end
end
endmodule
