`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst=0,vs=0,de=0;reg[15:0]data=0;
wire ov,od;wire[15:0]p11,p00,p01;
line_buffer #(.P_DEPTH(8),.X_CNT_WIDTH(10)) dut(.i_arstn(rst),.i_pclk(clk),.i_vsync(vs),.i_hsync(1'b0),.i_de(de),.i_valid(de),.i_p(data),.o_vsync(ov),.o_de(od),.o_p_11(p11),.o_p_00(p00),.o_p_01(p01));
integer x,y,n=0,errors=0;integer yy,xx;
always @(negedge clk)if(od)begin
 yy=n/960;xx=n%960;
 if(p01!==16'(yy*1024+xx) || (yy>=1 && p00!==16'((yy-1)*1024+xx)) || (yy>=2 && p11!==16'((yy-2)*1024+xx)))begin
 errors=errors+1;if(errors<8)$display("BAD y=%0d x=%0d cur=%h prev=%h prev2=%h",yy,xx,p01,p00,p11);
 end
 n=n+1;
end
initial begin
 #1;#30;rst=1;vs=1;#40;vs=0;#40;
 for(y=0;y<6;y=y+1)begin
 for(x=0;x<960;x=x+1)begin de=1;data=y*1024+x;#10;end
 de=0;#140;
 end
 #40;$display("RESULT pairs=%0d errors=%0d",n,errors);$finish;
end
endmodule
