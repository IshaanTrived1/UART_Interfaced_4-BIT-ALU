module ALU(
    //4 bit inputs, 3 bit opcode (tells the ALU what you want it to do), 8 bit result
    input [3:0]  A,
    input [3:0]  B,
    input[2:0] Operation,
    output reg [7:0] result
);
//Change to localparam Add = 3'b001 etc

localparam ADD = 3'b001;
localparam SUB = 3'b010;
localparam MULT = 3'b011;
localparam SHIFT_LEFT = 3'b100;
localparam SHIFT_RIGHT = 3'b101;
    
always @(*) begin
    //based on the opcode, tells the ALU to add, subtract, multiply, shift right/left
    case(Operation)
        ADD: 
            result = A + B;
        SUB:
            result = A - B;
        MULT: 
            result = A * B;
        SHIFT_LEFT:
            result = A << B;
        SHIFT_RIGHT:
            result = A >> B;

        default: 
            result = 0;
    endcase


end




endmodule
