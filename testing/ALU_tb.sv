//ALU testbench rewrite in SystemVerilog
module ALU_tb_sv;
  function automatic reg[7:0] ALUTest (reg[3:0]A, reg[3:0]B, reg[2:0]Operation) 
    begin
      case(Operation)
      3'b001: 
            return A + B;
        3'b010:
            return A - B;
        3'b011: 
            return A * B;
        3'b100:
            return A << B;
        3'b101:
            return A >> B;
        default: 
            return 0;
        
      endcase
    end

  class alu_transaction;
    rand bit [3:0] A,
    rand bit [3:0] B, 
    rand bit [2:0] Operation;
    
  endfunction

endmodule

  
