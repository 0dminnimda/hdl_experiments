`timescale 1ns/100ps

`ifndef EDAPLAYGROUND
`include "../addressable.sv"
`else
`include "addressable.sv"
`endif

module tb_rw_addressable();
    localparam address_width = 4;
    localparam self_address = 'd7;

    addressable_if #(.addressed_direction(READ_N_WRITE), .address_width(address_width), .self_address(self_address)) addr();
    addressable addressable(addr);

    initial begin
        for (int i = 0; i < 2**address_width; i = i * 2 + 1) begin
            if (i == self_address) continue;

            addr.active_address = i;
            for (int j = 0; j < 2; j = j + 2) begin
                for (int k = 0; k < 2; k = k + 2) begin
                    addr.read_enable_in = j;
                    addr.write_enable_in = k;
                    #10ns;
                    assert (addr.read_enable_out == 0);
                    assert (addr.write_enable_out == 0);
                end
            end
        end

        addr.active_address = self_address;
        for (int j = 0; j < 2; j = j + 2) begin
            for (int k = 0; k < 2; k = k + 2) begin
                addr.read_enable_in = j;
                addr.write_enable_in = k;
                #10ns;
                assert (addr.read_enable_out == j);
                assert (addr.write_enable_out == k);
            end
        end
    end
endmodule
