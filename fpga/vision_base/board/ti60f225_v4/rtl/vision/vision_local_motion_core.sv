// Local ON/OFF delayed correlation. No MaleCNS/Flyvis whole-network state.
// One 8x8 multiplier is time-shared over eight terms per grid word.
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
localparam IDLE=0,READ=1,LOAD=2,MULTIPLY=3,COMMIT=4,FINISH=5;
reg[2:0]state;reg[AW-1:0]index;reg[CW-1:0]col;reg[RW-1:0]row;
reg packet_open,history_valid,warm;reg[7:0]gray_latched,current_on,current_off;
// Store signed contrast instead of two disjoint ON/OFF bytes: 8+9 bits/site.
reg[16:0]cells[0:N-1],cell_q;
// Per-column previous-row history, plus one left neighbor. Not a frame image.
reg[COLS*18-1:0]line_store;reg[17:0]above,left,line_read;integer li;
reg[2:0]term;reg[7:0]mul_a,mul_b;wire[15:0]product=mul_a*mul_b;
wire signed[31:0]signed_product={16'd0,product};
reg signed[31:0]hx,vy;reg[15:0]count_active;
reg[CW-1:0]xmin,xmax;reg[RW-1:0]ymin,ymax;
wire signed[8:0]delta=$signed({1'b0,gray_latched})-$signed({1'b0,cell_q[16:9]});
wire[8:0]negative_delta=-delta;
wire signed[8:0]old_delta=cell_q[8:0],old_left=left[17:9],now_left=left[8:0],old_above=above[17:9],now_above=above[8:0];
wire[8:0]neg_old=-old_delta,neg_ol=-old_left,neg_nl=-now_left,neg_oa=-old_above,neg_na=-now_above;
wire[7:0]old_on=old_delta>0?old_delta[7:0]:0,old_off=old_delta<0?neg_old[7:0]:0;
wire[7:0]ol_on=old_left>0?old_left[7:0]:0,ol_off=old_left<0?neg_ol[7:0]:0;
wire[7:0]nl_on=now_left>0?now_left[7:0]:0,nl_off=now_left<0?neg_nl[7:0]:0;
wire[7:0]oa_on=old_above>0?old_above[7:0]:0,oa_off=old_above<0?neg_oa[7:0]:0;
wire[7:0]na_on=now_above>0?now_above[7:0]:0,na_off=now_above<0?neg_na[7:0]:0;
wire[8:0]stored_delta=warm?delta:9'd0;
always @*begin
 line_read=0;
 for(li=0;li<COLS;li=li+1)if(col==li)line_read=line_store[li*18+:18];
end
genvar lj;generate for(lj=0;lj<COLS;lj=lj+1)begin:line_registers
 always @(posedge clk)if(rst_n&&!abort_frame&&state==COMMIT&&col==lj)
  line_store[lj*18+:18]<={warm?cell_q[8:0]:9'd0,stored_delta};
end endgenerate
wire[31:0]abs_h=hx[31]?-hx:hx,abs_v=vy[31]?-vy:vy;
wire[31:0]major=abs_h>=abs_v?abs_h:abs_v,minor=abs_h>=abs_v?abs_v:abs_h;
assign in_ready=state==IDLE&&(!out_valid||out_ready);
always @*begin
 mul_a=0;mul_b=0;
 if(warm&&term<4&&col!=0)case(term)
  0:begin mul_a=ol_on;mul_b=current_on;end
  1:begin mul_a=old_on;mul_b=nl_on;end
  2:begin mul_a=ol_off;mul_b=current_off;end
  3:begin mul_a=old_off;mul_b=nl_off;end
 endcase
 if(warm&&term>=4&&row!=0)case(term)
  4:begin mul_a=oa_on;mul_b=current_on;end
  5:begin mul_a=old_on;mul_b=na_on;end
  6:begin mul_a=oa_off;mul_b=current_off;end
  7:begin mul_a=old_off;mul_b=na_off;end
 endcase
end
always @(posedge clk)begin
 if(!rst_n)begin
  state<=IDLE;index<=0;col<=0;row<=0;packet_open<=0;history_valid<=0;warm<=0;
  out_valid<=0;fault<=0;direction<=0;temporal_valid<=0;roi_valid<=0;
  horizontal_response<=0;vertical_response<=0;active_sites<=0;
  roi_x0<=0;roi_y0<=0;roi_x1<=0;roi_y1<=0;hx<=0;vy<=0;count_active<=0;
  current_on<=0;current_off<=0;term<=0;gray_latched<=0;
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
   READ:begin cell_q<=cells[index];above<=line_read;state<=LOAD;end
   LOAD:begin
    current_on<=(warm&&delta>0)?delta[7:0]:8'd0;
    current_off<=(warm&&delta<0)?negative_delta[7:0]:8'd0;
    term<=0;state<=MULTIPLY;
   end
   MULTIPLY:begin
    if(term<4)begin if(term[0])hx<=hx-signed_product;else hx<=hx+signed_product;end
    else begin if(term[0])vy<=vy-signed_product;else vy<=vy+signed_product;end
    if(term==7)state<=COMMIT;else term<=term+1'b1;
   end
   COMMIT:begin
    cells[index]<={gray_latched,stored_delta};
    left<={warm?cell_q[8:0]:9'd0,stored_delta};
    if(warm&&(current_on>8||current_off>8))begin
     count_active<=count_active+1'b1;
     if(col<xmin)xmin<=col;if(col>xmax)xmax<=col;
     if(row<ymin)ymin<=row;if(row>ymax)ymax<=row;
    end
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
    else if(warm&&major>=256&&(major<<1)>=minor+(minor<<1))begin
     if(abs_h>=abs_v)direction<=hx[31]?2:3;else direction<=vy[31]?4:5;
    end
    history_valid<=1;packet_open<=0;state<=IDLE;
   end
   default:begin state<=IDLE;history_valid<=0;packet_open<=0;fault<=1;end
  endcase
 end
end
endmodule
