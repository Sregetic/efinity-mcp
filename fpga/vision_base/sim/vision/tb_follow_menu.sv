`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst_n=0,de=0,hs=0,vs=0;reg[23:0]rgb=24'h283038,ui_state=0;
reg[3:0]ai_status=0;reg motion_enable=0,motion_held=0;reg[2:0]motion_direction=0;
reg[27:0]target_classes=0;wire ode,ohs,ovs;wire[23:0]orgb;
vision_sidebar_overlay dut(.*);
reg[1023:0]output_dir;integer frame,row,col,file,ink=0;
initial begin
 if(!$value$plusargs("output=%s",output_dir))$fatal(1,"output required");
 repeat(3)@(negedge clk);rst_n=1;
 for(frame=0;frame<4;frame++)begin
  case(frame)
   0:ui_state=24'h800000|(1<<18)|(1<<14)|1;
   1:ui_state=24'h800000|(2<<18)|(1<<14)|1;
   2:ui_state=24'h800000|(13<<18)|(5<<15)|512;
   3:ui_state=(5<<15)|1024;
  endcase
  @(negedge clk);vs=1;repeat(3)@(negedge clk);vs=0;
  file=$fopen($sformatf("%0s/menu_%0d.ppm",output_dir,frame),"wb");
  $fwrite(file,"P6\n1920 1080\n255\n");
  for(row=0;row<1080;row++)begin
   for(col=0;col<1920;col++)begin
    de=1;@(posedge clk);#1;
    if(!ode||ohs!==hs||ovs!==vs)$fatal(1,"menu sync");
    if(orgb==24'hffff80)ink++;
    $fwrite(file,"%c%c%c",orgb[23:16],orgb[15:8],orgb[7:0]);@(negedge clk);
   end
   de=0;@(posedge clk);#1;@(negedge clk);
  end
  $fclose(file);
 end
 if(ink<2000)$fatal(1,"follow/trail/lost menu text absent");
 $display("PASS follow/trail/lost production menu: 8294400 pixels, %0d ink pixels",ink);$finish;
end
initial begin #100000000;$fatal(1,"follow menu timeout");end
endmodule
