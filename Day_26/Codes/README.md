# Day 26 - Verilog Codes

This folder contains the Verilog HDL programs for implementing a PWM (Pulse Width Modulation) Generator using Verilog HDL on the FPGA board.

## Files

- ``pwm_generator.v``
- ``pwm_generator_tb.v``
- ``pwm_generator.xdc``

## Description

``pwm_generator.v`` contains the Verilog module for generating a Pulse Width Modulation (PWM) signal using an 8-bit counter. The duty cycle is controlled by an 8-bit input value. The counter continuously increments on every clock cycle and compares its value with the selected duty cycle to generate the PWM output signal. By changing the duty cycle input the HIGH pulse width of the PWM signal changes while the output frequency remains constant.

``pwm_generator_tb.v`` contains the testbench used to simulate and verify the PWM generator. The simulation applies reset and tests different duty cycle values such as 25% 50% 75% and 100%. The waveform verifies that the PWM output changes according to the selected duty cycle while maintaining a constant frequency.

``pwm_generator.xdc`` contains the Xilinx Design Constraints (XDC) file that maps the system clock reset signal duty cycle input switches and PWM output to the appropriate FPGA pins. It also specifies the LVCMOS33 I/O standard required for FPGA implementation.
