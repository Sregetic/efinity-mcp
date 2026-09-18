`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0,de=0,hs=0,vs=0;reg[7:0]r=0,g=0,b=0;
wire od,oh,ov;wire[23:0]rgb,linear_rgb;reg[15:0]lut[0:255];
rgb_chroma_tone #(.GAIN_FILE("board/ti60f225_v4/rtl/gamma_conrrection/chroma_tone_gain_q8.mem"))dut(clk,rst,de,hs,vs,r,g,b,od,oh,ov,rgb,linear_rgb);
reg[23:0]inputs[0:801];reg[2:0]syncs[0:801];reg[23:0]expected;integer i,j,peak,gain,rr,gg,bb,checked=0;
initial begin
 $readmemh("board/ti60f225_v4/rtl/gamma_conrrection/chroma_tone_gain_q8.mem",lut);
 #21;rst=1;
 for(i=0;i<802;i=i+1)begin
  @(negedge clk);r=i*37;g=i*19+65;b=i;
  if(i%17==0)begin r=0;g=0;b=0;end
  if(i%19==0)begin r=i;g=i;b=i;end
  if(i%23==0)begin r=i;g=0;b=0;end
  de=i<800&&i%5!=0;hs=i%7==0;vs=i%73==0;
  inputs[i]={r,g,b};syncs[i]={de,hs,vs};@(posedge clk);#1;
  if(i>=2)begin
   j=i-2;rr=inputs[j][23:16];gg=inputs[j][15:8];bb=inputs[j][7:0];peak=rr>gg?rr:gg;if(bb>peak)peak=bb;gain=lut[peak];
   rr=(rr*gain+128)>>8;gg=(gg*gain+128)>>8;bb=(bb*gain+128)>>8;
   if(rr>255)rr=255;if(gg>255)gg=255;if(bb>255)bb=255;
   expected=syncs[j][2]?{8'(rr),8'(gg),8'(bb)}:0;
   if(rgb!==expected||linear_rgb!==(syncs[j][2]?inputs[j]:24'd0)||{od,oh,ov}!==syncs[j])$fatal(1,"tone mismatch sample%0d got%h expected%h",j,rgb,expected);
   checked=checked+1;
  end
 end
 $display("CHROMA TONE PASS %0d samples, RGB/common gain, black, gray, pure colors, bypass, DE/HS/VS alignment",checked);$finish;
end
endmodule
