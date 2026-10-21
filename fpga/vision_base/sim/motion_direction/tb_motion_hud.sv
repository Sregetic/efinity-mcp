`timescale 1ns/1ps
module tb;
reg[11:0]x=0,y=0;reg[31:0]status=0,observation=32'h1234abcd;reg[15:0]sites=0;
reg[2:0]show=0;reg held=0;wire active,ink;wire[23:0]color;
vision_motion_osd dut(x,y,status,observation,sites,show,held,active,ink,color);
integer checks=0,n,ix,iy,fd;reg[23:0]rgb;reg[4095:0]filename;
task pixel(input integer px,py,input bit want);
 begin x=px;y=py;#1;if(ink!==want)$fatal(1,"Arrow mismatch x=%0d y=%0d status=%h got=%b want=%b",px,py,status,ink,want);checks=checks+1;end
endtask
task direction(input integer code);
 begin status=32'h203|(code<<3);show=code;sites=12;#1;
 pixel(772,112,code==2);pixel(828,112,code==3);pixel(816,68,code==4);pixel(816,124,code==5);
 if(code==2)begin pixel(748,112,0);pixel(748,96,1);end
 if(code==3)begin pixel(852,112,0);pixel(852,96,1);end
 if(code==4)begin pixel(816,44,0);pixel(800,44,1);end
 if(code==5)begin pixel(816,148,0);pixel(800,148,1);end
 if(code==1)pixel(800,96,1);
 if(code==0||code>5)begin pixel(800,96,0);if(color!=24'hffb050)$fatal(1,"Unknown is not marked amber");end
 end
endtask
initial begin
 for(n=0;n<8;n=n+1)direction(n);
 status=32'h200;sites=0;pixel(800,96,0);if(color!=24'hffb050)$fatal(1,"Warmup color");
 status=32'h243;pixel(816,112,1);if(color!=24'hff5050)$fatal(1,"Fault color");
 status=32'h21b;sites=145;pixel(816,112,1);if(color!=24'hff5050)$fatal(1,"Invalid count must show error");
 x=900;y=50;#1;if(active)$fatal(1,"HUD escaped panel");checks=checks+1;
 // Render actual combinational RTL pixels for visual inspection, not an HTML mockup.
 for(n=0;n<8;n=n+1)begin
  status=n==0?32'h200:n==7?32'h243:(32'h203|((n-1)<<3));sites=n==0?0:n==7?144:n*17;
  show=n==0?0:n==7?0:n-1;held=n==3;
  if(n==3)status=32'h207;
  $sformat(filename,"hud_%0d.ppm",n);
  fd=$fopen(filename,"wb");if(fd==0)$fatal(1,"Cannot create render output");$fwrite(fd,"P6\n900 216\n255\n");
  for(iy=0;iy<216;iy=iy+1)for(ix=0;ix<900;ix=ix+1)begin
   x=ix;y=iy;#1;rgb=active?(ink?color:24'h101820):24'h303940;
   $fwrite(fd,"%c%c%c",rgb[23:16],rgb[15:8],rgb[7:0]);
  end
  $fclose(fd);
 end
 $display("PASS HUD black-box arrow/status/bounds checks=%0d rendered_states=8",checks);$finish;
end
initial begin #20000000;$fatal(1,"HUD timeout");end
endmodule
