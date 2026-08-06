# Actuator Subsystem: `relay_driver.v`

This directory contains the actuator driver module responsible for controlling external relay-based outputs in the Sentinel-RV system.

---

## Module Explanation

### `relay_driver.v`

**What it is:**  
A relay driver module that controls electromechanical or solid-state relays from FPGA logic.

**Why it is used:**  
Provides a safe interface between the FPGA and external high-power devices by driving relay control signals.

**Uses & Capabilities in Sentinel-RV:**
- Activates safety relays during threat detection to isolate protected circuits or disconnect power.
- Allows manual relay control through software or keypad commands.
- Controls external actuators such as alarms, motors or power isolation circuits.
- Executes physical safety actions commanded by the security controller.

---
