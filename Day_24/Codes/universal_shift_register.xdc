## Clock
create_clock -period 41.667 -name sys_clk [get_ports clk]
set_property PACKAGE_PIN D13 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

## Reset
set_property PACKAGE_PIN A13 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

## Mode Select

set_property PACKAGE_PIN C9 [get_ports {mode[1]}]
set_property PACKAGE_PIN B9 [get_ports {mode[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports mode[*]]

## Serial Inputs

set_property PACKAGE_PIN G5 [get_ports serial_left]
set_property PACKAGE_PIN A7 [get_ports serial_right]

set_property IOSTANDARD LVCMOS33 [get_ports serial_left]
set_property IOSTANDARD LVCMOS33 [get_ports serial_right]

## Parallel Inputs

set_property PACKAGE_PIN C7  [get_ports {parallel_in[3]}]
set_property PACKAGE_PIN A10 [get_ports {parallel_in[2]}]
set_property PACKAGE_PIN B7  [get_ports {parallel_in[1]}]
set_property PACKAGE_PIN A8  [get_ports {parallel_in[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports parallel_in[*]]

## LEDs

set_property PACKAGE_PIN D5  [get_ports {q[3]}]
set_property PACKAGE_PIN A3  [get_ports {q[2]}]
set_property PACKAGE_PIN B4  [get_ports {q[1]}]
set_property PACKAGE_PIN A4  [get_ports {q[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports q[*]]
