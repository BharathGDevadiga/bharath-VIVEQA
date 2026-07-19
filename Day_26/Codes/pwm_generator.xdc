## Clock
create_clock -period 41.667 -name sys_clk [get_ports clk]

set_property -dict { PACKAGE_PIN D13 IOSTANDARD LVCMOS33 } [get_ports clk]

## Reset
set_property -dict { PACKAGE_PIN A13 IOSTANDARD LVCMOS33 } [get_ports rst]

## Duty Cycle Inputs

set_property -dict { PACKAGE_PIN C9  IOSTANDARD LVCMOS33 } [get_ports duty_cycle[0]]
set_property -dict { PACKAGE_PIN B9  IOSTANDARD LVCMOS33 } [get_ports duty_cycle[1]]
set_property -dict { PACKAGE_PIN G5  IOSTANDARD LVCMOS33 } [get_ports duty_cycle[2]]
set_property -dict { PACKAGE_PIN A7  IOSTANDARD LVCMOS33 } [get_ports duty_cycle[3]]
set_property -dict { PACKAGE_PIN C7  IOSTANDARD LVCMOS33 } [get_ports duty_cycle[4]]
set_property -dict { PACKAGE_PIN A10 IOSTANDARD LVCMOS33 } [get_ports duty_cycle[5]]
set_property -dict { PACKAGE_PIN B7  IOSTANDARD LVCMOS33 } [get_ports duty_cycle[6]]
set_property -dict { PACKAGE_PIN A8  IOSTANDARD LVCMOS33 } [get_ports duty_cycle[7]]

## PWM Output

set_property -dict { PACKAGE_PIN D5 IOSTANDARD LVCMOS33 } [get_ports pwm_out]
