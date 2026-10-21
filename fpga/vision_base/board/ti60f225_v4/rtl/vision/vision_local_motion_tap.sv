// Tap already-aligned gray/fde/fx/fy. Fixed 8x8 sample mean per coarse tile.
// Default board use is observational: no capture/display gating is performed.
module vision_local_motion_tap #(
 parameter WIDTH=1920,HEIGHT=1080,COLS=12,ROWS=12,
 parameter TW=WIDTH/COLS,TH=HEIGHT/ROWS,PADX=(WIDTH*6+95)/96,PADY=(HEIGHT*6+95)/96
)(input clk,rst_n,input de,vs,input[11:0]x,y,input[7:0]gray,input config_bit,
 output reg[31:0]observation_id,output reg[31:0]status,
 output reg signed[31:0]horizontal_response,vertical_response,
 output reg[11:0]roi_x0,roi_y0,roi_x1,roi_y1,
 output reg[15:0]active_sites,output reg[31:0]dropped_frames);
reg vq,blocked,abort_core,was_bad,config_previous;
reg[11:0]local_x,local_y,scan_x,scan_y;reg[$clog2(COLS+1)-1:0]tile_x;reg[$clog2(ROWS+1)-1:0]tile_y;
reg[COLS*14-1:0]sums;reg[13:0]stored_sum;integer si;
reg[7:0]word;reg word_valid,word_first,word_last,word_reset;
reg pending,pending_temporal,pending_roi;reg[2:0]pending_direction;
reg signed[31:0]pending_hx,pending_vy;reg[15:0]pending_active;
reg[$clog2(COLS+1)-1:0]pending_x0,pending_x1;
reg[$clog2(ROWS+1)-1:0]pending_y0,pending_y1;
reg request_valid;wire policy_valid;wire[1:0]policy_task;
wire core_ready,core_valid,core_temporal,core_roi,core_fault;wire[2:0]core_direction;
wire signed[31:0]hx,vy;wire[15:0]core_active;
wire[$clog2(COLS+1)-1:0]bx0,bx1;wire[$clog2(ROWS+1)-1:0]by0,by1;
integer k;reg sample_x,sample_y;
always @*begin
 sample_x=0;sample_y=0;
 for(k=0;k<8;k=k+1)begin
  if(local_x==((2*k+1)*TW)/16)sample_x=1;
  if(local_y==((2*k+1)*TH)/16)sample_y=1;
 end
end
wire first_sample=local_x==TW/16&&local_y==TH/16;
wire last_sample=local_x==(15*TW)/16&&local_y==(15*TH)/16;
always @*begin stored_sum=0;for(si=0;si<COLS;si=si+1)if(tile_x==si)stored_sum=sums[si*14+:14];end
wire[13:0]sample_sum=first_sample?{6'd0,gray}:(stored_sum+{6'd0,gray});
wire sample_write=de&&!blocked&&x==scan_x&&y==scan_y&&x<WIDTH&&y<HEIGHT&&sample_x&&sample_y;
genvar sj;generate for(sj=0;sj<COLS;sj=sj+1)begin:pool_registers
 always @(posedge clk)if(rst_n&&sample_write&&tile_x==sj)sums[sj*14+:14]<=sample_sum;
end endgenerate
vision_local_motion_core #(.COLS(COLS),.ROWS(ROWS))core(
 .clk(clk),.rst_n(rst_n),.abort_frame(abort_core),.in_valid(word_valid),.in_ready(core_ready),
 .in_first(word_first),.in_last(word_last),.reset_history(word_reset),.in_gray(word),
 .out_valid(core_valid),.out_ready(1'b1),.temporal_valid(core_temporal),.direction(core_direction),
 .horizontal_response(hx),.vertical_response(vy),.active_sites(core_active),.roi_valid(core_roi),
 .roi_x0(bx0),.roi_y0(by0),.roi_x1(bx1),.roi_y1(by1),.fault(core_fault));
// Existing DDR identity is asynchronous here; keep live requests FULL.
vision_motion_policy #(.WIDTH(WIDTH),.HEIGHT(HEIGHT))policy(
 .clk(clk),.rst_n(rst_n),.in_valid(request_valid),.in_ready(),.source_verified(1'b0),
 .frame_id(observation_id),.timestamp_us(32'd0),.config_id({15'd0,config_previous}),
 .temporal_valid(status[1]),.roi_valid(status[2]),.x0(roi_x0),.y0(roi_y0),.x1(roi_x1),.y1(roi_y1),
 .out_valid(policy_valid),.out_ready(1'b1),.task_code(policy_task),.out_frame_id(),
 .out_x0(),.out_y0(),.out_x1(),.out_y1(),.metadata_fault());
// Explicit shift/add coordinate scaling avoids consuming DSPs for constants.
function automatic[15:0]scale(input[15:0]value,input integer factor);
 integer bit_index;begin scale=0;for(bit_index=0;bit_index<12;bit_index=bit_index+1)if((factor>>bit_index)&1)scale=scale+(value<<bit_index);end
endfunction
localparam[15:0]PX=PADX,PY=PADY,W=WIDTH,H=HEIGHT;
wire[15:0]px0=scale(pending_x0,TW),py0=scale(pending_y0,TH),px1=scale(pending_x1,TW)+PX,py1=scale(pending_y1,TH)+PY;
wire[15:0]clamp_x0=px0>PX?px0-PX:16'd0,clamp_y0=py0>PY?py0-PY:16'd0,clamp_x1=px1>W?W:px1,clamp_y1=py1>H?H:py1;
always @(posedge clk)begin
 vq<=vs;word_valid<=0;abort_core<=0;request_valid<=0;
 if(!rst_n)begin
  vq<=0;blocked<=1;abort_core<=0;was_bad<=1;config_previous<=0;
  local_x<=0;local_y<=0;scan_x<=0;scan_y<=0;tile_x<=0;tile_y<=0;
  word<=0;word_first<=0;word_last<=0;word_reset<=1;
  observation_id<=0;status<=0;horizontal_response<=0;vertical_response<=0;
  roi_x0<=0;roi_y0<=0;roi_x1<=0;roi_y1<=0;active_sites<=0;dropped_frames<=0;
  pending<=0;request_valid<=0;
 end else begin
  if(vs&&!vq)begin
   if(!blocked)begin
    if(scan_y!=HEIGHT||scan_x!=0||!pending)begin dropped_frames<=dropped_frames+1'b1;abort_core<=1;was_bad<=1;status[2:0]<=0;end
    else begin
     observation_id<=observation_id+1'b1;request_valid<=1;
     status<={22'd0,2'd2,1'b0,core_fault,pending_direction,pending_roi,pending_temporal,1'b1};
     horizontal_response<=pending_hx;vertical_response<=pending_vy;active_sites<=pending_active;
     roi_x0<=pending_roi?clamp_x0[11:0]:0;roi_y0<=pending_roi?clamp_y0[11:0]:0;
     roi_x1<=pending_roi?clamp_x1[11:0]:0;roi_y1<=pending_roi?clamp_y1[11:0]:0;
    end
   end
   pending<=0;
   blocked<=0;local_x<=0;local_y<=0;scan_x<=0;scan_y<=0;tile_x<=0;tile_y<=0;
   if(config_bit!=config_previous)begin was_bad<=1;abort_core<=1;end
   config_previous<=config_bit;
  end
  if(word_valid&&!core_ready&&!blocked)begin blocked<=1;abort_core<=1;was_bad<=1;dropped_frames<=dropped_frames+1'b1;status[2:0]<=0;end
  if(de&&!blocked)begin
   if(x!=scan_x||y!=scan_y||x>=WIDTH||y>=HEIGHT)begin blocked<=1;abort_core<=1;was_bad<=1;dropped_frames<=dropped_frames+1'b1;status[2:0]<=0;end
   else begin
    if(sample_x&&sample_y)begin
     if(last_sample)begin
      word_valid<=1;word<=sample_sum[13:6];word_first<=tile_x==0&&tile_y==0;
      word_last<=tile_x==COLS-1&&tile_y==ROWS-1;
      if(tile_x==0&&tile_y==0)begin word_reset<=was_bad;was_bad<=0;end
     end
    end
    if(x==WIDTH-1)begin
     scan_x<=0;scan_y<=scan_y+1'b1;local_x<=0;tile_x<=0;
     if(local_y==TH-1)begin local_y<=0;tile_y<=tile_y+1'b1;end else local_y<=local_y+1'b1;
    end else begin
     scan_x<=scan_x+1'b1;
     if(local_x==TW-1)begin local_x<=0;tile_x<=tile_x+1'b1;end else local_x<=local_x+1'b1;
    end
   end
  end
  if(core_valid&&!blocked&&!(vs&&!vq))begin
   pending<=1;pending_temporal<=core_temporal;pending_roi<=core_roi;pending_direction<=core_direction;
   pending_hx<=hx;pending_vy<=vy;pending_active<=core_active;
   pending_x0<=bx0;pending_y0<=by0;pending_x1<=bx1;pending_y1<=by1;
  end
  if(policy_valid)status[9:8]<=policy_task;
 end
end
endmodule
