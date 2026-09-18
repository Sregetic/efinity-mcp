`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0,bist=0;
panel_config #(.INITIAL_CODE("./rtl/lcd/Panel_1080p_reg.mem"),.REG_DEPTH(173),.BIST_INDEX(165))d(.bist_enable(bist),.i_axi_clk(clk),.i_restn(rst),.i_axi_awready(1'b0),.i_axi_wready(1'b0),.i_axi_bvalid(1'b0),.i_axi_arready(1'b0),.i_axi_rdata(32'b0),.i_axi_rvalid(1'b0),.i_dbg_we(1'b0),.i_dbg_din(40'b0),.i_dbg_addr(9'b0),.i_dbg_reconfig(1'b0));
initial begin
 #21;rst=1;force d.r_addr=165;repeat(4)@(negedge clk);if(d.w_reg!==40'h2000017623)$fatal(1,"normal command override");
 bist=1;#1;if(d.w_reg!==40'h20006c0b23)$fatal(1,"BIST command missing");
 force d.r_addr=167;repeat(4)@(negedge clk);if(d.w_reg!==40'h2000007623)$fatal(1,"page0 restore missing");
 $display("LCD BIST PASS normal override, vendor selftest command, page0 restore");$finish;
end
endmodule
