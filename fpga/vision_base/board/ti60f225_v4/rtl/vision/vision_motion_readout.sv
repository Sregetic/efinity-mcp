// Display-only temporal readout. Raw core/status and scheduling are untouched.
// Four fresh observations form one signed-response window. Two agreeing windows
// confirm a direction; HOLD explicitly marks a bounded previous result.
module vision_motion_readout #(
 parameter CLOCK_HZ=148500000,HOLD_MS=700,MIN_DWELL_MS=250,FRESH_MS=100,
 parameter MS_CYCLES=CLOCK_HZ/1000,MW=(MS_CYCLES<2?1:$clog2(MS_CYCLES))
)(input clk,rst_n,frame_tick,input[31:0]status,observation,
 input signed[31:0]horizontal,vertical,input[15:0]active_sites,
 output reg[2:0]show_direction,output held);
reg[MW-1:0]ms_div;
wire ms_tick=ms_div==MS_CYCLES-1;
reg[9:0]hold_ms,watchdog_ms;reg[7:0]dwell_ms,fresh_ms;
reg have_observation;reg[31:0]last_observation;
reg signed[33:0]sum_h,sum_v;
reg[1:0]window_count;reg[2:0]active_count,previous_candidate;
reg candidate_seen;
wire signed[33:0]next_h=sum_h+{{2{horizontal[31]}},horizontal};
wire signed[33:0]next_v=sum_v+{{2{vertical[31]}},vertical};
// Break accumulation, absolute value and dominance into separate clocks.
reg window_pending,magnitude_valid,candidate_valid;
reg signed[33:0]complete_h,complete_v;
reg[2:0]complete_active,mag_active;
reg[33:0]mag_h,mag_v;reg sign_h,sign_v;
wire[33:0]major=mag_h>=mag_v?mag_h:mag_v,minor=mag_h>=mag_v?mag_v:mag_h;
wire[2:0]next_active=active_count+(active_sites!=0);
wire ready=status[0]&&status[1]&&!status[6]&&active_sites<=144;
wire fresh_observation=frame_tick&&(!have_observation||observation!=last_observation);
wire gap=have_observation&&observation!=last_observation+32'd1;
wire flush_pipeline=(frame_tick&&!ready)||(fresh_observation&&gap)||(ms_tick&&watchdog_ms==1);
reg[2:0]candidate,candidate_q;
always @*begin
 candidate=0;
 if(mag_active==0)candidate=1;
 else if(mag_active>=2&&major>=256&&{1'b0,major,1'b0}>=({2'd0,minor}+{1'b0,minor,1'b0}))
  candidate=mag_h>=mag_v?(sign_h?2:3):(sign_v?4:5);
end
assign held=show_direction>=2&&show_direction<=5&&fresh_ms==0;
always @(posedge clk)begin
 if(!rst_n)begin
  window_pending<=0;magnitude_valid<=0;candidate_valid<=0;candidate_q<=0;
  complete_h<=0;complete_v<=0;complete_active<=0;mag_h<=0;mag_v<=0;mag_active<=0;sign_h<=0;sign_v<=0;
  ms_div<=0;hold_ms<=0;watchdog_ms<=0;dwell_ms<=0;fresh_ms<=0;
  show_direction<=0;have_observation<=0;last_observation<=0;
  sum_h<=0;sum_v<=0;window_count<=0;active_count<=0;previous_candidate<=0;candidate_seen<=0;
 end else begin
  window_pending<=0;magnitude_valid<=window_pending;candidate_valid<=magnitude_valid;
  if(window_pending)begin
   mag_h<=complete_h[33]?-complete_h:complete_h;mag_v<=complete_v[33]?-complete_v:complete_v;
   sign_h<=complete_h[33];sign_v<=complete_v[33];mag_active<=complete_active;
  end
  if(magnitude_valid)candidate_q<=candidate;
  if(flush_pipeline)begin window_pending<=0;magnitude_valid<=0;candidate_valid<=0;end
  if(ms_tick)begin
   ms_div<=0;
   if(hold_ms!=0)begin hold_ms<=hold_ms-1'b1;if(hold_ms==1)show_direction<=0;end
   if(dwell_ms!=0)dwell_ms<=dwell_ms-1'b1;
   if(fresh_ms!=0)fresh_ms<=fresh_ms-1'b1;
   if(watchdog_ms!=0)begin
    watchdog_ms<=watchdog_ms-1'b1;
    if(watchdog_ms==1)begin show_direction<=0;have_observation<=0;sum_h<=0;sum_v<=0;window_count<=0;active_count<=0;candidate_seen<=0;hold_ms<=0;fresh_ms<=0;dwell_ms<=0;end
   end
  end else ms_div<=ms_div+1'b1;
  if(candidate_valid&&!flush_pipeline)begin
    previous_candidate<=candidate_q;candidate_seen<=candidate_q>=2&&candidate_q<=5;
    if(candidate_q>=2&&candidate_q<=5&&candidate_seen&&candidate_q==previous_candidate)begin
     if(show_direction==candidate_q||show_direction<2||dwell_ms==0)begin
      show_direction<=candidate_q;hold_ms<=HOLD_MS;fresh_ms<=FRESH_MS;
      if(show_direction!=candidate_q)dwell_ms<=MIN_DWELL_MS;
     end
    end else if(candidate_q==1&&(show_direction<2||hold_ms==0))begin show_direction<=1;hold_ms<=0;fresh_ms<=0;end
  end
  if(frame_tick&&!ready)begin
   show_direction<=0;have_observation<=0;hold_ms<=0;fresh_ms<=0;dwell_ms<=0;watchdog_ms<=0;
   sum_h<=0;sum_v<=0;window_count<=0;active_count<=0;candidate_seen<=0;
  end else if(fresh_observation)begin
   have_observation<=1;last_observation<=observation;watchdog_ms<=HOLD_MS;
   if(active_sites!=0&&show_direction==1)show_direction<=0;
   if(gap)begin
    sum_h<=0;sum_v<=0;window_count<=0;active_count<=0;candidate_seen<=0;
    show_direction<=0;hold_ms<=0;fresh_ms<=0;dwell_ms<=0;
   end else if(window_count==3)begin
    sum_h<=0;sum_v<=0;window_count<=0;active_count<=0;
    complete_h<=next_h;complete_v<=next_v;complete_active<=next_active;window_pending<=1;
   end else begin sum_h<=next_h;sum_v<=next_v;window_count<=window_count+1'b1;active_count<=next_active;end
  end
 end
end
endmodule
