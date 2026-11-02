// HQ12 RGB pixels -> full 2PPC rows in the existing stable ISP clock domain.
// The FIFO holds one row, not a video frame; source loss aborts the old capture.
module vision_hdmi_frontend #(parameter W=1920,H=1080,FIFO_AW=10)(
 input rst_n,input_clk,input_locked,input_valid,vs,de,input[23:0]rgb,
 input isp_clk,output reg out_vs,out_de,output reg[47:0]pixels,
 output reg[31:0]frame_id,output reg frame_bad,
 output reg[31:0]overflow_count
);
 initial begin out_vs=0;out_de=0;pixels=0;frame_id=0;frame_bad=1;overflow_count=0;end
 localparam DATA=0,EOL=1,EOF=2,HEADER=3,ABORT=7;
 reg vq=0,dq=0,taking=0,phase=0,sv=0,abort_toggle=0;
 reg[11:0]x=0,y=0,line_pixels=0;reg[31:0]serial=0;reg[23:0]left=0;
 reg[50:0]sd=0;wire[50:0]md;wire sr,mv,mr;wire[FIFO_AW:0]level;
 stream_cdc #(.WIDTH(51),.AW(FIFO_AW)) fifo(rst_n&&input_locked,input_clk,sv,sr,sd,isp_clk,mv,mr,md,,level);
 always @(posedge input_clk)begin
  vq<=vs;dq<=de;
  if(!rst_n)begin vq<=0;dq<=0;taking<=0;phase<=0;sv<=0;abort_toggle<=0;x<=0;y<=0;line_pixels<=0;serial<=0;left<=0;sd<=0;overflow_count<=0;end
  else if(!input_valid)begin
   if(taking)abort_toggle<=!abort_toggle;
   taking<=0;phase<=0;sv<=0;x<=0;y<=0;line_pixels<=0;
  end else begin
   if(sv&&sr)sv<=0;
   if(vs&&!vq)begin
    if(taking)abort_toggle<=!abort_toggle;
    serial<=serial+1'b1;taking<=1;phase<=0;x<=0;y<=0;line_pixels<=0;
    sv<=1;sd<={3'(HEADER),16'd0,serial+32'd1};
   end
   if(taking&&de)begin
    line_pixels<=line_pixels+1'b1;
    if(!phase)begin left<=rgb;phase<=1;end
    else begin
     sv<=1;sd<={(x==W-1?(y==H-1?3'(EOF):3'(EOL)):3'(DATA)),rgb,left};phase<=0;
    end
    if(x==W-1)begin x<=0;y<=y+1'b1;end else x<=x+1'b1;
    if(x==W-1&&y==H-1)taking<=0;
   end
   if(dq&&!de)begin
    line_pixels<=0;
    if(taking&&line_pixels!=W)begin taking<=0;sv<=1;sd<={3'(ABORT),48'd0};abort_toggle<=!abort_toggle;end
   end
   if(sv&&!sr)begin
    if(sd[50:48]!=ABORT)begin overflow_count<=overflow_count+1'b1;abort_toggle<=!abort_toggle;end
    sv<=1;sd<={3'(ABORT),48'd0};taking<=0;
   end
  end
 end
 (* async_reg="true" *)reg[2:0]lock_s=0,abort_s=0;
 reg abort_seen=0,have_frame=0;reg[1:0]state=0,gap=0;reg last_row=0;
 wire metadata=md[50:48]>=HEADER;
 wire start_line=state==0&&have_frame&&level>=W/2;
 assign mr=metadata||frame_bad||(!have_frame&&mv)||state==1||start_line;
 always @(posedge isp_clk)begin
  lock_s<={lock_s[1:0],input_locked};abort_s<={abort_s[1:0],abort_toggle};abort_seen<=abort_s[2];
  out_vs<=0;out_de<=0;
  if(!rst_n)begin lock_s<=0;abort_s<=0;abort_seen<=0;state<=0;gap<=0;have_frame<=0;pixels<=0;frame_id<=0;frame_bad<=1;last_row<=0;end
  else if(!lock_s[2]||abort_seen!=abort_s[2])begin frame_bad<=1;have_frame<=0;state<=0;end
  else if(mv&&mr&&metadata)begin
   state<=0;
   if(md[50:48]==HEADER)begin have_frame<=1;frame_id<=md[31:0];frame_bad<=0;out_vs<=1;end
   else begin have_frame<=0;frame_bad<=1;end
  end else if(!frame_bad)case(state)
   0,1:if(mv&&(state==1||start_line))begin
    pixels<=md[47:0];out_de<=1;state<=1;
    if(md[50:48]==EOL||md[50:48]==EOF)begin state<=2;gap<=0;last_row<=md[50:48]==EOF;end
   end else if(state==1)begin frame_bad<=1;have_frame<=0;state<=0;end
   2:if(gap==3)begin state<=0;if(last_row)have_frame<=0;end else gap<=gap+1'b1;
  endcase
 end
endmodule
