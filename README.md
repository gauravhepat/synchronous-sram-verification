# Synchronous SRAM Design & Verification using SystemVerilog, Assertions, Coverage and Python Automation

## Project Overview

This project presents the **design and functional verification of a parameterized Synchronous SRAM** using **SystemVerilog** along with a **self-checking verification environment**.

The project focuses not only on RTL implementation but also on **verification-driven development**, including:

* FSM-based SRAM control
* SystemVerilog Assertions (SVA)
* Functional Coverage
* Randomized Stress Testing
* Python-based Regression Automation
* Multi-configuration Verification

The objective was to move beyond basic RTL coding and build a **verification-oriented memory design flow similar to industry practices**.

---

## Features

### Parameterized SRAM Design

The SRAM is fully parameterized for:

* **DATA_WIDTH**
* **ADDR_WIDTH**
* **Memory Depth**

This allows verification across multiple memory configurations without modifying RTL.

Verified configurations:

| DATA_WIDTH | ADDR_WIDTH | DEPTH |
| ---------- | ---------- | ----- |
| 8          | 4          | 16    |
| 16         | 5          | 32    |
| 32         | 6          | 64    |

Memory depth is derived as:

```systemverilog
DEPTH = 2^ADDR_WIDTH
```

---

## Design Architecture

The SRAM uses an **FSM-based control architecture** with four states:

* **IDLE**
* **WRITE**
* **READ**
* **HOLD**

### FSM Flow

```text
IDLE
 ├── WRITE
 ├── READ
 └── HOLD

WRITE → HOLD
READ  → HOLD
HOLD  → IDLE / WRITE / READ
```

The FSM controls:

* Write operations
* Read operations
* Output stability
* Legal state transitions

---

## Verification Methodology

The project follows a **self-checking verification approach**.

Verification includes:

### 1. Directed Testing

Basic functional scenarios were verified through directed tests.

Examples:

* Write → Read verification
* Multiple address transactions
* Output correctness checks

---

### 2. SystemVerilog Assertions (SVA)

Assertions were added to continuously monitor design behavior.

Implemented assertions:

### Assertion 1 — No Simultaneous Read & Write

Ensures:

```text
WE and RE are never high together
```

---

### Assertion 2 — HOLD State Stability

Checks:

```text
Output remains stable while FSM stays in HOLD state
```

---

### Assertion 3 — Read-After-Write (RAW) Correctness

Verifies:

```text
Read data matches previously written data
```

This assertion was refined during debugging to correctly support:

* Same-address checking
* Transaction-aware verification
* Correct read latency behavior

---

### Assertion 4 — FSM Transition Validation

Ensures legal transitions such as:

```text
WRITE → HOLD
READ → HOLD
```

---

## Functional Coverage

Functional coverage was implemented to ensure the FSM was properly exercised.

Coverage includes:

### State Coverage

* IDLE
* WRITE
* READ
* HOLD

### Transition Coverage

Examples:

* IDLE → WRITE
* IDLE → READ
* WRITE → HOLD
* READ → HOLD
* HOLD → IDLE
* HOLD → WRITE
* HOLD → READ

Coverage ensured the verification environment exercised both states and transitions.

---

## Randomized Stress Testing

To improve confidence beyond directed tests, randomized verification was implemented.

Random testing included:

* Random WE/RE generation
* Random addresses
* Random input data
* Multiple transaction sequences

Approximately:

```text
200+ randomized transactions
```

were executed per simulation run.

This helped expose:

* Corner cases
* Assertion weaknesses
* Protocol violations
* Timing/sequence issues

---

## Python-Based Regression Automation

A Python automation framework was developed to run simulations automatically in **Vivado Batch Mode**.

Python automation performs:

* Launch Vivado in batch mode
* Run TCL simulation scripts
* Capture simulator logs
* Parse assertion results
* Generate pass/fail dashboard
* Save logs and CSV reports

Regression verified:

* Multiple parameter configurations
* Assertion status
* Coverage execution
* Corner-case completion

---

## Tools & Technologies

### RTL / Verification

* Verilog
* SystemVerilog
* SystemVerilog Assertions (SVA)
* Functional Coverage

### Simulation

* Xilinx Vivado Simulator (XSim)

### Automation

* Python
* TCL scripting

---

## Project Verification Flow

```text
RTL Design
        ↓
Directed Testing
        ↓
Assertions
        ↓
Coverage
        ↓
Random Stress Testing
        ↓
Python Regression
        ↓
Verification Dashboard
```

---

## Key Learning Outcomes

This project provided practical exposure to:

* RTL design methodology
* FSM-based memory design
* SystemVerilog Assertions
* Functional coverage
* Debugging assertion failures
* Verification refinement
* Randomized testing
* Python-based EDA automation
* Regression-based verification

---

## Sample Regression Output

```text
Simulation        : PASSED
Assertions        : PASSED
Coverage          : PASSED
Corner Cases      : PASSED
Regression        : PASSED

OVERALL REGRESSION : PASSED
```

---

## Repository Structure

```text
├── rtl/
│   └── sync_sram.sv
│
├── tb/
│   └── tb_sync_sram.sv
│
├── tcl/
│   └── run_sim.tcl
│
├── scripts/
│   └── run_sim.py
│
├── logs/
│
└── README.md
```

---

## Future Improvements

Possible extensions:

* UVM-based verification
* Scoreboard implementation
* Memory initialization strategies
* Formal verification
* Coverage reporting enhancements

---

## Author

**Gaurav Laxman Hepat**
M.Tech VLSI | NIT Jaipur

Focused on RTL Design, Digital Design and Verification.
