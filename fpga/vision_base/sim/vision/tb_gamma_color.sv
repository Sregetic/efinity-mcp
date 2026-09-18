`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0,de=0;reg[7:0]r=0,g=0,b=0;
wire[7:0]ro,go,bo;wire od,oh,ov;reg[9:0]lut[0:1023];integer i,errors=0;
gamma_correction #(.DATA_WIDTH(8),.GAMMA_CURVE("board/ti60f225_v4/rtl/gamma_conrrection/display_gamma_2p2.mem")) dut(clk,rst,de,1'b0,1'b0,r,g,b,ro,go,bo,od,oh,ov);
initial begin
 $readmemh("board/ti60f225_v4/rtl/gamma_conrrection/display_gamma_2p2.mem",lut);
 #21;rst=1;repeat(2100)@(negedge clk);
 for(i=0;i<256;i=i+1)begin
  @(negedge clk);de=1;r=i;g=255-i;b=37;@(posedge clk);#1;
  if(ro!==(lut[{r,r[7:6]}]>>2)||go!==(lut[{g,g[7:6]}]>>2)||bo!==(lut[{b,b[7:6]}]>>2)||!od)begin
   errors=errors+1;if(errors<6)$display("GAMMA BAD %0d rgb=%0d/%0d/%0d",i,ro,go,bo);
  end
 end
 $display("GAMMA independent RGB 256 inputs errors=%0d",errors);if(errors)$fatal;$finish;
end
endmodule
