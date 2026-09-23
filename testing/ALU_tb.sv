module alu_tb;//module declaration
  logic [3:0] A, B;
  logic [2:0] Operation;
  logic [7:0] result;


  ALU dut ( //initializing the dut
    .A(A),
    .B(B),
    .Operation(Operation),
    .result(result)
  );

  //our test function
  task automatic check_alu(input logic[2:0]op, input logic[3:0]a, input logic[3:0]b, input logic[7:0] expected);    A = a;
    B = b;
    Operation = op;
    #10;

    if(result == expected)
      $display("Test passed");
    else 
      $display("Test failed. Expected %d, got %d for operation: %d", expected, result, op);
  endtask


  initial begin 
    check_alu(dut.ADD, 4, 3, 7);
    check_alu(dut.SUB, 9, 4, 5);
    check_alu(dut.MULT, 3, 3, 9);
    check_alu(dut.SHIFT_LEFT, 1, 2, 4);
    check_alu(dut.ADD, 10, 10, 20);
    check_alu(dut.SUB, 9, 0, 9);
    check_alu(dut.MULT, 1, 3, 3);
    check_alu(dut.SHIFT_LEFT, 1, 2, 4);
  end
      

  
  
endmodule
  
