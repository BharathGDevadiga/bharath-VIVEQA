# Day 18 - UART Communication

## Introduction

This project demonstrates the implementation of a **UART (Universal Asynchronous Receiver/Transmitter)** communication system using Verilog HDL. The design supports UART transmission and reception with configurable baud rate and optional parity checking. It also includes button debouncing predefined message transmission and LED control through UART commands.

This project introduces the concepts of serial communication UART protocol finite state machines (FSMs) button debouncing and FPGA implementation using Verilog HDL.

---

## UART Communication

UART (Universal Asynchronous Receiver/Transmitter) is a serial communication protocol used to transfer data between devices without a shared clock.

The transmitter converts parallel data into serial data while the receiver converts serial data back into parallel data.

---

## UART Transmitter

The UART transmitter sends 8-bit data one bit at a time.

The transmitted frame consists of:

- Start Bit
- 8 Data Bits
- Optional Parity Bit
- Stop Bit

The baud rate determines the speed of communication.

---

## UART Receiver

The UART receiver detects the start bit samples the incoming serial data checks the parity (if enabled) verifies the stop bit and stores the received byte.

It also generates:

- Receive Complete (`rx_done`)
- Parity Error (`parity_err`)
- Frame Error (`frame_err`)

---

## Input and Output Ports

```verilog
input clk;
input rst;

input uart_rx_pin;
output uart_tx_pin;

input [3:0] btn;
output [3:0] led;
```

- **clk** – System clock
- **rst** – System reset
- **uart_rx_pin** – UART receive pin
- **uart_tx_pin** – UART transmit pin
- **btn[3:0]** – Push button inputs
- **led[3:0]** – LED outputs

---

## Working Principle

Initially the UART waits for data or button presses.

- When a button is pressed the corresponding message is transmitted through UART.
- When UART receives a valid command the LEDs respond accordingly.
- Commands `1` `2` `3` and `4` turn on the respective LED for two seconds.
- Command `a` turns on all LEDs.
- Command `x` turns off all LEDs.
- Button inputs are debounced before transmission.

---

## UART Commands

| Received Character | Action |
|--------------------|--------|
| `1` | Turn ON LED 0 |
| `2` | Turn ON LED 1 |
| `3` | Turn ON LED 2 |
| `4` | Turn ON LED 3 |
| `a` | Turn ON All LEDs |
| `x` | Turn OFF All LEDs |

---

## Button Messages

Each push button sends a predefined UART message.

| Button | Message |
|---------|---------|
| BTN0 | Button 0 Pressed |
| BTN1 | Button 1 Pressed |
| BTN2 | Button 2 Pressed |
| BTN3 | Button 3 Pressed |

---

## Button Debouncing

Mechanical push buttons produce unwanted transitions when pressed.

A debounce circuit removes these unwanted changes and generates a clean button press signal.

---

## UART Transmit Controller

A Finite State Machine (FSM) controls message transmission.

The FSM performs the following steps:

- Waits for a button press.
- Loads the message.
- Sends one character at a time.
- Waits until transmission is complete.
- Sends the next character.
- Returns to the idle state.

---

## FPGA Mapping

Typical FPGA connections:

- **CLK** → 24 MHz Clock
- **BTN0–BTN3** → Push Buttons
- **LED0–LED3** → LEDs
- **UART RX** → Serial Receive Pin
- **UART TX** → Serial Transmit Pin

---

## Simulation

The testbench verifies:

- Reset operation
- UART data transmission
- UART transmitter timing
- Busy and Done signals
- Correct serial output

The simulation confirms that the UART transmitter sends the correct serial data.

---

## Applications

- Serial Communication
- FPGA Debugging
- Embedded Systems
- Microcontroller Communication
- PC-to-FPGA Communication
- IoT Devices
- Industrial Automation

---

## Key Takeaways

- Learned the basics of UART communication.
- Implemented UART transmitter and receiver using Verilog HDL.
- Understood serial data transmission and reception.
- Used configurable baud rate and optional parity checking.
- Implemented button debouncing for reliable input detection.
- Controlled LEDs using UART commands.
- Verified the design using a simulation testbench.
- Implemented the design on an FPGA.
