# Actuator Subsystem: `relay_driver.v`

This directory contains the actuator interface driver module for controlling physical electromechanical relays.

---

### 📌 Module Explanation: `relay_driver.v`

* **What it is:** A Form-C electromechanical relay controller module.
* **Why it is used:** Drives external high-voltage or high-current loads safely through an optocoupler/transistor relay interface circuit connected to FPGA pin `N16`.
* **Uses and Capabilities:**
  * Energizes or de-energizes the relay coil based on CPU software commands or keypad shortcut **Key 1**.
  * Provides hardware override support when slide switch **S5** (`sw_relay_force`) is switched UP.
  * Status feedback is mapped directly to **LED L5** (`led[4]`, Pin `E6`) for instant visual verification.
