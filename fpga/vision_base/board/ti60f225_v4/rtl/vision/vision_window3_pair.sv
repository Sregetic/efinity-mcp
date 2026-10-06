// Two adjacent grayscale pixels/clock; two previous rows, no frame memory.
// Pair0/1 reproduce consecutive scalar3x3 windows, including odd/even columns.
module vision_window3_pair #(parameter WIDTH=1920)(
 input clk,rst_n,de,hs,vs,input[15:0]pixels,
 output reg ode,ohs,ovs,border,output reg[11:0]ox,oy,
 output reg[71:0]window0,window1);
 reg[15:0]line1[0:WIDTH/2-1],line2[0:WIDTH/2-1];
 reg[15:0]q1,q2,pair_q,top_previous,middle_previous,bottom_previous;
 reg[11:0]group_x=0,row_y=0,xq=0,yq=0;reg dq=0,hq=0,vq=0,previous_de=0,previous_vs=0;
 always @(posedge clk)begin
  if(de)begin q1<=line1[group_x];q2<=line2[group_x];line1[group_x]<=pixels;line2[group_x]<=line1[group_x];end
  pair_q<=pixels;dq<=de;hq<=hs;vq<=vs;xq<=group_x;yq<=row_y;
  previous_de<=de;previous_vs<=vs;
  if(!rst_n)begin group_x<=0;row_y<=0;dq<=0;hq<=0;vq<=0;previous_de<=0;previous_vs<=0;ode<=0;ohs<=0;ovs<=0;border<=1;ox<=0;oy<=0;end
  else begin
   if(vs&&!previous_vs)row_y<=0;else if(previous_de&&!de)row_y<=row_y+1'b1;
   if(de)group_x<=group_x+1'b1;else group_x<=0;
   ode<=dq;ohs<=hq;ovs<=vq;ox<=xq<<1;oy<=yq;border<=xq<1||yq<2;
   if(dq)begin
    window0<={(xq==0?16'd0:top_previous),q2[7:0],(xq==0?16'd0:middle_previous),q1[7:0],(xq==0?16'd0:bottom_previous),pair_q[7:0]};
    window1<={(xq==0?8'd0:top_previous[7:0]),q2[7:0],q2[15:8],(xq==0?8'd0:middle_previous[7:0]),q1[7:0],q1[15:8],(xq==0?8'd0:bottom_previous[7:0]),pair_q[7:0],pair_q[15:8]};
    // Previous pair is low=earlier pixel; window rows are MSB=earlier column.
    top_previous<={q2[7:0],q2[15:8]};middle_previous<={q1[7:0],q1[15:8]};bottom_previous<={pair_q[7:0],pair_q[15:8]};
   end
  end
 end
endmodule
