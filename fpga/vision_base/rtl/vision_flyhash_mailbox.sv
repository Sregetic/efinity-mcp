// Tagged Canny task and bitmap read port only. Features/hash live in CPU DDR.
module vision_flyhash_mailbox(
 input clk,rst_n,cpu_clk,cpu_rst_n,cmd_event,input[7:0]cmd_op,input[23:0]cmd_value,
 input context_valid,input[31:0]frame_id,config_id,epoch,stream_errors,
 output[31:0]status,result_frame_id,result_config_id,result_epoch,
 output bitmap_req,bitmap_busy,input bitmap_ready,output[11:0]bitmap_address,
 input bitmap_valid,input[31:0]bitmap_data,
 input[15:0]paddr,input psel,penable,pwrite,input[31:0]pwdata,
 output reg[31:0]prdata,output pready,pslverror,
 output[31:0]firmware_state,full_cycles
);
 reg valid=0,busy=0,fault=0,auto_features=0;
 reg[6:0]sequence_id=0;reg[15:0]nonce=0;
 reg[31:0]job_frame=0,job_config=0,job_epoch=0,job_errors=0;
 reg[31:0]published_frame=0,published_config=0,published_epoch=0,published_cycles=0;
 reg[31:0]cpu_tick=0,cpu_cycles=0;reg[1:0]boot_state=0;
 reg[15:0]done_nonce=0;reg done_toggle=0;
 (* async_reg="true" *)reg[1:0]done_sync=0;reg done_seen=0;
 (* async_reg="true" *)reg[1:0]boot_meta=0,boot_sync=0;
 wire ready_context=context_valid&&boot_sync==1;
 wire start=cmd_event&&(cmd_op==8'h50||cmd_op==8'h54);
 wire cancel=cmd_event&&cmd_op==8'h52;
 wire changed=busy&&(!ready_context||frame_id!=job_frame||config_id!=job_config||epoch!=job_epoch||stream_errors!=job_errors);
 wire failed=changed||(start&&(busy||!ready_context));
 reg job_toggle=0;
 assign status={valid,busy,1'b0,fault,ready_context,((valid||busy)?7'd64:7'd0),sequence_id,published_cycles[12:0]};
 assign result_frame_id=published_frame,result_config_id=published_config,result_epoch=published_epoch;
 assign firmware_state={30'b0,boot_sync},full_cycles=published_cycles;
 always @(posedge clk)begin
  if(!rst_n)begin
   valid<=0;busy<=0;fault<=0;auto_features<=0;sequence_id<=0;nonce<=0;
   job_frame<=0;job_config<=0;job_epoch<=0;job_errors<=0;
   published_frame<=0;published_config<=0;published_epoch<=0;published_cycles<=0;job_toggle<=0;
   done_sync<=0;done_seen<=0;boot_meta<=0;boot_sync<=0;
  end else begin
   done_sync<={done_sync[0],done_toggle};done_seen<=done_sync[1];
   boot_meta<=boot_state;boot_sync<=boot_meta;
   if(cancel||failed)begin valid<=0;busy<=0;fault<=failed;nonce<=nonce+1'b1;job_toggle<=~job_toggle;end
   else begin
    if(start)begin
     valid<=0;busy<=1;fault<=0;auto_features<=cmd_op==8'h54;nonce<=nonce+1'b1;
     job_toggle<=~job_toggle;
     job_frame<=frame_id;job_config<=config_id;job_epoch<=epoch;job_errors<=stream_errors;
    end
    if(done_sync[1]!=done_seen&&busy&&done_nonce==nonce)begin
     valid<=1;busy<=0;sequence_id<=sequence_id+1'b1;published_cycles<=cpu_cycles;
     published_frame<=job_frame;published_config<=job_config;published_epoch<=job_epoch;
    end
   end
  end
 end
 // One outstanding CPU read; address/data stay fixed through backpressure.
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
 wire word_ready=word_ack_sync[1]==word_toggle;
 assign pready=!(psel&&penable&&((!pwrite&&paddr==16'h20)||(pwrite&&paddr==16'h1c)))||word_ready;
 assign pslverror=0;
 always @*begin
  prdata=0;
  case(paddr)
   16'h00:prdata=32'h26100801;
   16'h04:prdata={30'b0,boot_state};
   16'h08:prdata=job_snapshot;
   16'h0c:prdata=job_frame;
   16'h10:prdata=job_config;
   16'h14:prdata=job_epoch;
   16'h18:prdata=job_errors;
   16'h20:prdata=word_data;
   16'h24:prdata=cpu_cycles;
   16'h30:prdata=cpu_tick;
   16'h34:prdata=32'h07620000;
   16'h38:prdata=32'h07620100;
  endcase
 end
 always @(posedge cpu_clk)begin
  if(!cpu_rst_n)begin
   job_req_sync<=0;job_seen<=0;job_snapshot<=0;
   word_ack_sync<=0;word_toggle<=0;word_address<=0;
   cpu_tick<=0;cpu_cycles<=0;boot_state<=0;done_nonce<=0;done_toggle<=0;
  end else begin
   cpu_tick<=cpu_tick+1'b1;
   job_req_sync<={job_req_sync[1:0],job_toggle};job_seen<=job_req_sync[2];
   if(job_req_sync[2]!=job_seen)job_snapshot<={busy,auto_features,14'b0,nonce};
   word_ack_sync<={word_ack_sync[0],word_ack};
   if(psel&&penable&&pwrite&&pready)case(paddr)
    16'h04:boot_state<=pwdata[1:0];
    16'h1c:begin word_address<=pwdata[11:0];word_toggle<=~word_toggle;end
    16'h24:if(result_write_allowed)cpu_cycles<=pwdata;
    16'h28:if(result_write_allowed&&pwdata[15:0]==done_nonce)done_toggle<=~done_toggle;
    16'h2c:done_nonce<=pwdata[15:0];
   endcase
  end
 end
endmodule
