###################################################
## Clock
###################################################

set_property PACKAGE_PIN D13 [get_ports clk_24mhz]
set_property IOSTANDARD LVCMOS33 [get_ports clk_24mhz]

create_clock -period 41.667 -name clk24 [get_ports clk_24mhz]

###################################################
## MAX7219
###################################################

# DIN
set_property PACKAGE_PIN J15 [get_ports seg_din]
set_property IOSTANDARD LVCMOS33 [get_ports seg_din]

# LOAD / CS
set_property PACKAGE_PIN J16 [get_ports seg_cs]
set_property IOSTANDARD LVCMOS33 [get_ports seg_cs]

# CLK
set_property PACKAGE_PIN H12 [get_ports seg_clk]
set_property IOSTANDARD LVCMOS33 [get_ports seg_clk]
