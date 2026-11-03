`timescale 1ns/1ps
module tb;
parameter W=16,H=6;
reg clk=0,rc=0,rst=0,req=0,src=0,vs=0,de=0,bc=0,bs=0,bad=0;
reg[10:0]row=0;reg[23:0]srgb=0,drgb=0;
wire[31:0]status,seq,fid,cid;wire phase,tdo;
vision_line_snapshot #(.W(W),.H(H)) dut(clk,rst,req,row,src,vs,de,srgb,vs,de,drgb,
 32'd123,32'd7,3'd5,11'd128,1'b1,2'd3,status,seq,fid,cid,rc,bc,bs,phase,tdo);
always #5 clk=~clk;always #35 rc=~rc;
integer gx,gy,xx,yy,stage,target,k,bitno,checks=0;reg[23:0]got,want;reg[31:0]old;
initial begin
 forever begin
  @(negedge clk);vs=1;de=0;repeat(5)@(negedge clk);vs=0;
  for(gy=0;gy<H;gy=gy+1)begin
   for(gx=0;gx<(bad?W-2:W);gx=gx+1)begin
    de=1;srgb=24'h800000+gy*16+gx;drgb=24'h400000+gy*256+gx;@(negedge clk);
   end
   de=0;repeat(4)@(negedge clk);
  end
 end
end
task arm(input integer s,input integer r);
 begin old=seq;@(negedge clk);src=s;row=r;req=~req;wait(seq!=old);#1;end
endtask
initial begin
 repeat(4)@(negedge clk);rst=1;
 for(stage=0;stage<2;stage=stage+1)for(target=0;target<H;target=target+1)begin
  arm(stage,target);
  if(status[31:29]!=3'b100||status[28]!=stage||status[10:0]!=target||fid!=123||cid!=7)$fatal(1,"metadata");
  repeat(4)@(negedge rc);bc=1;@(negedge rc);bc=0;bs=1;
  for(k=0;k<192;k=k+1)begin if(phase)$fatal(1,"header short");@(negedge rc);end
  for(xx=0;xx<W;xx=xx+1)begin
   got=0;
   for(bitno=0;bitno<24;bitno=bitno+1)begin if(!phase)$fatal(1,"payload phase");got[bitno]=tdo;@(negedge rc);end
   want=stage?24'h800000+target*16+xx:24'h400000+target*256+xx;
   if(got!==want)$fatal(1,"pixel stage%0d row%0d x%0d got%h want%h",stage,target,xx,got,want);
   checks=checks+1;
  end
  bs=0;
 end
 arm(0,H);if(!status[29]||status[31]||status[30])$fatal(1,"invalid row");
 bad=1;arm(0,2);if(!status[29]||status[31]||status[30])$fatal(1,"short line");
 $display("PASS line snapshot %0d RGB888 pixels, both taps, all rows,192-bit header, serial order, metadata, bad row/short line rejected",checks);$finish;
end
initial begin #100000000;$fatal(1,"timeout");end
endmodule
