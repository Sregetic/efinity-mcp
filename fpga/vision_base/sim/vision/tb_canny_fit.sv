`timescale 1ns/1ps
module tb;
localparam W=48,H=36,PW=W*4,PH=H*4;
reg clk=0,rst=0,vblank=0,de=0,ready=1,bitmap=0;reg[11:0]x=0,y=0;
wire[8:0]fx,fy;wire[7:0]coverage;wire pixel;wire[31:0]coarse,shown;
vision_canny_raster #(.W(W),.H(H),.INDEX_FILE("board/ti60f225_v4/rtl/vision/canny_coverage_index.mem"),.PALETTE_FILE("board/ti60f225_v4/rtl/vision/canny_coverage_palette.mem"))
 dut(clk,rst,vblank,de,x,y,bitmap,ready,fx,fy,pixel,coarse,shown,coverage);
always #5 clk=~clk;
integer trace_checks=0;
always @(posedge clk)if(rst&&dut.line_fit.busy)begin
 if({dut.line_fit.trace_hl_q,dut.line_fit.trace_hr_q,dut.line_fit.trace_vl_q,dut.line_fit.trace_vr_q}!==
    {dut.line_fit.trace_line(dut.line_fit.job_window,dut.line_fit.step,1'b1,1'b0),
     dut.line_fit.trace_line(dut.line_fit.job_window,dut.line_fit.step,1'b1,1'b1),
     dut.line_fit.trace_line(dut.line_fit.job_window,dut.line_fit.step,1'b0,1'b0),
     dut.line_fit.trace_line(dut.line_fit.job_window,dut.line_fit.step,1'b0,1'b1)})$fatal(1,"trace prefetch phase mismatch");
 trace_checks=trace_checks+1;
end
reg map[0:W*H-1];reg[79:0]lut[0:511];reg[4:0]level;reg[7:0]expected;
always @(posedge clk)bitmap<=fx<W&&fy<H?map[fy*W+fx]:0;
integer f,i,xx,yy,a,b,nx,ny,pattern,cx,cy,k,minor,total,weight,slope,start,distance,major,minor_axis;
integer checks=0,fit_checks=0,radius,walk_pattern,previous,candidate,q,golden;reg[4:0]actual_walk;
integer bridge_mask,bridge_line;
integer sample_slope,sample_error,sample_offset,sample_a,sample_b,sample_checks=0;
reg signed[10:0]profile_error;reg[17:0]profile_active;
reg signed[6:0]fit_sum_input;reg fit_short_input;integer center_cases=0;
initial begin
 $readmemh("board/ti60f225_v4/rtl/vision/canny_coverage_q5.mem",lut);
 repeat(4)@(negedge clk);rst=1;
 force dut.line_fit.result_sum=fit_sum_input;force dut.line_fit.result_short=fit_short_input;
 for(f=0;f<2;f=f+1)for(i=-64;i<64;i=i+1)begin
  @(negedge clk);fit_sum_input=i;fit_short_input=f;
  repeat(2)@(posedge clk);#1;
  golden=32+(f?((i*51+2)>>>2):((i*57+4)>>>3));
  if(dut.line_fit.center_q!==10'(golden))$fatal(1,"signed center sum%0d short%0d got%0d expected%0d",i,f,dut.line_fit.center_q,golden);
  center_cases=center_cases+1;
 end
 release dut.line_fit.result_sum;release dut.line_fit.result_short;
 $display("PASS signed Canny center offset %0d cases",center_cases);
 for(bridge_mask=0;bridge_mask<4;bridge_mask=bridge_mask+1)
 for(walk_pattern=0;walk_pattern<2048;walk_pattern=walk_pattern+1)for(previous=-5;previous<=5;previous=previous+1)begin
  bridge_line=0;
  if(previous>-5&&(bridge_mask&1))bridge_line=bridge_line|(1<<(previous+4));
  if(previous<5&&(bridge_mask&2))bridge_line=bridge_line|(1<<(previous+6));
  golden=0;
  for(q=4;q>=0;q=q-1)begin
   candidate=previous+(q==1?-1:q==2?1:q==3?-2:q==4?2:0);
   if(candidate>=-5&&candidate<=5&&(walk_pattern&(1<<(candidate+5)))&&
      (q<3||(q==3?(bridge_mask&1):(bridge_mask&2))))golden=16|(candidate&15);
  end
  actual_walk=dut.line_fit.walk(11'(walk_pattern),4'(previous),11'(bridge_line));
  if(actual_walk!==5'(golden))$fatal(1,"walk pattern%h previous%0d got%h expected%h",walk_pattern,previous,actual_walk,golden);
 end
 force dut.line_fit.error=profile_error;force dut.line_fit.active=profile_active;
 for(sample_slope=-32;sample_slope<32;sample_slope=sample_slope+1)
  for(sample_error=-64;sample_error<=64;sample_error=sample_error+1)begin
   profile_error=sample_error;profile_active={12'd0,6'(sample_slope)};#1;
   sample_offset=(sample_slope<0?-sample_slope:sample_slope)/4;
   sample_a=sample_error-sample_offset;if(sample_a<0)sample_a=-sample_a;
   sample_b=sample_error+sample_offset;if(sample_b<0)sample_b=-sample_b;
   sample_a=255-16*sample_a;if(sample_a<0)sample_a=0;
   sample_b=255-16*sample_b;if(sample_b<0)sample_b=0;
   golden=(sample_a+sample_b)/2;
   if(dut.line_fit.coverage!==8'(golden))$fatal(1,"pixel samples slope%0d error%0d got%0d expected%0d",sample_slope,sample_error,dut.line_fit.coverage,golden);
   sample_checks=sample_checks+1;
  end
 release dut.line_fit.error;release dut.line_fit.active;
 for(f=0;f<5;f=f+1)begin
  for(yy=0;yy<H;yy=yy+1)for(xx=0;xx<W;xx=xx+1)
   case(f)
    0:map[yy*W+xx]=yy==8+xx/3;
    1:map[yy*W+xx]=yy==27-xx/3;
    2:map[yy*W+xx]=xx==8+yy/3;
    3:map[yy*W+xx]=xx==28-yy/3;
    default:map[yy*W+xx]=0;
   endcase
  for(yy=0;yy<H;yy=yy+1)for(xx=0;xx<W;xx=xx+1)
   if(xx<2||xx>=W-2||yy<2||yy>=H-2)map[yy*W+xx]=0;
  @(negedge clk);vblank=1;de=0;repeat(8)@(negedge clk);vblank=0;
  wait(!dut.prefill);repeat(16)@(negedge clk);
  for(yy=0;yy<PH;yy=yy+1)begin
   for(xx=0;xx<PW;xx=xx+1)begin
    @(negedge clk);de=1;x=xx;y=yy;@(posedge clk);#1;
    cx=xx/4;cy=yy/4;pattern=0;
    for(b=-1;b<=1;b=b+1)for(a=-1;a<=1;a=a+1)begin
     nx=cx+a;ny=cy+b;
     if(nx>=0&&nx<W&&ny>=0&&ny<H&&map[ny*W+nx])pattern=pattern|(1<<(8-(b+1)*3-a-1));
    end
    level=lut[pattern][5*((yy%4)*4+xx%4)+:5];expected={level,level[4:2]};
    minor=f==0?8+cx/3:f==1?27-cx/3:f==2?8+cy/3:28-cy/3;
    minor_axis=f<2?cy:cx;
    major=f<2?cx:cy;
    radius=(major>=6&&major<(f<2?W:H)-6)?4:(major>=4&&major<(f<2?W:H)-4)?2:0;
    if(f<4&&cx>=2&&cx<W-2&&cy>=2&&cy<H-2&&radius!=0&&minor-minor_axis>=-1&&minor-minor_axis<=1)begin
     total=0;weight=0;
     for(k=-radius;k<=radius;k=k+1)begin
      minor=(f==0?8+(cx+k)/3:f==1?27-(cx+k)/3:f==2?8+(cy+k)/3:28-(cy+k)/3)-minor_axis;
      total=total+minor;weight=weight+k*minor;
     end
     slope=radius==4?(weight*17+32)>>>6:(weight*13+4)>>>3;
     start=32+(radius==4?((total*57+4)>>>3):((total*51+2)>>>2))-2*slope;
     major=f<2?xx%4:yy%4;minor_axis=f<2?yy%4:xx%4;
     distance=minor_axis*16-(start+major*slope);if(distance<0)distance=-distance;
     sample_offset=(slope<0?-slope:slope)/4;
     sample_a=distance-sample_offset;if(sample_a<0)sample_a=-sample_a;
     sample_b=distance+sample_offset;
     sample_a=255-16*sample_a;if(sample_a<0)sample_a=0;
     sample_b=255-16*sample_b;if(sample_b<0)sample_b=0;
     expected=(sample_a+sample_b)/2;fit_checks=fit_checks+1;
    end
    if(cx<2||cx>=W-2||cy<2||cy>=H-2)expected=0;
    if(coverage!==expected)$fatal(1,"fit frame%0d x%0d y%0d got%0d expected%0d enable%b active%h",f,xx,yy,coverage,expected,dut.fit_enable,dut.line_fit.active);
    checks=checks+1;
   end
   @(negedge clk);de=0;x=0;repeat(12)@(negedge clk);
  end
 end
 if(fit_checks<3000)$fatal(1,"straight-fit interior not exercised");
 $display("PASS9-point fit %0d raster pixels, %0d fitted pixels, %0d pixel-area cases, +/- shallow/steep slopes and empty next frame",checks,fit_checks,sample_checks);$finish;
end
endmodule
