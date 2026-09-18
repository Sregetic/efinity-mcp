`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst=0,vs=0,hs=0,valid=0;reg[31:0]data=0;
wire ov,oh,od;wire[31:0]outdata;
bayer_fov_reduce dut(clk,rst,vs,hs,valid,data,ov,oh,od,outdata);
integer x,y,k,n=0,errors=0,dx,dy,sx,sy;reg[7:0]expected;
always @(negedge clk)if(od)begin
 dy=n/480;
 for(k=0;k<4;k=k+1)begin
 dx=(n%480)*4+k;sx=2*((dx/2)+(dx/2)/3)+(dx%2);sy=2*((dy/2)+(dy/2)/3)+(dy%2);
 expected=(sx+17*sy)%256;
 if(outdata[31-8*k-:8]!==expected || !oh)begin errors++;if(errors<5)$display("BAD word=%d x=%d y=%d actual=%d expected=%d",n,dx,dy,outdata[31-8*k-:8],expected);end
 end
 n++;
end
initial begin
 #31;rst=1;vs=1;#40;vs=0;#40;
 for(y=0;y<1440;y++)begin
 hs=1;
 for(x=0;x<2560;x+=4)begin
 valid=1;for(k=0;k<4;k++)data[31-k*8-:8]=(x+k+17*y)%256;
 #10;if((x%68)==0)begin valid=0;#10;end
 end
 valid=0;hs=0;#60;
 end
 #50;
 $display("RESULT words=%0d expected=518400 pixels=%0d errors=%0d",n,n*4,errors);
 if(n!=518400||errors)$fatal;$finish;
end
endmodule
