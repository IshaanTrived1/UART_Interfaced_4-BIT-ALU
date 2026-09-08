# UART-Interfaced 4-Bit ALU on FPGA
 
A Verilog implementation of a 4-bit ALU controlled entirely over UART, built on the Sipeed Tang Nano 20K (Gowin GW2AR-18). Since the board has no physical switches or a 7-segment display, 
UART serves as the primary interface for both sending operands/opcodes to the ALU and reading back results. This can also be utilized in a variety of projects. Runs on 9600 baud.

## Status
This project's functionality is complete but extra comments will be incorporated for readability and replicability for users. 
 
| Module | Status |
|---|---|
| `BAUD RATE GEN` | ✅ done|
| UART `TX` | ✅ done|
| UART `RX` | ✅ done|
| ALU CORE | ✅ done|
| ALU TESTBENCH | ✅ done|
| RX TWO-FLOP SYNCRHONIZER |✅ done|
| TX TESTBENCH |✅ done|
| RX TESTBENCH |✅ done|
| COMMAND PARSER |✅ done|
| TOP-LEVEL INTEGRATION |✅ done|
| PIN CONSTRAINTS (`.cst`) |✅ done|
| END TO END TESTING |✅ done|
