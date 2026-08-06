# Analog ADC Subsystem: `mcp3202_sampler.v` `spi_master.v`

This directory contains the SPI driver modules for interfacing with the external MCP3202 12-bit Analog-to-Digital Converter (ADC).

---

## Module Explanations

### `mcp3202_sampler.v`

**What it is:**  
A Finite State Machine (FSM) based sampler for the MCP3202 dual-channel 12-bit SPI ADC.

**Why it is used:**  
Continuously reads analog voltage signals and converts them into digital values.

**Uses & Capabilities in Sentinel-RV:**
- Samples external analog voltage rails and sensor inputs.
- Feeds digital voltage readings into the security monitoring pipeline to detect power supply tampering or brownout conditions.

---

### `spi_master.v`

**What it is:**  
A generic full-duplex SPI bus master controller.

**Why it is used:**  
Generates the SPI clock (`dc_sck`) MOSI MISO and Chip Select timing signals required for SPI communication.

**Uses & Capabilities in Sentinel-RV:**
- Handles low-level SPI communication with the MCP3202 ADC module.
- Supports configurable SPI clock division for different operating speeds.

---
