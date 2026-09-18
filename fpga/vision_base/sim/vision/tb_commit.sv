`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0,start=0,aw=0,w=0,b=0;reg[1:0]resp=0;wire done;wire[31:0]errors;integer n=0,i;
vision_write_commit dut(clk,rst,start,32'd4,aw,w,b,resp,done,errors);
always @(negedge clk)if(done)n++;
initial begin
 #21;rst=1;start=1;#50;start=0;#30;aw=1;#10;aw=0;
 for(i=0;i<4;i++)begin w=1;#10;end w=0;#100;
 if(n!=0)$fatal(1,"published before B");b=1;#10;b=0;#40;if(n!=1)$fatal;
 start=1;#50;start=0;#30;aw=1;#10;aw=0;w=1;#40;w=0;resp=2;b=1;#10;b=0;#40;
 if(n!=1||errors!=1)$fatal;$display("COMMIT PASS");$finish;
end
endmodule
