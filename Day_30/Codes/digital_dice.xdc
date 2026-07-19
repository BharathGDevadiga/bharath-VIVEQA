#################################################
## Clock (24 MHz)
#################################################

create_clock -period 41.667 -name sys_clk [get_ports clk_24mhz]

set_property PACKAGE_PIN D13 [get_ports clk_24mhz]
set_property IOSTANDARD LVCMOS33 [get_ports clk_24mhz]

## Roll
set_property PACKAGE_PIN C9 [get_ports roll]
set_property IOSTANDARD LVCMOS33 [get_ports roll]

## Reset
set_property PACKAGE_PIN B9 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
