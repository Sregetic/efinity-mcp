`timescale 1ns/1ps
module tb;
localparam W=64,H=48,N=W*H,CASES=10;
reg clk=0,rst=0,de=0,hs=0,vs=0;always #5 clk=~clk;
reg[7:0]p=0;reg[11:0]dx=0,dy=0;
wire edgepix,ready,busy,fault,noise_valid;wire[31:0]done;wire[7:0]mean;wire[10:0]high;
vision_canny #(.W(W),.H(H))dut(.clk(clk),.rst_n(rst),.de(de),.hs(hs),.vs(vs),.r(p),.g(p),.b(p),
 .high_threshold(11'd16),.display_x(dx),.display_y(dy),.edge_pixel(edgepix),.ready(ready),.busy(busy),.fault(fault),.completed(done),
 .display_de(1'b0),.probe_hold(1'b0),.probe_req(1'b0),.probe_address(12'd0),.median_en(1'b1),
 .noise_mean(mean),.noise_valid(noise_valid),.effective_threshold(high),.raster_de(1'b0));
reg[7:0]input_pixels[0:CASES*N-1],means[0:CASES-1];reg gold[0:CASES*N-1];reg[10:0]highs[0:CASES-1];
integer c,source_case,x,y,errors=0,checks=0,edges=0;
task boundary;begin @(negedge clk);vs=1;repeat(8)@(negedge clk);vs=0;repeat(8)@(negedge clk);end endtask
task frame;begin
 for(y=0;y<H*4;y=y+1)begin
  for(x=0;x<W*4;x=x+1)begin de=1;p=input_pixels[source_case*N+(y/4)*W+x/4];@(negedge clk);end
  de=0;hs=1;repeat(8)@(negedge clk);hs=0;repeat(8)@(negedge clk);
 end
 wait(dut.hyst.state==8);boundary;
end endtask
initial begin
 $readmemh("results/noise_finish_20261004/noise_input.mem",input_pixels);
 $readmemh("results/noise_finish_20261004/noise_expected.mem",gold);
 $readmemh("results/noise_finish_20261004/noise_mean.mem",means);
 $readmemh("results/noise_finish_20261004/noise_high.mem",highs);
 for(c=0;c<CASES;c=c+1)begin
  source_case=c;
  rst=0;repeat(4)@(negedge clk);rst=1;wait(dut.hyst.state==1);boundary;
  // Median applies at a frame boundary and restarts the mutable padding map.
  wait(dut.hyst.state==1);boundary;
  frame;if(ready||done!=1)$fatal(1,"bootstrap frame exposed");
  frame;wait(ready);edges=0;
  if(fault||mean!==means[c]||high!==highs[c])$fatal(1,"case%0d statistic mean%0d/%0d high%0d/%0d",c,mean,means[c],high,highs[c]);
  for(y=0;y<H;y=y+1)for(x=0;x<W;x=x+1)begin
   @(negedge clk);dx=x*4;dy=y*4;@(posedge clk);#1;
   if(edgepix!==gold[c*N+y*W+x])begin errors=errors+1;if(errors<8)$display("NOISE BAD case%0d x%0d y%0d got%b wanted%b",c,x,y,edgepix,gold[c*N+y*W+x]);end
   checks=checks+1;if(edgepix)edges=edges+1;
  end
  $display("NOISE case%0d pixels%0d high%0d mean%0d",c,edges,high,mean);
  if(c==6)begin
   // A sudden noise-floor rise must keep the accepted contour, not publish
   // a frame classified with yesterday's lower threshold.
   source_case=5;frame;
   if(done!=2||!ready||mean!==means[5])$fatal(1,"noisy frame was published");
   for(y=0;y<H;y=y+1)for(x=0;x<W;x=x+1)begin
    @(negedge clk);dx=x*4;dy=y*4;@(posedge clk);#1;
    if(edgepix!==gold[c*N+y*W+x])$fatal(1,"accepted contour replaced by rejected noise");
    checks=checks+1;
   end
   frame;
   if(done!=3||high!==highs[5])$fatal(1,"new noise floor was not applied");
   for(y=0;y<H;y=y+1)for(x=0;x<W;x=x+1)begin
    @(negedge clk);dx=x*4;dy=y*4;@(posedge clk);#1;
    if(edgepix!==gold[5*N+y*W+x])$fatal(1,"adapted flat frame retained noise");
    checks=checks+1;
   end
   $display("PASS sudden noise rise holds front contour and retries with calibrated threshold");
  end
 end
 if(errors)$fatal(1,"noise pipeline errors%0d",errors);
 $display("PASS Canny RGB/area/median/adaptive/NMS/hysteresis/component pipeline %0d pixels, flat noise removed, geometry/thin lines retained",checks);$finish;
end
initial begin #100000000;$fatal(1,"noise watchdog case%0d state%0d",c,dut.hyst.state);end
endmodule
