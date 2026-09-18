// Publish a frame only after all expected W beats AND all B acknowledgements.
module vision_write_commit(input clk,rst_n,frame_start,input[31:0]expected_beats,
 input aw_fire,w_fire,b_fire,input[1:0]bresp,output reg done=0,output reg[31:0]errors=0);
reg[1:0]fs=0;reg fsq=0;reg[31:0]words=0,expected=0;reg[15:0]pending=0;reg active=0,bad=0;
always @(posedge clk)begin
 fs<={fs[0],frame_start};fsq<=fs[1];done<=0;
 if(!rst_n)begin words<=0;expected<=0;pending<=0;active<=0;bad<=0;errors<=0;fs<=0;fsq<=0;end
 else if(fs[1]&&!fsq)begin
  if(active&&expected!=0)errors<=errors+1;
  words<=0;pending<=0;expected<=expected_beats;active<=expected_beats!=0;bad<=0;
 end else begin
  if(aw_fire&&!b_fire)pending<=pending+1'b1;else if(b_fire&&!aw_fire)begin if(pending!=0)pending<=pending-1'b1;else bad<=1;end
  if(w_fire)words<=words+1'b1;
  if(b_fire&&bresp!=0)bad<=1;
  if(active&&words==expected&&pending==0&&!aw_fire)begin
   active<=0;if(!bad)done<=1;else errors<=errors+1;
  end
 end
end
endmodule
