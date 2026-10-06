`timescale 1ns/1ps
module tb;
 reg clk=0,rst=0,cv=0,rr=0;always #5 clk=~clk;
 reg[9:0]fn=0;reg[31:0]a=0,b=0;wire cr,rv;wire[31:0]q;
 vision_int8_cfu dut(clk,rst,cv,cr,fn,a,b,rv,rr,q);
 function automatic integer reference(input[31:0]x,y);
 integer k,v,w,s;begin s=0;for(k=0;k<4;k++)begin
 v=$signed(x[k*8+:8]);w=$signed(y[k*8+:8]);s=s+v*w;end reference=s;end endfunction
 integer i,expected;reg[31:0]held;
 initial begin
  repeat(3)@(negedge clk);rst=1;
  for(i=0;i<1024;i++)begin
   a=i==0?32'h80808080:$random;b=i==0?32'h80808080:$random;
   expected=reference(a,b);cv=1;@(negedge clk);cv=0;
   if(!rv||q!==32'(expected))$fatal(1,"INT8 dot i%0d %h %h",i,q,expected);
   held=q;a=~a;b=~b;repeat(3)@(negedge clk);
   if(!rv||q!==held||cr)$fatal(1,"response changed under backpressure");
   rr=1;@(negedge clk);rr=0;if(rv)$fatal(1,"response not consumed");
  end
  fn=1;cv=1;@(negedge clk);if(cr||rv)$fatal(1,"unsupported function accepted");
  rst=0;@(negedge clk);if(rv)$fatal(1,"reset");
  $display("PASS signed INT8 dot41024 vectors incl -128, response hold/backpressure/reset");$finish;
 end
endmodule
