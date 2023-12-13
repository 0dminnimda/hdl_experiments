typedef enum logic [1:0] {READ, WRITE, READ_N_WRITE} ADDRESSED_DIRECTION;

interface addressable_if #(
    parameter addressed_direction = READ_N_WRITE,
    parameter self_address = 0,
    parameter address_width = 4
);
    logic [address_width-1:0] active_address;
    logic read_enable_in;
    logic write_enable_in;
    logic read_enable_out;
    logic write_enable_out;

    modport DUT (
        input active_address,
        input read_enable_in, write_enable_in,
        output read_enable_out, write_enable_out
    );
endinterface
