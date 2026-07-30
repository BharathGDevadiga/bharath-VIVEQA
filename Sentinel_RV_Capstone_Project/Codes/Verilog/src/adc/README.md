# Analog ADC Subsystem: mcp3202_sampler.v and spi_master.v

This directory contains the SPI driver modules for interfacing with the external MCP3202 12-bit Analog-to-Digital Converter.

---

### 📌 Module Explanations:

#### 1. mcp3202_sampler.v
* **What it is:** Finite State Machine (FSM) sampler for the MCP3202 dual-channel 12-bit SPI ADC.
* **Why it is used:** Continuously reads analog voltage signals and converts them into digital values.
* **Uses & Capabilities in Sentinel-RV:**
  * Samples external analog voltage rails and sensor inputs.
  * Feeds digital voltage readouts into the security monitoring pipeline to detect power-supply tampering or brownout conditions.

#### 2. spi_master.v
* **What it is:** Generic full-duplex SPI bus master controller.
* **Why it is used:** Generates low-level SPI clock (dc_sck), MOSI, MISO, and Chip Select timing signals.
* **Uses & Capabilities in Sentinel-RV:**
  * Handles low-level SPI communication for the MCP3202 ADC module with configurable clock division.
