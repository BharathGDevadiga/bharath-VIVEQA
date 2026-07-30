# Sentinel-RV Team 2

Synthesizable Verilog for the peripherals surrounding Team 1's
`sentinel_rv_security` core on the AT-STLN-ARTIX7-001 Artix-7 board.

## Security boundary

Team 2 does not decide whether an actuator may move.  `team2_top` accepts
`core_actuator_authorized` and command fields from Team 1, and every actuator
driver requires that authorization input.  Team 2 passes these inputs to Team
1:

- `core_adc_sample` / `core_adc_sample_valid`: MCP3202 CH0/CH1 samples.
- `core_command_*`: framed UART command received from trusted PMOD or ESP32.
- `core_key_*`: local keypad events.

Team 1 provides telemetry, HMI status, audit digests, and authenticated
actuator intent through the `core_*` inputs on `team2_top`.  The final
`sentinel_rv_top` wrapper keeps the same ports so Team 1 can be connected with
named port associations without changing the board-facing implementation.

## Framing

- PMOD command: `A5 opcode sequence argument[15:8] argument[7:0] xor8`.
- PMOD telemetry: `A6 sequence event sensor[11:8] sensor[7:0] status xor8`.
- ESP32 command: `E3 type value[15:8] value[7:0] xor8`.
- ESP32 dashboard: `D3 sequence event sensor[11:8] sensor[7:0] status xor8`.

`xor8` is the XOR of every preceding byte in the frame.  It is a transport
integrity check only; Team 1 must authenticate and replay-check every command.

## Board notes

The supplied manual conflicts about the SPI and SD assignments.  The XDC uses
the detailed ADC table (G11/G12/G14/H14) and the detailed SD table
(C11/B12/D8/B11), not the contradictory abbreviated XDC snippet on manual
page 12.  Confirm these nets against the board schematic before programming.

The manual's keypad pin table names individual keys while also describing a
4x4 matrix.  `team2.xdc` deliberately leaves keypad assignments commented out
until the row/column wiring is confirmed; applying guessed pin constraints can
damage the intended interface.

## Build

Use a Verilog-2001/SystemVerilog-capable simulator.  Example with Icarus:

```text
iverilog -g2012 -s tb_uart_top -o sim tb/tb_uart_top.v uart/*.v
vvp sim
```

To compile and run every supplied testbench on Windows PowerShell:

```text
.\tb\run_tests.ps1
```

Hardware use requires a reset source.  `reset` is synchronous active-high in
all modules.
