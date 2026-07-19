## Slide Switches (Binary Input)

set_property -dict { PACKAGE_PIN C9 IOSTANDARD LVCMOS33 } [get_ports binary[0]]
set_property -dict { PACKAGE_PIN B9 IOSTANDARD LVCMOS33 } [get_ports binary[1]]
set_property -dict { PACKAGE_PIN G5 IOSTANDARD LVCMOS33 } [get_ports binary[2]]
set_property -dict { PACKAGE_PIN A7 IOSTANDARD LVCMOS33 } [get_ports binary[3]]

## LEDs (Binary to Gray Output)

set_property -dict { PACKAGE_PIN D5 IOSTANDARD LVCMOS33 } [get_ports binary_to_gray[0]]
set_property -dict { PACKAGE_PIN A3 IOSTANDARD LVCMOS33 } [get_ports binary_to_gray[1]]
set_property -dict { PACKAGE_PIN B4 IOSTANDARD LVCMOS33 } [get_ports binary_to_gray[2]]
set_property -dict { PACKAGE_PIN A4 IOSTANDARD LVCMOS33 } [get_ports binary_to_gray[3]]
