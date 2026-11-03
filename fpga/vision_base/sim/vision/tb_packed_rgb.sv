`timescale 1ns/1ps
module tb;
reg[23:0]rgb=0;
vision_rgb_capture #(.W(8),.H(2),.FIFO_AW(4)) dut(.rst_n(1'b0),.video_clk(1'b0),.vs(1'b0),.de(1'b0),.rgb(rgb),
 .raw_id(32'd0),.clk(1'b0),.enable(1'b0),.freeze_source(1'b0),.capture_ready(1'b0),.capture_pixel_ready(1'b0),.capture_done(1'b0),.capture_error(1'b0));
integer i,r,g,b,errors=0,checked=0;reg[15:0]expected;reg[23:0]decoded;
function automatic[23:0]decode(input[15:0]v);
 decode=v[15]?{v[14:10],v[14:12],v[9:5],v[9:7],v[4:0],v[4:2]}:{2'b0,v[14:10],1'b0,2'b0,v[9:5],1'b0,2'b0,v[4:0],1'b0};
endfunction
initial begin
 // Exhaust the fine range, including the formerly coarse32..63 interval.
 for(r=0;r<64;r++)for(g=0;g<64;g++)for(b=0;b<64;b++)begin
  rgb={8'(r),8'(g),8'(b)};#1;
  decoded=decode(dut.pixel);
  if(dut.pixel!=={1'b0,5'(r/2),5'(g/2),5'(b/2)}||
    decoded!=={8'(r/2*2),8'(g/2*2),8'(b/2*2)})errors++;
  checked++;
 end
 for(i=0;i<256;i++)begin
  r=i;g=255-i;b=(73*i)%256;rgb={8'(r),8'(g),8'(b)};#1;
  expected={1'b1,5'((r*31+127)/255),5'((g*31+127)/255),5'((b*31+127)/255)};
  if(dut.pixel!==expected)errors++;checked++;
 end
 // Equal-channel gray stays gray across both31/32 and63/64, including black/white.
 for(i=0;i<256;i++)begin
  rgb={3{8'(i)}};#1;decoded=decode(dut.pixel);
  if(decoded[23:16]!==decoded[15:8]||decoded[15:8]!==decoded[7:0])errors++;
  if(i<64&&(decoded[7:0]>i||i-decoded[7:0]>1))errors++;
  if(i>=64&&($signed({1'b0,decoded[7:0]})-i>4||i-$signed({1'b0,decoded[7:0]})>4))errors++;
  checked++;
 end
 $display("Packed RGB checked=%0d errors=%0d:262144 fine-range colors error<=1, independent bright channels, neutral gray and range boundary",checked,errors);
 if(errors)$fatal(1,"Packed RGB codec failed");$finish;
end
endmodule
