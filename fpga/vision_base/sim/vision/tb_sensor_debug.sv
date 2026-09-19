`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst=0,cfg=0,req=0,wd=0,rd=0;reg[15:0]value=888;reg[7:0]rdata=0;
reg dr=0,dw=0;reg[15:0]da=16'h320e;reg[7:0]dd=0;wire dak,df,db;wire[7:0]rb;
wire we,re,ack,fault,busy;wire[15:0]addr,applied,updates;wire[7:0]data;wire[23:0]erb;
sensor_exposure_writer #(.TIMEOUT(100))d(clk,rst,cfg,req,value,wd,rd,rdata,we,re,addr,data,ack,fault,busy,applied,erb,updates,dr,dw,da,dd,dak,rb,df,db);
reg[7:0]mem[0:65535];reg corrupt=0,stall=0;integer writes=0,reads=0;
always @(negedge clk)begin
 wd=0;rd=0;
 if(we&&re)$fatal(1,"overlapping requests");
 if(we&&!stall)begin mem[addr]=data;writes++;wd=1;end
 if(re&&!stall)begin rdata=mem[addr]^(corrupt?1:0);reads++;rd=1;end
end
task transact(input wr,input[15:0]a,input[7:0]v);
begin @(negedge clk);dw=wr;da=a;dd=v;dr=~dr;wait(dak==dr);@(negedge clk);end endtask
initial begin
 mem[16'h320e]=8'h0b;mem[16'h320f]=8'hb8;
 #21;rst=1;dr=1;repeat(8)@(negedge clk);if(we||re||busy)$fatal(1,"early bus access");cfg=1;
 wait(dak==dr);@(negedge clk);if(rb!=8'h0b||df)$fatal(1,"read failed");
 transact(1,16'h320f,8'hdc);if(rb!=8'hdc||mem[16'h320f]!=8'hdc||df)$fatal(1,"write/readback failed");
 // Queue diagnostic request while the three-byte exposure transaction owns the bus.
 @(negedge clk);req=1;wait(busy);transact(0,16'h320f,0);
 if(!ack||applied!=888||erb!=24'h003780||rb!=8'hdc||fault||df)$fatal(1,"arbitration failed");
 corrupt=1;transact(1,16'h320e,5);if(!df||fault)$fatal(1,"missing debug mismatch");
 corrupt=0;transact(0,16'h320f,0);if(df||rb!=8'hdc)$fatal(1,"debug did not recover");
 stall=1;transact(0,16'h320f,0);if(!df||busy||fault)$fatal(1,"debug timeout");
 stall=0;transact(0,16'h320f,0);if(df||rb!=8'hdc)$fatal(1,"timeout recovery");
 $display("SENSOR DEBUG PASS read/write/readback, boot gate, AE arbitration, mismatch, timeout recovery");$finish;
end
initial begin #100000;$fatal(1,"timeout");end
endmodule
