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

    // initial begin
    //     check_data[0] = 'b1010;
    //     check_data[1] = 'b111110;

    //     for (int i = 0; i < 2; i++) begin
    //         repeat(1) @(posedge check_clock or negedge check_clock);

    //         for (int index = -1; index <= bui.width; index++) begin
    //             case (index)
    //                 -1:        bui.rx = 0;
    //                 bui.width: bui.rx = 1;
    //                 default:   bui.rx = check_data[i][index];
    //             endcase

    //             repeat(ticks_per_bit) @(negedge clock);
    //         end
    //     end

    // end

    initial begin
        check_data[0] = 'b1010;
        check_data[1] = 'b111110;

        clock = 0;
        check_clock = 0;

        bui.rx = 0;
        bui.active_address = 0;
        bui.read_enable = 0;
        bui.write_enable = 0;
        bui.data = 0;

        resetn = 0;

        repeat(1) @(negedge clock);

        resetn = 1;

        repeat(1) @(negedge clock);

        bui.active_address = 'd4;
        bui.read_enable = 1;
        bui.data = check_data[0];

        while (1) begin            
            repeat(1) @(negedge clock);
        end

        // for (int index = -1; index <= bui.width; index++) begin
        //     case (index)
        //         -1:        bui.rx = 0;
        //         bui.width: bui.rx = 1;
        //         default:   bui.rx = check_data[0][index];
        //     endcase

        //     repeat(ticks_per_bit) @(negedge clock);
        // end

        // check_clock = ~check_clock;

        // repeat(1) @(negedge clock);

        // // bui.data = check_data[1];
        // // check_clock = ~check_clock;

        // // repeat(1) @(negedge clock);

        // // bui.read_enable = 0;

        // while (1) begin
        //     repeat(1) @(negedge clock);
        // end
        // // $finish;
    end
endmodule
