// Read-only central ROI sums, held for one frame; default ROI has 65536 pixels.
module rgb_roi_probe #(parameter X0=832,X1=1088,Y0=412,Y1=668)(
 input clk,rst_n,vs,de,input[23:0]rgb,output reg[95:0]sums,output reg[95:0]clips);
reg[11:0]x=0,y=0;reg vq=0,dq=0;
reg[31:0]sr=0,sg=0,sb=0,cr=0,cg=0,cb=0;
always @(posedge clk)begin
 vq<=vs;dq<=de;
 if(!rst_n)begin x<=0;y<=0;vq<=0;dq<=0;sr<=0;sg<=0;sb<=0;cr<=0;cg<=0;cb<=0;sums<=0;clips<=0;end
 else begin
  if(vs&&!vq)begin y<=0;sums<={sr,sg,sb};clips<={cr,cg,cb};sr<=0;sg<=0;sb<=0;cr<=0;cg<=0;cb<=0;end
  else begin
   if(dq&&!de)y<=y+1'b1;
   if(de&&x>=X0&&x<X1&&y>=Y0&&y<Y1)begin
    sr<=sr+rgb[23:16];sg<=sg+rgb[15:8];sb<=sb+rgb[7:0];
    if(rgb[23:16]>=250)cr<=cr+1'b1;
    if(rgb[15:8]>=250)cg<=cg+1'b1;
    if(rgb[7:0]>=250)cb<=cb+1'b1;
   end
  end
  if(de)x<=x+1'b1;else x<=0;
 end
end
endmodule
