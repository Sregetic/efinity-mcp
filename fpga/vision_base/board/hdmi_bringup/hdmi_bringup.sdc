create_clock -period 40.000 -name CLK_25M [get_ports {CLK_25M}]
create_clock -period 37.037 -name CLK_27M [get_ports {CLK_27M}]
create_clock -period 6.722689 -name hdmi_tx_slow_clk [get_ports {hdmi_tx_slow_clk}]
create_clock -period 1.344538 -waveform {0.336135 1.008404} -name hdmi_tx_fast_clk [get_ports {hdmi_tx_fast_clk}]
create_clock -period 166.667 -name jtag_drck [get_ports {jtag_inst1_DRCK}]
# Registered Gray counters and two-stage synchronizers; unrelated debug clock.
set_clock_groups -asynchronous -group {jtag_drck} -group {CLK_25M CLK_27M hdmi_tx_slow_clk hdmi_tx_fast_clk}
