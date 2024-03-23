`include "../buff_uart.sv"

module tb_buff_uart();
    localparam baud_rate = 9600;
    localparam clock_freq = 460800;

    buff_uart_if #(.rx_address('d3), .tx_address('d4), .clock_freq(clock_freq), .baud_rate(baud_rate)) bui();

    localparam nanoseconds_in_second = 10**9;
    localparam clock_period = nanoseconds_in_second / clock_freq;

    always #(clock_period / 2) begin
        bui.clock = ~bui.clock;
    end

    buff_uart dut(bui);

    localparam ticks_per_bit = clock_freq / baud_rate;

    logic [bui.width-1:0] check_data [1:0];
    logic check_clock;

    assign bui.rx = bui.tx;

    initial begin
        check_data[0] = 'b1010;
        check_data[1] = 'b111110;

        bui.clock = 0;
        check_clock = 0;

        bui.active_address = 0;
        bui.read_enable = 0;
        bui.write_enable = 0;
        bui.data_in = 0;

        bui.resetn = 0;

        repeat(1) @(negedge bui.clock);

        bui.resetn = 1;

        repeat(1) @(negedge bui.clock);

        bui.active_address = 'd4;
        bui.read_enable = 1;
        bui.data_in = check_data[0];

        repeat(1) @(negedge bui.clock);

        bui.read_enable = 0;

        repeat(2) @(negedge bui.clock);

        for (int index = -1; index <= bui.width; index++) begin
            repeat(ticks_per_bit) @(negedge bui.clock) begin
                case (index)
                    -1:        assert(bui.tx == 0);
                    bui.width: assert(bui.tx == 1);
                    default:   assert(bui.tx == check_data[0][index]);
                endcase
            end
        end

        repeat(1) @(negedge bui.clock);

        bui.active_address = 'd3;
        bui.read_enable = 0;
        bui.write_enable = 1;

        repeat(1) @(negedge bui.clock);

        // TODO: uncomment
        // assert(bui.data_out == check_data[0]);

        // while (1) begin            
        //     repeat(1) @(negedge bui.clock);
        // end

        $display("Test succeeded");

        $finish;
    end
endmodule
