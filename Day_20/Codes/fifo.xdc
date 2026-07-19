## Clock
create_clock -period 41.667 -name sys_clk [get_ports clk]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports clk]


## User LEDs (L1-L8 shown; extend to L16)
set_property -dict {PACKAGE_PIN D5  IOSTANDARD LVCMOS33} [get_ports read_data[7]]
set_property -dict {PACKAGE_PIN A3  IOSTANDARD LVCMOS33} [get_ports read_data[6]]
set_property -dict {PACKAGE_PIN B4  IOSTANDARD LVCMOS33} [get_ports read_data[5]]
set_property -dict {PACKAGE_PIN A4  IOSTANDARD LVCMOS33} [get_ports read_data[4]]
set_property -dict {PACKAGE_PIN E6  IOSTANDARD LVCMOS33} [get_ports read_data[3]]
set_property -dict {PACKAGE_PIN C13  IOSTANDARD LVCMOS33} [get_ports read_data[2]]
set_property -dict {PACKAGE_PIN C14  IOSTANDARD LVCMOS33} [get_ports read_data[1]]
set_property -dict {PACKAGE_PIN D14  IOSTANDARD LVCMOS33} [get_ports read_data[0]]


## Slide Switches
set_property -dict {PACKAGE_PIN C9  IOSTANDARD LVCMOS33} [get_ports write_data[7]]
set_property -dict {PACKAGE_PIN B9  IOSTANDARD LVCMOS33} [get_ports write_data[6]]
set_property -dict {PACKAGE_PIN G5  IOSTANDARD LVCMOS33} [get_ports write_data[5]]
set_property -dict {PACKAGE_PIN A7  IOSTANDARD LVCMOS33} [get_ports write_data[4]]
set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS33} [get_ports write_data[3]]
set_property -dict {PACKAGE_PIN A10 IOSTANDARD LVCMOS33} [get_ports write_data[2]]
set_property -dict {PACKAGE_PIN B7 IOSTANDARD LVCMOS33} [get_ports write_data[1]]
set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS33} [get_ports write_data[0]]


## 7-Segment Display (MAX7219 SPI)
set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33} [get_ports rst]
set_property -dict {PACKAGE_PIN F5 IOSTANDARD LVCMOS33} [get_ports wr_en]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports rd_en]

