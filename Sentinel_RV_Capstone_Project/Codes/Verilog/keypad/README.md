# 4x4 Matrix Keypad Subsystem: `keypad_scan.v` and `keypad_decoder.v`

This directory contains the matrix scanning and decoding logic for the 16-button 4x4 keypad.

---

### 📌 Module Explanations:

#### 1. `keypad_scan.v`
* **What it is:** Active-low matrix scanner module for 4 rows (`keypad_row_n`) and 4 columns (`keypad_col_n`).
* **Why it is used:** Detects physical key presses across 16 switches with internal input pull-ups.
* **Uses and Capabilities:**
  * Debounces key contacts and generates single-cycle key-pressed pulse flags.

#### 2. `keypad_decoder.v`
* **What it is:** Keycode-to-ASCII and action decoder block.
* **Why it is used:** Translates row/column matrix coordinates into hex values (`0` to `F`) and triggers hardware actions.
* **Uses and Capabilities:**
  * Maps Key 1 (Relay Toggle), Key 2 (Alarm Silence), Key 3 (Buzzer Test), Key 6 (Voltage Mode), Key B (Display Freeze) and Key D (Burglar Siren Test).
