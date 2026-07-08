# Day 08 - Verilog Codes

This folder contains the Verilog HDL programs for implementing an Edge Detector using a D Flip-Flop.

## Files

- edge_detector.v
- tb_edge_detector.v

## Description

**edge_detector.v** contains the Verilog module for detecting positive, negative, and both edges of an input signal. The previous state of the input signal is stored using a D Flip-Flop, and combinational logic compares the current and previous states to generate the required edge detection signals.

**tb_edge_detector.v** contains the testbench used to simulate and verify the functionality of the Edge Detector by generating the clock, applying reset, changing the input signal, and observing the positive edge, negative edge, and both-edge detection outputs.
