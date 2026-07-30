# Target Device: Artix-7 XC7A35T-FTG256-1
# Board: AT-STLN-ARTIX7-001 V1.0 (Anmaya Technologies)

# Clock Signal (24 MHz Onboard Oscillator)
set_property PACKAGE_PIN D13 [get_ports clk_24mhz]
set_property IOSTANDARD LVCMOS33 [get_ports clk_24mhz]
create_clock -period 41.667 -name sys_clk_pin -waveform {0.000 20.833} [get_ports clk_24mhz]

# Slide Switches S1 to S8 (Active High)
# S1: System Reset (DOWN = Reset held, UP = System Runs)
set_property PACKAGE_PIN C9 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

# S2: Alarm Clear / Silence Buzzer
set_property PACKAGE_PIN B9 [get_ports clear_alarm]
set_property IOSTANDARD LVCMOS33 [get_ports clear_alarm]

# S3: Display Lock (Hold 7-Seg on Temperature)
set_property PACKAGE_PIN G5 [get_ports sw_display_lock]
set_property IOSTANDARD LVCMOS33 [get_ports sw_display_lock]

# S4: Manual Alarm Test
set_property PACKAGE_PIN A7 [get_ports sw_alarm_test]
set_property IOSTANDARD LVCMOS33 [get_ports sw_alarm_test]

# S5: Manual Relay Force ON
set_property PACKAGE_PIN C7 [get_ports sw_relay_force]
set_property IOSTANDARD LVCMOS33 [get_ports sw_relay_force]

# S6: Tamper Sensitivity Boost
set_property PACKAGE_PIN A10 [get_ports sw_tamper_boost]
set_property IOSTANDARD LVCMOS33 [get_ports sw_tamper_boost]

# S7: SD Card Audit Log Active
set_property PACKAGE_PIN B7 [get_ports sw_sd_log_enable]
set_property IOSTANDARD LVCMOS33 [get_ports sw_sd_log_enable]

# S8: Master Clock Heartbeat Active
set_property PACKAGE_PIN A8 [get_ports sw_clock_heartbeat]
set_property IOSTANDARD LVCMOS33 [get_ports sw_clock_heartbeat]

# Status LEDs L1 to L8 (Placed directly above Switches S1 to S8)
set_property PACKAGE_PIN D5  [get_ports {led[0]}]
set_property PACKAGE_PIN A3  [get_ports {led[1]}]
set_property PACKAGE_PIN B4  [get_ports {led[2]}]
set_property PACKAGE_PIN A4  [get_ports {led[3]}]
set_property PACKAGE_PIN E6  [get_ports {led[4]}]
set_property PACKAGE_PIN C13 [get_ports {led[5]}]
set_property PACKAGE_PIN C14 [get_ports {led[6]}]
set_property PACKAGE_PIN D14 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

# 4x4 Matrix Keypad (Rows = Outputs, Columns = Inputs with PULLUP)
set_property PACKAGE_PIN J15 [get_ports {keypad_row_n[0]}]
set_property PACKAGE_PIN J16 [get_ports {keypad_row_n[1]}]
set_property PACKAGE_PIN K15 [get_ports {keypad_row_n[2]}]
set_property PACKAGE_PIN K16 [get_ports {keypad_row_n[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_row_n[*]}]

set_property PACKAGE_PIN L14 [get_ports {keypad_col_n[0]}]
set_property PACKAGE_PIN M14 [get_ports {keypad_col_n[1]}]
set_property PACKAGE_PIN N14 [get_ports {keypad_col_n[2]}]
set_property PACKAGE_PIN M16 [get_ports {keypad_col_n[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {keypad_col_n[*]}]
set_property PULLUP true [get_ports {keypad_col_n[*]}]

# USB/UART Telemetry Stream (FT232H Port J1)
set_property PACKAGE_PIN P15 [get_ports pmod_uart_rx]
set_property IOSTANDARD LVCMOS33 [get_ports pmod_uart_rx]

set_property PACKAGE_PIN P16 [get_ports pmod_uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports pmod_uart_tx]

# MAX7219 7-Segment SPI Display
set_property PACKAGE_PIN H11 [get_ports seg_din]
set_property PACKAGE_PIN H12 [get_ports seg_clk]
set_property PACKAGE_PIN H13 [get_ports seg_load]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_din seg_clk seg_load}]

# 16x2 HD44780 LCD Interface
set_property PACKAGE_PIN P10 [get_ports lcd_rs]
set_property PACKAGE_PIN P11 [get_ports lcd_rw]
set_property PACKAGE_PIN R11 [get_ports lcd_en]
set_property PACKAGE_PIN R10 [get_ports {lcd_d[0]}]
set_property PACKAGE_PIN T10 [get_ports {lcd_d[1]}]
set_property PACKAGE_PIN R12 [get_ports {lcd_d[2]}]
set_property PACKAGE_PIN T12 [get_ports {lcd_d[3]}]
set_property PACKAGE_PIN R13 [get_ports {lcd_d[4]}]
set_property PACKAGE_PIN T13 [get_ports {lcd_d[5]}]
set_property PACKAGE_PIN R15 [get_ports {lcd_d[6]}]
set_property PACKAGE_PIN T15 [get_ports {lcd_d[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {lcd_rs lcd_rw lcd_en lcd_d[*]}]

# Piezo Alarm Buzzer & Form-C Relay
set_property PACKAGE_PIN M15 [get_ports buzzer]
set_property IOSTANDARD LVCMOS33 [get_ports buzzer]

set_property PACKAGE_PIN N16 [get_ports relay_in]
set_property IOSTANDARD LVCMOS33 [get_ports relay_in]

# Micro-SD SPI Interface
set_property PACKAGE_PIN J13 [get_ports sd_clk]
set_property PACKAGE_PIN H14 [get_ports sd_cmd]
set_property PACKAGE_PIN J14 [get_ports sd_d0]
set_property PACKAGE_PIN H16 [get_ports sd_cs_n]
set_property PACKAGE_PIN G16 [get_ports sd_detect_n]
set_property IOSTANDARD LVCMOS33 [get_ports {sd_clk sd_cmd sd_d0 sd_cs_n sd_detect_n}]
set_property PULLUP true [get_ports sd_detect_n]

# DHT11 Temperature & Humidity Sensor
set_property PACKAGE_PIN F14 [get_ports dht11_data]
set_property IOSTANDARD LVCMOS33 [get_ports dht11_data]

# HC-SR04 Ultrasonic Distance Sensor
set_property PACKAGE_PIN E15 [get_ports hc_sr04_echo]
set_property PACKAGE_PIN E16 [get_ports hc_sr04_trigger]
set_property IOSTANDARD LVCMOS33 [get_ports {hc_sr04_echo hc_sr04_trigger}]

# MCP3202 Analog SPI ADC
set_property PACKAGE_PIN F12 [get_ports adc_sck]
set_property PACKAGE_PIN F13 [get_ports adc_mosi]
set_property PACKAGE_PIN G11 [get_ports adc_miso]
set_property PACKAGE_PIN G12 [get_ports adc_cs_n]
set_property IOSTANDARD LVCMOS33 [get_ports {adc_sck adc_mosi adc_miso adc_cs_n}]
