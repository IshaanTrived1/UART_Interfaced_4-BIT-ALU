# UART-Interfaced 4-Bit ALU on FPGA

A UART-controlled 4-bit arithmetic logic unit (ALU) implemented in Verilog/SystemVerilog on the **Sipeed Tang Nano 20K FPGA (Gowin GW2AR-18)**.

The design accepts commands from a PC over a serial connection, executes an arithmetic or bit-shift operation in hardware, and transmits the 8-bit result back over UART. Since the board has no convenient switches or display for entering operands and inspecting results, UART provides the interface for both control and output.

## Features

- 4-bit operands with an 8-bit result
- Five operations: addition, subtraction, multiplication, left shift, and right shift
- UART communication at 9600 baud using 8N1 framing
- RX input synchronization using a two-flop synchronizer
- Modular command parsing and result transmission
- Self-checking ALU testbench with constrained-random stimulus, corner-case weighting, and functional coverage
- Separate UART RX and TX testbenches

## Example Session

**Serial settings:** 9600 baud, 8 data bits, no parity, 1 stop bit (8N1).

Send a three-byte command containing the opcode and operands. The FPGA computes the result and returns one result byte.

## Architecture

| Module | Responsibility |
|---|---|
| Baud rate generator | Generates timing ticks for UART reception and transmission |
| RX synchronizer | Synchronizes the asynchronous UART RX input to the FPGA clock domain |
| UART RX | Samples incoming serial frames and reconstructs received bytes |
| Command parser | Collects command bytes, extracts operands and opcode, and signals when a command is ready |
| ALU core | Performs the selected operation and produces an 8-bit result |
| UART TX | Serializes the result into a UART frame for transmission to the PC |

### Command Protocol

Each command consists of three bytes. The intended encoding is shown below; confirm that the parser uses this exact byte order before relying on it.

| Byte | Contents | Relevant bits |
|---|---|---|
| Byte 0 | Operation opcode | `[2:0]` |
| Byte 1 | Operand A | `[3:0]` |
| Byte 2 | Operand B | `[3:0]` |

Unused bits are ignored if the parser only extracts the fields shown above.

**Response:** One byte containing the 8-bit ALU result, transmitted over UART.

### Supported Operations

| Opcode | Operation | Description |
|---|---|---|
| `3'b001` | Addition | `A + B` |
| `3'b010` | Subtraction | `A - B`, represented modulo 256 |
| `3'b011` | Multiplication | `A * B` |
| `3'b100` | Shift left | `A << B` |
| `3'b101` | Shift right | `A >> B` |

Both operands are unsigned 4-bit values, so each ranges from 0 to 15. The result is 8 bits wide to accommodate multiplication and subtraction underflow.

**Subtraction note:** The output is an 8-bit modular result. For example, `3 - 5` produces `254` (`8'hFE`) if the subtraction is performed with the intended 8-bit result width.

**Shift note:** The shift amount is the 4-bit operand B. The result is retained in the 8-bit output.

## Hardware

- **FPGA board:** Sipeed Tang Nano 20K
- **FPGA device:** Gowin GW2AR-18
- **System clock:** 27 MHz
- **UART baud rate:** 9600 baud
- **UART framing:** 8N1
- **IDE:** GowinIDE 1.9.12.03

### Pin Assignments

Pin assignments are defined in the Gowin constraint file (`.cst`).

| Signal | FPGA pin |
|---|---:|
| `clk` | 4 |
| `reset` | 88 |
| `uart_rx` | 68 |
| `uart_tx` | 70 |

### Baud Timing

The design uses a 27 MHz system clock to generate UART timing.

| Parameter | Value |
|---|---:|
| System clock | 27,000,000 Hz |
| Baud rate | 9,600 baud |
| TX clock divisor, rounded | 2812 |
| RX oversampling factor | 16 |
| RX oversampling divisor, rounded | 175 |

The divisors above assume the implementation uses the rounded integer-divider formula and subtracts one from the calculated count. Confirm the exact values against the RTL parameters.

## Build, Program, and Run

The FPGA design is developed using **GowinIDE 1.9.12.03**, with a Python script used to send commands to the ALU and read back results over UART.

1. Open the project in GowinIDE.
2. Confirm the target device is GW2AR-18 and the correct `.cst` constraint file is included.
3. Run synthesis and place-and-route.
4. Generate the programming bitstream.
5. Connect the Tang Nano 20K and program the FPGA.
6. Connect the board's UART interface to the PC.
7. Run the Python communication script to send ALU commands and receive results.

The UART connection uses **9600 baud, 8N1**. The Python script provides the interface for testing the ALU without manually entering raw serial bytes in a terminal.

The terminal can be used to send command bytes and inspect the returned result. If the terminal only supports text entry, use a serial tool that can transmit raw hexadecimal bytes.

## Simulation and Verification

Each major module has a dedicated testbench in `testing/`.

| Testbench | Verification goals |
|---|---|
| ALU | Self-checking comparisons against a reference model, constrained-random testing, weighted corner cases, and functional coverage |
| UART TX | Verify frame serialization, start and stop bits, transmitted data, and baud timing |
| UART RX | Verify incoming frame reception, reconstructed bytes, and data-valid signaling |

### ALU Verification

The ALU testbench uses a reference model to check the hardware output against the expected result. Constrained-random stimulus explores combinations of operations and operands, while corner-case weighting increases the frequency of important cases.

Functional coverage tracks operation and operand combinations, including subtraction cases where `B > A`.

**Results**

- Tests passed: `500`
- Tests failed: `0`
- Functional coverage: `100%`

### Running the Tests

Simulation tools used during development:

- Verilator 5.050
- GTKWave
- Cadence Xcelium 25.03

Use GTKWave to inspect the generated waveform dump when debugging timing or protocol failures, if waveform output is enabled for that test.
