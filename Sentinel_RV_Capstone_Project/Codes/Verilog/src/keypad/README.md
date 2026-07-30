# Matrix Keypad Input Subsystem

This directory contains drivers for 4x4 matrix keypad user input.

---

### 📌 Module Explanations:

#### 1. keypad_scan.v
* **What it is:** Matrix keypad row/column scanning FSM with debouncing.
* **Why it is used:** Detects physical key presses on a 4x4 keypad matrix and eliminates mechanical switch bounce.

#### 2. keypad_decoder.v
* **What it is:** Key press code decoder.
* **Why it is used:** Translates matrix row/column coordinates into hexadecimal key codes (0-F) for PIN validation and menu navigation.
