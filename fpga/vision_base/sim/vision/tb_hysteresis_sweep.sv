`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0,vblank=0,cv=0,last=0;reg[7:0]x=0,y=0,dx=0,dy=0;reg[1:0]c=0;
wire cap,ready,busy,pixel,fault;wire[31:0]frames;wire[3:0]state;wire[8:0]queued;
vision_hysteresis_sweep #(.W(16),.H(12),.CW(8))dut(clk,rst,vblank,cv,x,y,c,last,dx,dy,cap,ready,busy,pixel,frames,fault,state,queued);
function automatic integer path(input integer a,b);begin path=(b==1&&a>=1&&a<=14)||(a==14&&b>=1&&b<=10)||(b==10&&a>=1&&a<=14)||(a==b&&a>=2&&a<=4);end endfunction
integer ix,iy,errors=0;
initial begin
 #21;rst=1;wait(state==1);@(negedge clk);vblank=1;#10;vblank=0;wait(cap);
 for(iy=0;iy<12;iy++)for(ix=0;ix<16;ix++)begin
 @(negedge clk);x=ix;y=iy;cv=1;c=(ix==1&&iy==1)?2:((path(ix,iy)||(ix==8&&iy==5))?1:0);last=(ix==15&&iy==11);
 end
 @(negedge clk);cv=0;last=0;wait(state==8);if(ready)$fatal(1,"published before vblank");
 @(negedge clk);vblank=1;#10;vblank=0;wait(ready);
 for(iy=0;iy<12;iy++)for(ix=0;ix<16;ix++)begin
 @(negedge clk);dx=ix;dy=iy;@(posedge clk);#1;if(pixel!==1'(path(ix,iy)))begin errors++;$display("BAD %d,%d",ix,iy);end
 end
 if(errors||fault||frames!=1)$fatal;
 wait(state==1);@(negedge clk);vblank=1;#10;vblank=0;wait(cap);
 for(iy=0;iy<12;iy++)for(ix=0;ix<16;ix++)begin
 @(negedge clk);x=ix;y=iy;cv=1;c=0;last=(ix==15&&iy==11);
 end
 @(negedge clk);cv=0;last=0;wait(state==8);
 dx=1;dy=1;@(posedge clk);#1;if(!pixel)$fatal(1,"old front changed before publication");
 @(negedge clk);vblank=1;#10;vblank=0;#20;
 for(iy=0;iy<12;iy++)for(ix=0;ix<16;ix++)begin
 @(negedge clk);dx=ix;dy=iy;@(posedge clk);#1;if(pixel!==0)errors++;
 end
 if(errors||fault||frames!=2)$fatal;$display("HYSTERESIS SWEEP PASS long/diagonal chain and disconnected weak rejected");$finish;
end
initial begin #1000000;$fatal(1,"timeout");end
endmodule
