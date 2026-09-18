// Read-only sparse RAW probe: one 2x2 Bayer tile every 24x24 source pixels.
// Captures 80x45 tiles from a 1920x1080 two-pixel/clock DDR read stream.
module raw_snapshot #(parameter PAIRS=960,HEIGHT=1080,XS=12,YS=24,COLS=80,ROWS=45)(
 input clk,rst_n,vs,de,input[15:0]pixels,input arm_toggle,
 input read_clk,input[11:0]read_addr,output reg[31:0]read_data,
 output reg[31:0]sequence_id=0,output reg busy=0);
reg[31:0]mem[0:4095];reg[15:0]even_row[0:COLS-1];
reg[2:0]arm_sync=0;reg seen=0,pending=1,vq=0,dq=0;
reg[10:0]x=0,y=0;reg[4:0]xm=0,ym=0;reg[6:0]sx=0,sy=0;
wire start=vs&&!vq;
always @(posedge read_clk)read_data<=mem[read_addr];
always @(posedge clk)begin
 arm_sync<={arm_sync[1:0],arm_toggle};vq<=vs;dq<=de;
 if(!rst_n)begin seen<=0;pending<=1;busy<=0;sequence_id<=0;x<=0;y<=0;xm<=0;ym<=0;sx<=0;sy<=0;vq<=0;dq<=0;end
 else begin
  if(arm_sync[2]!=seen)begin seen<=arm_sync[2];pending<=1;end
  if(start)begin
   if(busy)sequence_id<=sequence_id+1'b1;
   busy<=pending;pending<=0;y<=0;ym<=0;sy<=0;
  end else if(dq&&!de)begin
   y<=y+1'b1;
   if(ym==YS-1)begin ym<=0;sy<=sy+1'b1;end else ym<=ym+1'b1;
  end
  if(de)begin
   x<=x+1'b1;
   if(xm==XS-1)begin xm<=0;sx<=sx+1'b1;end else xm<=xm+1'b1;
   if(busy&&x<PAIRS&&y<HEIGHT&&xm==0&&sx<COLS&&sy<ROWS)begin
    if(ym==0)even_row[sx]<=pixels;
    else if(ym==1)mem[sy*COLS+sx]<={even_row[sx],pixels};
   end
  end else begin x<=0;xm<=0;sx<=0;end
 end
end
endmodule
