`include "if/uart_if.sv"

module uart_rx (uart_if.RX rx_if, input logic clock, logic resetn);
    localparam ticks_per_bit = rx_if.clock_freq / rx_if.baud_rate;
    localparam double_ticks_per_bit = 2 * rx_if.clock_freq / rx_if.baud_rate;

    enum logic [0:0] { WAIT_FOR_START_BIT, RECEIVING_DATA } state;

    logic [rx_if.width-1:0] samples;
    logic [$clog2(rx_if.width):0] sample_count;
    logic [$clog2(ticks_per_bit):0] ticks_until_next_sample;

    always_ff @(posedge clock) begin
        if(!resetn) begin
            state <= WAIT_FOR_START_BIT;
            ticks_until_next_sample <= 0;
            // samples <= 0;
            sample_count <= 0;
            rx_if.ready <= 0;
        end else if (ticks_until_next_sample > 0) begin
            ticks_until_next_sample <= ticks_until_next_sample - 1;
        end else case(state)
            WAIT_FOR_START_BIT: begin
                rx_if.ready <= 0;
                if (rx_if.signal == 0) begin
                    ticks_until_next_sample <= ticks_per_bit;
                    sample_count <= 0;
                    state <= RECEIVING_DATA;
                end else begin
                    ticks_until_next_sample <= 0;
                end
            end

            RECEIVING_DATA: begin
                // or samples[rx_if.width - 1 - sample_count] - for different endian
                samples[sample_count] = rx_if.signal;
                if (sample_count < rx_if.width - 1) begin
                    ticks_until_next_sample <= ticks_per_bit;
                    sample_count <= sample_count + 1;
                end else begin
                    ticks_until_next_sample <= double_ticks_per_bit;
                    state <= WAIT_FOR_START_BIT;
                    rx_if.ready <= 1;
                    rx_if.data <= samples;
                end
            end

            default: begin
                ticks_until_next_sample <= 0;
                state <= WAIT_FOR_START_BIT;
            end
        endcase
    end
endmodule
