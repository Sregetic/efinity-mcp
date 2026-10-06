// Existing USER2 mailbox -> one frozen, frame-tagged FlyHash job.
// 50=host features,51=index[13:8]/uint8,52=abort,54=on-board bitmap features.
module vision_flyhash_control #(parameter PROJECTION_FILE="../../models/flyhash_projection.mem")(
 input clk,rst_n,cmd_event,input[7:0]cmd_op,input[23:0]cmd_value,
 input context_valid,input[31:0]frame_id,config_id,epoch,stream_errors,
 output[255:0]hash,output[31:0]status,
 output[31:0]result_frame_id,result_config_id,output reg[31:0]result_epoch=0,
 output bitmap_req,bitmap_busy,input bitmap_ready,output[11:0]bitmap_address,
 input bitmap_valid,input[31:0]bitmap_data,
 input[1:0]feature_quarter,output[127:0]feature_probe
);
 wire job_ready,feature_ready,done,busy;wire[31:0]cycles;
 reg valid=0,fault=0,auto_features=0;reg[6:0]loaded=0,sequence_id=0;
 reg[31:0]job_frame=0,job_config=0,job_epoch=0,job_errors=0;
 wire start=cmd_event&&(cmd_op==8'h50||cmd_op==8'h54);
 wire feed=cmd_event&&cmd_op==8'h51;
 wire abort_job=cmd_event&&cmd_op==8'h52;
 wire changed=(busy||done)&&(!context_valid||frame_id!=job_frame||config_id!=job_config||epoch!=job_epoch||stream_errors!=job_errors);
 wire bad_start=start&&(!job_ready||!context_valid);
 wire bad_feed=feed&&(auto_features||!feature_ready||cmd_value[23:8]!={10'b0,loaded[5:0]});
 wire failed=changed||bad_start||bad_feed;
 wire auto_valid;wire[7:0]auto_data;
 vision_edge_features feature_extractor(.clk(clk),.rst_n(rst_n&&!abort_job&&!failed),
  .job_valid(start&&cmd_op==8'h54&&!bad_start),.job_ready(),.busy(bitmap_busy),.done(),
  .word_req(bitmap_req),.word_ready(bitmap_ready),.word_address(bitmap_address),
  .word_valid(bitmap_valid),.word_data(bitmap_data),
  .feature_valid(auto_valid),.feature_ready(feature_ready),.feature_data(auto_data));
 flyhash_encoder #(.PROJECTION_FILE(PROJECTION_FILE)) encoder(
  .clk(clk),.rst_n(rst_n&&!abort_job&&!failed),.job_valid(start&&!bad_start),.job_ready(job_ready),
  .frame_id(frame_id),.config_id(config_id),.feature_valid(auto_features?auto_valid:(feed&&!bad_feed)),.feature_ready(feature_ready),
  .feature_data(auto_features?auto_data:cmd_value[7:0]),.done(done),.busy(busy),.hash(hash),
  .result_frame_id(result_frame_id),.result_config_id(result_config_id),.cycles(cycles),
  .feature_quarter(feature_quarter),.feature_probe(feature_probe));
 // Compute bound is4877 clocks;13 bits are sufficient. LOAD gaps excluded.
 assign status={valid,busy,(feature_ready&&!auto_features),fault,context_valid,loaded,sequence_id,cycles[12:0]};
 always @(posedge clk)begin
  if(!rst_n)begin valid<=0;fault<=0;auto_features<=0;loaded<=0;sequence_id<=0;job_frame<=0;job_config<=0;job_epoch<=0;job_errors<=0;result_epoch<=0;end
  else if(abort_job||failed)begin valid<=0;fault<=failed;auto_features<=0;loaded<=0;end
  else begin
   if(start)begin valid<=0;fault<=0;auto_features<=cmd_op==8'h54;loaded<=0;job_frame<=frame_id;job_config<=config_id;job_epoch<=epoch;job_errors<=stream_errors;end
   if((auto_features&&auto_valid&&feature_ready)||(!auto_features&&feed))loaded<=loaded+1'b1;
   if(done)begin valid<=1;auto_features<=0;sequence_id<=sequence_id+1'b1;result_epoch<=job_epoch;end
  end
 end
endmodule
