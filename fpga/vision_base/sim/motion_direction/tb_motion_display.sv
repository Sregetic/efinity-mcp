`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst=0,de=0,hs=0,vs=0;reg[7:0]p=0;reg[2:0]mode=1;
wire d0,h0,v0,d1,h1,v1;wire[7:0]r0,g0,b0,r1,g1,b1;
wire[31:0]id,status,mhx,mvy,drop;wire[47:0]box;wire[15:0]active;
vision_display #(.WIDTH(192),.HEIGHT(96),.LOCAL_MOTION_ENABLE(0))baseline(
 .clk(clk),.rst_n(rst),.de(de),.hs(hs),.vs(vs),.r(p),.g(p),.b(p),.mode(mode),.threshold(11'd160),.median_en(1'b0),
 .memory_mode(2'd0),.history_index(3'd0),.canny_pixel(1'b0),.canny_ready(1'b0),
 .ode(d0),.ohs(h0),.ovs(v0),.orr(r0),.ogg(g0),.obb(b0));
vision_display #(.WIDTH(192),.HEIGHT(96),.LOCAL_MOTION_ENABLE(1))integrated(
 .clk(clk),.rst_n(rst),.de(de),.hs(hs),.vs(vs),.r(p),.g(p),.b(p),.mode(mode),.threshold(11'd160),.median_en(1'b0),
 .memory_mode(2'd0),.history_index(3'd0),.canny_pixel(1'b0),.canny_ready(1'b0),
 .ode(d1),.ohs(h1),.ovs(v1),.orr(r1),.ogg(g1),.obb(b1),
 .motion_observation(id),.motion_status(status),.motion_h(mhx),.motion_v(mvy),.motion_dropped(drop),.motion_box(box),.motion_active(active));
reg[7:0]pixels[0:6*192*96-1];integer f,ix,iy,n=0,last_id=0,fd,words,overlay_changes=0;
always @(negedge clk)if(rst)begin
 if({d0,h0,v0}!={d1,h1,v1})$fatal(1,"Integration changed raster timing");
 if(d0)begin
  n=n+1;
  if(mode!=7&&{r0,g0,b0}!=={r1,g1,b1})$fatal(1,"Integration changed existing display mode");
  if(mode==7&&{r0,g0,b0}!={r1,g1,b1})overlay_changes=overlay_changes+1;
 end
 if(integrated.local_motion.tap.word_valid&&integrated.local_motion.tap.core_ready)
  $fdisplay(words,"%0d",integrated.local_motion.tap.word);
 if(id!=last_id)begin
  $fdisplay(fd,"%0d %0d %0d %0d %0d %h %0d",id,status,$signed(mhx),$signed(mvy),active,box,drop);last_id=id;
 end
end
task boundary;
 begin @(negedge clk);vs=1;de=0;repeat(60)@(negedge clk);vs=0;repeat(40)@(negedge clk);end
endtask
initial begin
 fd=$fopen("display_results.txt","w");
 words=$fopen("display_grid_words.txt","w");
 $readmemh("vectors/pixel_frames.mem",pixels);
 repeat(3)@(negedge clk);rst=1;
 for(f=0;f<8;f=f+1)begin
  boundary;
  mode=f;
  for(iy=0;iy<96;iy=iy+1)begin
   for(ix=0;ix<192;ix=ix+1)begin @(negedge clk);de=1;p=pixels[(f%6)*192*96+iy*192+ix];end
   @(negedge clk);de=0;hs=1;repeat(12)@(negedge clk);hs=0;repeat(12)@(negedge clk);
  end
  repeat(100)@(negedge clk);
 end
 boundary;repeat(20)@(negedge clk);
 if(id!=8||drop!=0||n!=8*192*96||overlay_changes==0)$fatal(1,"Display integration count/overlay failed id=%0d drop=%0d pixels=%0d overlay=%0d",id,drop,n,overlay_changes);
 $fclose(fd);$fclose(words);
 $display("PASS display integration frames=8 modes0-6 preserved unchanged raster pixels=%0d mode7_overlay_pixels=%0d",n,overlay_changes);$finish;
end
initial begin #100000000;$fatal(1,"Display timeout");end
endmodule
