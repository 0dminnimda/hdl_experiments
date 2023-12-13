`include "if/addressable_if.sv"

module addressable(addressable_if.DUT addr);
    localparam allowed_to_read = addr.addressed_direction == READ || addr.addressed_direction == READ_N_WRITE;
    localparam allowed_to_write = addr.addressed_direction == WRITE || addr.addressed_direction == READ_N_WRITE;

    logic is_my_address;
    assign is_my_address = (addr.active_address == addr.self_address);

    assign addr.read_enable_out = (allowed_to_read && is_my_address) ? addr.read_enable_in : 0;
    assign addr.write_enable_out = (allowed_to_write && is_my_address) ? addr.write_enable_in : 0;
endmodule
