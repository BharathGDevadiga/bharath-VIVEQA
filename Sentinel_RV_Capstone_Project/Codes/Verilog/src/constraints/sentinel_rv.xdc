## AT-STLN-ARTIX7-001 Hardware Reference Manual Pin Mapping (Anmaya Technologies)
## Target Device: Artix-7 XC7A35T-FTG256-1

#============================================================================
# 1. ## Configuration Bank Voltage - CFGBVS DRC Fix (Manual Section 2.1)
#============================================================================
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

#============================================================================
# 2. ## System Clock - 24 MHz Onboard Crystal Oscillator (Manual Section 3.9)
#============================================================================
create_clock -period 41.667 -name sys_clk [get_ports clk_24mhz]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports clk_24mhz]

#============================================================================
# 3. ## System Reset & Slide Switches S1-S8 (Manual Section 3.4 & Page 12)
#    S1 (C9)  - reset_pin   : System Reset (DOWN = Reset, UP = Run)
#    S2 (B9)  - clear_alarm : Security Alarm Clear / Buzzer Silence
#    S4 (A7)  - sw_alarm_test  : Manual Alarm / Buzzer Test
#    S5 (C7)  - sw_relay_force : Force Relay ON manually
#============================================================================
set_property -dict {PACKAGE_PIN C9  IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports reset_pin]
set_property -dict {PACKAGE_PIN B9  IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports clear_alarm]
set_property -dict {PACKAGE_PIN A7  IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports sw_alarm_test]
set_property -dict {PACKAGE_PIN C7  IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports sw_relay_force]

#============================================================================
# 4. ## User LEDs L1-L8 - Active Low (Manual Section 3.1 & Page 12)
#    L1 (D5)  - led[0] : System Power / Run (ON when S1 is UP)
#    L2 (A3)  - led[1] : SD Card Detected (ON when card inserted)
#    L3 (B4)  - led[2] : SD Card SPI Activity (ON during read/write)
#    L4 (A4)  - led[3] : RISC-V CPU Running (ON when PicoRV32 not trapped)
#    L5 (E6)  - led[4] : Relay Status (ON when Relay is energized)
#    L6 (C13) - led[5] : Security Alarm Active (ON when tamper detected)
#    L7 (C14) - led[6] : Command Accepted (ON when valid AES command received)
#    L8 (D14) - led[7] : Command Rejected (ON when replay/invalid command)
#============================================================================
set_property -dict {PACKAGE_PIN D5  IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN A3  IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN B4  IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN A4  IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN E6  IOSTANDARD LVCMOS33} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN C13 IOSTANDARD LVCMOS33} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33} [get_ports {led[7]}]



#============================================================================
# 7. ## Piezo Alarm Buzzer & Form-C Relay Coil Driver (Manual Section 4.10, 4.11 & Page 12)
#    buzzer    (K5) : Piezo buzzer output - 2 kHz tone when security alarm active
#    relay_in  (L5) : Relay coil control - HIGH = Relay energized/closed
#============================================================================
set_property -dict {PACKAGE_PIN K5 IOSTANDARD LVCMOS33} [get_ports buzzer]
set_property -dict {PACKAGE_PIN L5 IOSTANDARD LVCMOS33} [get_ports relay_in]

#============================================================================
# 8. ## DHT11 Temperature & Humidity Sensor - PMOD Header J16 Pin 4 (Manual Section 3.7)
#    dht11_data (M1) : Single-wire bidirectional data (INOUT)
#============================================================================
set_property -dict {PACKAGE_PIN M1  IOSTANDARD LVCMOS33} [get_ports dht11_data]

#============================================================================
# 9. ## MCP3202 12-bit SPI Analog-to-Digital Converter (Manual Section 4.4 & Page 12)
#    adc_sck  (G11) : SPI Clock Output to MCP3202
#    adc_mosi (G12) : SPI Master Out Slave In (MOSI)
#    adc_miso (G14) : SPI Master In Slave Out (MISO)
#    adc_cs_n (H14) : SPI Chip Select (Active Low)
#============================================================================
set_property -dict {PACKAGE_PIN G11 IOSTANDARD LVCMOS33} [get_ports adc_sck]
set_property -dict {PACKAGE_PIN G12 IOSTANDARD LVCMOS33} [get_ports adc_mosi]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports adc_miso]
set_property -dict {PACKAGE_PIN H14 IOSTANDARD LVCMOS33} [get_ports adc_cs_n]

#============================================================================
# 10. ## Micro-SD Card SPI Interface & Card Detect (Manual Section 4.6)
#     sd_clk     (C11) : SD Card SPI Clock
#     sd_cmd     (B12) : SD Card SPI MOSI (Command/Data)
#     sd_d0      (D8)  : SD Card SPI MISO (Data Out from card)
#     sd_cs_n    (B11) : SD Card SPI Chip Select (Active Low)
#     sd_detect_n(C12) : SD Card Physical Presence Detect (Active Low, PULLUP)
#============================================================================
set_property -dict {PACKAGE_PIN C11 IOSTANDARD LVCMOS33} [get_ports sd_clk]
set_property -dict {PACKAGE_PIN B12 IOSTANDARD LVCMOS33} [get_ports sd_cmd]
set_property -dict {PACKAGE_PIN D8  IOSTANDARD LVCMOS33} [get_ports sd_d0]
set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports sd_cs_n]
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33 PULLUP true} [get_ports sd_detect_n]

#============================================================================
# 11. ## PMOD Telemetry UART Interface - Host PC Communication (Manual Section 3.7 & Section 4.1)
#     pmod_uart_tx (T2) : FPGA Transmit -> Host PC Receive (Telemetry / Sensor Data)
#     pmod_uart_rx (R3) : Host PC Transmit -> FPGA Receive (Encrypted Commands)
#     Baud Rate: 115200, 8N1
#============================================================================
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports pmod_uart_tx]
set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports pmod_uart_rx]
