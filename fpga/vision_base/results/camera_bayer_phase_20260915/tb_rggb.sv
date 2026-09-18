`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst=0,vs=0,de=0;reg[15:0]data=0;wire od;wire[47:0]rgb;
debayer_top_2to1 dut(.in_pclk(clk),.in_rstn(rst),.raw_vs_i(vs),.raw_hs_i(1'b0),.raw_de_i(de),.raw_valid_i(de),.raw_datax4_i(data),.r_gain(16'd256),.g_gain(16'd256),.b_gain(16'd256),.rgb_de_o(od),.rgb_datax2_o(rgb));
integer x,y,n=0,errors=0,checked=0;integer yy,xx;
always @(negedge clk)if(od)begin
 yy=n/64;xx=n%64;
 if(yy>=3 && xx>=8 && xx<60)begin
 checked=checked+1;
 if(rgb!==48'h2864b42864b4)begin errors=errors+1;if(errors<8)$display("BAD y=%0d x=%0d rgb=%h",yy,xx,rgb);end
 end
 n=n+1;
end
initial begin
 #31;rst=1;vs=1;#40;vs=0;#40;
 for(y=0;y<8;y=y+1)begin
 for(x=0;x<64;x=x+1)begin de=1;data=(y%2)?16'h2864:16'h64b4;#10;end
 de=0;#140;
 end
 #80;$display("RESULT pairs=%0d checked=%0d errors=%0d",n,checked,errors);$finish;
end
endmodule


