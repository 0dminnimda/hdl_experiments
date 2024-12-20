interface buff_uart_if #(parameter
    width = 8,
    fifo_length = 16,
    address_width = 4,
    // FIX: remove those 3 hardcoded values
	    rx_address = 3,
	    tx_address = 4,
	    status_address = 5,
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

    logic recieved_byte;
    logic transmitted_byte;

    modport DUT (
        input rx, data_in, active_address, read_enable, write_enable, clock, resetn,
        output tx, data_out, recieved_byte, transmitted_byte
    );
endinterface
