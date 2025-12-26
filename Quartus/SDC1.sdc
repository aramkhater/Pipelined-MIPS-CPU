# constrain clock

create_clock -period 20 [get_ports clk_i]
derive_pll_clocks

##

set_instance_assignment -name DSP_BLOCK_BALANCING ON -to Execute:behavior|*