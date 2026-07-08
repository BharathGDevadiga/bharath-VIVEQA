##############################
# Output Pins (LEDs)
##############################

# Binary Output Bit 3 (MSB)
set_property -dict {PACKAGE_PIN D5  IOSTANDARD LVCMOS33} [get_ports bin[3]]

# Binary Output Bit 2
set_property -dict {PACKAGE_PIN A3  IOSTANDARD LVCMOS33} [get_ports bin[2]]

# Binary Output Bit 1
set_property -dict {PACKAGE_PIN B4  IOSTANDARD LVCMOS33} [get_ports bin[1]]

# Binary Output Bit 0 (LSB)
set_property -dict {PACKAGE_PIN A4  IOSTANDARD LVCMOS33} [get_ports bin[0]]


##############################
# Input Pins (Switches)
##############################

# Hex Input Bit 0
set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33} [get_ports hex[0]]

# Hex Input Bit 1
set_property -dict {PACKAGE_PIN F5  IOSTANDARD LVCMOS33} [get_ports hex[1]]

# Hex Input Bit 2
set_property -dict {PACKAGE_PIN E3  IOSTANDARD LVCMOS33} [get_ports hex[2]]

# Hex Input Bit 3
set_property -dict {PACKAGE_PIN F2  IOSTANDARD LVCMOS33} [get_ports hex[3]]

# Hex Input Bit 4
set_property -dict {PACKAGE_PIN A12 IOSTANDARD LVCMOS33} [get_ports hex[4]]

# Hex Input Bit 5
set_property -dict {PACKAGE_PIN D6  IOSTANDARD LVCMOS33} [get_ports hex[5]]

# Hex Input Bit 6
set_property -dict {PACKAGE_PIN D3  IOSTANDARD LVCMOS33} [get_ports hex[6]]

# Hex Input Bit 7
set_property -dict {PACKAGE_PIN F3  IOSTANDARD LVCMOS33} [get_ports hex[7]]

# Hex Input Bit 8
set_property -dict {PACKAGE_PIN A5  IOSTANDARD LVCMOS33} [get_ports hex[8]]

# Hex Input Bit 9
set_property -dict {PACKAGE_PIN C6  IOSTANDARD LVCMOS33} [get_ports hex[9]]

# Hex Input Bit 10
set_property -dict {PACKAGE_PIN D4  IOSTANDARD LVCMOS33} [get_ports hex[10]]

# Hex Input Bit 11
set_property -dict {PACKAGE_PIN F4  IOSTANDARD LVCMOS33} [get_ports hex[11]]

# Hex Input Bit 12
set_property -dict {PACKAGE_PIN B6  IOSTANDARD LVCMOS33} [get_ports hex[12]]

# Hex Input Bit 13
set_property -dict {PACKAGE_PIN B5  IOSTANDARD LVCMOS33} [get_ports hex[13]]

# Hex Input Bit 14
set_property -dict {PACKAGE_PIN C4  IOSTANDARD LVCMOS33} [get_ports hex[14]]

# Hex Input Bit 15
set_property -dict {PACKAGE_PIN E5  IOSTANDARD LVCMOS33} [get_ports hex[15]]
