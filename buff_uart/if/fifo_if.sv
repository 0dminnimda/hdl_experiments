interface fifo_if #(parameter width = 8, parameter length = 16);
    logic [width-1:0] data_in;
    logic read_enable;
    logic write_enable;
    logic [width-1:0] data_out;
    logic full;
    logic empty;
    logic can_read;
    logic can_write;

    modport DUT (
        input data_in, read_enable, write_enable,
        output data_out, full, empty, can_read, can_write
    );
endinterface
