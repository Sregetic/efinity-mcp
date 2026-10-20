`timescale 1ns/1ps
`include "sim/vision/vision_hysteresis_sweep_reference.sv"
module tb;
parameter W=48,H=32;
localparam N=W*H,CW=9;
reg clk=0,rst=0,vblank=0,cv=0,last=0,de=0,req=0,discard=0;
reg[CW-1:0]x=0,y=0,dx=0,dy=0,hx=0,hy=0;
reg[1:0]c=0;reg[11:0]address=0;
wire cap,ready,busy,pixel,fault,ack,pbusy,hpixel;
wire ref_cap,ref_ready,ref_busy,ref_pixel,ref_fault,ref_ack,ref_pbusy,ref_hpixel;
wire[3:0]state,ref_state;wire[$clog2(N):0]queue_size,ref_queue_size;
wire[31:0]frames,data,cycles,passes,visits,ref_frames,ref_data,ref_cycles,ref_passes,ref_visits;
wire[11:0]read_address,ref_read_address;
vision_hysteresis_sweep #(.W(W),.H(H),.CW(CW),.REUSE_CAPTURE_MAP(1),.MIN_COMPONENT(32),.PROBE(1),.ALLOW_DISCARD(1),.HISTORY(1)) dut(
 clk,rst,vblank,cv,x,y,c,last,dx,dy,cap,ready,busy,pixel,frames,fault,state,queue_size,
 de,req,address,ack,data,read_address,pbusy,discard,cycles,passes,visits,hx,hy,hpixel);
vision_hysteresis_sweep_reference #(.W(W),.H(H),.CW(CW),.REUSE_CAPTURE_MAP(1),.MIN_COMPONENT(32),.PROBE(1),.ALLOW_DISCARD(1),.HISTORY(1)) original(
 clk,rst,vblank,cv,x,y,c,last,dx,dy,ref_cap,ref_ready,ref_busy,ref_pixel,ref_frames,ref_fault,ref_state,ref_queue_size,
 de,req,address,ref_ack,ref_data,ref_read_address,ref_pbusy,discard,ref_cycles,ref_passes,ref_visits,hx,hy,ref_hpixel);
always #5 clk=~clk;
integer ticks=0,compared=0,skip_checks=0,pixel_checks=0,probe_checks=0;
integer display_phase=0,display_row=0;
always @(negedge clk)begin
 display_phase=(display_phase+1)%(W+40);
 if(display_phase==0)display_row=(display_row+1)%H;
 de=display_phase<W;dx=de?display_phase:0;dy=display_row;
 hx=(dx+3)%W;hy=(dy+1)%H;
end
always @(posedge clk)begin
 ticks=ticks+1;#1;
 if(rst)begin
  if({cap,ready,busy,pixel,frames,fault,state,queue_size,ack,data,read_address,pbusy,cycles,passes,visits,hpixel} !==
     {ref_cap,ref_ready,ref_busy,ref_pixel,ref_frames,ref_fault,ref_state,ref_queue_size,ref_ack,ref_data,ref_read_address,ref_pbusy,ref_cycles,ref_passes,ref_visits,ref_hpixel})
   $fatal(1,"cycle/output mismatch tick=%0d state=%0d/%0d xy=%0d,%0d",ticks,state,ref_state,dut.px,dut.py);
  if({dut.px,dut.py,dut.neighbor,dut.front,dut.reverse,dut.changed} !==
     {original.px,original.py,original.neighbor,original.front,original.reverse,original.changed})
   $fatal(1,"scan timing mismatch tick=%0d",ticks);
  if(state==4||state==7)begin
   if(dut.tile_read_row_q!=(dut.py>>4)||dut.empty_tile!==original.empty_tile)
    $fatal(1,"tile prefetch mismatch tick=%0d xy=%0d,%0d row=%0d",ticks,dut.px,dut.py,dut.tile_read_row_q);
   skip_checks=skip_checks+1;
  end
  compared=compared+1;
  if(de&&ready)pixel_checks=pixel_checks+1;
 end
end
function automatic [1:0]classification_for(input integer frame_no,xx,yy);
 begin
  classification_for=0;
  if(frame_no!=1)begin
   if(yy==0||xx%16==15||xx%16==0||xx==yy)classification_for=1;
   if(xx==0&&yy==0)classification_for=2;
   if(xx==W-1&&yy==H-2)classification_for=2;
   if(xx==W-1&&yy==H-1)classification_for=1;
  end
 end
endfunction
integer f,i,xx,yy,r,process_start;
initial begin
 repeat(4)@(negedge clk);rst=1;
 wait(state==1);@(negedge clk);vblank=1;@(negedge clk);vblank=0;
 for(f=0;f<4;f=f+1)begin
  wait(cap);
  for(i=0;i<N;i=i+1)begin
   // Column-major capture forces adjacent-clock writes to different tile rows.
   xx=f==2?i/H:i%W;yy=f==2?i%H:i/W;
   @(negedge clk);cv=1;x=xx;y=yy;c=classification_for(f,xx,yy);last=i==N-1;
   if(f==3&&i%7==0)begin @(negedge clk);cv=0;last=0;end
  end
  @(negedge clk);cv=0;last=0;process_start=ticks;
  wait(state==8);@(negedge clk);
  for(r=0;r<(H+15)/16;r=r+1)
   if((dut.tile_rows_valid[r]?dut.weak_tiles[r]:0)!==original.weak_tiles[r])
    $fatal(1,"captured tile row mismatch frame=%0d row=%0d",f,r);
  if(fault)$fatal(1,"unexpected fault");
  $display("PASS tile frame=%0d %0dx%0d processing=%0d last_cycles=%0d passes=%0d weak_visits=%0d",f,W,H,ticks-process_start,cycles,passes,visits);
  discard=f==2;vblank=1;@(negedge clk);vblank=0;discard=0;
  // Requests exercise the unmodified front-plane readback during concurrent capture.
  address=0;req=~req;wait(ack==req);@(negedge clk);probe_checks=probe_checks+32;
  if(N>=64)begin address=(N-32)/32;req=~req;wait(ack==req);@(negedge clk);probe_checks=probe_checks+32;end
  repeat(N+W+40)@(negedge clk);
 end
 if(frames!=3||skip_checks==0||pixel_checks==0||probe_checks==0)$fatal(1,"missing coverage");
 $display("PASS weak tile cycle equivalence: %0d clocks, %0d tile decisions, %0d display pixels, %0d probe bits, clear/consecutive/column-major/gaps/last-sample/discard/history",compared,skip_checks,pixel_checks,probe_checks);
 $finish;
end
initial begin #1000000000;$fatal(1,"weak tile watchdog state=%0d frame=%0d",state,f);end
endmodule
