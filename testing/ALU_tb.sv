module alu_tb;//module declaration
  reg [3:0] A, B;
  reg[2:0] Operation;
  wire [7:0] result;


  ALU dut ( //initializing the dut
    .A(A),
    .B(B),
    .Operation(Operation),
    .result(result)
  );


  task automatic check_alu(input reg[2:0]op, input reg[3:0]a, input reg[3:0]b, input reg[7:0] expected); //our test function
    A = a;
    B = b;
    Operation = op;
    #10;

    if(result == expected)
      $display("Test passed");
    else 
      $display("Test failed. Expected %d, got %d for operation: %d", expected, result, Operation);
  endtask


  initial begin 
    check_alu(dut.ADD, 4, 3, 7);

    check_alu(dut.SUB, 9, 4, 5);
    check_alu(dut.MULT, 3, 3, 9);
    check_alu(dut.SHIFT_LEFT, 1, 2, 4);
  end
      

  
  
endmodule
  
