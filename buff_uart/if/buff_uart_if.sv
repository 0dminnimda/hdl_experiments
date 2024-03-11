interface buff_uart_if #(parameter
    width = 8,
    fifo_length = 16,
    address_width = 4,
    rx_address = 0,
    tx_address = 0,
    baud_rate = 9600,
    clock_freq = 460800
);
    logic clock;
    logic resetn;

    logic rx;
    logic tx;

    logic read_enable;
    logic write_enable;

    logic [address_width-1:0] active_address;
    logic [width-1:0] data_in;
    logic [width-1:0] data_out;

    modport DUT (
        input rx, data_in, active_address, read_enable, write_enable, clock, resetn,
        output tx, data_out
    );
endinterface
