// Nine-stage odd/even compare-exchange sorting network, one window/clock.
module vision_median9 #(parameter META=64)(input clk,input[71:0]pixels,input[META-1:0]meta,
 output[7:0]median,output[META-1:0]out_meta);
wire[71:0]v[0:9];wire[META-1:0]m[0:9];assign v[0]=pixels;assign m[0]=meta;
genvar s,k;
generate for(s=0;s<9;s=s+1)begin:stage
 reg[71:0]r=0;reg[META-1:0]mr=0;assign v[s+1]=r;assign m[s+1]=mr;
 always @(posedge clk)mr<=m[s];
 for(k=0;k<9;k=k+1)begin:lane
  if((k%2)==(s%2) && k<8)begin
   always @(posedge clk)r[k*8+:8]<=(v[s][k*8+:8]<v[s][(k+1)*8+:8])?v[s][k*8+:8]:v[s][(k+1)*8+:8];
  end else if(k>0 && ((k-1)%2)==(s%2))begin
   always @(posedge clk)r[k*8+:8]<=(v[s][k*8+:8]>v[s][(k-1)*8+:8])?v[s][k*8+:8]:v[s][(k-1)*8+:8];
  end else always @(posedge clk)r[k*8+:8]<=v[s][k*8+:8];
 end
end endgenerate
assign median=v[9][4*8+:8];assign out_meta=m[9];
endmodule
