# Integration

Instantiate `sentinel_rv_top` and connect System Subsystem to ports prefixed `core_`.
Commands, ADC samples, and keypad data flow toward System Subsystem; telemetry, display
state, audit digests, and authenticated actuator intent flow from System Subsystem.

`sentinel_rv_top` does not instantiate a guessed `sentinel_rv_security` port
list. Once System Subsystem publishes its exact contract, add a named-port instance in
this wrapper and connect it directly to the existing `core_*` boundary.
