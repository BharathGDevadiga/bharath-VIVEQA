# RISC-V PicoRV32 Processor Subsystem

This directory contains the 32-bit RISC-V soft processor core and associated memory components.

---

### 📌 Module Explanations:

#### 1. `picorv32.v`
* **What it is:** Open-source 32-bit RISC-V (RV32I) soft CPU core.
* **Why it is used:** Serves as the central processing brain for the Sentinel-RV system.
* **Uses & Capabilities in Sentinel-RV:**
  * Executes embedded firmware instructions to coordinate system tasks, evaluate security policies and communicate with peripherals.

#### 2. `simple_bram_memory.v`
* **What it is:** Dual-port Block RAM (BRAM) memory module pre-loaded with firmware (`cpu_test_program.hex`).
* **Why it is used:** Stores executable machine code and runtime data for the PicoRV32 CPU.

#### 3. `cpu_mmio_bridge.v`
* **What it is:** Memory-Mapped I/O (MMIO) bus interface.
* **Why it is used:** Allows the RISC-V CPU to read and write peripheral registers (sensors, displays, actuators) using memory address reads and writes.

#### 4. `picorv32_wrapper.v`
* **What it is:** Top-level structural wrapper combining the PicoRV32 CPU core and BRAM memory into a single component.
