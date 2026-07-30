# 16x2 LCD Display Subsystem: `lcd_controller.v` and `lcd_driver.v`

This directory contains the 8-bit parallel HD44780 LCD driver and role sync controller modules.

---

### 📌 Module Explanations:

#### 1. `lcd_controller.v`
* **What it is:** High-level character LCD text formatter and state machine.
* **Why it is used:** Manages LCD line 1 and line 2 character string buffers.
* **Uses and Capabilities:**
  * Displays user login role status (`ROLE: ADMIN`, `ROLE: RESEARCH` or `ROLE: INTERN`) received over UART from the Python app.

#### 2. `lcd_driver.v`
* **What it is:** HD44780 timing controller driving `lcd_rs`, `lcd_rw`, `lcd_en` and `lcd_d[7:0]`.
* **Why it is used:** Generates standard HD44780 initialization and byte write timing waveforms.
* **Uses and Capabilities:**
  * Configures 2-line display mode, 5x8 font matrix and cursor clear operations.
