`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst=0,de=0,hs=0,vs=0,median_en=0;reg[23:0]pixel=0;
wire fd,fh,fv,border;wire[11:0]x,y;wire[7:0]r,g,b,gray;wire[10:0]mag;wire[1:0]dir;
vision_frontend #(.WIDTH(32))dut(clk,rst,de,hs,vs,pixel[23:16],pixel[15:8],pixel[7:0],median_en,
 fd,fh,fv,border,x,y,r,g,b,gray,mag,dir,11'd64,);
function automatic[23:0]clean(input integer px);clean=px<16?24'h606870:24'hc0b8b0;endfunction
function automatic[23:0]noisy(input integer px,py);
 begin noisy=clean(px);if(px==10&&py==8)noisy=24'h00ff00;if(px==22&&py==7)noisy=24'hff00ff;end
endfunction
integer ix,iy,f,checked=0,errors=0,sx,sy;reg[23:0]expected;
always @(negedge clk)if(fd&&x>=5&&x<30&&y>=5&&y<14)begin
 sx=x-2;sy=y-2;expected=median_en?clean(sx):noisy(sx,sy);
 if({r,g,b}!==expected)begin errors++;$display("BAD median%0d source%0d,%0d got%h expected%h",median_en,sx,sy,{r,g,b},expected);end
 checked++;
end
initial begin
 #21;rst=1;
 for(f=0;f<2;f++)begin
  median_en=f;vs=1;#40;vs=0;#80;
  for(iy=0;iy<16;iy++)begin
   for(ix=0;ix<32;ix++)begin de=1;pixel=noisy(ix,iy);#10;end
   de=0;hs=1;#80;hs=0;#80;
  end
  #400;
 end
 $display("RGB denoise checked=%0d errors=%0d",checked,errors);
 if(checked!=450||errors)$fatal(1,"RGB denoise/disabled bypass/edge alignment failed");$finish;
end
endmodule
