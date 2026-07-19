# Day 21 - Parameterized FIFO with Edge Detector

## Introduction

This project demonstrates the implementation of a **Parameterized FIFO (First In First Out)** using Verilog HDL. Unlike the basic FIFO, this design uses Verilog parameters to make the FIFO configurable for different data widths and memory depths. A separate Edge Detector module generates single-clock pulses from the push button inputs, ensuring that only one write or read operation occurs for each button press.

This project introduces parameterized hardware design modular design edge detection synchronous FIFO operation and FPGA implementation using Verilog HDL.

---

## Parameterized FIFO

A Parameterized FIFO allows the memory size and data width to be modified using Verilog parameters without changing the internal logic.

```verilog
parameter WIDTH = 8;
parameter DEPTH = 16;
parameter PTR_WIDTH = 4;
```

The FIFO performs synchronous write and read operations.

```verilog
always @(posedge clk) begin
    if (wr_en && !full) begin
        mem[wr_ptr[PTR_WIDTH-1:0]] <= write_data;
        wr_ptr <= wr_ptr + 1;
    end
end

always @(posedge clk) begin
    if (rd_en && !empty) begin
        read_data <= mem[rd_ptr[PTR_WIDTH-1:0]];
        rd_ptr <= rd_ptr + 1;
    end
end
```

Triggered on the positive edge of the clock.

Writes data when `wr_en` is HIGH and the FIFO is not full.

Reads data when `rd_en` is HIGH and the FIFO is not empty.

Read and write operations are synchronized with the clock.

---

## Edge Detector

Mechanical push buttons remain HIGH for several clock cycles when pressed.

The Edge Detector converts each button press into a single clock pulse.

```verilog
always @(posedge clk)
begin
    if(rst)
        delay <= 0;
    else
        delay <= signal_in;
end

assign pulse = signal_in & ~delay;
```

This ensures that only one FIFO operation is performed for each button press.

---

## Input and Output Ports

```verilog
input clk;
input rst;
input wr_en;
input rd_en;
input [7:0] sw;

output [7:0] led;
```

- **clk** – System clock
- **rst** – Active HIGH reset
- **wr_en** – Write button
- **rd_en** – Read button
- **sw** – 8-bit input from slide switches
- **led** – 8-bit output to LEDs

---

## Parameterized Memory Structure

```verilog
reg [WIDTH-1:0] mem [0:DEPTH-1];
```

The default configuration is:

- Data Width = 8 bits
- Memory Depth = 16 locations
- Pointer Width = 4 bits

These values can be changed simply by modifying the parameters.

---

## FIFO Status Flags

### Empty Detection

```verilog
assign empty = (wr_ptr == rd_ptr);
```

### Full Detection

```verilog
assign full =
    (wr_ptr[PTR_WIDTH] != rd_ptr[PTR_WIDTH]) &&
    (wr_ptr[PTR_WIDTH-1:0] == rd_ptr[PTR_WIDTH-1:0]);
```

The FIFO automatically detects Full and Empty conditions using the read and write pointers.

---

## Top Module

The top module integrates:

- Edge Detector
- Parameterized FIFO

The Edge Detector generates single-cycle pulses which are used by the FIFO for reliable push-button operation on the FPGA.

---

## Working Principle

Initially both pointers are reset.

When the Write button is pressed the Edge Detector generates a single pulse.

If the FIFO is not full the input data from the switches is written into memory.

When the Read button is pressed another pulse is generated.

If the FIFO is not empty the stored data is displayed on the LEDs.

---

## Sequential Logic

The FIFO is a sequential circuit.

The operation depends on:

- Clock
- Reset
- Write Enable
- Read Enable
- Write Data
- Read Data
- Read Pointer
- Write Pointer

---

## FPGA Mapping

Typical FPGA connections:

- **CLK** → 24 MHz Clock
- **Slide Switches** → Input Data
- **Push Button** → Write Enable
- **Push Button** → Read Enable
- **Push Button** → Reset
- **LEDs** → Output Data

The Edge Detector converts each push button press into a single clock pulse before sending it to the FIFO.

---

## Simulation

The testbench verifies:

- Reset operation
- Edge Detector functionality
- Multiple write operations
- Multiple read operations
- FIFO data storage
- FIFO data retrieval
- Parameterized FIFO functionality

The simulation confirms that the FIFO performs one write or read operation for each button press.

---

## Applications

- UART Buffers
- Processor Interfaces
- Embedded Systems
- Communication Systems
- Data Buffering
- FPGA Learning Projects

---

## Key Takeaways

- Learned parameterized hardware design using Verilog parameters.
- Implemented a reusable FIFO module.
- Designed a separate Edge Detector module.
- Integrated multiple modules using a top-level design.
- Verified the design using a simulation testbench.
- Tested the design on an FPGA using switches push buttons and LEDs.
