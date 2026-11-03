// One RGB888 line from a repeatedly scanned frozen source, read in bulk via USER2.
// The host holds the source/parameters and Canny plane while assembling all rows.
module vision_line_snapshot #(parameter W=1920,H=1080,AW=$clog2(W))(
 input clk,rst_n,request_toggle,input[10:0]request_row,input request_source,
 input source_vs,source_de,input[23:0]source_rgb,
 input display_vs,display_de,input[23:0]display_rgb,
 input[31:0]frame_id,config_id,input[2:0]mode,input[10:0]threshold,input median,input[1:0]tone,
 output[31:0]status,output reg[31:0]sequence_id,captured_frame,captured_config,
 input read_clk,bulk_capture,bulk_shift,output payload_phase,payload_tdo
);
 localparam IDLE=0,WAIT_VS=1,WAIT_ROW=2,TAKE=3;
 reg[1:0]state=IDLE;reg[2:0]req_sync=0;reg seen=0,source=0,vq=0,dq=0;
 reg ready=0,busy=0,error=0;reg[10:0]row=0,y=0;reg[AW:0]x=0;
 reg captured_source=0,captured_median=0;reg[2:0]captured_mode=0;
 reg[10:0]captured_threshold=0;reg[1:0]captured_tone=0;
 wire vs=source?source_vs:display_vs,de=source?source_de:display_de;
 wire[23:0]rgb=source?source_rgb:display_rgb;
 reg[23:0]memory[0:(1<<AW)-1];
 wire write_line=de&&x<W&&((state==WAIT_ROW&&y==row)||state==TAKE);
 always @(posedge clk)if(write_line)memory[x[AW-1:0]]<=rgb;
 assign status={ready,busy,error,captured_source,captured_mode,captured_threshold,captured_median,captured_tone,row};
 always @(posedge clk)begin
  req_sync<={req_sync[1:0],request_toggle};vq<=vs;dq<=de;
  if(!rst_n)begin
   state<=IDLE;req_sync<=0;seen<=0;source<=0;vq<=0;dq<=0;
   ready<=0;busy<=0;error<=0;row<=0;x<=0;y<=0;sequence_id<=0;
   captured_source<=0;captured_mode<=0;captured_threshold<=0;captured_median<=0;captured_tone<=0;
   captured_frame<=0;captured_config<=0;
  end else if(req_sync[2]!=seen)begin
   seen<=req_sync[2];row<=request_row;source<=request_source;ready<=0;busy<=1;error<=0;state<=WAIT_VS;
   if(request_row>=H)begin busy<=0;error<=1;sequence_id<=sequence_id+1'b1;state<=IDLE;end
  end else begin
   if(state==WAIT_VS&&vs&&!vq)begin x<=0;y<=0;state<=WAIT_ROW;end
   if(state==WAIT_ROW||state==TAKE)begin
    if(de)x<=x+1'b1;else begin x<=0;if(dq)y<=y+1'b1;end
   end
   if(state==WAIT_ROW)begin
    if(vs&&!vq)begin busy<=0;error<=1;sequence_id<=sequence_id+1'b1;state<=IDLE;end
    else if(de&&y==row&&x==0)begin
     state<=TAKE;captured_source<=source;captured_mode<=mode;captured_threshold<=threshold;
     captured_median<=median;captured_tone<=tone;captured_frame<=frame_id;captured_config<=config_id;
    end
   end
   if(state==TAKE&&!de)begin
    ready<=x==W;error<=x!=W;busy<=0;sequence_id<=sequence_id+1'b1;state<=IDLE;
   end
  end
 end
 // Normal status/command scans prime address0. CAPTURE then prefetches pixel1;
 // every pixel has24 SHIFT clocks, so the synchronous RAM is ready well ahead.
 reg[AW-1:0]read_addr=0;reg[23:0]ram_q=0,shift_pixel=0;
 reg[7:0]header_remaining=0;reg[4:0]bit_index=0;
 assign payload_phase=header_remaining==0,payload_tdo=shift_pixel[0];
 always @(posedge read_clk)begin
  ram_q<=memory[read_addr];
  if(!rst_n)begin read_addr<=0;shift_pixel<=0;header_remaining<=0;bit_index<=0;end
  else if(bulk_capture)begin read_addr<=1;shift_pixel<=ram_q;header_remaining<=192;bit_index<=0;end
  else if(bulk_shift)begin
   if(header_remaining!=0)header_remaining<=header_remaining-1'b1;
   else if(bit_index==23)begin shift_pixel<=ram_q;read_addr<=read_addr+1'b1;bit_index<=0;end
   else begin shift_pixel<={1'b0,shift_pixel[23:1]};bit_index<=bit_index+1'b1;end
  end else read_addr<=0;
 end
endmodule
