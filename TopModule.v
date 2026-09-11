module TopModule( //Connects everything together
    input reset, clk, rx_in,
    output wire tx
);

    wire busy, ALUready;
    wire[2:0] opcode;
    wire[3:0] A, B;
    wire[7:0] result;

    CommandParser topCommandParser(
        .reset(reset),
        .clk(clk),
        .rx_in(rx_in),
        .opcode(opcode),
        .A(A),
        .B(B),
        .ALUready(ALUready)
    );


    ALU TopALU(
        .A(A),
        .B(B),
        .Operation(opcode),
        .result(result)
    );

TX TopTX(
    .clk(clk),
    .reset(reset),
    .data_in(result),
    .start(ALUready),
    .tx(tx),
    .busy(busy)
);

endmodule
