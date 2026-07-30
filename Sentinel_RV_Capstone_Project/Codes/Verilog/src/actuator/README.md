# Actuator Subsystem: 
relay_driver.v

This directory contains the physical actuator driver module responsible for executing output safety actions.

---

### 📌 Module Explanations:

#### 1. 
relay_driver.v
* **What it is:** Electromechanical & Solid-State Relay driver module.
* **Why it is used:** Controls physical relay switches to toggle external high-power loads or safety isolation circuits.
* **Uses & Capabilities in Sentinel-RV:**
  * Driven by the security controller during threat detection or emergency conditions to trip safety isolation power rails.
  * Allows user commands via keypad or software to manually toggle relays for load control.
