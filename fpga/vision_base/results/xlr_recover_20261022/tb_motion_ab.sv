`timescale 1ns/1ps
module tb;
parameter FRAMES=346;
reg clk=0;always #5 clk=~clk;
reg rst=0,abort_frame=0,iv=0,first=0,last=0,clear_history=0,oready=0;
reg[7:0]gray;wire ir,ov,tv,rv,fault;wire[2:0]direction;wire signed[31:0]hx,vy;
wire[15:0]active;wire[3:0]x0,y0,x1,y1;
vision_local_motion_core dut(clk,rst,abort_frame,iv,ir,first,last,clear_history,gray,
 ov,oready,tv,direction,hx,vy,active,rv,x0,x1,y0,y1,fault);

wire old_ir,old_ov,old_tv,old_rv,old_fault;wire[2:0]old_direction;
wire signed[31:0]old_hx,old_vy;wire[15:0]old_active;wire[3:0]old_x0,old_y0,old_x1,old_y1;
vision_local_motion_core_reference ref_dut(clk,rst,abort_frame,iv,old_ir,first,last,clear_history,gray,
 old_ov,oready,old_tv,old_direction,old_hx,old_vy,old_active,old_rv,old_x0,old_x1,old_y0,old_y1,old_fault);
integer cycle_pairs=0;
always @(posedge clk)begin
 #1;
 if({ir,ov,tv,rv,fault,direction,hx,vy,active,x0,y0,x1,y1}!==
    {old_ir,old_ov,old_tv,old_rv,old_fault,old_direction,old_hx,old_vy,old_active,old_x0,old_y0,old_x1,old_y1})
  $fatal(1,"Motion public port/cycle mismatch %0d",cycle_pairs);
 cycle_pairs=cycle_pairs+1;
end
reg[7:0]words[0:FRAMES*144-1],resets[0:FRAMES-1];
reg[100:0]expected[0:FRAMES-1];wire[100:0]actual={tv,direction,rv,active,hx,vy,x0,y0,x1,y1};
integer f,i,n=0,stalls=0;reg[100:0]held;
task send_word(input[7:0]value,input sf,sl,rh);
 begin
  @(negedge clk);iv=1;gray=value;first=sf;last=sl;clear_history=rh;
  while(!ir)begin @(negedge clk);stalls=stalls+1;end
  @(negedge clk);iv=0;
 end
endtask
initial begin
 $readmemh("vectors/grid_words.mem",words);
 $readmemh("vectors/reset_history.mem",resets);
 $readmemh("vectors/core_expected.mem",expected);
 repeat(3)@(negedge clk);rst=1;
 for(f=0;f<FRAMES;f=f+1)begin
  for(i=0;i<144;i=i+1)begin
   send_word(words[f*144+i],i==0,i==143,resets[f][0]);
   if((i+f)%17==0)repeat(3)@(negedge clk);
  end
  while(!ov)@(negedge clk);
  if(actual!==expected[f])begin $display("BAD frame=%0d actual=%h expected=%h hx=%0d vy=%0d",f,actual,expected[f],hx,vy);$fatal;end
  held=actual;
  repeat(5+(f%7))begin @(negedge clk);if(!ov||ir||actual!==held)$fatal(1,"Output not held under backpressure");end
  oready=1;@(negedge clk);oready=0;n=n+1;
 end
 if(fault)$fatal(1,"Unexpected core packet fault");
 // Abort a partial packet. The next complete packet must be a warmup.
 for(i=0;i<7;i=i+1)send_word(255,i==0,0,0);
 @(negedge clk);abort_frame=1;@(negedge clk);abort_frame=0;
 for(i=0;i<144;i=i+1)send_word(i[7:0],i==0,i==143,0);
 while(!ov)@(negedge clk);
 if(tv||rv||direction!=0||hx!=0||vy!=0)$fatal(1,"Abort did not invalidate history");
 oready=1;@(negedge clk);oready=0;
 // A malformed last marker cannot publish a partial result.
 send_word(255,1,1,0);repeat(30)@(negedge clk);
 if(ov||!fault)$fatal(1,"Malformed packet silently accepted");
 $display("PASS motion A/B %0d identical port cycles",cycle_pairs);
 $display("PASS local motion core frames=%0d synthetic-only stalled_cycles=%0d",n,stalls);$finish;
end
initial begin #100000000;$fatal(1,"Core timeout");end
endmodule
