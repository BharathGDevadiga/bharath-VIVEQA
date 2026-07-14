# Day 17 - Vending Machine (Finite State Machine)

## Introduction
This project demonstrates the implementation of a **Vending Machine Controller** using a **Moore Finite State Machine (FSM)** in Verilog HDL. The vending machine accepts two types of coins (`₹5` and `₹10`) keeps track of the total amount inserted using different states dispenses a product when the required amount is reached and returns change whenever extra money is inserted.

This project introduces the concepts of **Finite State Machines (FSMs)** **state transitions** **sequential logic** and **digital controller design** using Verilog HDL.

---

## Finite State Machine (FSM)

A **Finite State Machine (FSM)** is a sequential circuit whose output depends on its current state and inputs.

In a **Moore FSM** the outputs depend only on the current state.

```verilog
always @(posedge clk) begin
    if (rst)
        state <= S0;
    else
        state <= next_state;
end
```

- Triggered on the positive edge of the clock.
- Reset initializes the machine to the idle state (`S0`).
- The next state depends on the current state and the inserted coin.
- Outputs are generated according to the current state.

---

## Input and Output Ports

```verilog
input clk;
input rst;
input [1:0] coin;

output D;
output C;
```

- **clk** – System clock
- **rst** – Resets the vending machine to the initial state
- **coin[1:0]** – Coin input
  - `2'b00` → No coin
  - `2'b01` → ₹5 coin
  - `2'b10` → ₹10 coin
- **D** – Dispense signal
- **C** – Change return signal

---

## State Diagram

The vending machine uses five states.

| State | Amount Collected |
|--------|------------------|
| S0 | ₹0 |
| S1 | ₹5 |
| S2 | ₹10 |
| S3 | ₹15 (Dispense Product) |
| S4 | ₹20 (Dispense Product + Return Change) |

After dispensing the product the machine automatically returns to **S0**.

---

## Working Principle

Initially the machine remains in **S0** waiting for a coin.

- Inserting a **₹5** coin moves the machine to the next state.
- Inserting a **₹10** coin advances the machine by two levels.
- Once the accumulated amount reaches **₹15** the machine dispenses the product.
- If **₹20** is accumulated the machine dispenses the product and also returns change.
- After completing the transaction the machine resets to the initial state for the next customer.

---

## State Transitions

| Current State | Coin Inserted | Next State |
|--------------|---------------|------------|
| S0 | ₹5 | S1 |
| S0 | ₹10 | S2 |
| S1 | ₹5 | S2 |
| S1 | ₹10 | S3 |
| S2 | ₹5 | S3 |
| S2 | ₹10 | S4 |
| S3 | Any | S0 |
| S4 | Any | S0 |

---

## Output Conditions

| State | Dispense (D) | Change (C) |
|--------|--------------|------------|
| S0 | 0 | 0 |
| S1 | 0 | 0 |
| S2 | 0 | 0 |
| S3 | 1 | 0 |
| S4 | 1 | 1 |

---

## Sequential Logic

The vending machine is a **sequential circuit**.

The current state is stored in flip-flops and updated on every clock edge.

The next state depends on:
- Current state
- Coin inserted

The outputs depend only on the present state making it a **Moore FSM**.

---

## FPGA Mapping

Typical FPGA connections:

- **CLK** → 24 MHz Clock
- **BTN0** → Reset
- **SW0–SW1** → Coin Input
- **LED0** → Dispense Output (D)
- **LED1** → Change Output (C)

---

## Simulation

The testbench verifies:

- Reset operation
- State transitions for ₹5 and ₹10 coin inputs
- Product dispensing at the correct amount
- Change generation for excess payment
- Automatic return to the initial state after each transaction

The simulation confirms that the vending machine controller behaves correctly for different coin combinations.

---

## Applications

- Automatic Vending Machines
- Ticket Dispensing Systems
- Parking Payment Machines
- Beverage Dispensers
- Digital Payment Controllers
- Embedded Control Systems
- FPGA Learning Projects

---

## Key Takeaways

- Learned the concept of **Finite State Machines (FSMs)**.
- Understood the working of a **Moore FSM**.
- Implemented a vending machine controller using Verilog HDL.
- Performed state transitions based on different coin inputs.
- Generated dispense and change outputs using FSM states.
- Verified the design using a simulation testbench.
- Interfaced clock reset switches and LEDs for FPGA implementation.
