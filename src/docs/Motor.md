# Motors

`motor_driver` drives DRV8833 IN1/IN2 with a PWM speed command and rejects
motor enable while unauthorised. `stepper_driver` drives the L293DD in a
four-phase full-step sequence, de-energizes on completion, and likewise rejects
unapproved starts.

The Team 1 authorization signal must stay high for each security-approved
operation. The interface intentionally fails safe if it is low.
