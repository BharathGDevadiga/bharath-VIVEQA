# ADC

`mcp3202_sampler` periodically requests CH0 or CH1 from the MCP3202 and emits
a 12-bit `sample_value` pulse. CH0 is intended for LM35/external voltage;
CH1 is the on-board potentiometer. The security core chooses the channel and
may force an immediate sample.

The assumed MCP3202 command is single-ended, MSB-first. Confirm its bit timing
with a scope or logic analyzer during bring-up.
