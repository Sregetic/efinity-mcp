`timescale 1ns/1ps
// Same captured RGB scene -> independent Canny classifications/flood gold.
module tb_hysteresis_scene;
 localparam W=480,H=270,N=W*H;
 reg clk=0,rst=0,vblank=0,cv=0,last=0;always #5 clk=~clk;
 reg[8:0]x=0,y=0,dx=0,dy=0;reg[1:0]c=0;
 wire cap,ready,busy,pixel,fault;wire[31:0]frames,cycles,passes,visits;wire[3:0]state;
 reg[1:0]cls[0:N-1];reg gold[0:N-1];integer i,n;
 vision_hysteresis_sweep #(.W(W),.H(H),.REUSE_CAPTURE_MAP(1),.MIN_COMPONENT(32))dut(
  .clk(clk),.rst_n(rst),.vblank(vblank),.class_valid(cv),.class_x(x),.class_y(y),.classification(c),.class_last(last),
  .display_x(dx),.display_y(dy),.capture_enable(cap),.ready(ready),.busy(busy),.pixel(pixel),.completed(frames),.fault(fault),.debug_state(state),.debug_queue(),
  .display_de(1'b0),.probe_req(1'b0),.probe_address(12'd0),.probe_ack(),.probe_data(),.probe_read_address(),.probe_busy(),.frame_discard(1'b0),
  .last_cycles(cycles),.sweep_passes(passes),.weak_visits(visits));
 initial begin
  $readmemh("results/project_light_20261005/scene.class.mem",cls);$readmemh("results/project_light_20261005/scene.edge.mem",gold);
  repeat(4)@(negedge clk);rst=1;wait(state==1);@(negedge clk);vblank=1;@(negedge clk);vblank=0;
  for(n=0;n<2;n=n+1)begin
   wait(cap);
   for(i=0;i<N;i=i+1)begin @(negedge clk);cv=1;x=i%W;y=i/W;c=n==0?cls[i]:0;last=i==N-1;end
   @(negedge clk);cv=0;last=0;wait(state==8);repeat(2)@(negedge clk);
   $display("SCENE frame%0d analysis_cycles=%0d passes=%0d weak_visits=%0d",n,cycles,passes,visits);
   vblank=1;@(negedge clk);vblank=0;
   for(i=0;i<N;i=i+1)begin
    @(negedge clk);dx=i%W;dy=i/W;@(posedge clk);#1;
    if(pixel!==(n==0?gold[i]:1'b0))$fatal(1,"scene pixel%0d frame%0d",i,n);
   end
   if(fault||frames!=n+1)$fatal(1,"scene status");
  end
  $display("PASS scene exact259200 pixels: actual image classification,8-connected hysteresis,MIN32 and next-frame mask clear");$finish;
 end
 initial begin #5000000000;$fatal(1,"scene watchdog");end
endmodule
