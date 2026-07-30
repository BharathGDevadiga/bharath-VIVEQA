## DRC Warning Overrides for Clean Reports
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]

create_clock -period 41.667 -name sys_clk [get_ports clk_24mhz]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports clk_24mhz]

## False Paths for Low-Speed Asynchronous Peripherals (Displays, LEDs, Actuators)
set_false_path -to [get_ports {led[*]}]
set_false_path -to [get_ports {seg_din seg_load seg_clk}]
set_false_path -to [get_ports {lcd_rs lcd_rw lcd_en lcd_d[*]}]
set_false_path -to [get_ports {buzzer relay_in hc_sr04_trigger}]
set_false_path -from [get_ports {reset clear_alarm dht11_data hc_sr04_echo}]

## Slide Switches S1 to S8 (SW0 to SW7)
# S1 (C9) - Move DOWN for reset, UP to run
set_property -dict {PACKAGE_PIN C9  IOSTANDARD LVCMOS33} [get_ports reset]
# S2 (B9) - Alarm Clear / Silence Buzzer
set_property -dict {PACKAGE_PIN B9  IOSTANDARD LVCMOS33} [get_ports clear_alarm]
# S3 (G5) - Lock 7-Seg on Temp
set_property -dict {PACKAGE_PIN G5  IOSTANDARD LVCMOS33} [get_ports sw_display_lock]
# S4 (A7) - Manual Alarm Test
set_property -dict {PACKAGE_PIN A7  IOSTANDARD LVCMOS33} [get_ports sw_alarm_test]
# S5 (C7) - Manual Relay Force ON
set_property -dict {PACKAGE_PIN C7  IOSTANDARD LVCMOS33} [get_ports sw_relay_force]
# S6 (A10) - Tamper Glitch Boost
set_property -dict {PACKAGE_PIN A10 IOSTANDARD LVCMOS33} [get_ports sw_tamper_boost]
# S7 (B7) - SD Log Active
set_property -dict {PACKAGE_PIN B7  IOSTANDARD LVCMOS33} [get_ports sw_sd_log_enable]
# S8 (A8) - Master Clock Heartbeat
set_property -dict {PACKAGE_PIN A8  IOSTANDARD LVCMOS33} [get_ports sw_clock_heartbeat]

## 4x4 Matrix Keypad (Bank 35)
set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33} [get_ports {keypad_row_n[0]}]
set_property -dict {PACKAGE_PIN F5  IOSTANDARD LVCMOS33} [get_ports {keypad_row_n[1]}]
set_property -dict {PACKAGE_PIN E3  IOSTANDARD LVCMOS33} [get_ports {keypad_row_n[2]}]
set_property -dict {PACKAGE_PIN F2  IOSTANDARD LVCMOS33} [get_ports {keypad_row_n[3]}]

set_property -dict {PACKAGE_PIN A12 IOSTANDARD LVCMOS33 PULLUP true} [get_ports {keypad_col_n[0]}]
set_property -dict {PACKAGE_PIN D6  IOSTANDARD LVCMOS33 PULLUP true} [get_ports {keypad_col_n[1]}]
set_property -dict {PACKAGE_PIN D3  IOSTANDARD LVCMOS33 PULLUP true} [get_ports {keypad_col_n[2]}]
set_property -dict {PACKAGE_PIN F3  IOSTANDARD LVCMOS33 PULLUP true} [get_ports {keypad_col_n[3]}]

## User LEDs (LED1=D5 through LED8=D14)
set_property -dict {PACKAGE_PIN D5  IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN A3  IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN B4  IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN A4  IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN E6  IOSTANDARD LVCMOS33} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33} [get_ports {led[7]}]

## MAX7219 4-digit display
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports seg_din]
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS33} [get_ports seg_load]
set_property -dict {PACKAGE_PIN H12 IOSTANDARD LVCMOS33} [get_ports seg_clk]

## LCD in 8-bit write mode
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33} [get_ports lcd_rs]
set_property -dict {PACKAGE_PIN H3 IOSTANDARD LVCMOS33} [get_ports lcd_rw]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports lcd_en]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {lcd_d[0]}]
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {lcd_d[1]}]
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports {lcd_d[2]}]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {lcd_d[3]}]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {lcd_d[4]}]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33} [get_ports {lcd_d[5]}]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {lcd_d[6]}]
set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports {lcd_d[7]}]

## Alarm 
set_property -dict {PACKAGE_PIN K5 IOSTANDARD LVCMOS33} [get_ports buzzer]
set_property -dict {PACKAGE_PIN L5 IOSTANDARD LVCMOS33} [get_ports relay_in]


## MCP3202 SPI (manual section 4.4)
set_property -dict {PACKAGE_PIN G11 IOSTANDARD LVCMOS33} [get_ports adc_sck]
set_property -dict {PACKAGE_PIN G12 IOSTANDARD LVCMOS33} [get_ports adc_mosi]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports adc_miso]
set_property -dict {PACKAGE_PIN H14 IOSTANDARD LVCMOS33} [get_ports adc_cs_n]

## Micro-SD in SPI mode (manual section 4.6)
set_property -dict {PACKAGE_PIN C11 IOSTANDARD LVCMOS33} [get_ports sd_clk]
set_property -dict {PACKAGE_PIN B12 IOSTANDARD LVCMOS33} [get_ports sd_cmd]
set_property -dict {PACKAGE_PIN D8 IOSTANDARD LVCMOS33} [get_ports sd_d0]
set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports sd_cs_n]
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33} [get_ports sd_detect_n]

## PMOD UART uses J16 IO_0 and IO_2
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports pmod_uart_tx]
set_property -dict {PACKAGE_PIN T3 IOSTANDARD LVCMOS33} [get_ports pmod_uart_rx]

## DHT11 and Ultrasonic Sensors (PMOD J16 IO_4, IO_5, IO_6)
set_property -dict {PACKAGE_PIN M1 IOSTANDARD LVCMOS33 PULLUP true} [get_ports dht11_data]
set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports hc_sr04_echo]
set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports hc_sr04_trigger]

## Configuration voltage
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
