// Bundled-data request/ack snapshot. Payload stays held until the next request.
// JTAG capture returns a previous completed snapshot; prime then read again.
module vision_motion_snapshot_cdc #(parameter W=224)(
 input src_clk,src_rst_n,input[W-1:0]src_data,
 input dst_clk,dst_rst_n,dst_request,output reg[W-1:0]dst_data,output reg dst_valid);
reg request_toggle,ack_toggle,ack_seen;
reg[2:0]request_sync,ack_sync;
reg[W-1:0]held;
always @(posedge src_clk or negedge src_rst_n)begin
 if(!src_rst_n)begin request_sync<=0;ack_toggle<=0;held<=0;end
 else begin
  request_sync<={request_sync[1:0],request_toggle};
  if(request_sync[2]!=ack_toggle)begin held<=src_data;ack_toggle<=request_sync[2];end
 end
end
always @(posedge dst_clk or negedge dst_rst_n)begin
 if(!dst_rst_n)begin request_toggle<=0;ack_sync<=0;ack_seen<=0;dst_data<=0;dst_valid<=0;end
 else begin
  ack_sync<={ack_sync[1:0],ack_toggle};
  if(ack_sync[2]!=ack_seen)begin dst_data<=held;dst_valid<=1;ack_seen<=ack_sync[2];end
  if(dst_request&&request_toggle==ack_sync[2])request_toggle<=~request_toggle;
 end
end
endmodule
