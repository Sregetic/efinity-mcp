module vision_controls #(parameter CLK_HZ=148500000,parameter DEBOUNCE=CLK_HZ/50,parameter LONG_PRESS=CLK_HZ,parameter THRESHOLD_MIN=16,parameter THRESHOLD_STEP=16)(
 input clk,rst_n,vs,input[2:0]keys_n,input cmd_event,input[7:0]cmd_op,input[23:0]cmd_value,
 output reg[2:0]mode,output[10:0]threshold,output reg median_en,
 output reg[1:0]memory_mode,output reg[2:0]history_index,output reg[10:0]sobel_threshold,canny_threshold);
assign threshold=(mode==5||mode==6)?canny_threshold:sobel_threshold;
wire pending_canny=pmode==5||pmode==6;
wire[2:0]last_index=pmem==2?3'd6:3'd5;
function automatic[10:0]clamp_threshold(input[10:0]v);begin clamp_threshold=v<THRESHOLD_MIN?THRESHOLD_MIN:v;end endfunction
function automatic[10:0]increase(input[10:0]v);begin increase=v>2047-THRESHOLD_STEP?2047:v+THRESHOLD_STEP;end endfunction
function automatic[10:0]decrease(input[10:0]v);begin decrease=v<THRESHOLD_MIN+THRESHOLD_STEP?THRESHOLD_MIN:v-THRESHOLD_STEP;end endfunction
wire[2:0]short_p,long_p;
vision_keys #(.DEBOUNCE(DEBOUNCE),.LONG_PRESS(LONG_PRESS)) keys(clk,rst_n,keys_n,short_p,long_p);
reg[2:0]pmode=3,pindex=0;reg[10:0]psobel=128,pcanny=128;reg pmed=0;reg[1:0]pmem=0;reg vq=0;
always @(posedge clk)begin
 vq<=vs;
 if(!rst_n)begin
  pmode<=3;psobel<=128;pcanny<=128;pmed<=0;pmem<=0;pindex<=0;
  mode<=3;sobel_threshold<=128;canny_threshold<=128;median_en<=0;memory_mode<=0;history_index<=0;
 end else begin
  if(short_p[0])pmode<=pmode==6?0:pmode+1'b1;
  if(long_p[0])pmed<=~pmed;
  if(short_p[1])begin if(pmem>=2)pindex<=(pindex>=last_index)?0:pindex+1'b1;else if(pending_canny)pcanny<=increase(pcanny);else psobel<=increase(psobel);end
  if(short_p[2])begin if(pmem>=2)pindex<=(pindex==0||pindex>last_index)?last_index:pindex-1'b1;else if(pending_canny)pcanny<=decrease(pcanny);else psobel<=decrease(psobel);end
  if(long_p[1])pmem<=(pmem==0)?1:0;
  if(long_p[2])begin pmem<=(pmem==0||pmem==3)?1:pmem+1'b1;pindex<=0;end
  if(cmd_event)case(cmd_op)
   1:if(cmd_value<7)pmode<=cmd_value[2:0];2:if(pending_canny)pcanny<=clamp_threshold(cmd_value[10:0]);else psobel<=clamp_threshold(cmd_value[10:0]);
   8'h28:psobel<=clamp_threshold(cmd_value[10:0]);8'h29:pcanny<=clamp_threshold(cmd_value[10:0]);3:pmed<=cmd_value[0];
   4:pmem<=cmd_value[1:0];5:pindex<=(cmd_value[2:0]>last_index)?0:cmd_value[2:0];default:;
  endcase
  if(vs&&!vq)begin mode<=pmode;sobel_threshold<=psobel;canny_threshold<=pcanny;median_en<=pmed;memory_mode<=pmem;history_index<=pindex;end
 end
end
endmodule
