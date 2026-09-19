create_clock -period 4.545454 -name clk [get_ports {clk}]
create_clock -period 40.000 -name CLK_25M [get_ports {CLK_25M}]
set_output_delay -clock clk -max 0 [get_ports {result}]
set_output_delay -clock clk -min 0 [get_ports {result}]
