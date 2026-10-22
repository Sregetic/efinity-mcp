// Same-clock request policy. A request is NOT a completed image-processing job.
// Unverified source identity always asks for FULL: display refresh != camera ID.
module vision_motion_policy #(parameter WIDTH=96,HEIGHT=96)(input clk,rst_n,
 input in_valid,output in_ready,input source_verified,input[31:0]frame_id,timestamp_us,
 input[15:0]config_id,input temporal_valid,roi_valid,input[11:0]x0,y0,x1,y1,
 output reg out_valid,input out_ready,output reg[1:0]task_code,
 output reg[31:0]out_frame_id,output reg[11:0]out_x0,out_y0,out_x1,out_y1,
 output reg metadata_fault);
reg seen;reg[31:0]last_id,last_time,last_full;reg[15:0]last_config;
wire[31:0]id_delta=frame_id-last_id,time_delta=timestamp_us-last_time,since_full=timestamp_us-last_full;
wire stale=seen&&(id_delta==0||id_delta[31]||time_delta==0||time_delta[31]);
wire bad_roi=roi_valid&&(x0>=x1||y0>=y1||x1>WIDTH||y1>HEIGHT);
wire force_full=!source_verified||!seen||!temporal_valid||config_id!=last_config||id_delta!=1||since_full>=100000||stale||bad_roi;
assign in_ready=!out_valid||out_ready;
always @(posedge clk)begin
 if(!rst_n)begin seen<=0;out_valid<=0;task_code<=2;metadata_fault<=0;last_id<=0;last_time<=0;last_full<=0;last_config<=0;out_frame_id<=0;out_x0<=0;out_y0<=0;out_x1<=0;out_y1<=0;end
 else begin
  if(out_valid&&out_ready)out_valid<=0;
  if(in_valid&&in_ready)begin
   out_valid<=1;out_frame_id<=frame_id;
   task_code<=force_full?2:(roi_valid?1:0);
   out_x0<=force_full?0:(roi_valid?x0:0);out_y0<=force_full?0:(roi_valid?y0:0);
   out_x1<=force_full?WIDTH:(roi_valid?x1:0);out_y1<=force_full?HEIGHT:(roi_valid?y1:0);
   if((stale&&source_verified)||bad_roi)metadata_fault<=1;
   if(source_verified&&!stale)begin
    seen<=1;last_id<=frame_id;last_time<=timestamp_us;last_config<=config_id;
    if(force_full)last_full<=timestamp_us;
   end else seen<=0;
  end
 end
end
endmodule
