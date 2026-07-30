# LCD and Keypad

The LCD driver writes the 16x2 display in 8-bit, write-only HD44780-compatible
mode. `lcd_controller` initializes it and updates two fixed 16-character lines
when `core_lcd_refresh` pulses.

`keypad_scan` expects active-low matrix rows and columns. The project manual's
keypad pin table is ambiguous; wire and constrain it only after confirming the
schematic's eight row/column nets.
