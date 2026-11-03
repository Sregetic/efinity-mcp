// Local ON/OFF delayed correlation. No MaleCNS/Flyvis whole-network state.
// Four sign-matched products retain the original eight load/accumulate beats.
module vision_local_motion_core #(
 parameter COLS=12,ROWS=12,N=COLS*ROWS,AW=$clog2(N),CW=$clog2(COLS+1),RW=$clog2(ROWS+1)
)(input clk,rst_n,abort_frame,
 input in_valid,output in_ready,input in_first,in_last,reset_history,input[7:0]in_gray,
 output reg out_valid, input out_ready,
 output reg temporal_valid,output reg[2:0]direction,
 output reg signed[31:0]horizontal_response,vertical_response,
 output reg[15:0]active_sites,output reg roi_valid,
 output reg[CW-1:0]roi_x0,roi_x1,output reg[RW-1:0]roi_y0,roi_y1,
 output reg fault);
localparam IDLE=0,READ=1,READ_LINE=2,LOAD=3,MULTIPLY=4,COMMIT=5,STORE_LINE=6,FINISH=7;
reg[2:0]state;reg[AW-1:0]index;reg[CW-1:0]col;reg[RW-1:0]row;
reg packet_open,history_valid,warm;reg[7:0]gray_latched;reg signed[8:0]current_delta;
// Store signed contrast instead of two disjoint ON/OFF bytes: 8+9 bits/site.
localparam LINE_BASE=1<<AW;
(* syn_ramstyle="block_ram",syn_ramdecomp="area" *)reg[17:0]history[0:LINE_BASE+COLS-1];
reg[17:0]history_q;reg[16:0]cell_q;reg[17:0]above,left;
reg[2:0]term;reg[7:0]mul_a,mul_b;wire[15:0]product=mul_a*mul_b;
wire signed[16:0]signed_increment=term[1]?-$signed({1'b0,product}):$signed({1'b0,product});
localparam SUM_W=$clog2(2*N*255*255+1)+1;
reg signed[SUM_W-1:0]hx,vy;reg[$clog2(N+1)-1:0]count_active;
reg[CW-1:0]xmin,xmax;reg[RW-1:0]ymin,ymax;
wire signed[8:0]delta=$signed({1'b0,gray_latched})-$signed({1'b0,cell_q[16:9]});
wire signed[8:0]old_delta=cell_q[8:0],old_left=left[17:9],now_left=left[8:0],old_above=above[17:9],now_above=above[8:0];
reg signed[8:0]pair_a,pair_b;
always @*case(term[2:1])
 0:begin pair_a=old_left;pair_b=current_delta;end
 1:begin pair_a=old_delta;pair_b=now_left;end
 2:begin pair_a=old_above;pair_b=current_delta;end
 3:begin pair_a=old_delta;pair_b=now_above;end
endcase
wire[8:0]magnitude_a=pair_a[8]?-pair_a:pair_a,magnitude_b=pair_b[8]?-pair_b:pair_b;
wire[8:0]current_magnitude=current_delta[8]?-current_delta:current_delta;
wire[8:0]stored_delta=warm?delta:9'd0;
// Separate cell/line reads and writes share one physical RAM port pair.
wire[AW:0]history_read=state==READ?{1'b0,index}:LINE_BASE+col;
wire[AW:0]history_write=state==COMMIT?{1'b0,index}:LINE_BASE+col;
wire[17:0]history_data=state==COMMIT?{1'b0,gray_latched,stored_delta}:
                                     {warm?cell_q[8:0]:9'd0,stored_delta};
always @(posedge clk)begin
 history_q<=history[history_read];
 if(rst_n&&!abort_frame&&(state==COMMIT||state==STORE_LINE))history[history_write]<=history_data;
end
wire[SUM_W-1:0]abs_h=hx[SUM_W-1]?-hx:hx,abs_v=vy[SUM_W-1]?-vy:vy;
wire[SUM_W-1:0]major=abs_h>=abs_v?abs_h:abs_v,minor=abs_h>=abs_v?abs_v:abs_h;
wire signed[SUM_W-1:0]updated_sum=(term[2]?vy:hx)+signed_increment;
assign in_ready=state==IDLE&&(!out_valid||out_ready);
always @(posedge clk)begin
 if(!rst_n)begin
  state<=IDLE;index<=0;col<=0;row<=0;packet_open<=0;history_valid<=0;warm<=0;
  out_valid<=0;fault<=0;direction<=0;temporal_valid<=0;roi_valid<=0;
  horizontal_response<=0;vertical_response<=0;active_sites<=0;
  roi_x0<=0;roi_y0<=0;roi_x1<=0;roi_y1<=0;hx<=0;vy<=0;count_active<=0;
  current_delta<=0;mul_a<=0;mul_b<=0;term<=0;gray_latched<=0;
 end else if(abort_frame)begin
  state<=IDLE;packet_open<=0;history_valid<=0;out_valid<=0;fault<=1;
 end else begin
  if(out_valid&&out_ready)out_valid<=0;
  case(state)
   IDLE:if(in_valid&&in_ready)begin
    if((!packet_open&&!in_first)||(in_first&&in_last)||(!in_first&&(in_last!=(index==N-1))))begin
     fault<=1;packet_open<=0;history_valid<=0;
    end else begin
     gray_latched<=in_gray;
     if(in_first)begin
      warm<=history_valid&&!reset_history&&!packet_open;
      if(packet_open)fault<=1;
      index<=0;col<=0;row<=0;packet_open<=1;hx<=0;vy<=0;count_active<=0;
      xmin<=COLS-1;xmax<=0;ymin<=ROWS-1;ymax<=0;
     end
     state<=READ;
    end
   end
   READ:state<=READ_LINE;
   READ_LINE:begin cell_q<=history_q[16:0];state<=LOAD;end
   LOAD:begin
    above<=history_q;
    current_delta<=warm?delta:9'sd0;
    term<=0;state<=MULTIPLY;
   end
   MULTIPLY:begin
    if(!term[0])begin
     mul_a<=0;mul_b<=0;
     if(warm&&(term[2]?row!=0:col!=0)&&pair_a[8]==pair_b[8])begin
      mul_a<=magnitude_a[7:0];mul_b<=magnitude_b[7:0];
     end
    end else if(!term[2])begin
     hx<=updated_sum;
    end else begin
     vy<=updated_sum;
    end
    if(term==7)state<=COMMIT;else term<=term+1'b1;
   end
   COMMIT:begin
    left<={warm?cell_q[8:0]:9'd0,stored_delta};
    if(warm&&current_magnitude>8)begin
     count_active<=count_active+1'b1;
     if(col<xmin)xmin<=col;if(col>xmax)xmax<=col;
     if(row<ymin)ymin<=row;if(row>ymax)ymax<=row;
    end
    state<=STORE_LINE;
   end
   STORE_LINE:begin
    if(index==N-1)state<=FINISH;
    else begin index<=index+1'b1;if(col==COLS-1)begin col<=0;row<=row+1'b1;end else col<=col+1'b1;state<=IDLE;end
   end
   FINISH:begin
    out_valid<=1;temporal_valid<=warm;horizontal_response<=hx;vertical_response<=vy;
    active_sites<=count_active;roi_valid<=count_active!=0;
    roi_x0<=count_active!=0?xmin:0;roi_x1<=count_active!=0?CW'(xmax+1'b1):0;
    roi_y0<=count_active!=0?ymin:0;roi_y1<=count_active!=0?RW'(ymax+1'b1):0;
    direction<=0;
    // 0 unknown,1 static,2 left,3 right,4 up,5 down. Scores are not probability.
    if(warm&&count_active==0)direction<=1;
    else if(warm&&major>=256&&({1'b0,major}<<1)>={1'b0,minor}+({1'b0,minor}<<1))begin
     if(abs_h>=abs_v)direction<=hx[SUM_W-1]?2:3;else direction<=vy[SUM_W-1]?4:5;
    end
    history_valid<=1;packet_open<=0;state<=IDLE;
   end
   default:begin state<=IDLE;history_valid<=0;packet_open<=0;fault<=1;end
  endcase
 end
end
endmodule
