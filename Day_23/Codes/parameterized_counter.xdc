## Clock
create_clock -period 41.667 -name sys_clk [get_ports clk]
set_property PACKAGE_PIN D13 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

## Reset Button
set_property PACKAGE_PIN A13 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

## Enable Button
set_property PACKAGE_PIN F5 [get_ports en]
set_property IOSTANDARD LVCMOS33 [get_ports en]

## LEDs
set_property PACKAGE_PIN D5  [get_ports {count[7]}]
set_property PACKAGE_PIN A3  [get_ports {count[6]}]
set_property PACKAGE_PIN B4  [get_ports {count[5]}]
set_property PACKAGE_PIN A4  [get_ports {count[4]}]
set_property PACKAGE_PIN E6  [get_ports {count[3]}]
set_property PACKAGE_PIN C13 [get_ports {count[2]}]
set_property PACKAGE_PIN C14 [get_ports {count[1]}]
set_property PACKAGE_PIN D14 [get_ports {count[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports count[*]]
