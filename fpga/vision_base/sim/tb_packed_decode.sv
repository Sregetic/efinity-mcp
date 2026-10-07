`timescale 1ns/1ps
module tb_packed_decode;
 reg[15:0]pixel=0;wire[23:0]rgb;vision_packed_rgb dut(pixel,rgb);
 integer i,r,g,b;
 initial begin
  for(i=0;i<65536;i++)begin
   pixel=i;r=(i>>10)&31;g=(i>>5)&31;b=i&31;
   if(i&32768)begin r=r*8+r/4;g=g*8+g/4;b=b*8+b/4;end
   else begin r=r*2;g=g*2;b=b*2;end
   #1;if(rgb!=={8'(r),8'(g),8'(b)})$fatal(1,"packed decode value%0d",i);
  end
  $display("PASS tb_packed_decode: shared packed16 decoder65536 patterns, identical RGB precision/range for display and DMA");$finish;
 end
endmodule
