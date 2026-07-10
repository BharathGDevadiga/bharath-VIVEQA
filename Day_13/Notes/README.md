# Day 13 - Parallel-In Serial-Out (PISO) Shift Register

## Introduction

This project demonstrates the implementation of a **4-bit Parallel-In Serial-Out (PISO) Shift Register** using Verilog HDL on the Basys 3 FPGA board. The parallel data is entered using four slide switches and loaded into the shift register using a **Load** button. A separate **Shift** button is used to serially transmit one bit at a time through the output LED.

This project introduces the concept of **parallel-to-serial data conversion**, which is widely used in digital communication systems and embedded applications.

---

## Shift Register

A shift register is a sequential logic circuit used to store and transfer binary data.

A **Parallel-In Serial-Out (PISO)** shift register:

- Accepts multiple bits simultaneously.
- Stores the data in an internal register.
- Outputs one bit at a time in serial form.
- Requires a clock signal for synchronization.

---

## Input and Output Ports

```verilog
input clk;
input rst;
input [3:0] data_in;
input load;
input shift;

output reg data_out;
```

- `clk` – System clock.
- `rst` – Resets the shift register.
- `data_in[3:0]` – 4-bit parallel input from the slide switches.
- `load` – Loads the parallel data into the register.
- `shift` – Generates a shift operation on its rising edge.
- `data_out` – Serial output displayed on an LED.

---

## Internal Registers

```verilog
reg [3:0] data_reg;
reg [1:0] cnt;
reg shift_d;
```

- `data_reg` stores the loaded parallel data.
- `cnt` keeps track of the bit currently being transmitted.
- `shift_d` stores the previous state of the shift button for edge detection.

---

## Working Principle

1. Enter a 4-bit value using the slide switches.
2. Press the **Load** button to store the value in the internal register.
3. Press the **Shift** button repeatedly.
4. On every rising edge of the shift signal, one bit is transmitted serially.
5. After four shift operations, all bits have been transmitted.

Example:

```
Parallel Input

1010

↓

Load

↓

Internal Register

1010

↓

Shift Operations

0 → 1 → 0 → 1
```

The current implementation shifts the data **LSB first**.

---

## Edge Detection

The shift operation occurs only when a rising edge of the **Shift** button is detected.

```verilog
assign pos_shift = ~shift_d & shift;
```

This prevents multiple shift operations while the button remains pressed.

---

## Truth Table (Operation Table)

| Reset (`rst`) | Load (`load`) | Shift Pulse (`shift`) | Operation | `data_out` |
|:-------------:|:-------------:|:---------------------:|-----------|:----------:|
| 1 | X | X | Reset the register | 0 |
| 0 | 1 | X | Load parallel data | Previous value |
| 0 | 0 | ↑ | Shift one bit serially | Next bit |
| 0 | 0 | 0 | Hold current state | Unchanged |

**Note:** `↑` represents the rising edge of the **Shift** signal.

---

## Example Operation

Assume the following parallel input is loaded:

```
data_in = 1010
```

After pressing the **Load** button, each **Shift** pulse produces:

| Shift Pulse | Counter | Serial Output (`data_out`) |
|:-----------:|:-------:|:--------------------------:|
| 1 | 0 | 0 |
| 2 | 1 | 1 |
| 3 | 2 | 0 |
| 4 | 3 | 1 |

Thus, the serial output sequence becomes:

```
0 → 1 → 0 → 1
```

---

## Why a Clock?

A PISO shift register is a **sequential circuit** because it stores data internally.

It contains:

- Internal storage register
- Counter
- Shift operation
- Sequential data transfer

Therefore, a clock signal is required to synchronize all operations.

---

## Sequential Logic

Unlike combinational logic, sequential logic depends on both:

- Current inputs
- Previously stored values

Since the register stores data before shifting it out, this design is a **sequential logic circuit**.

---

## FPGA Mapping

Typical Basys 3 connections:

- SW0 → Data Bit 0
- SW1 → Data Bit 1
- SW2 → Data Bit 2
- SW3 → Data Bit 3
- BTN1 → Reset
- BTN2 → Load
- BTN3 → Shift
- LED0 → Serial Output

---

## Simulation

The testbench verifies the following operations:

- Reset operation
- Loading a 4-bit parallel value
- Performing multiple shift operations
- Observing the serial output after each shift pulse

The simulation confirms that the data is correctly loaded into the register and shifted out one bit at a time.

---

## Applications

- Serial communication
- SPI interfaces
- UART communication
- Data transmission systems
- Embedded systems
- FPGA learning projects
- Digital communication circuits

---

## Advantages

- Simple hardware implementation
- Reduces the number of output lines required
- Efficient method for serial data transmission
- Easy to interface with communication protocols

---

## Key Takeaways

- Learned the working of a Parallel-In Serial-Out (PISO) shift register.
- Understood the difference between parallel and serial data transfer.
- Learned how to implement sequential logic using Verilog HDL.
- Used edge detection to perform one shift operation per button press.
- Verified the design through simulation and FPGA hardware implementation.
- Understood how data is converted from parallel form into serial form.
