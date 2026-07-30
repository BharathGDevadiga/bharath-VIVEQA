# Display and Visual Notification Subsystem

This directory contains drivers for the MAX7219 7-segment display, status LEDs and piezo alarm buzzer.

---

### 📌 Module Explanations:

#### 1. `sevenseg_driver.v`
* **What it is:** MAX7219 SPI driver for the 4-digit 7-segment display.
* **Why it is used:** Multiplexes 4 numeric digits to display temperature (`t. 28`), distance (`d. 34`), voltage (`U.1.65`) and humidity (`H. 55`).
* **Uses and Capabilities:**
  * Supports freeze mode via keypad **Key B** or slide switch **S3** (`sw_display_lock`).

#### 2. `buzzer_controller.v`
* **What it is:** Piezoelectric alarm sounder driver.
* **Why it is used:** Generates 2048 Hz audio tones and siren patterns upon security intrusion or alarm testing.
* **Uses and Capabilities:**
  * Plays intruder alert siren patterns when security glitches or burglar alarm tests (keypad **Key D**) are triggered.

#### 3. `led_controller.v`
* **What it is:** 8-bit LED status controller module.
* **Why it is used:** Manages 1-to-1 status LED illumination for LEDs **L1 to L8** placed directly above slide switches **S1 to S8**.
* **Uses and Capabilities:**
  * Provides visual feedback for power, alarm status, display lock and clock activity.
