# 32bit-digital-calculator-logisim
# Digital Calculator

A digital calculator designed and simulated in **Logisim-evolution**, built from fundamental digital logic components and sequential circuits.

The project implements arithmetic operations through dedicated hardware blocks rather than relying on software-based calculation.

## Features

* Basic arithmetic operations
* Decimal digit input
* Operand storage using registers
* Binary arithmetic processing
* Addition and subtraction
* Logical operations
* Result storage
* Decimal/BCD output for display
* Modular circuit design using separate subcircuits

## Requirements

* **Logisim-evolution 4.1.0** or a compatible version
* A computer capable of running Logisim-evolution

The `.circ` file contains the complete Logisim-evolution circuit and can be opened directly in Logisim-evolution.

## How to Run

1. Install Logisim-evolution.
2. Open `calculator_perfect.circ`.
3. Run the circuit in simulation mode.
4. Use the digit and operation buttons to enter an expression.
5. Press `=` to evaluate the expression.
6. Use the clear/reset control to reset the calculator.

## Design

The calculator is constructed from smaller digital blocks, including:

* Input and digit handling
* Operand registers
* Arithmetic units
* Logic gates
* Multiplexers
* Registers and sequential logic
* Result handling
* BCD/decimal display logic

The design was developed to understand how a calculator can be constructed at the hardware level from digital logic rather than implementing the calculation as conventional software.

## Known Limitation

The current version does not use a dedicated control unit/state machine for coordinating all operations. Because of the resulting timing/control behavior, the `=` button may need to be pressed **twice** for the final result to appear correctly.

This is a known limitation of the current implementation and is intended to be addressed in a future revision with a proper control unit.

## Future Improvements

* Implement a dedicated control unit/FSM
* Remove the need for a second `=` press
* Improve operation sequencing
* Add multiplication and division
* Develop a complete Verilog/RTL implementation
* Add a Verilog testbench and simulation results

## Tools

* Logisim-evolution
* Digital logic / sequential circuit design
* Verilog *(for the RTL version, if included)*

## License

This project is intended for educational and portfolio purposes.
