# Relay

`relay_driver` latches an ON request only when `authorized` is high. Reset or
an explicit `relay_reset` de-energizes the coil. An unauthorized set request
sets a one-cycle `denied` indication and leaves the output unchanged.
