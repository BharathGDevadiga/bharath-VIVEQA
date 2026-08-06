# Sentinel-RV Peripheral & Hardware Subsystem

Synthesizable Verilog HDL design for the peripherals and security boundary surrounding the `sentinel_rv_security` core and 32-bit RISC-V CPU on the AT-STLN-ARTIX7-001 Artix-7 FPGA board. Designed and synthesized using the **AMD/Xilinx Vivado Design Suite**.

---

## 🛡️ Security Boundary & Architecture

The Peripheral Subsystem (`peripheral_top.v`) manages external hardware interfaces and enforces strict security boundaries:

* **Actuator Authorization:** Does not allow unauthorized relay safety isolation triggers. It strictly requires `core_actuator_authorized` signals from the security core.
* **Telemetry Collection:** Passes sampled sensor data to the core processing unit:
  * `core_adc_sample`: MCP3202 analog voltage samples.
  * `dht11_data`: One-wire environmental temperature & humidity readings.
  * `core_command_*`: Framed UART serial commands received from external trusted control centers.
* **Output Interfacing:** Coordinates system telemetry, 8 status LEDs, a piezo alarm siren, and relay safety switches.

---

## 📡 Serial Telemetry & Command Framing Protocol

* **UART Command Frame:** `0xA5` | `opcode` | `sequence` | `argument[15:8]` | `argument[7:0]` | `xor8`
* **UART Telemetry Frame:** `0xA6` | `sequence` | `event` | `sensor[11:8]` | `sensor[7:0]` | `status` | `xor8`

*Note: `xor8` is a byte-wise XOR checksum. The security core performs secondary cryptographic nonces and replay-checks on all incoming authorization packets.*

---

## 📌 Board Hardware & Design Constraints

* **Target Hardware:** AT-STLN-ARTIX7-001 Artix-7 FPGA (`xc7a35tftg256-1`).
* **Constraints File:** `sentinel_rv.xdc` enforces 3.3V LVCMOS (`LVCMOS33`) IO standards:
  * **MCP3202 ADC SPI:** Pins G11, G12, G14, H14.
  * **Micro-SD Card SPI:** Pins C11, B12, D8, B11.
  * **UART Serial Line:** PMOD TX/RX pins.
  * **User Outputs:** 8 status LEDs, piezo buzzer, and safety relay.

---

## 🛠️ Vivado Synthesis & Implementation

This design is configured for full compilation within **AMD/Xilinx Vivado**:

1. **Project File:** Open `Sentinel_RV_Capstone_Project/Codes/Verilog/Sentinel_RV-Project/Sentinel_RV-Project.xpr` in Vivado.
2. **Synthesis & Implementation:** Run `synth_1` and `impl_1` to synthesize RTL and generate the bitstream output.
3. **System Reset:** All modules incorporate synchronous active-high `reset` logic.
