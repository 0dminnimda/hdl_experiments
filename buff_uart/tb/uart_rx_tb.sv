`timescale 1ns/100ps

`include "../uart_rx.sv"

module tb_uart_rx();
    uart_rx_if #(.width(8), .baud_rate(9600), .clock_freq(460800)) rx_if();
    logic clock, resetn;

    localparam nanoseconds_in_second = 10**9;
    localparam clock_period = nanoseconds_in_second / rx_if.clock_freq;

    always #(clock_period / 2) begin
        clock = ~clock;
    end

    uart_rx dut(.rx_if(rx_if), .clock(clock), .resetn(resetn));

    localparam ticks_per_bit = rx_if.clock_freq / rx_if.baud_rate;

    logic [rx_if.width-1:0] data = 0;

    initial begin
        clock = 0;

        rx_if.can_receive_next_word = 1;
        rx_if.signal = 1;
        resetn = 0;

        repeat(1) @(negedge clock);

        resetn = 1;

        repeat(1) @(negedge clock);

        repeat(ticks_per_bit) @(negedge clock) begin
            assert (!rx_if.ready);
        end

        for (int data = 0; data < 2**rx_if.width; data = data + 1) begin
            assert (!rx_if.ready);

            for (int index = -1; index <= rx_if.width; index++) begin
                case (index)
                    -1:          rx_if.signal = 0;
                    rx_if.width: rx_if.signal = 1;
                    default:     rx_if.signal = data[index];
                endcase

                repeat(ticks_per_bit) @(negedge clock);

                case (index)
                    -1: begin
                        assert (!rx_if.ready);
                    end
                    rx_if.width: begin
                        assert (rx_if.ready);
                        assert (data == rx_if.data);
                    end
                    default: begin
                        assert (!rx_if.ready);
                    end
                endcase
            end

            // $display("input : ", data, ", result :", rx_if.data);
            repeat($urandom_range(ticks_per_bit/2, ticks_per_bit)) @(negedge clock);
        end

        $finish;
    end
endmodule
