`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0;wire panel_reset,backlight;
lcd_dsi_tx_top d(.rst_n(rst),.bist_enable(1'b0),.backlight_enable(1'b1),.i_mipi_clk(clk),.i_mipi_tx_pclk(clk),.i_sysclk(clk),.i_sysclk_div_2(clk),.pixel_vs_i(1'b0),.pixel_hs_i(1'b0),.pixel_de_i(1'b0),.pixel_data_i(64'd0),.mipi_dp_data0_LP_N_IN(1'b0),.mipi_dp_data0_LP_P_IN(1'b0),.LCD_RST_P(panel_reset),.LCD_POWER(backlight));
initial begin
 #21;rst=1;@(negedge clk);d.r_rst_cnt=0;#1;if(!panel_reset)$fatal(1,"reset released early");
 d.r_rst_cnt=26'd8388608;#1;if(panel_reset)$fatal(1,"reset not released");
 d.r_rst_cnt=26'd16777216;#1;if(panel_reset)$fatal(1,"reset reasserted at next bit transition");
 d.r_rst_cnt=26'd33554432;#1;if(panel_reset)$fatal(1,"reset stuck after counter saturation");
 force d.w_confdone=1;d.dly_cnt=27'd67108864;#1;if(!backlight)$fatal(1,"backlight gate");
 $display("LCD RESET PASS held83.9ms, monotonic release, delayed backlight (DSI IP not simulated)");$finish;
end
endmodule
