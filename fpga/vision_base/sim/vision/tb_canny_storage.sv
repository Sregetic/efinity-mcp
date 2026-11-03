`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg[11:0]x=0,y=0;wire[8:0]fx,fy;wire pixel;wire[7:0]coverage;wire[31:0]coarse,shown;
reg[8:0]pattern=0;reg short_case=0;reg[6:0]sum_code=0;reg[7:0]weight_code=0;
reg[79:0]coverage_reference[0:511];reg[9:0]fit_reference[0:1023];
integer p,phase,s,a,b,coverage_checks=0,fit_checks=0;
vision_canny_raster #(.W(16),.H(12),
 .INDEX_FILE("board/ti60f225_v4/rtl/vision/canny_coverage_index.mem"),
 .PALETTE_FILE("board/ti60f225_v4/rtl/vision/canny_coverage_palette.mem")) dut(
 clk,1'b1,1'b0,1'b0,x,y,1'b0,1'b0,fx,fy,pixel,coarse,shown,coverage);
initial begin
 $readmemh("board/ti60f225_v4/rtl/vision/canny_coverage_q5.mem",coverage_reference);
 $readmemh("board/ti60f225_v4/rtl/vision/canny_fit_q4.mem",fit_reference);
 force dut.tile=pattern;
 for(p=0;p<512;p=p+1)for(phase=0;phase<16;phase=phase+1)begin
  @(negedge clk);pattern=p;x=phase%4;y=phase/4;
  @(posedge clk);#1;
  if(dut.curve_level!==coverage_reference[p][5*phase+:5])$fatal(1,"Coverage pattern%0d phase%0d",p,phase);
  coverage_checks=coverage_checks+1;
 end
 release dut.tile;
 force dut.line_fit.result_short=short_case;
 force dut.line_fit.result_sum=sum_code;
 force dut.line_fit.result_weight=weight_code;
 for(s=0;s<2;s=s+1)for(a=0;a<128;a=a+1)for(b=0;b<256;b=b+1)begin
  @(negedge clk);short_case=s;sum_code=a;weight_code=b;
  @(posedge clk);#1;
  if(dut.line_fit.center_q!==fit_reference[(s<<7)|a]||dut.line_fit.slope!==fit_reference[512|(s<<8)|b][5:0])
   $fatal(1,"Signed fit/truncation mismatch short%0d sum%0d weight%0d",s,a,b);
  fit_checks=fit_checks+1;
 end
 $display("PASS production Canny storage: %0d coverage and %0d signed fit cycle pairs",coverage_checks,fit_checks);$finish;
end
endmodule
