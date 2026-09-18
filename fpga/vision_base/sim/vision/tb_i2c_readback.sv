`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0,re=0;wire init,wd,rd,valid,we,cs;wire[7:0]out,wdata;wire[2:0]addr;
reg[7:0]rdata=0;
i2c_16addr_8data d(.clk(clk),.rst_n(rst),.din(8'd0),.addr(16'h3e01),.dout(out),.dev_addr(8'h60),.init_done(init),.wr_en(1'b0),.rd_en(re),.wr_done(wd),.rd_done(rd),.dout_valid(valid),.i2c_address(addr),.i2c_write(we),.i2c_writedata(wdata),.i2c_chipselect(cs),.i2c_waitrequest(1'b0),.i2c_readdata(rdata));
// The actual Wishbone core registers its output: address-to-data is one cycle.
always @(posedge clk)rdata<=addr==3?8'h1b:8'h00;
initial begin #21;rst=1;wait(init);repeat(4)@(negedge clk);re=1;@(negedge clk);re=0;wait(rd);#1;if(out!==8'h1b)$fatal(1,"read latch returned %h",out);$display("I2C READBACK PASS: synchronous RX timing");$finish;end
initial begin #100000;$fatal(1,"timeout");end
endmodule
