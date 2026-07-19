## Clock

create_clock -period 41.667 -name sys_clk [get_ports clk]

set_property -dict { PACKAGE_PIN D13 IOSTANDARD LVCMOS33 } [get_ports clk]

## Reset

set_property -dict { PACKAGE_PIN A13 IOSTANDARD LVCMOS33 } [get_ports rst]

## Output LED

set_property -dict { PACKAGE_PIN D5 IOSTANDARD LVCMOS33 } [get_ports clk_out]
