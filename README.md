# ALU SystemVerilog Verification Project

This project is a SystemVerilog verification environment for a signed 5-bit ALU.

The ALU takes two signed 5-bit inputs `A` and `B`, and produces a signed 6-bit output `C`. The operation is selected using `ALU_en`, `a_en`, `b_en`, `a_op`, and `b_op`.

The testbench was written using SystemVerilog OOP concepts and includes generator, driver, monitor, scoreboard, interface, assertions, and functional coverage.

---

## Project Structure

```text
ALU_SV_PROJECT_Final/
│
├── design/
│   └── alu.sv
│
├── tb/
│   ├── alu_if.sv
│   ├── alu_pkg.sv
│   ├── alu_transaction.sv
│   ├── alu_generator.sv
│   ├── alu_driver.sv
│   ├── alu_monitor.sv
│   ├── alu_scoreboard.sv
│   ├── alu_environment.sv
│   └── tb_top.sv
│
├── run/
│   └── makefile
│
├── files.f
└── README.md
```

---

## DUT Description

The DUT is a sequential ALU.
The output `C` is updated on the positive edge of `clk`.

Main signals:

| Signal   | Description                   |
| -------- | ----------------------------- |
| `A`      | signed 5-bit input            |
| `B`      | signed 5-bit input            |
| `C`      | signed 6-bit output           |
| `clk`    | clock                         |
| `rst_n`  | asynchronous active-low reset |
| `ALU_en` | main ALU enable               |
| `a_en`   | enables `a_op` operation set  |
| `a_op`   | 3-bit operation selector      |
| `b_en`   | enables `b_op` operation set  |
| `b_op`   | 2-bit operation selector      |

---

## Verification Environment

The testbench contains:

| Component         | Role                                        |
| ----------------- | ------------------------------------------- |
| `alu_transaction` | stores one test item                        |
| `alu_generator`   | creates directed and random tests           |
| `alu_driver`      | drives inputs to the interface              |
| `alu_monitor`     | samples DUT inputs and output               |
| `alu_scoreboard`  | compares actual output with expected output |
| `alu_environment` | connects and runs all components            |
| `alu_if`          | contains signals, assertions, and coverage  |
| `tb_top`          | top-level testbench                         |

Basic flow:

```text
Generator -> Driver -> Interface -> DUT -> Monitor -> Scoreboard
```

---

## Tests

The testbench uses both directed and random tests.

Directed tests cover:

* A-only operations
* B-only operations
* both-enable operations
* reset behavior
* ALU disabled case
* no-operation case
* boundary values

Test count:

| Test Type      | Count |
| -------------- | ----: |
| Directed tests |    18 |
| Random tests   |   100 |
| Total          |   118 |

---

## Assertions

Assertions were added in the interface to check:

* reset behavior
* ALU disabled behavior
* illegal `a_op`
* illegal `b_op`
* output range

All assertions passed.

---

## Coverage Summary

Coverage was collected using Synopsys VCS and URG.

| Metric              | Result |
| ------------------- | -----: |
| Total score         | 91.75% |
| Line coverage       | 95.24% |
| Condition coverage  | 77.78% |
| Toggle coverage     |   100% |
| Branch coverage     | 85.71% |
| Functional coverage |   100% |

Functional coverage reached 100%.

The remaining code coverage gaps are mainly from illegal/default branches and failure paths that are not expected to run during legal testing.

---

## Simulation Result

The scoreboard result was:

```text
PASS  : 118
FAIL  : 0
TOTAL : 118
```

No functional failures were found.

---

## How to Run

Go to the run folder:

```bash
cd run
```

Run the full flow:

```bash
make
```

This will clean, compile, run the simulation, and generate the coverage report.

Other useful commands:

```bash
make clean
make compile
make run
make coverage
make textcov
```

---

## Tools

* SystemVerilog
* Synopsys VCS
* Synopsys URG
* QuestaSim

---

## Notes

The uncovered code coverage items are not considered functional bugs.
Most of them are related to illegal opcode default cases or testbench failure-handling paths.

The ALU passed all generated tests and reached 100% functional coverage.
