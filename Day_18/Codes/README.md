# Day 18 - UART Communication

This folder contains the Verilog HDL programs for implementing a **UART (Universal Asynchronous Receiver/Transmitter)** communication system. The design supports UART transmission and reception with optional parity checking, button-controlled message transmission and LED control through UART commands.

# Files

- `UART.v`
- `uart_tx.v`
- `uart_rx.v`
- `UART_tb.v`
- `uart.xdc`

# Description

`UART.v`
Contains the top-level Verilog implementation of the UART communication system. It instantiates the UART transmitter, UART receiver, button debounce logic and UART transmit controller. The design sends predefined messages whenever a push button is pressed and controls the onboard LEDs based on commands received through UART.

`uart_tx.v`
Contains the Verilog implementation of the UART transmitter. It serializes 8-bit parallel data into UART frames with configurable baud rate and optional parity generation.

`uart_rx.v`
Contains the Verilog implementation of the UART receiver. It receives serial UART data, converts it into parallel data and performs frame and parity error checking.

`UART_tb.v`
Contains the testbench used to simulate and verify the UART transmitter. The simulation generates the system clock, applies reset, transmits sample data and verifies the UART transmission.

`uart.xdc`
Contains the Xilinx Design Constraints (XDC) file that maps the **24 MHz system clock**, push buttons, LEDs, UART RX pin and UART TX pin to the FPGA pins. It also specifies the **LVCMOS33** I/O standard required for FPGA implementation.
