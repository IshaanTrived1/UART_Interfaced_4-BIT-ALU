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

  class alu_rand; //random stimulus 
      rand logic [3:0] a, b;
      rand logic [2:0] op;
      constraint c_op {op inside {[3'd1: 3'd5]}; }
  endclass

  covergroup alu_cg;
    cp_op : coverpoint Operation{
      bins low = {1};
      bins high = {5};
      bins rest = {[2:4]};
    }

    cp_a : coverpoint Operation{
      bins low = {0};
      bins high = {7};
      bins rest = {[1:6]};
    }

    cp_b : coverpoint Operation{
      bins low = {0};
      bins high = {7};
      bins rest = {[1:6]};
    }

    crossA: cross cp_op, cp_a{
      illegal_bins notlegal = ((op==0) & (b==0));
    }
    crossB: cross cp_op, cp_b{
      illegal_bins notlegal = ((op==0) & (b==0));
    }
  endgroup

  initial begin
    alu_rand t;
    alu_cg cg;
    cg = new ();
    t = new();
    for(i=0; i<50; i++) begin
      if(!t.randomize())
        $error("randomized failed");
      else begin
        check_alu(t.op, t.a, t.b, reference_alu(t.op, t.a, t.b));
        cg.sample();
        $display("A: %0d, B: %0d, op: %0d, answer:%d", t.a, t.b, t.op, result);
      end
    end
    $display("Test failed: %0d, Test passed: %0d", fail, pass);
    $display("Coverage: %0.2f", cg.get_coverage());
  end
      

  
  
endmodule
