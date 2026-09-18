`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst=0,valid=0,hs=0,vs=0;reg[7:0]value=0;
wire[7:0]r,g,b;wire ov,oh,os;
reg[9:0]lut[0:1023];integer i,errors=0;reg[7:0]expected;
gamma_correction #(.DATA_WIDTH(8),.GAMMA_CURVE("board/ti60f225_v4/rtl/gamma_conrrection/display_gamma_toe.mem")) dut(.i_pclk(clk),.i_rstn(rst),.i_valid(valid),.i_hs(hs),.i_vs(vs),.i_red(value),.i_green(value),.i_blue(value),.o_red(r),.o_green(g),.o_blue(b),.o_valid(ov),.o_hs(oh),.o_vs(os));
initial begin
 $readmemh("board/ti60f225_v4/rtl/gamma_conrrection/display_gamma_toe.mem",lut);
 #21;rst=1;repeat(4096)@(negedge clk);
 for(i=0;i<256;i=i+1)begin
 value=i;valid=1;hs=i%2;vs=(i%3)==0;expected=lut[(i<<2)|(i>>6)]>>2;
 @(posedge clk);#1;
 if(r!==expected||g!==expected||b!==expected||ov!==valid||oh!==hs||os!==vs)begin errors++;if(errors<6)$display("BAD input=%d actual=%d expected=%d",i,r,expected);end
 @(negedge clk);
 end
 valid=0;@(posedge clk);#1;if(ov!==0||r!==0||g!==0||b!==0)errors++;
 $display("RESULT 256 gray codes and blanking errors=%0d",errors);if(errors)$fatal; $finish;
end
endmodule
