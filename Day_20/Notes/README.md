# Day 20 - FIFO (First In First Out)

## Introduction

This project demonstrates the implementation of a **FIFO (First In First Out)** memory using Verilog HDL. The FIFO stores 8-bit data in 16 memory locations and transfers data in the same order in which it is written. It supports separate **write** and **read** operations using independent enable signals while maintaining **Full** and **Empty** status flags.

This project introduces the basics of FIFO memory architecture pointer-based memory management synchronous read/write operations FPGA implementation and on-chip debugging using the Integrated Logic Analyzer (ILA).

---

## FIFO (First In First Out)

A FIFO is a memory structure where the **first data written into the memory is the first data read out**.

```verilog
always @(posedge clk) begin
    if (wr_en && !full) begin
        mem[wr_ptr[3:0]] <= write_data;
        wr_ptr <= wr_ptr + 1;
    end
end

always @(posedge clk) begin
    if (rd_en && !empty) begin
        read_data <= mem[rd_ptr[3:0]];
        rd_ptr <= rd_ptr + 1;
    end
end
```

Triggered on the positive edge of the clock.

Writes data when `wr_en` is HIGH and the FIFO is not full.

Reads data when `rd_en` is HIGH and the FIFO is not empty.

Read and write operations are synchronized with the clock.

---

## Input and Output Ports

```verilog
input clk;
input rst;
input wr_en;
input rd_en;
input [7:0] write_data;

output reg [7:0] read_data;
```

- **clk** – System clock
- **rst** – Active HIGH reset
- **wr_en** – Write enable signal
- **rd_en** – Read enable signal
- **write_data** – 8-bit data input
- **read_data** – 8-bit data output

---

## Memory Structure

```verilog
reg [7:0] mem [0:15];
```

The FIFO contains:

- 16 memory locations
- Each location stores 8-bit data

---

## Pointer Structure

```verilog
reg [4:0] wr_ptr;
reg [4:0] rd_ptr;
```

The FIFO uses two pointers:

- **Write Pointer (wr_ptr)** – Points to the next location for writing.
- **Read Pointer (rd_ptr)** – Points to the next location for reading.

The extra MSB is used to distinguish between **Full** and **Empty** conditions.

---

## FIFO Status Flags

### Empty Detection

```verilog
assign empty = (wr_ptr == rd_ptr);
```

The FIFO is empty when both pointers are equal.

### Full Detection

```verilog
assign full = (wr_ptr[4] != rd_ptr[4]) &&
              (wr_ptr[3:0] == rd_ptr[3:0]);
```

The FIFO becomes full when:

- Lower 4 bits of both pointers are equal.
- MSBs are different.

---

## Edge Detection

To ensure that each push button press performs only one FIFO operation the design includes rising-edge detection for both the write enable and read enable signals.

```verilog
assign pos_det_wr_en = (~wr_en_d) & wr_en;
assign pos_det_rd_en = (~rd_en_d) & rd_en;
```

This prevents multiple write or read operations from occurring while a push button remains pressed.

---

## Working Principle

Initially the FIFO waits for a clock edge.

If `wr_en = 1` and the FIFO is not full data is written into the memory and the write pointer increments.

If `rd_en = 1` and the FIFO is not empty data is read from the memory and the read pointer increments.

The FIFO always maintains the First In First Out principle.

---

## Read and Write Operations

| Enable Signal | Operation |
| :-----------: | :-------: |
| `wr_en = 1` | Write Data |
| `rd_en = 1` | Read Data |

The FIFO prevents writing when it is full and reading when it is empty.

---

## Sequential Logic

The FIFO is a sequential circuit.

The memory updates only on the positive edge of the clock.

The operation depends on:

- Clock
- Reset
- Write Enable
- Read Enable
- Write Data
- Write Pointer
- Read Pointer

---

## FPGA Mapping

Typical FPGA connections:

- **CLK** → 24 MHz Clock
- **Slide Switches** → Write Data
- **Push Button** → Write Enable
- **Push Button** → Read Enable
- **Push Button** → Reset
- **LEDs** → Read Data
- **ILA** → Full and Empty status signals

The slide switches provide the input data while the LEDs display the data read from the FIFO. An Integrated Logic Analyzer (ILA) core is instantiated in the design to monitor the **Full** and **Empty** status signals in real time allowing the internal FIFO status to be observed directly on the FPGA during hardware debugging.

---

## Simulation

The testbench verifies:

- FIFO reset operation
- Multiple write operations
- Multiple read operations
- FIFO data storage
- FIFO data retrieval
- Full flag generation
- Empty flag generation
- Correct pointer operation

The simulation confirms that the FIFO correctly stores and retrieves data while maintaining FIFO behavior. The design is further verified on the FPGA by monitoring the Full and Empty status signals using the Integrated Logic Analyzer (ILA).

---

## Applications

- Data Buffering
- UART Communication
- Embedded Systems
- Processor Interfaces
- Network Packet Buffers
- FPGA Learning Projects

---

## Key Takeaways

- Learned the basics of FIFO (First In First Out).
- Understood pointer-based memory management.
- Implemented a 16 × 8 FIFO using Verilog HDL.
- Implemented Full and Empty status detection.
- Implemented rising-edge detection for reliable push button operation.
- Performed synchronous read and write operations.
- Verified the design using a simulation testbench.
- Tested the design on an FPGA using switches LEDs and the Integrated Logic Analyzer (ILA).
