# User Interface Display & Alarm Subsystem

This directory contains visual indicators and audible alarm driver modules.

---

### 📌 Module Explanations:

#### 1. `sevenseg_driver.v`
* **What it is:** Time-multiplexed 4-digit 7-segment display driver.
* **Why it is used:** Displays numerical values such as sensor readouts, system status codes, and PIN entries.
* **Uses & Capabilities in Sentinel-RV:**
  * Continuously multiplexes digit anodes/cathodes to display live temperature, distance, voltage, or status codes.

#### 2. `led_controller.v`
* **What it is:** System state LED controller.
* **Why it is used:** Drives status LEDs to visually indicate system power, security arm/disarm status, and alarm conditions.

#### 3. `buzzer_controller.v`
* **What it is:** Pulse-Width Modulation (PWM) piezo buzzer driver.
* **Why it is used:** Generates audible alert tones and alarm sirens during security trip conditions or keypress feedback.
