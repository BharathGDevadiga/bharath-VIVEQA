# Day 11 - Verilog Codes

This folder contains the Verilog HDL programs for interfacing the slide switches with the onboard LEDs of the Basys 3 FPGA board.

## Files

- `switch_to_led.v`
- `switch_to_led_tb.v`
- `switch_to_led.xdc`
  
## Description

- **`led_boardproj.v`** contains the Verilog module for an 8-bit LED interface. The design directly connects the eight slide switches (`switch[7:0]`) to the eight onboard LEDs (`led[7:0]`) using a continuous assignment statement. Whenever a switch is toggled, the corresponding LED immediately reflects its state, demonstrating a simple combinational logic circuit.

- **`led_boardproj_tb.v`** contains the testbench used to simulate and verify the functionality of the LED interface by applying different 8-bit switch patterns and observing that the LED outputs exactly match the applied switch inputs.

- **`led_boardproj.xdc`** contains the Xilinx Design Constraints (XDC) file that maps the slide switches to the input port (`switch[7:0]`) and the onboard LEDs to the output port (`led[7:0]`). It also specifies the **LVCMOS33** I/O standard required for FPGA implementation on the Basys 3 board.
