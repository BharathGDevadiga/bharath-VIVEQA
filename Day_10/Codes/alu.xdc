############################
## Slide Switches -> push[7:0]
############################

set_property -dict {PACKAGE_PIN C9  IOSTANDARD LVCMOS33} [get_ports {push[0]}]
set_property -dict {PACKAGE_PIN B9  IOSTANDARD LVCMOS33} [get_ports {push[1]}]
set_property -dict {PACKAGE_PIN G5  IOSTANDARD LVCMOS33} [get_ports {push[2]}]
set_property -dict {PACKAGE_PIN A7  IOSTANDARD LVCMOS33} [get_ports {push[3]}]
set_property -dict {PACKAGE_PIN C7  IOSTANDARD LVCMOS33} [get_ports {push[4]}]
set_property -dict {PACKAGE_PIN A10 IOSTANDARD LVCMOS33} [get_ports {push[5]}]
set_property -dict {PACKAGE_PIN B7  IOSTANDARD LVCMOS33} [get_ports {push[6]}]
set_property -dict {PACKAGE_PIN A8  IOSTANDARD LVCMOS33} [get_ports {push[7]}]

############################
## LEDs -> led[7:0]
############################

set_property -dict {PACKAGE_PIN D5  IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN A3  IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN B4  IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN A4  IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN E6  IOSTANDARD LVCMOS33} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33} [get_ports {led[7]}]

############################
## Keypad -> key[15:0]
############################

set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33} [get_ports {key[0]}]
set_property -dict {PACKAGE_PIN F5  IOSTANDARD LVCMOS33} [get_ports {key[1]}]
set_property -dict {PACKAGE_PIN E3  IOSTANDARD LVCMOS33} [get_ports {key[2]}]
set_property -dict {PACKAGE_PIN F2  IOSTANDARD LVCMOS33} [get_ports {key[3]}]
set_property -dict {PACKAGE_PIN A12 IOSTANDARD LVCMOS33} [get_ports {key[4]}]
set_property -dict {PACKAGE_PIN D6  IOSTANDARD LVCMOS33} [get_ports {key[5]}]
set_property -dict {PACKAGE_PIN D3  IOSTANDARD LVCMOS33} [get_ports {key[6]}]
set_property -dict {PACKAGE_PIN F3  IOSTANDARD LVCMOS33} [get_ports {key[7]}]
set_property -dict {PACKAGE_PIN A5  IOSTANDARD LVCMOS33} [get_ports {key[8]}]
set_property -dict {PACKAGE_PIN C6  IOSTANDARD LVCMOS33} [get_ports {key[9]}]
set_property -dict {PACKAGE_PIN D4  IOSTANDARD LVCMOS33} [get_ports {key[10]}]
set_property -dict {PACKAGE_PIN F4  IOSTANDARD LVCMOS33} [get_ports {key[11]}]
set_property -dict {PACKAGE_PIN B6  IOSTANDARD LVCMOS33} [get_ports {key[12]}]
set_property -dict {PACKAGE_PIN B5  IOSTANDARD LVCMOS33} [get_ports {key[13]}]
set_property -dict {PACKAGE_PIN C4  IOSTANDARD LVCMOS33} [get_ports {key[14]}]
set_property -dict {PACKAGE_PIN E5  IOSTANDARD LVCMOS33} [get_ports {key[15]}]
