module RX(
    input clk,
    input reset,
    input rx_in,
    output reg [7:0] data_out,
    output reg data_done
);
//fsm to organize the flow of the rx 
localparam IDLE    = 0;
localparam START   = 1;
localparam DATA    = 2;
localparam STOP    = 3;

reg [2:0] state;
reg [2:0] bit_index;
reg [7:0] shift_reg;
reg [3:0] tick_counter;

reg sync_stage1, rx;
wire tick;

    baud_rate_gen #(        //insantiates the baud gen, first bracket is the parameters and the second bracket are the ports
    .OVERSAMPLE(16),
    .BAUDRATE(9600),
    .CLOCKVALUE(27_000_000)
) rx_baudgen (
    .clk(clk),
    .reset(reset),
    .baud_clock(tick)
);

    always @(posedge clk) begin    //reset block and 2ff synchronizer
    if (reset) begin
        sync_stage1 <= 1'b1;
        rx <= 1'b1;
    end
    else begin
        sync_stage1 <= rx_in;
        rx <= sync_stage1;
    end
end

always @(posedge clk) begin
    if (reset) begin
        state <= IDLE; 
        bit_index <= 0;
        shift_reg <= 0;
        tick_counter <= 0;
        data_out <= 0;
        data_done <= 0;
    end
    else begin
        data_done <= 0; //once we start a new cycle, we set data_done to 0

        if (tick) begin //after one tick, we begin our cycle 
            case (state) 
                //in the idle state, we set tick_counter and bit_index to 0 starting the collection of a new byte. Then, if RX goes low we start
                IDLE: begin 
                    tick_counter <= 0;
                    bit_index <= 0;

                    if (!rx)
                        state <= START;
                end
                /* in the start state, once we hit 8 ticks (7 because it starts at 0) we check if RX is still 0, and if it is we go to the Data state, then reset tick_counter. 
                We check at 8 because its in the middle and the most stable.  */
                START: begin
                    if (tick_counter == 7) begin
                        tick_counter <= 0;
                        if (!rx)
                            state <= DATA;
                        else
                            state <= IDLE;
                    end
                    else begin
                        tick_counter <= tick_counter + 1;
                    end
                end
                /* in the data state we wait for tick_counter to go to 16 to find the middle of each data bit (since we already waited 8 so 16 takes us the the midpoint of the next bit). 
                Then we wait for 8 samples (8 bits) and go to the stop state. The structure for this is, outside is the tick counting and inside is the bit counting.*/
                DATA: begin
                    if (tick_counter == 15) begin
                        tick_counter <= 0;

                        // Sample and shift current data bit into shift_reg
                        shift_reg[bit_index] <= rx;

                        if (bit_index == 7) begin
                            state <= STOP;
                        end
                        else begin
                            bit_index <= bit_index + 1;
                        end
                    end
                    else begin
                        tick_counter <= tick_counter + 1;
                    end
                end
                /*In the stop state, once we check for stability in the stop bit (tick_counter == 15) and rx is still high, then we transfer the bits to data_out
                Then we set data_done high and go back to IDLE*/
                STOP: begin
                    if (tick_counter == 15) begin
                        tick_counter <= 0;

                        if (rx) begin
                            data_out <= shift_reg;
                            data_done <= 1;
                        end

                        state <= IDLE;
                    end
                    else begin
                        tick_counter <= tick_counter + 1;
                    end
                end

                default: begin //default case is IDLE and it resets the tick counter and bit_index back to 0, resetting the whole rx system basically if something weird happens
                    state <= IDLE;
                    tick_counter <= 0;
                    bit_index <= 0;
                end

            endcase
        end
    end
end

endmodule
