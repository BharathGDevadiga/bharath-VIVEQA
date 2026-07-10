############################
## 24 MHz Clock
############################
set_property PACKAGE_PIN D13 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 41.667 -name sys_clk [get_ports clk]

############################
## Reset Button
############################
set_property PACKAGE_PIN F5 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

############################
## Load Button
############################
set_property PACKAGE_PIN E3 [get_ports load]
set_property IOSTANDARD LVCMOS33 [get_ports load]

############################
## Shift Button
############################
set_property PACKAGE_PIN F2 [get_ports shift]
set_property IOSTANDARD LVCMOS33 [get_ports shift]

############################
## 4-bit Slide Switches
############################
set_property PACKAGE_PIN C9 [get_ports {data_in[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_in[0]}]

set_property PACKAGE_PIN B9 [get_ports {data_in[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_in[1]}]

set_property PACKAGE_PIN G5 [get_ports {data_in[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_in[2]}]

set_property PACKAGE_PIN A7 [get_ports {data_in[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {data_in[3]}]

############################
## Serial Output LED
############################
set_property PACKAGE_PIN D5 [get_ports data_out]
set_property IOSTANDARD LVCMOS33 [get_ports data_out]
