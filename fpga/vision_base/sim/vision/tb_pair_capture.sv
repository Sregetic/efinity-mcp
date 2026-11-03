`timescale 1ns/1ps
module tb;
reg[23:0]rgb=0,rgb_upper=0;
vision_rgb_capture #(.INPUT_PPC(2),.PAIR_DENOISE(1)) dut(.rst_n(1'b0),.video_clk(1'b0),.vs(1'b0),.de(1'b0),.rgb(rgb),.rgb_upper(rgb_upper),
 .raw_id(32'd0),.clk(1'b0),.enable(1'b0),.freeze_source(1'b0),.capture_ready(1'b0),.capture_pixel_ready(1'b0),.capture_done(1'b0),.capture_error(1'b0));
integer a,b,k;reg[23:0]lo,hi;
initial begin
 for(a=0;a<256;a++)for(b=0;b<256;b++)begin
  rgb={3{8'(a)}};rgb_upper={3{8'(b)}};#1;
  if(dut.flat_pair!==((a>b?a-b:b-a)<=8))$fatal(1,"flat pair range %d %d",a,b);
  lo={3{8'((3*a+b+2)/4)}};hi={3{8'((a+3*b+2)/4)}};
  if(!dut.flat_pair)begin lo=rgb;hi=rgb_upper;end
  if(dut.lower_clean!==lo||dut.upper_clean!==hi)$fatal(1,"pair mixing %d %d",a,b);
  if(dut.pixel!==dut.pack_pixel(lo)||dut.upper_pixel!==dut.pack_pixel(hi))$fatal(1,"packing after filter");
 end
 rgb=24'h505050;rgb_upper=24'h595050;#1;
 if(dut.flat_pair||dut.lower_clean!==rgb||dut.upper_clean!==rgb_upper)$fatal(1,"one-channel color boundary blurred");
 rgb=24'hffffff;rgb_upper=24'hffffff;#1;if(dut.lower_clean!==rgb)$fatal(1,"white overflow");
 $display("PASS pre-DDR pair filter65536 flat ranges, exact3:1 /1:3 rounding, strong/color edge bypass, black/white and pack order");$finish;
end
endmodule
