`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0;wire done;
panel_config #(.INITIAL_CODE("sim/vision/lcd_delay_test.mem"),.REG_DEPTH(1))d(.i_axi_clk(clk),.i_restn(rst),.i_axi_awready(1'b0),.i_axi_wready(1'b0),.i_axi_bvalid(1'b0),.i_axi_arready(1'b0),.i_axi_rdata(32'b0),.i_axi_rvalid(1'b0),.i_dbg_we(1'b0),.i_dbg_din(40'b0),.i_dbg_addr(9'b0),.i_dbg_reconfig(1'b0),.o_confdone(done));
initial begin
 #21;rst=1;repeat(10)@(negedge clk);d.r_done=0;d.r_timer=32'h003ffffe;
 repeat(3)@(negedge clk);if(d.r_timer<32'h00400000)$fatal(1,"delay counter truncated at22bits");
 repeat(12)@(negedge clk);if(!done)$fatal(1,"long delay did not complete");
 $display("PANEL DELAY PASS32bit wait and explicit end");$finish;
end
endmodule
