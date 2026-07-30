## AT-STLN-ARTIX7-001 Team 2 constraints
## Confirm against the schematic before programming: the supplied manual has
## conflicting SPI/SD entries. These assignments use its detailed tables.

create_clock -period 41.667 -name sys_clk [get_ports clk_24mhz]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports clk_24mhz]

## User LEDs (only LED1-LED8 are documented in the supplied manual)
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN E6 IOSTANDARD LVCMOS33} [get_ports {led[4]}]
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

## Alarm and actuators
set_property -dict {PACKAGE_PIN K5 IOSTANDARD LVCMOS33} [get_ports buzzer]
set_property -dict {PACKAGE_PIN L5 IOSTANDARD LVCMOS33} [get_ports relay_in]
set_property -dict {PACKAGE_PIN F12 IOSTANDARD LVCMOS33} [get_ports motor_in1]
set_property -dict {PACKAGE_PIN H11 IOSTANDARD LVCMOS33} [get_ports motor_in2]
set_property -dict {PACKAGE_PIN E12 IOSTANDARD LVCMOS33} [get_ports {stepper[0]}]
set_property -dict {PACKAGE_PIN E13 IOSTANDARD LVCMOS33} [get_ports {stepper[1]}]
set_property -dict {PACKAGE_PIN E11 IOSTANDARD LVCMOS33} [get_ports {stepper[2]}]
set_property -dict {PACKAGE_PIN D11 IOSTANDARD LVCMOS33} [get_ports {stepper[3]}]

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

## PMOD UART uses J16 IO_0/IO_1. Set the peer board to the crossed direction.
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports pmod_uart_tx]
set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports pmod_uart_rx]

## The manual routes ESP32 UART through J13 but does not give FPGA ball names.
## Leave esp_uart_rx/esp_uart_tx unconstrained until the J13 schematic sheet is verified.

## The keypad table is internally inconsistent: it names 16 keys but describes
## a four-row/four-column matrix. Do not apply guessed PACKAGE_PIN properties.
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_row_n[*] keypad_col_n[*]}]
set_property PULLUP true [get_ports {keypad_col_n[*]}]

## DHT11 and Ultrasonic Sensors (PMOD J16 IO_4, IO_5, IO_6)
set_property -dict {PACKAGE_PIN M1 IOSTANDARD LVCMOS33} [get_ports dht11_data]
set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports hc_sr04_echo]
set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports hc_sr04_trigger]
