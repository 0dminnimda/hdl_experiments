`include "if/uart_rx_if.sv"

module uart_rx (uart_rx_if.DUT rx_if, input logic clock, logic resetn);
    localparam ticks_per_bit = rx_if.clock_freq / rx_if.baud_rate;
    localparam half_ticks_per_bit = rx_if.clock_freq / rx_if.baud_rate / 2;

    enum logic [1:0] { WAIT_FOR_START_BIT, RECEIVING_START, RECEIVING_DATA, RECEIVING_END } state;

    logic [rx_if.width-1:0] bits;
    logic [$clog2(rx_if.width):0] bit_count;
    logic [$clog2(ticks_per_bit):0] ticks_until_next_action;

    logic action;
    assign action = ticks_until_next_action <= 0;

    logic signal_is_low;
    assign signal_is_low = rx_if.signal == 0 && rx_if.can_receive_next_word;

    logic reading_the_last_bit;
    assign reading_the_last_bit = bit_count >= rx_if.width - 1;

    always_ff @(posedge clock) begin
        if (action) case(state)
            WAIT_FOR_START_BIT: begin
                if (signal_is_low) begin
                    ticks_until_next_action <= half_ticks_per_bit;
                end else begin
                    ticks_until_next_action <= 0;
                end
            end
            RECEIVING_START: ticks_until_next_action <= ticks_per_bit;
            RECEIVING_DATA: ticks_until_next_action <= ticks_per_bit;
            RECEIVING_END: ticks_until_next_action <= ticks_per_bit;
            default: ticks_until_next_action <= 0;
        endcase
    end

    always_ff @(posedge clock) begin
        if (action) case(state)
            RECEIVING_DATA: bits = {rx_if.signal, bits[rx_if.width-1:1]};
        endcase
    end

    always_ff @(posedge clock) begin
        if (action) case(state)
            WAIT_FOR_START_BIT: if (signal_is_low) bit_count <= 0;
            RECEIVING_DATA: bit_count <= bit_count + 1;
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
        if (action) case(state)
            RECEIVING_END: if (!signal_is_low) rx_if.data <= bits;
        endcase
    end

    always_ff @(posedge clock, negedge resetn) begin
        if (!resetn) begin
            state <= WAIT_FOR_START_BIT;
        end else if (action) case(state)
            WAIT_FOR_START_BIT: if (signal_is_low) state <= RECEIVING_START;
            RECEIVING_START:
                if (signal_is_low) state <= RECEIVING_DATA;
                else state <= WAIT_FOR_START_BIT;
            RECEIVING_DATA: if (reading_the_last_bit) state <= RECEIVING_END;
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
            RECEIVING_END: if (!signal_is_low) rx_if.ready <= 1;
        endcase
    end
endmodule
