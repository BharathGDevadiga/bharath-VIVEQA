# RISC-V CPU Core and Memory Subsystem

This directory contains the PicoRV32 32-bit RISC-V CPU core, wrapper modules and internal Block RAM memory.

---

### 📌 Module Explanations:

#### 1. `picorv32.v` and `picorv32_wrapper.v`
* **What it is:** Open-source 32-bit RISC-V CPU core implementing the RV32I instruction set architecture.
* **Why it is used:** Serves as the central microprocessor running system firmware and protocol handling logic.
* **Uses and Capabilities:**
  * Executes embedded C/assembly firmware stored in on-chip BRAM.
  * Interfaces with memory-mapped peripherals over an internal bus.

#### 2. `simple_bram_memory.v`
* **What it is:** 4 KB internal Block RAM memory module ($2^{12} = 4096$ bytes).
* **Why it is used:** Provides fast 1-cycle instruction fetch and data read/write capabilities without wait states.
* **Uses and Capabilities:**
  * Holds compiled firmware hex code (`cpu_test_program.hex`) and stack memory.

#### 3. `cpu_mmio_bridge.v`
* **What it is:** Memory-Mapped I/O bridge controller.
* **Why it is used:** Translates CPU memory read/write requests into peripheral control signals.
* **Uses and Capabilities:**
  * Decodes memory addresses for accessing sensors, displays and security registers.
