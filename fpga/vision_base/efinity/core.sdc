# Core-only synthesis target. This is not a board timing constraint set.
create_clock -name core_clk -period 10.000 [get_ports {clk}]
