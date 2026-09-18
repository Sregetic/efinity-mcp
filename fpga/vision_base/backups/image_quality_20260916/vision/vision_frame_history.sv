// Eight physical DDR slots: live capture never writes the displayed slot.
// Frozen/replay/comparison modes pin six completed history slots and keep
// capture running in the excluded scratch slot without publishing it.
module vision_frame_history #(parameter FRAME_BYTES=2074112,START_ADDR=0)(
 input clk,rst_n,write_done,read_done,input[1:0]mode,input[2:0]index,
 output reg[31:0]write_base,read_base,output reg[31:0]capture_id,display_id,
 output reg[2:0]history_count,output reg[2:0]write_slot,read_slot);
reg[2:0]history[0:6];reg[31:0]tags[0:7];reg[31:0]serial=0;reg[2:0]play=0;reg[5:0]tick=0;reg[1:0]prev_mode=0;
integer i;reg[2:0]candidate,selected,idx,next_idx;reg[3:0]replay_idx;
always @*begin
 candidate=write_slot+1'b1;if(candidate==read_slot)candidate=candidate+1'b1;
 idx=(index<history_count)?index:3'd0;
 next_idx=(idx+1>=history_count)?3'd0:idx+1'b1;
 replay_idx={1'b0,idx}+{1'b0,play};
 if(replay_idx>=history_count)replay_idx=replay_idx-history_count;
 selected=read_slot;
 if(history_count!=0)case(mode)
 0:selected=history[0];
 1:selected=read_slot;
 2:selected=history[replay_idx[2:0]];
 3:selected=history[(tick<30||history_count<2)?idx:next_idx];
 endcase
 if(selected==write_slot)selected=read_slot;
end
always @(posedge clk)begin
 if(!rst_n)begin
  write_slot<=0;read_slot<=1;write_base<=START_ADDR;read_base<=START_ADDR+FRAME_BYTES;
  serial<=0;capture_id<=0;display_id<=0;history_count<=0;play<=0;tick<=0;prev_mode<=0;
  for(i=0;i<7;i=i+1)history[i]<=0;for(i=0;i<8;i=i+1)tags[i]<=0;
 end else begin
  prev_mode<=mode;
  if(mode!=prev_mode)begin play<=0;tick<=0;end
  if(write_done)begin
   serial<=serial+1'b1;capture_id<=serial+1'b1;
   if(mode==0)begin
    tags[write_slot]<=serial+1'b1;for(i=6;i>0;i=i-1)history[i]<=history[i-1];history[0]<=write_slot;
    if(history_count<6)history_count<=history_count+1'b1;
    write_slot<=candidate;write_base<=START_ADDR+candidate*FRAME_BYTES;
   end
  end
  if(read_done)begin
   if(tick==59)tick<=0;else tick<=tick+1'b1;
   if(tick==29||tick==59)play<=(play+1>=history_count)?0:play+1'b1;
   read_slot<=selected;read_base<=START_ADDR+selected*FRAME_BYTES;display_id<=tags[selected];
  end
 end
end
endmodule
