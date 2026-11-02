"""Use native PHY timing for the HDMI-only source and retained video/DDR backend."""
from pathlib import Path

root=Path(__file__).resolve().parent
text=(root/'outflow/vision_hdmi.pt.sdc').read_text()
text=text.replace('create_clock -period <USER_PERIOD> -name CLK_25M','create_clock -period 40.000 -name CLK_25M')
text=text.replace('create_clock -period <USER_PERIOD> -name CLK_27M','create_clock -period 37.037 -name CLK_27M')
assert not any('<USER_PERIOD>' in s for s in text.splitlines() if s.strip() and not s.startswith('#'))
text+='''
# Existing CPU/debug/video held-payload and FIFO crossings.
create_clock -period 166.667 -name jtag_inst1_TCK [get_ports jtag_inst1_TCK]
create_clock -period 1000.000 -name jtag_diag_TCK [get_ports jtag_diag_TCK]
create_clock -period 1000.000 -name jtag_diag_DRCK [get_ports jtag_diag_DRCK]
create_clock -period 1000.000 -name jtag_diag_UPDATE [get_ports jtag_diag_UPDATE]
set_clock_groups -asynchronous -group {core_clk} -group {hdmi_tx_slow_clk vid_clk_dvi2}
set_clock_groups -asynchronous -group {hdmi_rx_slow_clk hdmi_rx_fast_clk hdmi_rx_fb} -group {core_clk hdmi_tx_slow_clk vid_clk_dvi2 CLK_25M}
set_clock_groups -asynchronous -group {jtag_inst1_TCK jtag_diag_TCK jtag_diag_DRCK jtag_diag_UPDATE} -group {core_clk hdmi_tx_slow_clk vid_clk_dvi2 hdmi_rx_slow_clk CLK_25M}
set_clock_groups -asynchronous -group {jtag_diag_UPDATE} -group {jtag_diag_DRCK}
set_clock_groups -exclusive -group {core_clk} -group {tx_cal_clk} -group {i_mipi_tx_pclk} -group {vid_clk_dvi2} -group {sdram_clk} -group {rx_cal_clk}
'''
(root/'vision_hdmi.sdc').write_text(text)
print('Updated HDMI/DDR native I/O timing and existing asynchronous FIFO/mailbox clocks')
