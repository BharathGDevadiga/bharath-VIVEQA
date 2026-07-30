# Integration and Sensor Controllers

This directory contains sensor interface modules for environmental measurement and security telemetry bridges.

---

### 📌 Module Explanations:

#### 1. `dht11_controller.v`
* **What it is:** Single-wire protocol controller for the DHT11 temperature and humidity sensor.
* **Why it is used:** Reads digital relative humidity (e.g. `55%`) and ambient temperature (e.g. `28°C`).
* **Uses and Capabilities:**
  * Formats temperature and humidity data for display on 7-segment LED and LCD screens.

#### 2. `hc_sr04_controller.v`
* **What it is:** Ultrasonic distance sensor controller for the HC-SR04 module.
* **Why it is used:** Emits 10 µs trigger pulses and measures echo pulse duration to compute object distance in centimeters.
* **Uses and Capabilities:**
  * Provides proximity monitoring (`d. 34` cm) for intruder detection.

#### 3. `peripheral_controller.v`, `security_command_bridge.v` and `security_telemetry.v`
* **What it is:** Central MMIO peripheral multiplexer and security telemetry bridge modules.
* **Why it is used:** Aggregates sensor metrics and security state into formatted UART packets.
* **Uses and Capabilities:**
  * Streams real-time telemetry over USB/UART at 115200 baud to the desktop control app.
