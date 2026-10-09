`timescale 1ns/1ps

module TX_Testbench;
    reg clk;
    reg reset, start;
    reg[7:0] data_in;
    wire tx, busy, tick;
    integer pass_count = 0;
    integer test_count = 0;
    always #18.5185 clk = ~clk;
    integer i;
    
    baud_rate_gen#(
    .OVERSAMPLE(1),
    .BAUDRATE(9600),
    .CLOCKVALUE(27_000_000)
    ) tx_testbench_baudgen(
    .clk(clk),
    .reset(reset),
    .baud_clock(tick)
    );
    
    TX RXtest(
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .start(start),
        .tx(tx),
        .busy(busy)
    );

    task run_test;
        input reset_in, start_in;
        input[7:0] data_in_in;
        input[9:0] expected_tx; //lsb is tx at start
        input[9:0] expected_busy; //lsb is busy at start
        input[127:0] test_name;

        begin
            reset = reset_in;
            start = start_in;
            data_in = data_in_in;


            @(posedge clk) begin
                #1;
                reset = 0;
                start = 0;
            
                test_count = test_count + 1;
                if(tx == expected_tx[0] && busy == expected_busy[0]) begin //checking for tx to drop low after start and for busy to be busy, or for the resets stuff
                    pass_count = pass_count + 1;
                $display("%s: PASS (tx=%0d, busy=%0d)", test_name, tx, busy);
            end else begin
                $display("%s: FAIL (expected_tx= %0d, tx=%0d, expected_busy = %0d, busy=%0d)", test_name, expected_tx[0], tx, expected_busy[0], busy);
            end

            for(i = 1; i < 10; i = i+1) begin
                @(posedge tick); //when tick sees a change vs when clk sees a positive edge according to gac_cag
                @(posedge clk); //needs to process tick on clock edge? 
                #1;
                    test_count = test_count + 1;
                    if(tx == expected_tx[i] && busy == expected_busy[i]) begin
                    pass_count = pass_count + 1;
                $display("%s: PASS (tx=%0d, busy=%0d)", test_name, tx, busy);
            end else begin
                $display("%s: FAIL (expected_tx= %0d, tx=%0d, expected_busy = %0d, busy=%0d)", test_name, expected_tx[i], tx, expected_busy[i], busy);
                    end
                end
            end
        end

    endtask

    initial begin
        clk = 0;
        $dumpfile("tx_wave.vcd");
        $dumpvars(0, TX_Testbench.tx);
        $dumpvars(0, TX_Testbench.busy);
        $dumpvars(0, TX_Testbench.start);
        $dumpvars(0, TX_Testbench.reset);

        run_test(1'b0, 1'b1, 8'b01101001, 10'b1011010010, 10'b0111111111, "Mock");
        run_test(1'b0, 1'b1, 8'b01111001, 10'b1011110010, 10'b0111111111, "Value1");
        run_test(1'b1, 1'b0, 8'b01111001, 10'b1111111111, 10'b0000000000, "Reset1");
        run_test(1'b1, 1'b1, 8'b01111001, 10'b1111111111, 10'b0000000000, "Reset2");
        run_test(1'b0, 1'b0, 8'b01111001, 10'b1111111111, 10'b0000000000, "NoInput");
        run_test(1'b0, 1'b1, 8'b11111111, 10'b1111111110, 10'b0111111111, "All1");
        run_test(1'b0, 1'b1, 8'b11111111, 10'b1111111110, 10'b0111111111, "All1");

        $display("---");
        $display("%0d/%0d checks passed", pass_count, test_count);
        $finish;

    end

endmodule
