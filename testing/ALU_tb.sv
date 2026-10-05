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

  //writing a reference_alu so we dont have to call check_alu multiple times for each case
  function automatic logic [7:0] reference_alu(input logic[2:0]op, input logic[3:0]a, input logic[3:0]b);
    case(op)
      3'd1: return(a + b);
      3'd2: return (a-b);
      3'd3: return (a * b);
      3'd4: return (a << b);
      3'd5: return (a >> b);
    endcase
  endfunction 

  class alu_txn; //random stimulus 
      rand logic [3:0] a, b;
      rand logic [2:0] op;
      constraint c_op {op inside {[3'd1: 3'd5]}; }
  endclass

  initial begin
    alu_txn t;
    t = new();
    for(i=0; i<50; i++) begin
      if(!t.randomize())
        $error("randomized failed");
      else
        check_alu(t.op, t.a, t.b, reference_alu(t.op, t.a, t.b));
    end
    $display("Test failed: %d, Test passed: %d", fail, pass);
  end
      

  
  
endmodule
