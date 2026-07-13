# Day 16 - Sequence Detector (Mealy Machine)

This folder contains the Verilog HDL programs for implementing a **Sequence Detector (Mealy Machine)** using **D Flip-Flops**.

## Files

- Sequence_Detector.v
- seq_det_tb.v
- Sequence_Detector.xdc

## Description

**Sequence_Detector.v** contains both the **D Flip-Flop** module and the **Mealy Sequence Detector** module. The D Flip-Flop acts as the memory element for storing the current state, while the sequence detector uses two D Flip-Flops and combinational logic to detect the binary sequence **111**. The output becomes HIGH whenever the required sequence is detected.

**seq_det_tb.v** contains the testbench used to simulate and verify the operation of the sequence detector. The simulation applies reset and multiple serial input patterns to verify that the detector correctly identifies the sequence **111**.

**Sequence_Detector.xdc** contains the Xilinx Design Constraints (XDC) file that maps the **24 MHz system clock**, **reset button**, **serial input switch**, and **output LED** to the FPGA pins. It also specifies the **LVCMOS33** I/O standard required for FPGA implementation.
