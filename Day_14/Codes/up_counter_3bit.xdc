############################
## 24 MHz Clock
############################
create_clock -period 41.667 -name sys_clk [get_ports clk]
set_property PACKAGE_PIN D13 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

############################
## Reset Button (Key 0)
############################
set_property PACKAGE_PIN A13 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

############################
## LEDs (3-bit Counter Output)
############################
set_property PACKAGE_PIN D5 [get_ports {count[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {count[0]}]

set_property PACKAGE_PIN A3 [get_ports {count[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {count[1]}]

set_property PACKAGE_PIN B4 [get_ports {count[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {count[2]}]
