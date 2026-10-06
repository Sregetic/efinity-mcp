`timescale 1ns/1ps
module tb;
localparam W=1920,H=12;
reg clk=0,refclk=0;always #5 clk=~clk;always #2.5 refclk=~refclk;
reg rst=0,de=0,vs=0,rd=0,rv=0,median=0;reg[7:0]rp=0;reg[15:0]pair=0;
reg[31:0]input_id=0,display_id=0;reg display_de=0,display_vs=0,display_live=1;wire[31:0]display_min,display_max,display_samples,display_unmatched;wire[31:0]last_frame,last_pixels,last_edges,measured_pipe,semantic_min,semantic_max,last_gray_sum;
wire od,oh,ov;wire[11:0]x,y;wire[15:0]gray;wire[1:0]edges;wire[21:0]magnitudes;
vision_line_direct #(.WIDTH(W)) dut(clk,rst,de,de,vs,pair,median,11'd96,od,oh,ov,x,y,gray,edges,magnitudes);
vision_line_metrics metrics(clk,rst,de,vs,input_id,od,ov,x,y,gray,edges,display_de,display_vs,display_live,display_id,last_frame,last_pixels,last_edges,measured_pipe,semantic_min,semantic_max,last_gray_sum,display_min,display_max,display_samples,display_unmatched);
wire fd,fh,fv,fb;wire[11:0]fx,fy;wire[7:0]fr,fg,fblue,rg;wire[10:0]rm;wire[1:0]dir;wire re;
vision_frontend #(.WIDTH(W)) reference0(refclk,rst,rd,rd,rv,rp,rp,rp,median,fd,fh,fv,fb,fx,fy,fr,fg,fblue,rg,rm,dir,11'd96,re);
reg[19:0]expected[0:W*H-1];integer checked=0,pixels=0,tick=0,vs_tick=0,pipe_cycles=0;integer frame_edges=0,frame_sum=0,expected_edges=0,expected_sum=0;
function automatic[7:0]sample(input integer xx,yy,frame);
 begin sample=frame==0?(xx*7+yy*13+(xx%11)*9)%256:((xx*3+yy*11)%180+20);end
endfunction
always @(negedge refclk)if(fd)expected[fy*W+fx]={re,rm,rg};
always @(posedge clk)begin tick<=tick+1;if(vs)vs_tick<=tick;end
always @(negedge clk)begin
 if(ov)begin pipe_cycles=tick-vs_tick;expected_edges=frame_edges;expected_sum=frame_sum;frame_edges=0;frame_sum=0;end
 if(od)begin
  frame_edges=frame_edges+edges[0]+edges[1];frame_sum=frame_sum+gray[7:0]+gray[15:8];
  pixels=pixels+2;
  if(x>=4&&y>=4)begin
   if({edges[0],magnitudes[10:0],gray[7:0]}!==expected[y*W+x])$fatal(1,"2PPC lane0 mismatch x%0d y%0d got%h wanted%h",x,y,{edges[0],magnitudes[10:0],gray[7:0]},expected[y*W+x]);
   if({edges[1],magnitudes[21:11],gray[15:8]}!==expected[y*W+x+1])$fatal(1,"2PPC lane1 mismatch x%0d y%0d",x,y);
   checked=checked+2;
  end
 end
end
integer f,xx,yy;
initial begin
 repeat(5)@(negedge clk);rst=1;
 for(f=0;f<2;f=f+1)begin
  median=f;@(negedge refclk);rv=1;@(negedge refclk);rv=0;repeat(20)@(negedge refclk);
  for(yy=0;yy<H;yy=yy+1)begin
   for(xx=0;xx<W;xx=xx+1)begin rd=1;rp=sample(xx,yy,f);@(negedge refclk);end
   rd=0;repeat(12)@(negedge refclk);
  end
  repeat(40)@(negedge clk);
  input_id=f+1;vs=1;@(negedge clk);vs=0;repeat(12)@(negedge clk);
  for(yy=0;yy<H;yy=yy+1)begin
   for(xx=0;xx<W;xx=xx+2)begin de=1;pair={sample(xx+1,yy,f),sample(xx,yy,f)};@(negedge clk);end
   de=0;repeat(6)@(negedge clk);
   if(yy%6==5)repeat(1024)@(negedge clk);
  end
  repeat(40)@(negedge clk);
 end
 input_id=3;vs=1;@(negedge clk);vs=0;repeat(40)@(negedge clk);
 if(last_frame!=2||last_pixels!=W*H||last_edges!=expected_edges||last_gray_sum!=expected_sum)$fatal(1,"Direct completed-frame metrics");
 if(semantic_min!=2*(W/2+6)+measured_pipe+1||semantic_max!=semantic_min+1024)$fatal(1,"Semantic line latency min%0d max%0d pipe%0d",semantic_min,semantic_max,measured_pipe);
 display_live=0;display_id=0;display_vs=1;@(negedge clk);display_vs=0;@(negedge clk);display_de=1;@(negedge clk);display_de=0;@(negedge clk);
 if(display_samples||display_unmatched)$fatal(1,"Placeholder display was treated as a source frame");
 display_live=1;display_id=2;display_vs=1;@(negedge clk);display_vs=0;@(negedge clk);display_de=1;@(negedge clk);display_de=0;@(negedge clk);
 if(display_samples!=1||display_unmatched!=0||display_min!=display_max||display_min<semantic_max)$fatal(1,"Display/source timestamp correlation");
 display_id=7;display_vs=1;@(negedge clk);display_vs=0;@(negedge clk);display_de=1;@(negedge clk);display_de=0;@(negedge clk);
 if(display_samples!=1||display_unmatched!=1)$fatal(1,"Unmatched display tag was accepted");
 if(pixels!=2*W*H||checked!=2*(W-4)*(H-4))$fatal(1,"Pixel extent %0d/%0d",pixels,checked);
 $display("PASS2PPC direct %0d pixels, %0d interior comparisons, median off/on, full width, six-row gaps, VS latency%0d cycles, semantic%0d..%0d cycles",pixels,checked,measured_pipe,semantic_min,semantic_max);$finish;
end
endmodule
