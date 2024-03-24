`timescale 1ns/100ps

`ifndef EDAPLAYGROUND
`include "../uart_tx.sv"
`else
`include "uart_tx.sv"
`endif

module tb_uart_tx();
    uart_tx_if #(.width(8), .baud_rate(9600), .clock_freq(460800)) tx_if();
    logic clock, resetn;

    localparam nanoseconds_in_second = 10**9;
    localparam clock_period = nanoseconds_in_second / tx_if.clock_freq;

    always #(clock_period / 2) begin
        clock = ~clock;
    end

    uart_tx dut(.tx_if(tx_if), .clock(clock), .resetn(resetn));

    localparam ticks_per_bit = tx_if.clock_freq / tx_if.baud_rate;

    initial begin
        clock = 0;

        tx_if.can_send_next_word = 0;
        tx_if.data = 0;
        resetn = 0;

        repeat(1) @(negedge clock);

        resetn = 1;

        repeat(1) @(negedge clock);

        repeat(100) @(negedge clock) begin
            assert (tx_if.signal == 1);
            assert (tx_if.ready);
        end

        for (int data = 21; data < 2**tx_if.width; data = data + 1) begin
            tx_if.can_send_next_word = 1;
            tx_if.data = data;

            for (int index = -1; index <= tx_if.width; index++) begin
                repeat(ticks_per_bit) @(negedge clock) begin
                    // $display("index : %d, data : %d, signal : %d, ready: : %d", index, data[index], tx_if.signal, tx_if.ready);

                    case (index)
                        -1: begin
                            assert (!tx_if.ready);
                            assert (tx_if.signal == 0);
                        end
                        tx_if.width: begin
                            assert (tx_if.ready);
                            assert (tx_if.signal == 1);
                        end
                        default: begin
                            assert (!tx_if.ready);
                            assert (tx_if.signal == data[index]);
                        end
                    endcase
                end
            end

            tx_if.can_send_next_word = 0;
            repeat(1) @(negedge clock);
            assert (tx_if.ready);

            repeat($urandom_range(ticks_per_bit/2, ticks_per_bit)) @(negedge clock);
        end

        $finish;
    end
endmodule
