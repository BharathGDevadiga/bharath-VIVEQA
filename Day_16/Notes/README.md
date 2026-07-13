# Day 16 - Sequence Detector (Mealy Machine)

## Introduction
This project demonstrates the implementation of a **Sequence Detector (Mealy Machine)** using **Verilog HDL**. The design detects the binary sequence **111** in a serial input stream. When three consecutive logic HIGH (`1`) bits are received, the output becomes HIGH (`1`) for one clock cycle.

The detector is implemented using **D Flip-Flops** for state storage and combinational logic for next-state and output generation. Since it is a **Mealy Machine**, the output depends on both the present state and the current input, enabling faster detection and support for overlapping sequences.

---

## Project Files

### `Sequence_Detector.v`
Contains both the **D Flip-Flop** module and the **Mealy Sequence Detector** module.

- Implements a positive-edge triggered D Flip-Flop.
- Stores the FSM states using two D Flip-Flops.
- Uses combinational logic for next-state generation.
- Detects the binary sequence **111**.
- Produces a HIGH output whenever the required sequence is detected.

### `seq_det_tb.v`
Contains the simulation testbench.

- Generates a 10 ns clock.
- Applies reset.
- Provides multiple serial input patterns.
- Verifies correct sequence detection.
- Demonstrates overlapping sequence detection.
- Displays the simulation results using `$monitor`.

### `Sequence_Detector.xdc`
Contains the Xilinx Design Constraints (XDC) file.

Typical FPGA connections:

- **24 MHz Clock** → `clk`
- **Push Button** → `rst`
- **Switch** → `ip`
- **LED** → `op`

The constraint file also specifies the **LVCMOS33** I/O standard required for FPGA implementation.

---

## D Flip-Flop

A **D (Data) Flip-Flop** stores one bit of information and updates its output on the **positive edge of the clock**.

```verilog
always @(posedge clk)
begin
    if (rst)
        Q <= 1'b0;
    else
        Q <= D;
end
```

### Features

- Positive-edge triggered.
- Reset initializes the output to `0`.
- Stores one bit of state information.
- Used as the memory element of the FSM.

---

## Mealy Sequence Detector

A **Mealy Finite State Machine (FSM)** generates its output based on:

- Present State
- Current Input

Unlike a Moore machine, the output changes immediately when the required input is received at the active clock edge.

This design detects the sequence:

```
111
```

Whenever the third consecutive `1` arrives, the output becomes HIGH.

### Example

| Input | Output |
|------|------|
| 111 | 001 |
| 1111 | 0011 |
| 101110 | 000010 |

Since this is a **Mealy Machine**, overlapping sequences are detected automatically.

---

## Input and Output Ports

```verilog
input clk;
input rst;
input ip;
output reg op;
```

| Signal | Description |
|---------|-------------|
| `clk` | System clock |
| `rst` | Active HIGH reset |
| `ip` | Serial input |
| `op` | Sequence detected output |

---

## Internal Signals

```verilog
wire d0, d1;
wire q0, qb0;
wire q1, qb1;
```

- `d0`, `d1` → Next-state inputs.
- `q0`, `q1` → Current state outputs.
- `qb0`, `qb1` → Complement outputs.

---

## Next-State Logic

```verilog
assign d0 = ~ip;
assign d1 = q0 & ip;
```

The combinational logic determines the next state based on the current state and the incoming input.

---

## Output Logic

```verilog
always @(posedge clk)
begin
    if (rst)
        op <= 1'b0;
    else
        op <= ip & q1;
end
```

The output becomes HIGH only when:

- The FSM has already detected two consecutive `1`s.
- The current input is also `1`.

Thus, the detector recognizes the sequence **111**.

---

## Working Principle

The detector continuously monitors the incoming serial data.

```
Serial Input
      │
      ▼
Current State
      │
      ▼
Next-State Logic
      │
      ▼
D Flip-Flops
      │
      ▼
Updated State
      │
      ▼
Output Logic
      │
      ▼
Sequence Detected
```

### Operation

- First `1` → Moves to the first detection state.
- Second consecutive `1` → Moves to the second detection state.
- Third consecutive `1` → Output becomes HIGH.
- Additional consecutive `1`s continue to generate HIGH due to overlapping detection.
- A `0` resets the detection process.

---

## Simulation

The testbench verifies:

- Reset functionality.
- Correct state transitions.
- Detection of sequence **111**.
- Multiple sequence occurrences.
- Overlapping sequence detection.
- Proper output generation.

Clock generation:

```verilog
always #5 clk = ~clk;
```

Signal monitoring:

```verilog
$monitor("Time=%0t | rst=%b | ip=%b | op=%b",
         $time, rst, ip, op);
```

The simulation confirms that the detector correctly identifies every occurrence of the sequence **111**.

---

## FPGA Mapping

Typical Basys 3 connections:

- **CLK** → 24 MHz Clock
- **BTN0** → Reset
- **SW0** → Serial Input (`ip`)
- **LED0** → Sequence Detection Output (`op`)

---

## Applications

- Sequence Detection
- Pattern Recognition
- Digital Communication Systems
- Serial Data Processing
- Embedded Systems
- Error Detection
- FPGA-Based Digital Design
- Communication Protocol Controllers

---

## Key Takeaways

- Learned the working of a **D Flip-Flop**.
- Understood the concept of **Mealy Finite State Machines (FSMs)**.
- Implemented a **Sequence Detector** using Verilog HDL.
- Used **two D Flip-Flops** for state storage.
- Detected the binary sequence **111** in a serial input stream.
- Verified the design using a simulation testbench.
- Observed **overlapping sequence detection**, a key feature of Mealy machines.
- Successfully mapped the design to an FPGA using an **XDC constraint file**.
