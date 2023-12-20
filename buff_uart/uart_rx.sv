`include "if/uart_rx_if.sv"

// make always for each variable
// check for start and end bit

module uart_rx (uart_rx_if.DUT rx_if, input logic clock, logic resetn);
    localparam ticks_per_bit = rx_if.clock_freq / rx_if.baud_rate;
    localparam half_ticks_per_bit = rx_if.clock_freq / rx_if.baud_rate / 2;

    enum logic [1:0] { WAIT_FOR_START_BIT, RECEIVING_DATA, RECEIVING_END } state;

    logic [rx_if.width-1:0] bits;
    logic [$clog2(rx_if.width):0] bit_index;
    logic [$clog2(ticks_per_bit):0] ticks_until_next_action;

    logic action;
    assign action = ticks_until_next_action <= 0;

    logic signal;
    assign signal = rx_if.signal == 0 && rx_if.can_receive_next_word;

    always_ff @(posedge clock) begin
        if (action) case(state)
            WAIT_FOR_START_BIT: begin
                if (signal) begin
                    ticks_until_next_action <= ticks_per_bit + half_ticks_per_bit;
                    bit_index <= 0;
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
                    ticks_until_next_action <= ticks_per_bit;
                end
            end

            RECEIVING_END: begin
                ticks_until_next_action <= ticks_per_bit;
            end

            default: begin
                ticks_until_next_action <= 0;
            end
        endcase
    end

    always_ff @(posedge clock, negedge resetn) begin
        if (!resetn) begin
            ticks_until_next_action <= 0;
        end else if (ticks_until_next_action > 0) begin
            ticks_until_next_action <= ticks_until_next_action - 1;
        end
    end

    always_ff @(posedge clock) begin
        case(state)
            RECEIVING_END: rx_if.data <= bits;
        endcase
    end

    always_ff @(posedge clock, negedge resetn) begin
        if (!resetn) begin
            state <= WAIT_FOR_START_BIT;
        end else if (action) case(state)
            WAIT_FOR_START_BIT: if (signal) state <= RECEIVING_DATA;
            RECEIVING_DATA: if (!(bit_index < rx_if.width - 1)) state <= RECEIVING_END;
            RECEIVING_END: state <= WAIT_FOR_START_BIT;
            default: state <= WAIT_FOR_START_BIT;
        endcase
    end

    always_ff @(posedge clock, negedge resetn) begin
        if (!resetn) begin
            rx_if.ready <= 0;
        end else if (rx_if.ready) begin
            rx_if.ready <= 0;
        end else if (action) case(state)
            WAIT_FOR_START_BIT: rx_if.ready <= 0;
            RECEIVING_END: rx_if.ready <= 1;
        endcase
    end
endmodule
