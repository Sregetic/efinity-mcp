`timescale 1ns/1ps
module tb;
reg clk=0,rst_n=0,vs=0,hs=0,valid=0;reg[31:0]data=0;
wire ovs,ohs,ov,overrun;wire[31:0]od;
bayer_fov_reduce dut(clk,rst_n,vs,hs,valid,data,ovs,ohs,ov,od,overrun);
always #5 clk=~clk;
integer frame_id=0,words=0,lines=0,line_words=0,frames=0,cycles=0;
reg old_hs=0,old_vs=0;
function automatic integer source(input integer f,xx,yy);
 begin source=(xx*13+yy*29+(xx/7)*(yy/9)+f*67)&255;end
endfunction
function automatic integer blend(input integer a,b,p);
 begin case(p)0:blend=(3*a+b+2)/4;1:blend=(2*a+2*b+2)/4;default:blend=(a+3*b+2)/4;endcase end
endfunction
function automatic integer horizontal(input integer f,xx,yy);
 integer ix,p;
 begin p=(xx%6)/2;ix=(xx/6)*8+p*2+(xx%2);horizontal=blend(source(f,ix,yy),source(f,ix+2,yy),p);end
endfunction
function automatic[7:0]expected(input integer f,xx,yy);
 integer iy,p;
 begin p=(yy%6)/2;iy=(yy/6)*8+p*2+(yy%2);expected=blend(horizontal(f,xx,iy),horizontal(f,xx,iy+2),p);end
endfunction
`ifdef FOV_COMPARE_REFERENCE
wire rvs,rhs,rv,ro;wire[31:0]rd;
bayer_fov_reduce_reference reference(clk,rst_n,vs,hs,valid,data,rvs,rhs,rv,rd,ro);
`endif
always @(posedge clk)begin
 #1;cycles=cycles+1;
 if(rst_n)begin
`ifdef FOV_COMPARE_REFERENCE
  if({ovs,ohs,ov,overrun}!=={rvs,rhs,rv,ro} || (ov && od!==rd))
   $fatal(1,"old/new cycle mismatch cycle=%0d data=%h/%h",cycles,od,rd);
`endif
  if(overrun)$fatal(1,"FOV overrun");
  if(ovs&&!old_vs)begin words=0;lines=0;line_words=0;end
  if(ov)begin
   if(!ovs||!ohs)$fatal(1,"output outside active line/frame");
   if(od!=={expected(frame_id,line_words*4,lines),expected(frame_id,line_words*4+1,lines),expected(frame_id,line_words*4+2,lines),expected(frame_id,line_words*4+3,lines)})
    $fatal(1,"pixel mismatch frame=%0d x=%0d y=%0d got=%h",frame_id,line_words*4,lines,od);
   words=words+1;line_words=line_words+1;
  end
  if(old_hs&&!ohs)begin
   if(line_words!=480)$fatal(1,"output row length %0d",line_words);
   lines=lines+1;line_words=0;
  end
  if(old_vs&&!ovs)begin
   if(words!=518400||lines!=1080)$fatal(1,"frame geometry words=%0d lines=%0d",words,lines);
   frames=frames+1;$display("PASS FOV frame=%0d pixels=2073600, 1080 rows, no overrun",frame_id);
  end
 end
 old_hs=ohs;old_vs=ovs;
 if(cycles>3000000)$fatal(1,"timeout");
end
task send_frame(input integer f);
 integer yy,ww;reg[7:0]a,b,c,d;
 begin
  frame_id=f;@(negedge clk);vs=1;repeat(3)@(negedge clk);vs=0;
  for(yy=0;yy<1440;yy=yy+1)begin
   hs=1;
   for(ww=0;ww<640;ww=ww+1)begin
    a=source(f,ww*4,yy);b=source(f,ww*4+1,yy);c=source(f,ww*4+2,yy);d=source(f,ww*4+3,yy);
    data={a,b,c,d};valid=1;@(negedge clk);
    if(f==1 && ww%97==23)begin valid=0;repeat(2)@(negedge clk);end
   end
   valid=0;hs=0;repeat(24)@(negedge clk);
  end
  wait(!ovs);repeat(20)@(negedge clk);
 end
endtask
initial begin
 repeat(4)@(negedge clk);rst_n=1;
 send_frame(0);send_frame(1);
 if(frames!=2)$fatal(1,"missing output frame");
 @(negedge clk);rst_n=0;repeat(4)@(negedge clk);
 if(ovs||ov||ohs||overrun)$fatal(1,"reset stale state");
 $display("PASS FOV 4147200 pixels, bit-exact filter, bubbles, frame boundary and reset");$finish;
end
endmodule
