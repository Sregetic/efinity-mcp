`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst=0,vs=0,hs=0,valid=0;reg[31:0]data=0;
wire ov,oh,od;wire[31:0]outdata;
bayer_fov_reduce dut(clk,rst,vs,hs,valid,data,ov,oh,od,outdata);
function automatic integer mix(input integer a,input integer b,input integer phase);
 case(phase)0:mix=(3*a+b+2)/4;1:mix=(2*a+2*b+2)/4;default:mix=(a+3*b+2)/4;endcase
endfunction
function automatic integer hsample(input integer dx,input integer sy);
 integer sx,p;
 begin p=(dx%6)/2;sx=8*(dx/6)+2*p+dx%2;
 hsample=mix((sx+17*sy)%256,(sx+2+17*sy)%256,p);end
endfunction
integer x,y,k,n=0,errors=0,dx,dy,sx,sy,at_end=0;reg[7:0]expected;
always @(negedge clk)if(od)begin
 dy=n/480;
 for(k=0;k<4;k=k+1)begin
 dx=(n%480)*4+k;sy=8*(dy/6)+2*((dy%6)/2)+dy%2;
 expected=mix(hsample(dx,sy),hsample(dx,sy+2),(dy%6)/2);
 if(outdata[31-8*k-:8]!==expected || !oh)begin errors++;if(errors<5)$display("BAD word=%d x=%d y=%d actual=%d expected=%d",n,dx,dy,outdata[31-8*k-:8],expected);end
 end
 n++;
end
always @(negedge ov) if(n>0)begin at_end=n;$display("FRAME_END received_words=%0d expected=518400",n);end
initial begin
 #31;rst=1;#40;vs=1;#40;
 for(y=0;y<1440;y++)begin
 hs=1;
 for(x=0;x<2560;x+=4)begin
 valid=1;for(k=0;k<4;k++)data[31-k*8-:8]=(x+k+17*y)%256;
 #10;if((x%68)==0)begin valid=0;#10;end
 end
 valid=0;hs=0;#60;
 end
 vs=0;#50000;
 $display("RESULT words=%0d expected=518400 pixels=%0d errors=%0d",n,n*4,errors);
 if(n!=518400||errors||dut.overrun||at_end!=518400)$fatal;$finish;
end
endmodule
