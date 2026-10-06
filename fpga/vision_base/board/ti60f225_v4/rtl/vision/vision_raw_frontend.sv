// Sensor 4PPC RAW8 -> continuous 2PPC ISP rows, no DDR RAW frame store.
// FOV word {x0,x1,x2,x3}: emit MSB16 then LSB16, matching legacy vid_par2ser.
// Half-row prefill absorbs FOV's bubbles; the sensor cannot be backpressured.
module vision_raw_frontend #(parameter W=1920,H=1080,FIFO_AW=9)(
 input rst_n,input_clk,vs,valid,input[31:0]data,
 input isp_clk,output reg out_vs,out_de,output reg[15:0]out_data,
 output reg[31:0]frame_id,output reg frame_bad,
 output reg[31:0]overflow_count
);
 localparam DATA=0,EOL=1,EOF=2,HEADER=3,ABORT=7;
 reg vq=0,taking=0,sv=0;reg[11:0]x=0,y=0;reg[31:0]serial=0;reg[34:0]sd=0;
 wire sr,mv,mr;wire[34:0]md;wire[FIFO_AW:0]level;
 stream_cdc #(.WIDTH(35),.AW(FIFO_AW)) fifo(rst_n,input_clk,sv,sr,sd,isp_clk,mv,mr,md,,level);
 always @(posedge input_clk)begin
  vq<=vs;
  if(!rst_n)begin vq<=0;taking<=0;sv<=0;x<=0;y<=0;serial<=0;sd<=0;overflow_count<=0;end
  else begin
   if(sv&&sr)sv<=0;
   if(vs&&!vq)begin serial<=serial+1'b1;taking<=1;x<=0;y<=0;sv<=1;sd<={3'(HEADER),serial+32'd1};end
   if(taking&&valid)begin
    sv<=1;sd<={(x==W/4-1?(y==H-1?3'(EOF):3'(EOL)):3'(DATA)),data};
    if(x==W/4-1)begin x<=0;y<=y+1'b1;end else x<=x+1'b1;
    if(x==W/4-1&&y==H-1)taking<=0;
   end
   if(sv&&!sr)begin
    if(sd[34:32]!=ABORT)overflow_count<=overflow_count+1'b1;
    sv<=1;sd<={3'(ABORT),32'd0};taking<=0;
   end
  end
 end
 localparam WAIT_LINE=0,FIRST=1,SECOND=2,GAP=3;
 reg[1:0]state=WAIT_LINE,gap=0;reg have_frame=0;reg[15:0]second_pair=0;reg[2:0]kind=0;
 wire metadata=md[34:32]>=HEADER;
 wire start_line=state==WAIT_LINE&&have_frame&&level>=W/8;
 assign mr=state!=SECOND&&(metadata||frame_bad||(!have_frame&&mv)||(state==FIRST)||start_line);
 always @(posedge isp_clk)begin
  out_vs<=0;out_de<=0;
  if(!rst_n)begin state<=WAIT_LINE;gap<=0;have_frame<=0;second_pair<=0;kind<=0;out_data<=0;frame_id<=0;frame_bad<=0;end
  else if(mv&&mr&&metadata)begin
   state<=WAIT_LINE;out_de<=0;
   if(md[34:32]==HEADER)begin have_frame<=1;frame_id<=md[31:0];frame_bad<=0;out_vs<=1;end
   else begin have_frame<=0;frame_bad<=1;end
  end else case(state)
   WAIT_LINE:if(start_line&&mv)begin
    out_data<=md[31:16];out_de<=1;second_pair<=md[15:0];kind<=md[34:32];state<=SECOND;
   end
   FIRST:if(mv)begin out_data<=md[31:16];out_de<=1;second_pair<=md[15:0];kind<=md[34:32];state<=SECOND;end
    else begin frame_bad<=1;have_frame<=0;state<=WAIT_LINE;end
   SECOND:begin out_data<=second_pair;out_de<=1;if(kind==EOL||kind==EOF)begin state<=GAP;gap<=0;end else state<=FIRST;end
   // Existing ISP line-buffer address reset trails DE by two cycles.
   GAP:if(gap==3)begin state<=WAIT_LINE;if(kind==EOF)have_frame<=0;end else gap<=gap+1'b1;
  endcase
 end
endmodule
