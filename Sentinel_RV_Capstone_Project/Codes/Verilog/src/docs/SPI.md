# SPI

`adc/spi_master.v` is a mode-0, fixed-width master used by the MCP3202. The SD
stack has a separate byte-oriented mode-0 engine so it can hold card select
across CMD24 and a data block.

The manual conflicts about SPI/SD wiring. `Peripheral Subsystem.xdc` chooses G11/G12/G14/H14
for the ADC and C11/B12/D8/B11 for SD, which are the detailed peripheral-table
assignments. Verify these against the schematic before hardware testing.
