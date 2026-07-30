# Sentinel-RV Combined Project

This tree combines Team 1's security/core RTL and Team 2's peripheral RTL.
The synthesis top is `sentinel_rv_board_top`. The full `sentinel_rv_top`
wrapper remains available for simulation and exposes Team 1 debug/data buses;
using it directly as a board top would create hundreds of physical I/O pins.

## Command path

PMOD or ESP32 bytes are framed by Team 2. `sentinel_command_rx` or
`esp32_packet_parser` produces `core_command_valid`; Team 1 then checks the
packet through the security controller and replay table. Only
`security_command_accepted` authorizes relay, motor, or stepper outputs.

## Telemetry and HMI

ADC samples and security events are routed to Team 2 telemetry, LCD, LEDs,
seven-segment display, buzzer, and UART/ESP32 links. The combined wrapper also
exposes the Team 1 AES packet output and XADC sample inputs.

## Important integration assumptions

- Team 2's XOR frame check is represented at the Team 1 boundary by
  `rx_crc_ok`; replace this with the packet CRC engine when the final incoming
  packet byte bus is available.
- The PicoRV32 wrapper is inert unless the official `picorv32.v` source is
  added and `SENTINEL_USE_PICORV32` is defined for synthesis.
- XADC raw code thresholds must be calibrated for the board's XADC adapter.
- Verify the existing Team 2 XDC against the board schematic before hardware.
- Add `cpu_test_program.hex` as a Vivado memory initialization file.
