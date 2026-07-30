# Analog ADC Subsystem: `mcp3202_sampler.v` and `spi_master.v`

This directory contains the SPI driver modules for interfacing with the external MCP3202 12-bit Analog-to-Digital Converter.

---

### 📌 Module Explanations:

#### 1. `mcp3202_sampler.v`
* **What it is:** State machine sampler for the MCP3202 dual-channel 12-bit SPI ADC.
* **Why it is used:** Continuously reads analog voltage signals (such as power supply rails or analog sensor inputs) and converts them into 12-bit digital BCD values.
* **Uses and Capabilities:**
  * Generates digital voltage readouts (e.g. `U.1.65` volts) displayed on the 7-segment display when pressing keypad **Key 6**.
  * Transmits digital voltage samples into the security monitoring pipeline to detect power rail tampering or brownout attacks.

#### 2. `spi_master.v`
* **What it is:** Generic full-duplex SPI bus master controller.
* **Why it is used:** Provides low-level SPI clock (`adc_sck`), MOSI (`adc_mosi`), MISO (`adc_miso`) and Chip Select (`adc_cs_n`) timing signals.
* **Uses and Capabilities:**
  * Supports configurable SPI clock division and mode 0/mode 3 transfer formats.
