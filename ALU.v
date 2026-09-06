module ALU(
    //4 bit inputs, 3 bit opcode (tells the ALU what you want it to do), 8 bit result
    input [3:0]  A,
    input [3:0]  B,
    input[2:0] Operation,
    output reg [7:0] result
);
//Change to localparam Add = 3'b001 etc
always @(*) begin
    //based on the opcode, tells the ALU to add, subtract, multiply, shift right/left
    case(Operation)
        3'b001: 
            result = A + B;
        3'b010:
            result = A - B;
        3'b011: 
            result = A * B;
        3'b100:
            result = A << B;
        3'b101:
            result = A >> B;

        default: 
            result = 0;
    endcase


end




endmodule
