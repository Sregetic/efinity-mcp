// Seven comparison layers plus two delays keep nine-cycle pixel/meta alignment.
module vision_median9 #(parameter META=64)(input clk,input[71:0]pixels,input[META-1:0]meta,
 output[7:0]median,output[META-1:0]out_meta);
wire[71:0]v[0:9];wire[META-1:0]m[0:9];assign v[0]=pixels;assign m[0]=meta;
function automatic[15:0]ordered(input[7:0]a,b);
 begin ordered=a<b?{b,a}:{a,b};end
endfunction
genvar s;
generate for(s=0;s<9;s=s+1)begin:stage
 reg[71:0]r=0;reg[META-1:0]mr=0;assign v[s+1]=r;assign m[s+1]=mr;
 always @(posedge clk)begin
  r<=v[s];mr<=m[s];
  case(s)
   0:begin
    {r[7*8+:8],r[0*8+:8]}<=ordered(v[s][0*8+:8],v[s][7*8+:8]);
    {r[2*8+:8],r[1*8+:8]}<=ordered(v[s][1*8+:8],v[s][2*8+:8]);
    {r[5*8+:8],r[3*8+:8]}<=ordered(v[s][3*8+:8],v[s][5*8+:8]);
    {r[8*8+:8],r[4*8+:8]}<=ordered(v[s][4*8+:8],v[s][8*8+:8]);
   end
   1:begin
    {r[2*8+:8],r[0*8+:8]}<=ordered(v[s][0*8+:8],v[s][2*8+:8]);
    {r[5*8+:8],r[1*8+:8]}<=ordered(v[s][1*8+:8],v[s][5*8+:8]);
    {r[8*8+:8],r[3*8+:8]}<=ordered(v[s][3*8+:8],v[s][8*8+:8]);
    {r[7*8+:8],r[4*8+:8]}<=ordered(v[s][4*8+:8],v[s][7*8+:8]);
   end
   2:begin
    {r[3*8+:8],r[0*8+:8]}<=ordered(v[s][0*8+:8],v[s][3*8+:8]);
    {r[4*8+:8],r[1*8+:8]}<=ordered(v[s][1*8+:8],v[s][4*8+:8]);
    {r[8*8+:8],r[2*8+:8]}<=ordered(v[s][2*8+:8],v[s][8*8+:8]);
    {r[7*8+:8],r[5*8+:8]}<=ordered(v[s][5*8+:8],v[s][7*8+:8]);
   end
   3:begin
    {r[4*8+:8],r[3*8+:8]}<=ordered(v[s][3*8+:8],v[s][4*8+:8]);
    {r[6*8+:8],r[5*8+:8]}<=ordered(v[s][5*8+:8],v[s][6*8+:8]);
   end
   4:begin
    {r[5*8+:8],r[2*8+:8]}<=ordered(v[s][2*8+:8],v[s][5*8+:8]);
    {r[6*8+:8],r[4*8+:8]}<=ordered(v[s][4*8+:8],v[s][6*8+:8]);
   end
   5:begin
    {r[3*8+:8],r[2*8+:8]}<=ordered(v[s][2*8+:8],v[s][3*8+:8]);
    {r[5*8+:8],r[4*8+:8]}<=ordered(v[s][4*8+:8],v[s][5*8+:8]);
   end
   6:{r[4*8+:8],r[3*8+:8]}<=ordered(v[s][3*8+:8],v[s][4*8+:8]);
  endcase
 end
end endgenerate
assign median=v[9][4*8+:8];assign out_meta=m[9];
endmodule
