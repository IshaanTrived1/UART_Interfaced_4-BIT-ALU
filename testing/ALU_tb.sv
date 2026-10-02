module alu_tb;//module declaration
  logic [3:0] A, B;
  logic [2:0] Operation;
  logic [7:0] result;

  integer pass=0, fail =0;
  integer i, j;
  


  ALU dut ( //initializing the dut
    .A(A),
    .B(B),
    .Operation(Operation),
    .result(result)
  );

  //our test function
  task automatic check_alu(input logic[2:0]op, input logic[3:0]a, input logic[3:0]b, input logic[7:0] expected);    
    A = a;
    B = b;
    Operation = op;
    #10;

    if(result == expected) begin
      $display("Test passed");
      pass = pass + 1;
     end
    else begin
      $display("Test failed. Expected %d, got %d for operation: %d", expected, result, op);
      fail = fail + 1;
     end
  endtask


  initial begin 

    for(i=0; i < 16; i++) begin
      for(j=0; j<16; j++) begin
        check_alu(dut.ADD, i, j, i+j);
        check_alu(dut.SUB, i, j, i-j);
        //check_alu(dut.MULT, i, j, i*j);
        //check_alu(dut.SHIFT_LEFT, i, j, i<<j);
       // check_alu(dut.SHIFT_RIGHT, i, j, i>>j);

      end
    end

    $display("Test failed: %d, Test passed: %d", fail, pass);
  end
      

  
  
endmodule
