# UART

`uart_top` uses 8-N-1 UART with a 16x receiver oversample. `sentinel_command_rx`
accepts `A5 opcode sequence argument_hi argument_lo xor8`; `sentinel_telemetry_tx`
emits the documented `A6` telemetry frame. XOR failure generates a pulse on
`cmd_error` and never produces `cmd_valid`.

The baud divider is integer-only. At 24 MHz / 115200 baud the 16x sample rate
uses a divisor of 13, with approximately 0.16% frequency error.
