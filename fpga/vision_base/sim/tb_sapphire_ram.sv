`timescale 1ns/1ps
module tb;
 reg clk=0;always #5 clk=~clk;
 reg we=0,re=0;reg[3:0]mask=0;reg[3:0]wa=0,ra=0;reg[31:0]data=0;wire[31:0]q;
 wire[21:0]tag;wire[5:0]pending;
 wire[7:0]aq;
 reg twe=0,tre=0;reg[4:0]twa=0,tra=0;reg[22:0]td=0;wire[22:0]tq;
 reg[22:0]gold[0:31],expected_tag;integer i;
 Ram_1w_1rs #(.wordCount(32),.wordWidth(23),.wrAddressWidth(5),.rdAddressWidth(5),.wrDataWidth(23),.rdDataWidth(23)) actual_tags(clk,twe,1'b1,twa,td,clk,tre,tra,tq);
 Ram_1w_1ra async0(clk,we,1'b1,wa[1:0],data[7:0],ra[1:0],aq);
 Ram_1w_1rs #(.wordCount(16),.wrAddressWidth(4),.rdAddressWidth(4),.wrMaskWidth(4),.wrMaskEnable(1)) bytes0(clk,we,mask,wa,data,clk,re,ra,q);
 Ram_1w_1rs #(.wordCount(64),.wordWidth(22),.wrAddressWidth(6),.rdAddressWidth(6),.wrDataWidth(22),.rdDataWidth(22)) tags0(clk,we,1'b1,{2'b0,wa},data[21:0],clk,re,{2'b0,ra},tag);
 Ram_1w_1rs #(.wordCount(64),.wordWidth(6),.wrAddressWidth(6),.rdAddressWidth(6),.wrDataWidth(6),.rdDataWidth(6)) pending0(clk,we,1'b1,{2'b0,wa},data[5:0],clk,re,{2'b0,ra},pending);
 task write_word(input[31:0]d,input[3:0]m);begin @(negedge clk);we=1;data=d;mask=m;@(negedge clk);we=0;end endtask
 initial begin
  write_word(32'h12345678,15);re=1;@(negedge clk);
  if(q!==32'h12345678||tag!==22'h345678||pending!==6'h38||aq!==8'h78)$fatal(1,"one-cycle read/tag width/metadata/async UART");
  re=0;write_word(32'habcd0000,12);if(q!==32'h12345678)$fatal(1,"read enable did not hold data");
  re=1;@(negedge clk);if(q!==32'habcd5678||aq!==0)$fatal(1,"masked cache write/async UART");
  for(i=0;i<32;i=i+1)begin
   @(negedge clk);twe=1;twa=i;td=$urandom;gold[i]=td;
  end
  @(negedge clk);twe=0;tre=1;tra=0;
  @(posedge clk);#1;expected_tag=gold[0];if(tq!==expected_tag)$fatal(1,"23bit tag initial read");
  for(i=0;i<10000;i=i+1)begin
   @(negedge clk);twe=$urandom;tre=$urandom;twa=$urandom;tra=i%3==0?twa:$urandom;td=$urandom;
   if(tre)expected_tag=gold[tra];
   @(posedge clk);#1;
   if(tq!==expected_tag)$fatal(1,"Full tag/read-hold/old-word mismatch cycle%0d",i);
   if(twe)gold[twa]=td;
  end
  $display("PASS Sapphire RAM masks/22bit legacy/metadata/UART and10000 full23bit tag cycles including read-hold and same-address old-value");$finish;
 end
endmodule
