# Day 07 - Verilog Codes

This folder contains the Verilog HDL programs for implementing D, T, and JK Flip-Flops using a common D Flip-Flop and a 3:1 Multiplexer.

## Files

- Top.v
- tb_Top.v

## Description

**Top.v** contains the Verilog module that implements three types of flip-flops—D, T, and JK—using a common D Flip-Flop. The D Flip-Flop directly stores the input, the T Flip-Flop is realized using the equation **D = T ⊕ Q**, and the JK Flip-Flop is implemented using the equation **D = JQ' + K'Q**. A 3:1 multiplexer selects the required flip-flop output based on the 2-bit select input (`m`).

**tb_Top.v** contains the testbench used to simulate and verify the functionality of the D, T, and JK Flip-Flops by generating the clock, applying reset, providing different input combinations, selecting the desired flip-flop mode, and observing the corresponding outputs.
