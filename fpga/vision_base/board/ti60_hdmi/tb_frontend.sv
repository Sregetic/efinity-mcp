`timescale 1ns/1ps
module tb;
 parameter W=16,H=4,AW=5;
 reg rst_n=0,input_clk=0,isp_clk=0,run_input=1,input_locked=1,input_valid=1,vs=0,de=0;
 reg[23:0]rgb=0;always #7 if(run_input)input_clk=~input_clk;always #3 isp_clk=~isp_clk;
 wire out_vs,out_de,frame_bad;wire[47:0]pixels;wire[31:0]frame_id,overflow_count;
 vision_hdmi_frontend #(.W(W),.H(H),.FIFO_AW(AW)) dut(.*);
 integer received=0,frames=0,expected=0;reg check_pixels=1;
 always @(posedge isp_clk)begin #1;
  if(out_vs)begin frames=frames+1;expected=0;end
  if(out_de&&check_pixels)begin
   if(frame_bad||pixels[23:0]!==24'(expected)||pixels[47:24]!==24'(expected+1))$fatal(1,"pixel pair/order %0d %h bad%0d",expected,pixels,frame_bad);
   expected=expected+2;received=received+2;
  end
 end
 task input_tick(input v,d,input[23:0]p);begin @(negedge input_clk);vs=v;de=d;rgb=p;end endtask
 task frame;integer x,y;begin
  input_tick(1,0,0);repeat(4)input_tick(1,0,0);input_tick(0,0,0);
  for(y=0;y<H;y=y+1)begin
   for(x=0;x<W;x=x+1)input_tick(0,1,24'(y*W+x));
   repeat(12)input_tick(0,0,0);
  end
  repeat((W+70)/2)input_tick(0,0,0);
 end endtask
 initial begin
  repeat(5)input_tick(0,0,0);rst_n=1;
  frame;frame;
  if(received!=2*W*H||frames!=2||frame_bad||overflow_count)$fatal(1,"complete row/frame count");
  // A short row cannot strand an underfilled line FIFO ahead of its abort.
  check_pixels=0;input_tick(1,0,0);repeat(4)input_tick(0,0,0);repeat(6)input_tick(0,1,0);repeat(24)input_tick(0,0,0);
  if(!frame_bad)$fatal(1,"short row not aborted");
  check_pixels=1;frame;if(expected!=W*H||frame_bad)$fatal(1,"short row recovery");
  // Actual input clock disappearance is delivered to the stable ISP/capture domain.
  check_pixels=0;input_tick(1,0,0);repeat(4)input_tick(0,0,0);repeat(10)input_tick(0,1,0);
  @(negedge input_clk);run_input=0;input_locked=0;#200;
  if(!frame_bad||out_de)$fatal(1,"lost source did not stop/abort");
  run_input=1;input_locked=1;repeat(20)input_tick(0,0,0);
  check_pixels=1;frame;if(expected!=W*H||frame_bad)$fatal(1,"lost clock recovery");
  // Reject an unsupported colour format without publishing its pixels.
  input_valid=0;repeat(20)input_tick(0,0,0);check_pixels=0;
  input_tick(1,0,0);repeat(40)input_tick(0,1,0);repeat(20)input_tick(0,0,0);
  if(out_de)$fatal(1,"unsupported format emitted");
  input_valid=1;check_pixels=1;frame;if(expected!=W*H||frame_bad)$fatal(1,"format recovery");
  $display("PASS HDMI source pairing, stable-clock full rows, incomplete/lost-clock abort and recovery: %0d pixels",received);$finish;
 end
 initial begin #(W*H*14*12+100000);$fatal(1,"timeout");end
endmodule
