module alu_tb;
  reg [3:0] A, B;
  reg[2:0] Operation;
  wire [7:0] result;


  ALU dut (
    .A(A),
    .B(B),
    .Operation(Operation),
    .result(result)
  );

  initial begin (
    #10;

    A = 1; B = 1; Operation = 1;

    #10;

    if (result != 2)
      $display("Test failed, expected 2 and recieved %d", result);
    else
      $display("Test passed!");
  )

  
  
endmodule
  
