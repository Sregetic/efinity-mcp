`timescale 1ns/1ps
module tb;
reg clk=0,rst=0,de=0,hs=0,vs=0;always #5 clk=~clk;
reg[7:0]p=0;reg[11:0]dx=0,dy=0;reg rd=0;
reg pde=0;reg preq=0,phold=0;reg[11:0]paddr=0;wire pack;wire[31:0]pdata;
wire edgepix,ready,busy,fault,noise_valid;wire[31:0]done;wire[7:0]noise;wire[10:0]high;
vision_canny #(.STABLE_NMS(1),.CONTOUR_RASTER(1)) can(.clk(clk),.rst_n(rst),.de(de),.hs(hs),.vs(vs),.r(p),.g(p),.b(p),
 .high_threshold(11'd96),.display_x(dx),.display_y(dy),.edge_pixel(edgepix),.ready(ready),.busy(busy),.fault(fault),.completed(done),
 .display_de(pde),.probe_hold(phold),.probe_req(preq),.probe_address(paddr),.probe_ack(pack),.probe_data(pdata),.median_en(1'b1),
 .noise_mean(noise),.noise_valid(noise_valid),.effective_threshold(high),.raster_de(rd));
defparam can.raster.raster0.INDEX_FILE="board/ti60f225_v4/rtl/vision/canny_coverage_index.mem";
defparam can.raster.raster0.PALETTE_FILE="board/ti60f225_v4/rtl/vision/canny_coverage_palette.mem";
wire fd,fh,fv,fb,ed;wire[11:0]fx,fy;wire[7:0]fr,fg,blue,gray;wire[10:0]mag;wire[1:0]dir;
vision_frontend front(clk,rst,de,hs,vs,p,p,p,1'b1,fd,fh,fv,fb,fx,fy,fr,fg,blue,gray,mag,dir,11'd96,ed);
reg[7:0]photo[0:2073599],sobel[0:2073599];reg recording=0;
always @(negedge clk)if(recording&&fd&&fx<1920&&fy<1080)sobel[fy*1920+fx]=!fb&&fx>=4&&fy>=4&&ed?8'hff:0;
string file,prefix;integer f,xx,yy,i,fs,fc,ns=0,nc=0;
task boundary;begin @(negedge clk);vs=1;repeat(8)@(negedge clk);vs=0;repeat(8)@(negedge clk);end endtask
initial begin
 if(!$value$plusargs("image=%s",file)||!$value$plusargs("output=%s",prefix))$fatal(1,"Missing paths");
 $readmemh(file,photo);for(i=0;i<2073600;i=i+1)sobel[i]=0;
 repeat(4)@(negedge clk);rst=1;wait(can.hyst.state==1);boundary;wait(can.hyst.state==1);boundary;
 for(f=0;f<3;f=f+1)begin
  recording=f==2;
  for(yy=0;yy<1080;yy=yy+1)begin
   for(xx=0;xx<1920;xx=xx+1)begin de=1;p=photo[yy*1920+xx];@(negedge clk);end
   de=0;hs=1;repeat(8)@(negedge clk);hs=0;repeat(272)@(negedge clk);
  end
  wait(can.hyst.state==8);boundary;
  $display("FRAME %0d done%0d high%0d noise%0d ready%b",f,done,high,noise,ready);
 end
 recording=0;wait(ready);repeat(110000)@(negedge clk);
 phold=1;fc=$fopen({prefix,"_bitmap.mem"},"w");
 for(i=0;i<4050;i=i+1)begin
  @(negedge clk);paddr=i;preq=~preq;
  repeat(4)@(negedge clk);pde=1;@(negedge clk);pde=0;
  wait(pack==preq);@(negedge clk);
  if(^pdata===1'bx)$fatal(1,"Unknown probe word %0d",i);
  $fwrite(fc,"%08x\n",pdata);
 end
 $fclose(fc);
 if(fault||done!=3)$fatal(1,"Canny state fault/done");
 fs=$fopen({prefix,"_sobel.pgm"},"wb");$fwrite(fs,"P5\n1920 1080\n255\n");
 for(i=0;i<2073600;i=i+1)begin $fwrite(fs,"%c",sobel[i]);if(sobel[i])ns=ns+1;end
 $fclose(fs);
 fc=$fopen({prefix,"_canny.pgm"},"wb");$fwrite(fc,"P5\n1920 1080\n255\n");
 for(yy=0;yy<1080;yy=yy+1)begin
  for(xx=0;xx<1920;xx=xx+1)begin
   @(negedge clk);rd=1;dx=xx;dy=yy;@(posedge clk);#1;
   if(edgepix!==0&&edgepix!==1)$fatal(1,"Unknown Canny pixel %0d,%0d",xx,yy);
   $fwrite(fc,"%c",edgepix?8'hff:8'h00);if(edgepix)nc=nc+1;
  end
  @(negedge clk);rd=0;dx=0;repeat(280)@(negedge clk);
 end
 $fclose(fc);$display("EDGES sobel%0d canny%0d canny_high%0d noise_mean%0d",ns,nc,high,noise);$finish;
end
initial begin #500000000;$fatal(1,"watchdog state%0d done%0d",can.hyst.state,done);end
endmodule
