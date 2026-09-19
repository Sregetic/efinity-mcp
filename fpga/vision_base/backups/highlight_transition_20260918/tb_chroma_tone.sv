`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0,de=0,hs=0,vs=0;reg[7:0]r=0,g=0,b=0;
wire od,oh,ov,hit;wire[23:0]rgb,linear_rgb,plain_rgb;reg[15:0]lut[0:255];
rgb_chroma_tone #(.SHADOW_FILE("board/ti60f225_v4/rtl/gamma_conrrection/chroma_shadow_gain_q8.mem"),.GAIN_FILE("board/ti60f225_v4/rtl/gamma_conrrection/chroma_tone_gain_q8.mem"))dut(clk,rst,de,hs,vs,r,g,b,od,oh,ov,rgb,linear_rgb,16'd256,16'd161,16'd162,plain_rgb,hit,1'b0);
reg[23:0]inputs[0:802];reg[2:0]syncs[0:802];reg[23:0]expected,plain_expected;integer i,j,peak,gain,rr,gg,bb,checked=0,a,c,l,k,z,ir,ig,ib;
function automatic integer rank(input integer v,gain,base);
 integer n;begin rank=0;for(n=0;n<8;n=n+1)if(v>=((base+((base==223)?2:8)*n)*gain)/256)rank=n+1;end
endfunction
initial begin
 $readmemh("board/ti60f225_v4/rtl/gamma_conrrection/chroma_tone_gain_q8.mem",lut);
 #21;rst=1;
 for(i=0;i<803;i=i+1)begin
  @(negedge clk);r=i*37;g=i*19+65;b=i;
  if(i%17==0)begin r=0;g=0;b=0;end
  if(i%19==0)begin r=i;g=i;b=i;end
  if(i%23==0)begin r=i;g=0;b=0;end
  if(i%29==0)begin r=239;g=150;b=151;end // Measured clipped window tile after WB.
  if(i%31==0)begin r=239;g=30;b=20;end // Bright blue object: do not neutralize.
  de=i<800&&i%5!=0;hs=i%7==0;vs=i%73==0;
  inputs[i]={r,g,b};syncs[i]={de,hs,vs};@(posedge clk);#1;
  if(i>=3)begin
   j=i-3;ir=inputs[j][23:16];ig=inputs[j][15:8];ib=inputs[j][7:0];rr=ir;gg=ig;bb=ib;peak=rr>gg?rr:gg;if(bb>peak)peak=bb;gain=lut[peak];
   rr=(rr*gain+128)>>8;gg=(gg*gain+128)>>8;bb=(bb*gain+128)>>8;
   if(rr>255)rr=255;if(gg>255)gg=255;if(bb>255)bb=255;
   plain_expected=syncs[j][2]?{8'(rr),8'(gg),8'(bb)}:0;
   c=rank(ir,256,223);k=rank(ig,161,223);z=rank(ib,162,223);
   if(k>c)c=k;if(z>c)c=z;
   l=rank(ir,256,144);z=rank(ig,161,144);if(z<l)l=z;z=rank(ib,162,144);if(z<l)l=z;
   a=(c<l)?c:l;peak=rr>gg?rr:gg;if(bb>peak)peak=bb;
   rr=rr+((peak-rr)*a+4)/8;gg=gg+((peak-gg)*a+4)/8;bb=bb+((peak-bb)*a+4)/8;
   expected=syncs[j][2]?{8'(rr),8'(gg),8'(bb)}:0;
   if(rgb!==expected||plain_rgb!==plain_expected||linear_rgb!==(syncs[j][2]?inputs[j]:24'd0)||{od,oh,ov}!==syncs[j]||hit!==(syncs[j][2]&&a!=0))$fatal(1,"tone mismatch sample%0d got%h expected%h",j,rgb,expected);
   if(j%31==0&&syncs[j][2]&&(hit||rgb!==plain_rgb))$fatal(1,"blue object neutralized");
   if(j%29==0&&j%31!=0&&syncs[j][2]&&(!(rgb[23:16]==rgb[15:8]&&rgb[15:8]==rgb[7:0])||!hit))$fatal(1,"clipped window remains colored");
   checked=checked+1;
  end
 end
 $display("HIGHLIGHT TONE PASS %0d samples, clipped window neutral, blue preserved, four-cycle alignment, old tone/bypass",checked);$finish;
end
endmodule
