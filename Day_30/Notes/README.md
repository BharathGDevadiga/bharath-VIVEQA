# Day 30 - Digital Dice Game

## Introduction

This project introduces concepts of pseudo-random number generation, LFSR design, sequential logic, seven-segment display interfacing and FPGA implementation using Verilog HDL.

The design uses a 16-bit Linear Feedback Shift Register (LFSR) to generate pseudo-random values. The generated dice value is decoded and displayed on a seven-segment display.

---

## Digital Dice Game

A Digital Dice Game consists of:

- Random number generation logic
- Dice value conversion logic
- Seven-segment display decoder
- Push button control

The dice generates values between **1 and 6**.

The user can roll the dice by pressing the push button. The generated random value is displayed on the seven-segment display.

---

## Linear Feedback Shift Register (LFSR)

The design uses a **16-bit Linear Feedback Shift Register** for generating pseudo-random sequences.

An LFSR is a sequential circuit that generates a sequence of binary values using:

- Shift registers
- Feedback logic
- XOR operation

### Advantages of using LFSR

- Simple hardware implementation
- High-speed operation
- Low resource utilization
- Suitable for FPGA designs

The generated LFSR output is converted into a valid dice value ranging from 1 to 6.

---

## Input and Output Ports

```verilog
input clk_24mhz;
input rst;
input roll;

output reg [6:0] seg;
output [3:0] an;
```

## Port Description

| Port | Description |
|------|-------------|
| clk_24mhz | 24 MHz System Clock |
| rst | Reset signal used to initialize the LFSR |
| roll | Push button input used for rolling the dice |
| seg | Seven segment display output |
| an | Seven segment digit enable signal |

---

## Working Principle

Initially the LFSR starts generating pseudo-random values continuously with every positive edge of the clock.

When the roll button is pressed:

1. The current LFSR value is captured.
2. The generated value is converted into a number between 1 and 6.
3. The corresponding seven-segment pattern is generated.
4. The dice value is displayed on the seven-segment display.

When the reset button is activated:

- The LFSR is initialized with a predefined seed value.
- The dice output returns to the initial state.
- The display output is cleared.

---

## Dice Value Generation

The current LFSR value is converted into a dice value between **1 and 6** using the modulo (`%`) operation.

The dice value is calculated using:

```verilog
dice_value <= (lfsr % 6) + 1;
```

This ensures that the generated dice value is always between **1** and **6**.

The generated dice value is then passed to the seven-segment decoder for display.

## Seven Segment Display

The seven-segment display decoder converts the dice value into display signals.

The seven-segment display shows:

| Dice Value | Seven Segment Display |
|------------|------------------------|
| 1 | Seven Segment Pattern for 1 |
| 2 | Seven Segment Pattern for 2 |
| 3 | Seven Segment Pattern for 3 |
| 4 | Seven Segment Pattern for 4 |
| 5 | Seven Segment Pattern for 5 |
| 6 | Seven Segment Pattern for 6 |

The digit enable signal selects the required display digit.

---

## Sequential Logic

The Digital Dice Game is a sequential circuit.

The operation depends on:

- System Clock
- Reset Signal
- Roll Button Input
- LFSR Feedback Logic
- Seven Segment Decoder Logic

The LFSR updates its state on every positive edge of the clock.

The dice value changes whenever a new roll operation is performed.

---

## FPGA Mapping

Typical FPGA connections:

| FPGA Component | Signal |
|----------------|--------|
| 24 MHz Clock | clk_24mhz |
| Reset Button | rst |
| Roll Input | roll |
| Seven-Segment Display | seg |
| Digit Enable | an |

The push button is used to roll the dice while the seven-segment display shows the generated random dice value.

---

## Simulation

The testbench verifies the following operations:

- Clock generation
- Reset operation
- LFSR random sequence generation
- Dice value generation
- Roll button operation
- Seven-segment decoder
- Seven-segment display output

The simulation confirms that the Digital Dice Game correctly generates pseudo-random dice values and displays the corresponding output on the seven-segment display.

---

## Applications

- Digital Games
- Random Number Generators
- Electronic Dice Systems
- Embedded Systems
- FPGA Learning Projects
- Digital Logic Demonstrations

---

## Key Takeaways

- Learned the fundamentals of Linear Feedback Shift Registers.
- Implemented pseudo-random number generation using Verilog HDL.
- Designed a digital dice system using sequential logic.
- Understood seven-segment display interfacing with FPGA.
- Verified the design using a simulation testbench.
- Tested the Digital Dice Game on an FPGA board.
