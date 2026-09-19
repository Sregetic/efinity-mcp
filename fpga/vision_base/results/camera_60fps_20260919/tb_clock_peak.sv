`timescale 1ns/1ps
module tb;
reg core_clk=0,i_cam_ck_CLKOUT=0,w_mipi_rx_vs=0;realtime half_period=6.35;
always #5 core_clk=~core_clk;
always begin #(half_period)i_cam_ck_CLKOUT=~i_cam_ck_CLKOUT;end
reg[31:0] cam_byte_ticks=0,cam_byte_gray=0;
wire[31:0]cam_byte_next=cam_byte_ticks+1'b1;
always @(posedge i_cam_ck_CLKOUT)begin
 cam_byte_ticks<=cam_byte_next;cam_byte_gray<=(cam_byte_next>>1)^cam_byte_next;
end
(* async_reg = "true" *) reg[31:0]cam_byte_gray_meta=0,cam_byte_gray_sync=0;
reg[31:0]cam_byte_core=0;
function[31:0]decode_byte_gray(input[31:0]g);
 integer j;begin for(j=0;j<32;j=j+1)decode_byte_gray[j]=^(g>>j);end
endfunction
always @(posedge core_clk)begin
 cam_byte_gray_meta<=cam_byte_gray;cam_byte_gray_sync<=cam_byte_gray_meta;
 cam_byte_core<=decode_byte_gray(cam_byte_gray_sync);
end
// Peak byte-clock edges per 100 core cycles (1 us), retained per received frame.
reg[6:0]cam_clock_window=0;reg[31:0]cam_byte_prev=0;
reg[15:0]cam_clock_delta=0,cam_clock_peak=0,cam_clock_peak_hold=0;
reg[2:0]cam_probe_vs=0;
wire[31:0]cam_tick_delta=cam_byte_core-cam_byte_prev;
always @(posedge core_clk)begin
 cam_probe_vs<={cam_probe_vs[1:0],w_mipi_rx_vs};
 if(cam_clock_window==99)begin
  cam_clock_window<=0;cam_byte_prev<=cam_byte_core;cam_clock_delta<=cam_tick_delta[15:0];
  if(cam_tick_delta[15:0]>cam_clock_peak)cam_clock_peak<=cam_tick_delta[15:0];
 end else cam_clock_window<=cam_clock_window+1'b1;
 if(cam_probe_vs[1]&&!cam_probe_vs[2])begin cam_clock_peak_hold<=cam_clock_peak;cam_clock_peak<=0;end
end

initial begin
 #20000;w_mipi_rx_vs=1;#100;w_mipi_rx_vs=0;#100;
 if(cam_clock_peak_hold<78||cam_clock_peak_hold>81)$fatal(1,"78.74 MHz measured %d",cam_clock_peak_hold);
 $display("peak at78.74 MHz=%d",cam_clock_peak_hold);
 half_period=3.571;#20000;w_mipi_rx_vs=1;#100;w_mipi_rx_vs=0;#100;
 if(cam_clock_peak_hold<139||cam_clock_peak_hold>143)$fatal(1,"140 MHz measured %d",cam_clock_peak_hold);
 $display("CLOCK PEAK PASS 78.74/140 MHz, measured high=%d",cam_clock_peak_hold);$finish;
end
endmodule
