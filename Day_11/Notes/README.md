# Day 11 - Switch to LED Interface

## Introduction

This project demonstrates a simple **Switch-to-LED Interface** using Verilog HDL on the Basys 3 FPGA board. The state of each slide switch is directly reflected on its corresponding LED using a continuous assignment statement.

It is one of the simplest examples of **combinational logic** and helps in understanding FPGA input/output interfacing.

---

## Continuous Assignment

A continuous assignment is used to assign a value to a wire continuously.

```verilog
assign led = switch;
```

- Executes continuously.
- Does not require a clock.
- Suitable for combinational circuits.
- The output changes immediately whenever the input changes.

---

## Input and Output Ports

```verilog
input  [7:0] switch;
output [7:0] led;
```

- `switch[7:0]` represents the eight slide switches.
- `led[7:0]` represents the eight onboard LEDs.

Each bit of the switch controls the corresponding LED.

---

## Working Principle

The design simply copies the input value to the output.

```
Switch = 11001010

↓

LED    = 11001010
```

Whenever a switch changes its position, the corresponding LED immediately updates.

---

## Why No Clock?

This design is purely combinational.

There are:

- No flip-flops
- No registers
- No memory elements
- No sequential logic

Therefore, a clock signal is not required.

---

## Combinational Logic

A combinational circuit produces outputs based only on the current inputs.

Mathematically,

```
LED = SWITCH
```

There is no dependency on previous input values.

---

## FPGA Mapping

Typical Basys 3 connections:

```
SW0 → LED0
SW1 → LED1
SW2 → LED2
SW3 → LED3
SW4 → LED4
SW5 → LED5
SW6 → LED6
SW7 → LED7
```

---

## Simulation

The testbench verifies the design by applying different switch patterns such as:

```
00000000
11111111
10101010
01010101
11001100
00110011
```

For every input pattern, the LED output exactly matches the switch input.

---

## Applications

- FPGA I/O verification
- Switch and LED interfacing
- Learning combinational logic
- Hardware testing
- Beginner FPGA projects

---

## Key Takeaways

- Learned how to declare input and output ports in Verilog.
- Understood the use of the `assign` statement.
- Implemented a simple combinational logic circuit.
- Verified the design using simulation.
- Interfaced slide switches with onboard LEDs on the Basys 3 FPGA board.
