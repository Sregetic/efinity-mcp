`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0,de=0,hs=0,vs=0;reg[7:0]p=0;reg me=0;
wire fd,fh,fv,border;wire[11:0]x,y;wire[7:0]r,g,b,gray;wire[10:0]mag;wire[1:0]dir;
vision_frontend #(.WIDTH(32))dut(clk,rst,de,hs,vs,p,(8'd255-p),8'd37,me,fd,fh,fv,border,x,y,r,g,b,gray,mag,dir,11'd64,);
integer ix,iy,f,errors=0,checked=0,n=0,expected;
always @(negedge clk)if(fd)begin
 n=n+1;
 if(x>=5&&x<30&&y>=5&&y<14)begin
 expected=4*(x-2)+2*(y-2);
 if(r!==expected[7:0]||g!==(8'd255-expected[7:0])||b!==8'd37)begin
  errors++;if(errors<10)$display("BAD x%0d y%0d gray%0d rgb%h%h%h mag%0d expected%0d",x,y,gray,r,g,b,mag,expected);
 end
 checked++;
 end
end
initial begin
 #21;rst=1;
 for(f=0;f<2;f++)begin me=f;vs=1;#40;vs=0;#80;
 for(iy=0;iy<16;iy++)begin
  for(ix=0;ix<32;ix++)begin de=1;p=4*ix+2*iy;#10;end
  de=0;hs=1;#80;hs=0;#80;
 end
 #400;
 end
 $display("RESULT pixels=%d checked=%d errors=%d",n,checked,errors);
 if(errors||n!=1024||checked!=450)$fatal;$finish;
end
endmodule
