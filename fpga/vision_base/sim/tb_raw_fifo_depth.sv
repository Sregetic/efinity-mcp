`timescale 1ns/1ps
module tb #(parameter DEPTH=512);
 localparam WORDS=8192,AW=$clog2(DEPTH);
 reg wc=0,rc=0,reset=1,go=0,we=0,re=0;always #4 wc=~wc;always #5 rc=~rc;
 reg[127:0]data=0;wire[127:0]q;wire full,empty;wire[AW:0]wn,rn;
 integer sent=0,received=0,wcycle=0,rcycle=0,high_w=0,high_r=0,full_cycles=0,empty_cycles=0;
 DC_FIFO #(.DATA_WIDTH(128),.FIFO_DEPTH(DEPTH),.FIFO_MODE("Normal")) dut(
  .Reset(reset),.WrClk(wc),.WrEn(we),.WrData(data),.WrDNum(wn),.WrFull(full),
  .RdClk(rc),.RdEn(re),.RdData(q),.RdDNum(rn),.RdEmpty(empty));
 function automatic[127:0]word(input integer i);word={32'(i^'ha5a5a5a5),32'(i+123),32'(~i),32'(i)};endfunction
 always @(negedge wc)begin
  we=go&&sent<WORDS&&(wcycle%13!=0);data=word(sent);wcycle=wcycle+1;
 end
 always @(posedge wc)begin
  if(!reset&&we&&!full)sent=sent+1;
  #2;if(wn>DEPTH)$fatal(1,"write occupancy");if(wn>high_w)high_w=wn;if(full)full_cycles=full_cycles+1;
 end
 always @(negedge rc)begin
  // First force a full FIFO, then exercise continuous reads and backpressure.
  re=!reset&&rcycle>DEPTH*2&&received<WORDS&&(rcycle%17!=0);rcycle=rcycle+1;
 end
 always @(posedge rc)begin
  if(!reset&&re&&!empty)begin
   #2;if(q!==word(received))$fatal(1,"FIFO depth%0d word%0d got%h",DEPTH,received,q);received=received+1;
  end
  #2;if(rn>DEPTH)$fatal(1,"read occupancy");if(rn>high_r)high_r=rn;if(empty)empty_cycles=empty_cycles+1;
 end
 initial begin
  #100;reset=0;repeat(20)@(negedge rc);go=1;
  wait(received==WORDS);repeat(20)@(negedge rc);
  if(sent!=WORDS||!empty||full_cycles==0||high_w<DEPTH-2)$fatal(1,"FIFO coverage");
  $display("PASS RAW FIFO depth%0d words%0d wrap/full/drain asynchronous128bit; peaks W%0d R%0d",DEPTH,WORDS,high_w,high_r);$finish;
 end
 initial begin #2000000;$fatal(1,"FIFO watchdog sent%0d received%0d",sent,received);end
endmodule

