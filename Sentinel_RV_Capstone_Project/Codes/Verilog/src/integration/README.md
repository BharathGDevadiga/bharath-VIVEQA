# System Integration & Peripheral Aggregator

This directory contains the central peripheral integration modules connecting sensors, bridges, and peripherals to the top-level architecture.

---

### 📌 Module Explanations:

#### 1. peripheral_top.v
* **What it is:** Top-level peripheral aggregator module.
* **Why it is used:** Instantiates and interconnects all peripheral sub-controllers (sensors, keypad, displays, relays, UART, ADC) into a unified subsystem.

#### 2. peripheral_controller.v
* **What it is:** Memory-Mapped I/O (MMIO) peripheral decoder and dispatcher.
* **Why it is used:** Routes CPU read/write bus requests to the appropriate peripheral module registers based on memory address decoding.

#### 3. dht11_controller.v
* **What it is:** One-wire protocol reader for the DHT11 Temperature & Humidity sensor.
* **Why it is used:** Reads ambient temperature and humidity data for environmental safety monitoring.

#### 4. hc_sr04_controller.v
* **What it is:** Timing controller for the HC-SR04 Ultrasonic Distance sensor.
* **Why it is used:** Measures object distance in centimeters for intrusion detection and proximity monitoring.

#### 5. security_command_bridge.v & security_telemetry.v
* **What they are:** Security bridges between peripheral telemetry streams and the core security controller.
