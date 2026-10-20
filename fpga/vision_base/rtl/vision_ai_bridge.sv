// Two held-data CDC mailboxes: completed geometry -> CPU, CPU result -> VS.
// No pixel storage. Frame, render configuration and processing context are
// independent identities. A late result stays readable but never draws a box.
module vision_ai_bridge #(parameter SIG_BITS=88)(
 input clk,rst_n,video_clk,vs,input[31:0]view_frame,view_config,input frame_ok,
 input[SIG_BITS-1:0]signature,input geometry_done,input[31:0]geometry_frame,geometry_config,geometry_context,
 input[63:0]geometry_status,
 input[7:0]paddr,input psel,penable,pwrite,input[31:0]pwdata,
 output reg[31:0]prdata,output pready,pslverror,
 output reg enabled,context_changed,output reg[31:0]context_id=0,
 output[351:0]result,output result_match,result_identity_match,output[15:0]result_age
);
 wire wr=psel&&penable&&pwrite;
 reg enable_request=0;(* async_reg="true" *)reg[1:0]enable_sync=0;
 reg vq=0;reg[SIG_BITS-1:0]last_signature=0;
 reg[159:0]geometry_video=0,geometry_core=0;reg geometry_req=0,geometry_ack=0;
 (* async_reg="true" *)reg[2:0]geometry_sync=0;(* async_reg="true" *)reg[1:0]geometry_ack_sync=0;
 reg[31:0]geometry_sequence=0;
 reg[351:0]staging=0,front=0;reg publish_req=0,publish_ack=0;
 (* async_reg="true" *)reg[2:0]publish_sync=0;(* async_reg="true" *)reg[1:0]publish_ack_sync=0;
 wire publish_busy=publish_req!=publish_ack_sync[1];
 assign pready=!(wr&&publish_busy&&(paddr==8'h08||paddr>=8'h80)),pslverror=0;
 assign result=front;
 assign result_identity_match=front[0]&&enabled&&front[63:32]==view_frame&&
                     front[127:96]==view_config&&front[191:160]==context_id;
 assign result_match=result_identity_match&&frame_ok;
 wire[31:0]age=view_frame-front[63:32];
 assign result_age=age[31:16]!=0?16'hffff:age[15:0];
 always @*begin
  prdata=0;
  case(paddr)
   0:prdata=32'h26101003;
   4:prdata={30'b0,enable_request,publish_busy};
   8'h10:prdata=geometry_sequence;
   8'h14:prdata=geometry_core[31:0];
   8'h18:prdata=geometry_core[63:32];
   8'h1c:prdata=geometry_core[95:64];
   8'h20:prdata=geometry_core[159:128];
   8'h24:prdata=geometry_core[127:96];
   default:if(paddr>=8'h80&&paddr<=8'ha8)prdata=staging[32*((paddr-8'h80)>>2)+:32];
  endcase
 end
 always @(posedge clk)begin
  if(!rst_n)begin enable_request<=0;geometry_sync<=0;geometry_ack<=0;geometry_core<=0;geometry_sequence<=0;
   staging<=0;publish_req<=0;publish_ack_sync<=0;end
  else begin
   geometry_sync<={geometry_sync[1:0],geometry_req};publish_ack_sync<={publish_ack_sync[0],publish_ack};
   if(geometry_sync[2]!=geometry_ack)begin
    geometry_core<=geometry_video;geometry_sequence<=geometry_sequence+1'b1;geometry_ack<=geometry_sync[2];
   end
   if(wr&&pready)begin
    if(paddr==4)enable_request<=pwdata[0];
    else if(paddr==8)publish_req<=~publish_req;
    else if(paddr>=8'h80&&paddr<=8'ha8)staging[32*((paddr-8'h80)>>2)+:32]<=pwdata;
   end
  end
 end
 always @(posedge video_clk)begin
  if(!rst_n)begin vq<=0;enabled<=0;enable_sync<=0;last_signature<=0;context_id<=0;context_changed<=0;
   geometry_video<=0;geometry_req<=0;geometry_ack_sync<=0;publish_sync<=0;publish_ack<=0;front<=0;end
  else begin
   vq<=vs;enable_sync<={enable_sync[0],enable_request};geometry_ack_sync<={geometry_ack_sync[0],geometry_ack};
   publish_sync<={publish_sync[1:0],publish_req};context_changed<=0;
   if(vs&&!vq)begin
    enabled<=enable_sync[1];
    if(signature!=last_signature||enabled!=enable_sync[1])begin
     last_signature<=signature;context_id<=context_id+1'b1;context_changed<=1;
    end
    if(publish_sync[2]!=publish_ack)begin front<=staging;publish_ack<=publish_sync[2];end
   end
   if(geometry_done&&enabled&&geometry_context==context_id&&geometry_req==geometry_ack_sync[1])begin
    geometry_video<={geometry_status,geometry_context,geometry_config,geometry_frame};geometry_req<=~geometry_req;
   end
  end
 end
endmodule
