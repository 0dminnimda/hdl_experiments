`timescale 1ns/100ps

interface fifo_if #(parameter width = 8, parameter length_as_power_of_2 = 4) ();
    logic clock;
    logic resetn;
    logic [width-1:0] data_in;
    logic read_enable;
    logic write_enable;
    logic [width-1:0] data_out;
    logic full;
    logic empty;

    modport TEST (
        input clock,
        input resetn, data_in, read_enable, write_enable,
        output data_out, full, empty
    );

    modport DUT (
        input resetn, data_in, read_enable, write_enable,
        output clock,
        output data_out, full, empty
    );

    modport MONITOR (
        input clock,
        input resetn, data_in, read_enable, write_enable, data_out, full, empty
    );
endinterface

module fifo(fifo_if.DUT fifo_if);
    localparam length = 2 ** fifo_if.length_as_power_of_2;

    logic [fifo_if.width-1:0] queued [length-1:0];
    logic [fifo_if.length_as_power_of_2:0] size;

    assign full = (size >= length);
    assign empty = (size == 0);

    logic can_read, can_write;

    assign can_read = fifo_if.read_enable && !full;
    assign can_write = fifo_if.write_enable && !empty;

    integer i;

    always_ff @(posedge fifo_if.clock, posedge fifo_if.resetn) begin
        if (!fifo_if.resetn) begin
            size <= 0;
            fifo_if.data_out <= 0;
        end else begin
            if (fifo_if.read_enable && fifo_if.write_enable) begin
                if (can_read && can_write) begin
                    for (i = 0; i < size; i = i + 1) begin
                        queued[i] <= queued[i+1];
                    end
                    queued[size] <= fifo_if.data_in;
                    fifo_if.data_out <= queued[0];
                end else begin
                    // do not allow to do one action when two are requested
                    // thus do no actions
                    fifo_if.data_out <= 0;
                end
            end else if (can_read) begin
                queued[size] <= fifo_if.data_in;
                size <= size + 1;
                fifo_if.data_out <= 0;
            end else if (can_write) begin
                for (i = 0; i < length - 1; i = i + 1) begin
                    queued[i] <= queued[i+1];
                end
                queued[length - 1] <= 0;
                size <= size - 1;
                fifo_if.data_out <= queued[0];
            end else begin
                fifo_if.data_out <= 0;
            end
        end
    end
endmodule

module tb_fifo(fifo_if.TEST fifo_if);
    initial begin
        fifo_if.clock = 0;
        fifo_if.resetn = 0;
        fifo_if.read_enable = 0;
        fifo_if.write_enable = 0;
        fifo_if.data_in = 0;

        repeat (1) @ (negedge fifo_if.clock);

        fifo_if.resetn = 1;

        repeat (1) @ (negedge fifo_if.clock);

        assert (fifo_if.data_out == 0);
        assert (fifo_if.full == 0);
        assert (fifo_if.empty == 1);

        fifo_if.read_enable = 1;
        for (int i = 1; i <= 16; i = i + 1) begin
            fifo_if.data_in = i;

            repeat (1) @ (negedge fifo_if.clock);

            assert (fifo_if.data_out == 0);
            if (i < 4) begin
                assert (fifo_if.full == 0);
            end else begin
                assert (fifo_if.full == 1);
            end
            assert (fifo_if.empty == 0);
        end

        fifo_if.read_enable = 0;
        for (int i = 1; i <= 16; i = i + 1) begin
            repeat (1) @ (negedge fifo_if.clock);

            assert (fifo_if.data_out == 0);
            assert (fifo_if.full == 1);
            assert (fifo_if.empty == 0);
        end

        fifo_if.write_enable = 1;

        repeat (1) @ (negedge fifo_if.clock);

        assert (fifo_if.data_out == 1);
        assert (fifo_if.full == 0);
        assert (fifo_if.empty == 0);

        repeat (1) @ (negedge fifo_if.clock);

        assert (fifo_if.data_out == 2);
        assert (fifo_if.full == 0);
        assert (fifo_if.empty == 0);

        repeat (1) @ (negedge fifo_if.clock);

        assert (fifo_if.data_out == 3);
        assert (fifo_if.full == 0);
        assert (fifo_if.empty == 0);

        repeat (1) @ (negedge fifo_if.clock);

        assert (fifo_if.data_out == 4);
        assert (fifo_if.full == 0);
        assert (fifo_if.empty == 1);
        for (int i = 1; i <= 16; i = i + 1) begin
            repeat (1) @ (negedge fifo_if.clock);

            assert (fifo_if.data_out == 0);
            assert (fifo_if.full == 0);
            assert (fifo_if.empty == 1);
        end

        repeat (1) @ (negedge fifo_if.clock);

        $finish;
    end

    always #5ns fifo_if.clock = ~fifo_if.clock;
endmodule

module top_fifo();
    fifo_if #(8, 2) fifo_if();
    fifo fifo(fifo_if);
    tb_fifo tb_fifo(fifo_if);
endmodule

typedef enum logic [1:0] {READ, WRITE, READ_N_WRITE} ADRESSED_DIRECTION;

module adressed_fifo #(
    parameter adressed_direction = READ_N_WRITE,
    parameter self_adress = 0,
    parameter adress_width = 4,
    parameter data_width = 8,
    parameter length_as_power_of_2 = 4
) (
    input logic clock,
    input logic resetn,
    input logic [adress_width-1:0] active_adress,
    input tri [data_width-1:0] data_in,
    input logic read_enable,
    input logic write_enable,
    output tri [data_width-1:0] data_out,
    output logic full,
    output logic empty
);
    logic inner_read_enable;
    logic inner_write_enable;

    assign inner_read_enable = ((adressed_direction == READ || adressed_direction == READ_N_WRITE) && (active_adress == self_adress)) ? read_enable : 0;
    assign inner_write_enable = ((adressed_direction == WRITE || adressed_direction == READ_N_WRITE) && (active_adress == self_adress)) ? write_enable : 0;

    fifo #(data_width, length_as_power_of_2) inner(
        .clock(clock), .resetn(resetn), .data_in(data_in),
        .read_enable(inner_read_enable), .write_enable(inner_write_enable),
        .data_out(data_out), .full(full), .empty(empty)
    );
endmodule

module tb_rw_adressed_fifo();
    logic clock, resetn;
    logic [3:0] active_adress;
    logic [7:0] data_in;
    logic [7:0] data_out;
    logic full, empty;
    logic read_enable, write_enable;

    adressed_fifo #(.self_adress('d7), .length_as_power_of_2(2)) rw_fifo(
        .clock(clock), .resetn(resetn), .active_adress(active_adress),
        .data_in(data_in),
        .read_enable(read_enable), .write_enable(write_enable),
        .data_out(data_out), .full(full), .empty(empty)
    );

    initial begin
        clock = 0;
        resetn = 0;
        active_adress = 'd7;
        read_enable = 0;
        write_enable = 0;
        data_in = 0;

        repeat (1) @ (negedge clock);

        resetn = 1;

        repeat (1) @ (negedge clock);

        assert (data_out == 0);
        assert (full == 0);
        assert (empty == 1);

        read_enable = 1;
        for (int i = 1; i <= 16; i = i + 1) begin
            data_in = i;

            repeat (1) @ (negedge clock);

            assert (data_out == 0);
            if (i < 4) begin
                assert (full == 0);
            end else begin
                assert (full == 1);
            end
            assert (empty == 0);
        end

        read_enable = 0;
        for (int i = 1; i <= 16; i = i + 1) begin
            repeat (1) @ (negedge clock);

            assert (data_out == 0);
            assert (full == 1);
            assert (empty == 0);
        end

        write_enable = 1;

        repeat (1) @ (negedge clock);

        assert (data_out == 1);
        assert (full == 0);
        assert (empty == 0);

        repeat (1) @ (negedge clock);

        assert (data_out == 2);
        assert (full == 0);
        assert (empty == 0);

        repeat (1) @ (negedge clock);

        assert (data_out == 3);
        assert (full == 0);
        assert (empty == 0);

        repeat (1) @ (negedge clock);

        assert (data_out == 4);
        assert (full == 0);
        assert (empty == 1);
        for (int i = 1; i <= 16; i = i + 1) begin
            repeat (1) @ (negedge clock);

            assert (data_out == 0);
            assert (full == 0);
            assert (empty == 1);
        end

        repeat (1) @ (negedge clock);

        $finish;
    end

    always #5ns clock = ~clock;
endmodule
