`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg[11:0]x=0,y=0;reg[2:0]mode=0,history_index=0;reg[10:0]threshold=80,requested_threshold=80;
reg median_en=1,canny_ready=1,shape_valid=1,shape_enable=1,fusion_enabled=1,fusion_match=1;
reg[1:0]memory_mode=0,shape_class=2;reg[351:0]fusion_result={11{32'h13579bdf}};reg[15:0]fusion_age=3;reg[23:0]ui_state=0;
wire aa,ai,ba,bi;
vision_osd a(.active(aa),.ink(ai),.*);
vision_osd_first b(.active(ba),.ink(bi),.*);
reg[31:0]rng=32'h2210431;integer n;
initial begin
 for(n=0;n<262144;n=n+1)begin
  @(negedge clk);rng=rng^(rng<<13);rng=rng^(rng>>17);rng=rng^(rng<<5);
  x=rng%500;y=(rng>>9)%700;ui_state={n[0],rng[22:0]};mode=rng[2:0];
  @(posedge clk);#1;if(aa!==ba||ai!==bi)$fatal(1,"shared label differs at %0d UI=%h x=%d y=%d",n,ui_state,x,y);
 end
 $display("PASS shared sidebar label 262144 cycles, all items/edit/closed HUD/status/font bit-exact");$finish;
end
endmodule
