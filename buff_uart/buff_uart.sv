`timescale 1ns/100ps

`include "if/buff_uart_if.sv"
`include "uart_rx.sv"
`include "uart_tx.sv"
`include "fifo.sv"
`include "addressable.sv"

module buff_uart (
    buff_uart_if.DUT bui,
    input logic clock, logic resetn
);
    uart_rx_if #(.width(bui.width), .baud_rate(bui.baud_rate), .clock_freq(bui.clock_freq)) rx_if();
    uart_rx uart_rx(.rx_if(rx_if), .clock(clock), .resetn(resetn));

    uart_tx_if #(.width(bui.width), .baud_rate(bui.baud_rate), .clock_freq(bui.clock_freq)) tx_if();
    uart_tx uart_tx(.tx_if(tx_if), .clock(clock), .resetn(resetn));

    fifo_if #(.width(bui.width), .length(bui.fifo_length)) rx_fifo_if();
    fifo rx_fifo(.fifo_if(rx_fifo_if), .clock(clock), .resetn(resetn));

    fifo_if #(.width(bui.width), .length(bui.fifo_length)) tx_fifo_if();
    fifo tx_fifo(.fifo_if(tx_fifo_if), .clock(clock), .resetn(resetn));

    addressable_if #(
        .addressed_direction(READ),
        .self_address(bui.tx_address),
        .address_width(bui.address_width)
    ) rx_addr_if();
    addressable rx_addr(rx_addr_if);

    addressable_if #(
        .addressed_direction(WRITE),
        .self_address(bui.rx_address),
        .address_width(bui.address_width)
    ) tx_addr_if();
    addressable tx_addr(tx_addr_if);

    assign rx_if.signal = bui.rx;
    assign bui.tx = tx_if.signal;

    assign rx_fifo_if.read_enable = rx_if.ready;
    assign tx_fifo_if.write_enable = tx_if.ready;

    assign rx_if.can_receive_next_word = rx_fifo_if.can_read;
    assign tx_if.can_send_next_word = tx_fifo_if.can_write;

    assign rx_fifo_if.data_in = rx_if.data;
    assign tx_if.data = tx_fifo_if.data_out;

    assign rx_addr_if.active_address = bui.active_address;
    assign tx_addr_if.active_address = bui.active_address;

    // assign rx_addr_if.read_enable_in = bui.read_enable;
    assign rx_addr_if.write_enable_in = bui.write_enable;
    assign rx_fifo_if.write_enable = rx_addr_if.write_enable_out;

    // assign tx_addr_if.write_enable_in = bui.write_enable;
    assign tx_addr_if.read_enable_in = bui.read_enable;
    assign tx_fifo_if.read_enable = tx_addr_if.read_enable_out;

    // assign bui.data = rx_fifo_if.can_write ? rx_fifo_if.data_out : 'z;
    // assign tx_fifo_if.data_in = tx_fifo_if.can_read ? bui.data : 0;
    always_ff @(posedge clock) begin
        if (rx_fifo_if.can_write) begin
            bui.data <= rx_fifo_if.data_out;
        end
        if (tx_fifo_if.can_read) begin
            tx_fifo_if.data_in <= bui.data;
        end
    end
endmodule
