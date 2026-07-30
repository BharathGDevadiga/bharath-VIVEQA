# Sentinel-RV Peripheral & Hardware Subsystem

Synthesizable Verilog HDL design for the peripherals and security boundary surrounding the `sentinel_rv_security` core and 32-bit RISC-V CPU on the AT-STLN-ARTIX7-001 Artix-7 FPGA board. Designed, synthesized and simulated using the **AMD/Xilinx Vivado Design Suite (Version 2025.2)**.

---

## 🛡️ Security Boundary & Architecture

The Peripheral Subsystem (`peripheral_top.v`) manages all external hardware interfaces and enforces strict security boundaries:

* **Actuator Authorization:** The `peripheral_top.v` module does not allow unauthorized relay safety isolation triggers. It accepts `core_actuator_authorized` and command signals from the main RISC-V CPU and `security_controller.v`.
* **Telemetry Collection:** Passes sampled sensor data to the core processing unit:
  * `core_adc_sample` / `core_adc_sample_valid`: MCP3202 CH0/CH1 12-bit analog voltage samples.
  * `dht11_data`: One-wire environmental temperature & humidity readings.
  * `hc_sr04_echo` / `hc_sr04_trigger`: Ultrasonic distance proximity measurements.
  * `core_command_*`: Framed UART serial commands received from external trusted control centers.
  * `core_key_*`: Local 4x4 matrix keypad input events.
* **HMI & Output Interfacing:** `sentinel_rv_top.v` coordinates system telemetry, LCD character messages, 7-segment numeric multiplexing, piezo alarm sirens and relay safety switches.

---

## 📡 Serial Telemetry & Command Framing Protocol

* **UART Command Frame:** `0xA5` | `opcode` | `sequence` | `argument[15:8]` | `argument[7:0]` | `xor8`
* **UART Telemetry Frame:** `0xA6` | `sequence` | `event` | `sensor[11:8]` | `sensor[7:0]` | `status` | `xor8`

*Note: `xor8` is the byte-wise XOR checksum of all preceding frame bytes for transport integrity verification. The security core performs secondary cryptographic nonces and replay-checks on all incoming authorization packets.*

---

## 📌 Board Hardware & Design Constraints

* **Target Hardware:** AT-STLN-ARTIX7-001 Artix-7 FPGA (`xc7a35tftg256-1`).
* **Constraints File:** `sentinel_rv.xdc` enforces 3.3V LVCMOS (`LVCMOS33`) IO standards and pin assignments:
  * **MCP3202 ADC SPI:** Pins G11, G12, G14, H14.
  * **Micro-SD Card SPI:** Pins C11, B12, D8, B11.
  * **UART Serial Line:** PMOD TX/RX pins.
  * **Matrix Keypad:** 4x4 row/column pin assignments.
  * **User Outputs:** 8 status LEDs, 4-digit 7-segment display, 16x2 LCD, piezo buzzer and safety relay output.

---

## 🛠️ Vivado Synthesis, Implementation & Simulation

This design is configured for full compilation and simulation within **AMD/Xilinx Vivado**:

1. **Project File:** Open `Sentinel_RV_Capstone_Project/Codes/Verilog/Sentinel_RV-Project/Sentinel_RV-Project.xpr` in Xilinx Vivado.
2. **Synthesis & Implementation:** Run `synth_1` and `impl_1` in Vivado to synthesize RTL and generate bitstream output.
3. **Behavioral Simulation (Vivado Simulator / xsim):** Run unit testbenches in Vivado Simulator:
   ```bash
   # Example: Run UART top testbench in Vivado Simulator
   tb/tb_uart_top.v
   ```
4. **Automated Test Suite Execution:** Run all supplied testbenches on Windows PowerShell via:
   ```powershell
   .\tb\run_tests.ps1
   ```
5. **System Reset:** All modules incorporate synchronous active-high `reset` logic.
