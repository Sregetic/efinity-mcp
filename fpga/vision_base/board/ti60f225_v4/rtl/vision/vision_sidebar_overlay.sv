// Final scan overlay: opening the sidebar never switches the camera ISP bypass.
// All pixels and syncs retain their order, with one extra video-clock beat.
module vision_sidebar_overlay(input clk,rst_n,de,hs,vs,input[23:0]rgb,ui_state,input[3:0]ai_status,
 input motion_enable,motion_held,input[2:0]motion_direction,
 output ode,ohs,ovs,output[23:0]orgb);
 reg[11:0]x=0,y=0;reg de_q=0,hs_q=0,vs_q=0,open_q=0;reg[23:0]rgb_q=0;
 reg[2:0]direction_q=0;reg held_q=0;
 wire active,ink;
 vision_osd #(.MOTION_HINT(1)) sidebar_font(.clk(clk),.x(x),.y(y),.ui_state(ui_state),
  .mode(3'd0),.threshold(11'd0),.median_en(1'b0),.memory_mode(2'd0),.history_index(3'd0),
  .canny_ready(1'b0),.shape_class(2'd0),.shape_valid(1'b0),.shape_enable(1'b0),
  .requested_threshold(11'd0),.fusion_enabled(1'b0),.fusion_result({332'd0,motion_enable,direction_q,held_q,ai_status,11'd0}),
  .geometry_counts(16'd0),.geometry_symbol(7'd0),.fusion_match(1'b0),.fusion_age(16'd0),.active(active),.ink(ink));
 always @(posedge clk)begin
  if(!rst_n)begin x<=0;y<=0;de_q<=0;hs_q<=0;vs_q<=0;open_q<=0;rgb_q<=0;direction_q<=0;held_q<=0;end
  else begin
   de_q<=de;hs_q<=hs;vs_q<=vs;rgb_q<=rgb;open_q<=ui_state[23]||motion_enable;
   if(vs&&!vs_q)begin x<=0;y<=0;direction_q<=motion_direction;held_q<=motion_held;end
   else if(de)x<=x+1'b1;
   else if(de_q)begin x<=0;y<=y+1'b1;end
  end
 end
 assign ode=de_q,ohs=hs_q,ovs=vs_q;
 assign orgb=open_q&&active?(ink?24'hffff80:24'h101010):rgb_q;
endmodule
