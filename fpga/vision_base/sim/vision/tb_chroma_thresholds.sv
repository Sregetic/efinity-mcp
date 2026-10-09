`timescale 1ns/1ps
// Exhaust the complete 16-bit gain domain against the original integer formula.
// Run with rgb_chroma_tone.sv from the vision_base working directory.
module tb;
reg clk=0;always #5 clk=~clk;
reg[15:0]gr=0,gg=0,gb=0;
wire od,oh,ov,hit;wire[23:0]rgb,linear_rgb,plain_rgb;
rgb_chroma_tone #(
 .SHADOW_FILE("board/ti60f225_v4/rtl/gamma_conrrection/chroma_shadow_gain_q8.mem"),
 .GAIN_FILE("board/ti60f225_v4/rtl/gamma_conrrection/chroma_tone_gain_q8.mem")
) dut(clk,1'b1,1'b0,1'b0,1'b0,8'd0,8'd0,8'd0,
 od,oh,ov,rgb,linear_rgb,gr,gg,gb,plain_rgb,hit,1'b0,1'b0,);

function automatic[143:0]reference(input[15:0]gain);
 integer k,c,l;
 begin
  for(k=0;k<8;k=k+1)begin
   c=(223+2*k)*gain;l=(144+8*k)*gain;
   reference[k*9+:9]=(gain==0||c>65280)?9'd256:(c>>8);
   reference[72+k*9+:9]=(gain==0||l>65280)?9'd256:(l>>8);
  end
 end
endfunction

integer i;
initial begin
 for(i=0;i<65536;i=i+1)begin
  @(negedge clk);gr=i;gg=65535-i;gb=i*40503+37;
  @(posedge clk);#1;
  if({dut.lr,dut.cr}!==reference(gr))$fatal(1,"red thresholds gain=%0d",gr);
  if({dut.lg,dut.cg}!==reference(gg))$fatal(1,"green thresholds gain=%0d",gg);
  if({dut.lb,dut.cb}!==reference(gb))$fatal(1,"blue thresholds gain=%0d",gb);
 end
 $display("CHROMA THRESHOLDS PASS 65536 gains/channel, 3145728 threshold checks, cycle-exact updates");
 $finish;
end
initial begin #1000000;$fatal(1,"threshold regression timeout");end
endmodule
