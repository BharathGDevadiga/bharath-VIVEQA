# Day 12 - Verilog Codes

This folder contains the Verilog HDL programs for implementing a simple password lock system using slide switches, a confirmation button, and LEDs on the FPGA board.

## Files
- `pass_key.v`
- `pass_key_tb.v`
- `pass_key.xdc`

## Description

`pass_key.v` contains the Verilog module for a password-based access system. The eight slide switches (`sw[7:0]`) are used to enter an 8-bit password, while the `confirm` input acts as the verification button. If the entered password matches the predefined value (`10101010`), all eight LEDs turn ON, indicating successful authentication. If the password is incorrect, all LEDs remain OFF, indicating access is denied.

`pass_key_tb.v` contains the testbench used to simulate and verify the password lock system. The simulation checks different scenarios, including the confirm button not being pressed, entering the correct password, and entering incorrect passwords. The outputs are observed to ensure that the LEDs respond correctly for each test case.

`pass_key.xdc` contains the Xilinx Design Constraints (XDC) file that maps the slide switches to the input port (`sw[7:0]`), the push button to the `confirm` input, and the onboard LEDs to the output port (`leds[7:0]`). It also specifies the **LVCMOS33** I/O standard required for FPGA implementation.
