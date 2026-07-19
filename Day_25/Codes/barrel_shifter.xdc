
##==========================================================
## Slide Switches (8-bit Input Data)
##==========================================================
set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS33} [get_ports data_in[0]]
set_property -dict {PACKAGE_PIN B9 IOSTANDARD LVCMOS33} [get_ports data_in[1]]
set_property -dict {PACKAGE_PIN G5 IOSTANDARD LVCMOS33} [get_ports data_in[2]]
set_property -dict {PACKAGE_PIN A7 IOSTANDARD LVCMOS33} [get_ports data_in[3]]
set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS33} [get_ports data_in[4]]
set_property -dict {PACKAGE_PIN A10 IOSTANDARD LVCMOS33} [get_ports data_in[5]]
set_property -dict {PACKAGE_PIN B7 IOSTANDARD LVCMOS33} [get_ports data_in[6]]
set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS33} [get_ports data_in[7]]

##==========================================================
## LEDs (Shifted Output)
##==========================================================
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS33} [get_ports data_out[0]]
set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports data_out[1]]
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS33} [get_ports data_out[2]]
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports data_out[3]]
set_property -dict {PACKAGE_PIN E6 IOSTANDARD LVCMOS33} [get_ports data_out[4]]
set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33} [get_ports data_out[5]]
set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33} [get_ports data_out[6]]
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33} [get_ports data_out[7]]

##==========================================================
## Shift Amount (3 Push Buttons)
##==========================================================
set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33} [get_ports shift_amt[0]]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports shift_amt[1]]
set_property -dict {PACKAGE_PIN F5 IOSTANDARD LVCMOS33} [get_ports shift_amt[2]]

##==========================================================
## Direction (Use Relay Output Pin)
##==========================================================
set_property -dict {PACKAGE_PIN L5 IOSTANDARD LVCMOS33} [get_ports dir]
