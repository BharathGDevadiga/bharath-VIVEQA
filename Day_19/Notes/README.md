# Day 19 - Single Port RAM

## Introduction

This project demonstrates the implementation of a **Single Port RAM (Random Access Memory)** using Verilog HDL. The RAM stores **32-bit data** in **64 memory locations**. It uses a single port for both read and write operations. Data is written into memory when the write enable signal is HIGH and read from memory when the write enable signal is LOW.

This project introduces the basics of memory design synchronous read/write operations and FPGA implementation using Verilog HDL.

---

## Single Port RAM

A **Single Port RAM** uses one port for both reading and writing data.

```verilog
always @(posedge clk) begin
    if (wr_en)
        mem[addr] <= write_data;
    else
        read_data <= mem[addr];
end
```

- Triggered on the positive edge of the clock.
- Writes data when `wr_en` is HIGH.
- Reads data when `wr_en` is LOW.
- All operations are synchronized with the clock.

---

## Input and Output Ports

```verilog
input clk;
input wr_en;
input [31:0] addr;
input [31:0] write_data;

output reg [31:0] read_data;
```

- **clk** – System clock
- **wr_en** – Write enable signal
- **addr** – Memory address
- **write_data** – Data to be written
- **read_data** – Data read from memory

---

## Memory Structure

```verilog
reg [31:0] mem [0:63];
```

The RAM contains:

- 64 memory locations
- Each location stores 32-bit data

---

## Working Principle

Initially the RAM waits for a clock edge.

- If **wr_en = 1** data is written to the selected memory location.
- If **wr_en = 0** data is read from the selected memory location.
- Only one operation (read or write) is performed at a time.

---

## Read and Write Operations

| Write Enable | Operation |
|--------------|-----------|
| 1 | Write Data |
| 0 | Read Data |

---

## Sequential Logic

The RAM is a sequential circuit.

The memory updates only on the positive edge of the clock.

The operation depends on:

- Clock
- Write Enable
- Address
- Write Data

---

## FPGA Mapping

Typical FPGA connections:

- **CLK** → 24 MHz Clock
- **VIO** → Write Enable Address and Write Data
- **ILA** → Write Enable Address Write Data and Read Data

The VIO provides input values during hardware testing while the ILA monitors the RAM signals in real time.

---

## Simulation

The testbench verifies:

- Write operation
- Read operation
- Data storage
- Data retrieval
- Correct RAM functionality

The simulation confirms that the RAM correctly stores and reads data.

---

## Applications

- Processor Memory
- Embedded Systems
- Data Storage
- Buffer Memory
- FPGA Learning Projects

---

## Key Takeaways

- Learned the basics of Single Port RAM.
- Understood synchronous read and write operations.
- Implemented a 32-bit RAM with 64 memory locations using Verilog HDL.
- Controlled memory using the write enable signal.
- Verified the design using a simulation testbench.
- Tested the design on an FPGA using VIO and ILA.
