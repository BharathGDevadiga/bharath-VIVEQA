# Integration

Instantiate `sentinel_rv_top` and connect Team 1 to ports prefixed `core_`.
Commands, ADC samples, and keypad data flow toward Team 1; telemetry, display
state, audit digests, and authenticated actuator intent flow from Team 1.

`sentinel_rv_top` does not instantiate a guessed `sentinel_rv_security` port
list. Once Team 1 publishes its exact contract, add a named-port instance in
this wrapper and connect it directly to the existing `core_*` boundary.
