module ALU_Testbench;
    //creates variables we'll use to test the ALU such as the inputs (A, B, opcode), the result, and values to store tests that pass and total tests
    reg[3:0]  A, B;
    reg[2:0] Operation;
    wire[7:0] result;
    integer pass_count = 0;
    integer test_count = 0;
    
    //instantiates our ALU in our testbech
    ALU ALUtest (
        .A(A),
        .B(B),
        .Operation(Operation),
        .result(result)
    );

    //task that tests the alu
    task run_test; //task is run like this (a, b, opcode, expected_result, name)
        input[3:0] Ain, Bin;
        input[2:0] Operationin;
        input[7:0] Expected_result;
        input[127:0] test_name;
        begin //our test values are mapped over to the ALU's inputs
            A = Ain; 
            B = Bin;
            Operation = Operationin;
            #10; //wait 10 time units
            test_count = test_count + 1; //increases test count by 1
            if(result == Expected_result) begin //what to do if we get the correct result
                pass_count = pass_count + 1;
                $display("%s: PASS (result=%0d)", test_name, result);
            end else begin //what to do for incorrect result
                $display("%s: FAIL (expected=%d, result=%0d)", test_name, Expected_result, result);
            end
        end
    endtask

    initial begin
        $dumpfile("alu_wave.vcd"); //dumps everything into a wave so we can see it in gtkwave
        $dumpvars(0, ALU_Testbench);

        run_test(4'd1, 4'd1, 3'b001, 8'd2, "ADD");
        run_test(4'd1, 4'd1, 3'b010, 8'd0, "SUBTRACT");
        run_test(4'd1, 4'd1, 3'b011, 8'd1, "MULTIPLY");
        run_test(4'd1, 4'd1, 3'b100, 8'd2, "SHIFT_LEFT");
        run_test(4'd1, 4'd1, 3'b101, 8'd0, "SHIFT_RIGHT");
        run_test(4'd1, 4'd1, 3'b111, 8'd0, "OP_ERROR");
        run_test(4'd0, 4'd1, 3'b010, 8'd255, "SUB_OVERFLOW");
        run_test(4'd15, 4'd15, 3'b011, 8'd225, "MULT_MAX");
        run_test(4'd15, 4'd4, 3'b100, 8'd240, "SHIFTL_OVER");
        run_test(4'd15, 4'd2, 3'b101, 8'd3, "SHIFTR_TEST2");

        $display("---");
        $display("%0d/%0d tests passed", pass_count, test_count);
        $finish;
    end

endmodule
