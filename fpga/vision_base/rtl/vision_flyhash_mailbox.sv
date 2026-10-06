// USER2 video-domain task -> CPU APB, with held payloads and toggle handshakes.
// The FPGA holds/leases the plane; occupancy, projection and WTA run in firmware.
module vision_flyhash_mailbox(
 input clk,rst_n,cpu_clk,cpu_rst_n,cmd_event,input[7:0]cmd_op,input[23:0]cmd_value,
 input context_valid,input[31:0]frame_id,config_id,epoch,stream_errors,
 output[255:0]hash,output[31:0]status,
 output[31:0]result_frame_id,result_config_id,result_epoch,
 output bitmap_req,bitmap_busy,input bitmap_ready,output[11:0]bitmap_address,
 input bitmap_valid,input[31:0]bitmap_data,
 input[1:0]feature_quarter,output[127:0]feature_probe,
 input[15:0]paddr,input psel,penable,pwrite,input[31:0]pwdata,
 output reg[31:0]prdata,output pready,pslverror,
 output[31:0]firmware_state,full_cycles
);
 reg valid=0,busy=0,fault=0,auto_features=0;
 reg[6:0]loaded=0,sequence_id=0;reg[15:0]nonce=0;
 reg[31:0]job_frame=0,job_config=0,job_epoch=0,job_errors=0;
 reg[31:0]published_frame=0,published_config=0,published_epoch=0,published_cycles=0;
 reg[31:0]cpu_tick=0; // Minimal Sapphire has no mcycle read mapping; timer stays in CPU/APB clock domain.
 reg[255:0]cpu_hash=0;wire[511:0]cpu_features;reg[31:0]cpu_cycles=0,boot_state=0;
 reg feed_toggle=0,feed_pending=0;reg[5:0]feed_index=0;reg[7:0]feed_data=0;
 reg feed_ack=0;
 (* async_reg="true" *)reg[2:0]feed_req_sync=0;
 (* async_reg="true" *)reg[1:0]feed_ack_sync=0;reg feed_seen=0;
 reg[15:0]done_nonce=0;reg done_toggle=0;
 (* async_reg="true" *)reg[1:0]done_sync=0;reg done_seen=0;
 (* async_reg="true" *)reg[31:0]boot_meta=0,boot_sync=0;
 wire ready_context=context_valid&&boot_sync==1;
 wire start=cmd_event&&(cmd_op==8'h50||cmd_op==8'h54);
 wire feed=cmd_event&&cmd_op==8'h51;
 wire cancel=cmd_event&&cmd_op==8'h52;
 wire changed=busy&&(!ready_context||frame_id!=job_frame||config_id!=job_config||epoch!=job_epoch||stream_errors!=job_errors);
 wire bad_start=start&&(busy||!ready_context);
 wire feature_ready=busy&&!auto_features&&loaded<64&&feed_ack_sync[1]==feed_toggle;
 wire bad_feed=feed&&(!feature_ready||cmd_value[23:8]!={10'b0,loaded[5:0]});
 wire failed=changed||bad_start||bad_feed;
 reg job_toggle=0;
 wire[6:0]loaded_gray=(loaded>>1)^loaded;
 assign status={valid,busy,feature_ready,fault,ready_context,loaded,sequence_id,published_cycles[12:0]};
 // These CPU payloads stay fixed while valid; the next job clears valid first.
 assign hash=cpu_hash,result_frame_id=published_frame,result_config_id=published_config,result_epoch=published_epoch;
 assign feature_probe=cpu_features[feature_quarter*128+:128];
 assign firmware_state=boot_sync,full_cycles=published_cycles;
 always @(posedge clk)begin
  if(!rst_n)begin
   valid<=0;busy<=0;fault<=0;auto_features<=0;loaded<=0;sequence_id<=0;nonce<=0;
   job_frame<=0;job_config<=0;job_epoch<=0;job_errors<=0;
   feed_toggle<=0;feed_pending<=0;feed_index<=0;feed_data<=0;feed_ack_sync<=0;feed_seen<=0;
   published_frame<=0;published_config<=0;published_epoch<=0;published_cycles<=0;job_toggle<=0;
   done_sync<=0;done_seen<=0;boot_meta<=0;boot_sync<=0;
  end else begin
   done_sync<={done_sync[0],done_toggle};done_seen<=done_sync[1];
   boot_meta<=boot_state;boot_sync<=boot_meta;
   feed_ack_sync<={feed_ack_sync[0],feed_ack};feed_seen<=feed_ack_sync[1];
   if(cancel||failed)begin valid<=0;busy<=0;fault<=failed;loaded<=0;nonce<=nonce+1'b1;job_toggle<=~job_toggle;feed_pending<=0;end
   else begin
    if(start)begin
     valid<=0;busy<=1;fault<=0;auto_features<=cmd_op==8'h54;loaded<=0;nonce<=nonce+1'b1;
     job_toggle<=~job_toggle;
     feed_pending<=0;
     job_frame<=frame_id;job_config<=config_id;job_epoch<=epoch;job_errors<=stream_errors;
    end
    if(feed)begin feed_index<=loaded[5:0];feed_data<=cmd_value[7:0];feed_toggle<=~feed_toggle;feed_pending<=1;end
    if(feed_ack_sync[1]!=feed_seen&&feed_pending)begin loaded<=loaded+1'b1;feed_pending<=0;end
    if(done_sync[1]!=done_seen&&busy&&done_nonce==nonce)begin
     valid<=1;busy<=0;loaded<=64;sequence_id<=sequence_id+1'b1;
     published_cycles<=cpu_cycles;
     published_frame<=job_frame;published_config<=job_config;published_epoch<=job_epoch;
    end
   end
  end
 end
 // CPU word-read request. Address/data stay fixed until the acknowledgement.
 reg word_toggle=0;reg[11:0]word_address=0;
 (* async_reg="true" *)reg[1:0]word_req_sync=0;reg word_ack=0,word_wait=0;
 reg[31:0]word_data=0;
 assign bitmap_req=word_req_sync[1]!=word_ack&&!word_wait&&busy&&auto_features;
 assign bitmap_busy=busy&&auto_features,bitmap_address=word_address;
 always @(posedge clk)begin
  if(!rst_n)begin word_req_sync<=0;word_ack<=0;word_wait<=0;word_data<=0;end
  else begin
   word_req_sync<={word_req_sync[0],word_toggle};
   if(bitmap_req&&bitmap_ready)word_wait<=1;
   if(word_req_sync[1]!=word_ack&&(!busy||!auto_features))begin word_data<=0;word_ack<=word_req_sync[1];word_wait<=0;end
   else if(word_wait&&bitmap_valid)begin word_data<=bitmap_data;word_ack<=word_req_sync[1];word_wait<=0;end
  end
 end
 (* async_reg="true" *)reg[1:0]word_ack_sync=0;
 (* async_reg="true" *)reg[2:0]job_req_sync=0;reg job_seen=0;
 reg[31:0]job_snapshot=0;
 wire result_write_allowed=job_snapshot[31]&&job_snapshot[15:0]==done_nonce;
 (* async_reg="true" *)reg[6:0]loaded_meta=0,loaded_sync=0;
 wire[6:0]cpu_loaded;
 genvar g;generate for(g=0;g<7;g=g+1)begin:decode_loaded
  assign cpu_loaded[g]=^(loaded_sync>>g);
 end endgenerate
 wire word_ready=word_ack_sync[1]==word_toggle;
 assign pready=!(psel&&penable&&((!pwrite&&paddr==16'h20)||(pwrite&&paddr==16'h1c)))||word_ready;
 assign pslverror=0;
 always @*begin
  prdata=0;
  case(paddr)
   16'h00:prdata=32'h26100701;
   16'h04:prdata=boot_state;
   16'h08:prdata={job_snapshot[31:30],7'b0,cpu_loaded,job_snapshot[15:0]};
   16'h0c:prdata=job_frame;
   16'h10:prdata=job_config;
   16'h14:prdata=job_epoch;
   16'h18:prdata=job_errors;
   16'h20:prdata=word_data;
   16'h24:prdata=cpu_cycles;
   16'h30:prdata=cpu_tick;
   default:if(paddr>=16'h80&&paddr<16'hc0)prdata=cpu_features[paddr[5:2]*32+:32];
  endcase
 end
 always @(posedge cpu_clk)begin
  if(!cpu_rst_n)begin
   job_req_sync<=0;job_seen<=0;job_snapshot<=0;loaded_meta<=0;loaded_sync<=0;
   word_ack_sync<=0;word_toggle<=0;word_address<=0;
   cpu_tick<=0;cpu_hash<=0;cpu_cycles<=0;boot_state<=0;done_nonce<=0;done_toggle<=0;
   feed_req_sync<=0;feed_ack<=0;
  end else begin
   cpu_tick<=cpu_tick+1'b1;
   job_req_sync<={job_req_sync[1:0],job_toggle};job_seen<=job_req_sync[2];
   if(job_req_sync[2]!=job_seen)job_snapshot<={busy,auto_features,14'b0,nonce};
   loaded_meta<=loaded_gray;loaded_sync<=loaded_meta;
   feed_req_sync<={feed_req_sync[1:0],feed_toggle};
   if(feed_req_sync[2]!=feed_ack)feed_ack<=feed_req_sync[2];
   word_ack_sync<={word_ack_sync[0],word_ack};
   if(psel&&penable&&pwrite&&pready)begin
    case(paddr)
     16'h04:boot_state<=pwdata;
     16'h1c:begin word_address<=pwdata[11:0];word_toggle<=~word_toggle;end
     16'h24:if(result_write_allowed)cpu_cycles<=pwdata;
     16'h28:if(result_write_allowed&&pwdata[15:0]==done_nonce)done_toggle<=~done_toggle;
     16'h2c:done_nonce<=pwdata[15:0];
     default:begin
      if(result_write_allowed&&paddr>=16'h40&&paddr<16'h60)cpu_hash[paddr[4:2]*32+:32]<=pwdata;
     end
    endcase
   end
  end
 end
 // One feature store for both host-fed bytes and firmware-produced occupancy.
 // Constant bank/lane enables avoid a second 64-byte store and wide write mux.
 generate for(g=0;g<16;g=g+1)begin:feature_bank
  reg[31:0]data=0;
  assign cpu_features[g*32+:32]=data;
  always @(posedge cpu_clk)begin
   if(!cpu_rst_n)data<=0;
   else if(result_write_allowed&&psel&&penable&&pwrite&&pready&&paddr[15:6]==10'h3&&paddr[5:2]==g)data<=pwdata;
   else if(feed_req_sync[2]!=feed_ack&&feed_index[5:2]==g)
    case(feed_index[1:0])
     0:data[7:0]<=feed_data;
     1:data[15:8]<=feed_data;
     2:data[23:16]<=feed_data;
     3:data[31:24]<=feed_data;
    endcase
  end
 end endgenerate
endmodule
