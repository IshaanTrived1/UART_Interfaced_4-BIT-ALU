`timescale 1ns/1ps

module RX_Testbench;
    reg clk;
    always #18.5185 clk = ~clk;
    reg reset, rx_in;
    wire data_done;
    wire[7:0] data_out;
    integer pass_count = 0;
    integer test_count = 0;
    wire tick;
    integer i;

    baud_rate_gen#(
    .OVERSAMPLE(16),
    .BAUDRATE(9600),
    .CLOCKVALUE(27_000_000)
    ) tx_testbench_baudgen(
    .clk(clk),
    .reset(reset),
    .baud_clock(tick)
    );

    RX RXtest(
        .clk(clk),
        .reset(reset),
        .rx_in(rx_in),
        .data_out(data_out),
        .data_done(data_done)
    );

    task run_test;
        input reset_in;
        input[9:0] rx_in_in;
        input[7:0] expected_data_out;
        input expected_data_done;
        input[127:0] test_name;

        begin 
            #10;
            reset = reset_in; //lets test reset after data already gets a value

            rx_in = rx_in_in[0];    

            @(posedge clk) begin
                #10;
                reset = 0;
                test_count = test_count + 1;

                repeat(8) @(posedge tick);
                #10;
                rx_in = rx_in_in[1];
                for(i = 2; i < 9; i = i+1) begin
                    repeat(16) @(posedge tick);
                    #10;
                    
                    rx_in = rx_in_in[i];
                end

                repeat(16) @(posedge tick);
                #10;
                rx_in = rx_in_in[9]; // STOP bit
                repeat(16) @(posedge tick);
                #10;
                if(data_done == expected_data_done && data_out == expected_data_out) begin
                    pass_count = pass_count + 1;
                $display("%s: PASS (data_out = %0d, data_done=%0d)", test_name, data_out, data_done);
            end else begin
                $display("%s: FAIL (expected_data_out = %0d, data_out = %0d, expected_data_done=%0d, data_done=%0d)", test_name, expected_data_out, data_out, expected_data_done, data_done);
                    end
            end
        end

    endtask


    initial begin
        clk = 0;
        $dumpfile("rx_wave.vcd");
        $dumpvars(0, RX_Testbench.rx_in);
        $dumpvars(0, RX_Testbench.reset);
        $dumpvars(0, RX_Testbench.data_out);
        $dumpvars(0, RX_Testbench.data_done);

        run_test(1'b0, 10'b1100111000, 8'b10011100, 1'b1, "Mock");
        run_test(1'b0, 10'b1000000000, 8'b00000000, 1'b1, "All0");
        run_test(1'b0, 10'b1111111110, 8'b11111111, 1'b1, "All1");
        run_test(1'b0, 10'b1001010001, 8'b00010100, 1'b1, "LateStart");
        run_test(1'b0, 10'b1111111111, 8'b00010100, 1'b1, "NoStart"); //should keep the same as the last one since it never does anything to data_out hopefully

        $display("---");
        $display("%0d/%0d checks passed", pass_count, test_count);
        $finish;

        $finish;
    end   


   
endmodule
