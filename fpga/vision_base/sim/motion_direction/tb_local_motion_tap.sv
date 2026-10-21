`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst=0,de=0,vs=0,config_bit=0;reg[11:0]x=0,y=0;reg[7:0]gray=0;
wire[31:0]id,status,hx,vy,dropped;wire[11:0]x0,y0,x1,y1;wire[15:0]active;
vision_local_motion_tap #(.WIDTH(192),.HEIGHT(96))dut(clk,rst,de,vs,x,y,gray,config_bit,id,status,hx,vy,x0,y0,x1,y1,active,dropped);
reg[7:0]pixels[0:6*192*96-1],grid_expected[0:6*144-1];
integer f,ix,iy,nwords=0,last_id=0,fd;
always @(negedge clk)if(rst)begin
 if(dut.word_valid)begin
  if(!dut.core_ready)$fatal(1,"Unexpected tap overrun");
  if(nwords<864&&dut.word!==grid_expected[nwords])$fatal(1,"Grid mismatch index=%0d actual=%0d expected=%0d",nwords,dut.word,grid_expected[nwords]);
  nwords=nwords+1;
 end
 if(id!=last_id)begin
  $fdisplay(fd,"%0d %0d %0d %0d %0d %0d %0d %0d %0d %0d",id,status,$signed(hx),$signed(vy),active,x0,y0,x1,y1,dropped);
  last_id=id;
 end
 if(status[7]||status[9:8]!=2&&id!=0)$fatal(1,"Unverified raster requested partial work");
end
task boundary;
 begin @(negedge clk);de=0;vs=1;repeat(8)@(negedge clk);vs=0;repeat(8)@(negedge clk);end
endtask
task frame(input integer number);
 begin
  for(iy=0;iy<96;iy=iy+1)begin
   for(ix=0;ix<192;ix=ix+1)begin @(negedge clk);de=1;x=ix;y=iy;gray=pixels[number*192*96+iy*192+ix];end
   @(negedge clk);de=0;repeat(5)@(negedge clk);
  end
  repeat(50)@(negedge clk);
 end
endtask
initial begin
 fd=$fopen("tap_results.txt","w");
 $readmemh("vectors/pixel_frames.mem",pixels);
 $readmemh("vectors/pixel_grid_expected.mem",grid_expected);
 repeat(3)@(negedge clk);rst=1;
 for(f=0;f<6;f=f+1)begin boundary;frame(f);end
 boundary;repeat(10)@(negedge clk);
 if(id!=6||dropped!=0||nwords!=864)$fatal(1,"Tap count/dropped mismatch id=%0d drop=%0d words=%0d",id,dropped,nwords);
 // Bad raster must not publish and must reset temporal state on recovery.
 @(negedge clk);de=1;x=5;y=0;@(negedge clk);de=0;repeat(5)@(negedge clk);boundary;
 if(id!=6||dropped!=1)$fatal(1,"Bad raster not explicitly dropped");
 frame(0);boundary;repeat(10)@(negedge clk);
 if(id!=7||status[1]||status[2])$fatal(1,"Bad raster recovery did not warm up");
 config_bit=1;frame(1);boundary;repeat(10)@(negedge clk);
 // Configuration becomes effective at the following frame boundary.
 frame(2);boundary;repeat(10)@(negedge clk);
 if(status[1])$fatal(1,"Configuration change did not clear history");
 $fclose(fd);$display("PASS local tap exact grids=864 complete rasters=6 bad-raster and config guards");$finish;
end
initial begin #100000000;$fatal(1,"Tap timeout");end
endmodule
