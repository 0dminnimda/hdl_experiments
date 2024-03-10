`include "../buff_uart.sv"

module tb_buff_uart();
    buff_uart_if #(.rx_address('d3), .tx_address('d4)) bui();
    logic clock, resetn;

    localparam nanoseconds_in_second = 10**9;
    localparam clock_period = nanoseconds_in_second / bui.clock_freq;

    always #(clock_period / 2) begin
        clock = ~clock;
    end

    buff_uart dut(bui, clock, resetn);

    localparam ticks_per_bit = bui.clock_freq / bui.baud_rate;

    logic [bui.width-1:0] check_data [1:0];
    logic check_clock;

    assign bui.rx = bui.tx;

    initial begin
        check_data[0] = 'b1010;
        check_data[1] = 'b111110;

        clock = 0;
        check_clock = 0;

        bui.active_address = 0;
        bui.read_enable = 0;
        bui.write_enable = 0;
        bui.data_in = 0;

        resetn = 0;

        repeat(1) @(negedge clock);

        resetn = 1;

        repeat(1) @(negedge clock);

        bui.active_address = 'd4;
        bui.read_enable = 1;
        bui.data_in = check_data[0];

        repeat(1) @(negedge clock);

        bui.read_enable = 0;

        repeat(2) @(negedge clock);

        for (int index = -1; index <= bui.width; index++) begin
            repeat(ticks_per_bit) @(negedge clock) begin
                case (index)
                    -1:        assert(bui.tx == 0);
                    bui.width: assert(bui.tx == 1);
                    default:   assert(bui.tx == check_data[0][index]);
                endcase
            end
        end

        repeat(1) @(negedge clock);

        bui.active_address = 'd3;
        bui.read_enable = 0;
        bui.write_enable = 1;

        repeat(1) @(negedge clock);

        assert(bui.data_out == check_data[0]);

        // while (1) begin            
        //     repeat(1) @(negedge clock);
        // end

        $finish;
    end
endmodule
