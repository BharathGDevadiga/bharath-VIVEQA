# Character LCD Display Subsystem

This directory contains drivers for HD44780-compatible 16x2 character LCD modules.

---

### 📌 Module Explanations:

#### 1. `lcd_controller.v`
* **What it is:** High-level LCD display State Machine.
* **Why it is used:** Manages display initialization sequences, screen clearing and message formatting.

#### 2. `lcd_driver.v`
* **What it is:** Low-level HD44780 4-bit parallel bus interface driver.
* **Why it is used:** Generates exact RS, EN and Data timing signals to control the 16x2 character LCD screen.
