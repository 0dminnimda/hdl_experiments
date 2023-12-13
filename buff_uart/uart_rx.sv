`include "if/uart_rx_if.sv"

module uart_rx (uart_rx_if.DUT rx_if, input logic clock, logic resetn);
    localparam ticks_per_bit = rx_if.clock_freq / rx_if.baud_rate;
    localparam double_ticks_per_bit = 2 * rx_if.clock_freq / rx_if.baud_rate;

    enum logic [0:0] { WAIT_FOR_START_BIT, RECEIVING_DATA } state;

    logic [rx_if.width-1:0] bits;
    logic [$clog2(rx_if.width):0] bit_index;
    logic [$clog2(ticks_per_bit):0] ticks_until_next_action;

    always_ff @(posedge clock) begin
        if(!resetn) begin
            state <= WAIT_FOR_START_BIT;
            ticks_until_next_action <= 0;
            rx_if.ready <= 0;
        end else if (ticks_until_next_action > 0) begin
            ticks_until_next_action <= ticks_until_next_action - 1;
        end else case(state)
            WAIT_FOR_START_BIT: begin
                rx_if.ready <= 0;
                if (rx_if.signal == 0 && rx_if.can_receive_next_word) begin
                    ticks_until_next_action <= ticks_per_bit;
                    bit_index <= 0;
                    state <= RECEIVING_DATA;
                end else begin
                    ticks_until_next_action <= 0;
                end
            end

            RECEIVING_DATA: begin
                bits[bit_index] <= rx_if.signal;
                if (bit_index < rx_if.width - 1) begin
                    ticks_until_next_action <= ticks_per_bit;
                    bit_index <= bit_index + 1;
                end else begin
                    ticks_until_next_action <= double_ticks_per_bit;
                    state <= WAIT_FOR_START_BIT;
                    rx_if.ready <= 1;
                    rx_if.data <= bits;
                end
            end

            default: begin
                ticks_until_next_action <= 0;
                state <= WAIT_FOR_START_BIT;
            end
        endcase
    end
endmodule
