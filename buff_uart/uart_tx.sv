`ifndef EDAPLAYGROUND
`include "if/uart_tx_if.sv"
`else
`include "uart_tx_if.sv"
`endif

module uart_tx (uart_tx_if.DUT tx_if, input logic clock, logic resetn);
    localparam ticks_per_bit = tx_if.clock_freq / tx_if.baud_rate;

    enum logic [1:0] { WAIT_FOR_PREMISSION, SENDING_DATA, SENDING_END } state;

    logic [tx_if.width:0] bits;
    logic [$clog2(tx_if.width):0] bit_index;
    logic [$clog2(ticks_per_bit):0] ticks_until_next_action;

    always_ff @(posedge clock, negedge resetn) begin
        if(!resetn) begin
            state <= WAIT_FOR_PREMISSION;
            ticks_until_next_action <= 0;
            tx_if.signal <= 1;
            tx_if.ready <= 1;
        end else if (ticks_until_next_action > 1) begin
            ticks_until_next_action <= ticks_until_next_action - 1;
        end else case(state)
            WAIT_FOR_PREMISSION: begin
                // && tx_if.ready) but it's not needed because we the signal switches immediately
                if (tx_if.can_send_next_word) begin
                    tx_if.signal <= 0;
                    ticks_until_next_action <= ticks_per_bit;
                    bit_index <= 0;
                    bits <= tx_if.data;
                    state <= SENDING_DATA;
                    tx_if.ready <= 0;
                end else begin
                    ticks_until_next_action <= 0;
                end
            end

            SENDING_DATA: begin
                tx_if.signal <= bits[bit_index];
                ticks_until_next_action <= ticks_per_bit;
                if (bit_index < tx_if.width - 1) begin
                    bit_index <= bit_index + 1;
                end else begin
                    state <= SENDING_END;
                end
            end

            SENDING_END: begin
                tx_if.signal <= 1;
                ticks_until_next_action <= ticks_per_bit;
                state <= WAIT_FOR_PREMISSION;
                tx_if.ready <= 1;
            end

            default: begin
                ticks_until_next_action <= 0;
                state <= WAIT_FOR_PREMISSION;
                tx_if.ready <= 1;
            end
        endcase
    end
endmodule
