############################
## 24 MHz System Clock
############################

set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports clk_24mhz]
create_clock -period 41.667 -name sys_clk -waveform {0.000 20.833} [get_ports clk_24mhz]

############################
## MAX7219 SPI Interface
############################

# Chip Select (CS)
set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS33} [get_ports seg_cs]

# SPI Clock (CLK)
set_property -dict {PACKAGE_PIN B9 IOSTANDARD LVCMOS33} [get_ports seg_clk]

# SPI Data Input (DIN)
set_property -dict {PACKAGE_PIN G5 IOSTANDARD LVCMOS33} [get_ports seg_din]
