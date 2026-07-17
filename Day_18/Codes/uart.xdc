# Clock
set_property PACKAGE_PIN D13 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 41.667 [get_ports clk]

# LEDs L1-L3
set_property PACKAGE_PIN D5 [get_ports {led[0]}]
set_property PACKAGE_PIN A3 [get_ports {led[1]}]
set_property PACKAGE_PIN B4 [get_ports {led[2]}]
set_property PACKAGE_PIN A4 [get_ports {led[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]


set_property PACKAGE_PIN A13 [get_ports {btn[0]}]
set_property PACKAGE_PIN F5 [get_ports {btn[1]}]
set_property PACKAGE_PIN E3 [get_ports {btn[2]}]
set_property PACKAGE_PIN F2 [get_ports {btn[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {btn[*]}]

set_property PACKAGE_PIN A12 [get_ports rst]

set_property IOSTANDARD LVCMOS33 [get_ports rst]

set_property PACKAGE_PIN D5 [get_ports {led[0]}]
set_property PACKAGE_PIN A3 [get_ports {led[1]}]

set_property PACKAGE_PIN T2 [get_ports uart_rx_pin]
set_property PACKAGE_PIN T3 [get_ports uart_tx_pin]

set_property IOSTANDARD LVCMOS33 [get_ports uart_rx_pin]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx_pin]
