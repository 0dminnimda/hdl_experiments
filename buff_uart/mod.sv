`timescale 1ns/100ps

module fifo #(parameter width = 8, parameter length_as_power_of_2 = 4) (
    input logic clock,
    input logic resetn,
    input logic [width-1:0] data_in,
    input logic read_enable,
    input logic write_enable,
    output logic [width-1:0] data_out,
    output logic full,
    output logic empty
);
    localparam length = 2 ** length_as_power_of_2;

    logic [width-1:0] queued [length-1:0];
    logic [length_as_power_of_2:0] size;

    assign full = (size >= length);
    assign empty = (size == 0);

    logic can_read, can_write;

    assign can_read = read_enable && !full;
    assign can_write = write_enable && !empty;

    integer i;

    always_ff @(posedge clock, posedge resetn) begin
        if (!resetn) begin
            size <= 0;
            data_out <= 0;
        end else begin
            if (read_enable && write_enable) begin
                if (can_read && can_write) begin
                    for (i = 0; i < size; i = i + 1) begin
                        queued[i] <= queued[i+1];
                    end
                    queued[size] <= data_in;
                    data_out <= queued[0];
                end else begin
                    // do not allow to do one action when two are requested
                    // thus do no actions
                    data_out <= 0;
                end
            end else if (can_read) begin
                queued[size] <= data_in;
                size <= size + 1;
                data_out <= 0;
            end else if (can_write) begin
                for (i = 0; i < length - 1; i = i + 1) begin
                    queued[i] <= queued[i+1];
                end
                queued[length - 1] <= 0;
                size <= size - 1;
                data_out <= queued[0];
            end else begin
                data_out <= 0;
            end
        end
    end
endmodule

module tb_fifo();
    logic clock, resetn;
    logic [7:0] data_in;
    logic [7:0] data_out;
    logic full, empty;
    logic read_enable, write_enable;

    fifo #(8, 2) fifo1(
        .clock(clock), .resetn(resetn), .data_in(data_in),
        .read_enable(inner_read_enable), .write_enable(inner_write_enable),
        .data_out(data_out), .full(full), .empty(empty)
    );

    initial begin
        clock = 0;
        resetn = 0;
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
    input logic [adress_width-1:0] active_read_adress,
    input logic [adress_width-1:0] active_write_adress,
    input tri [data_width-1:0] data_in,
    input logic read_enable,
    input logic write_enable,
    output tri [data_width-1:0] data_out,
    output logic full,
    output logic empty
);
    logic inner_read_enable;
    logic inner_write_enable;

    assign inner_read_enable = ((adressed_direction == READ || adressed_direction == READ_N_WRITE) && (active_read_adress == self_adress)) ? read_enable : 0;
    assign inner_write_enable = ((adressed_direction == WRITE || adressed_direction == READ_N_WRITE) && (active_write_adress == self_adress)) ? write_enable : 0;

    fifo #(data_width, length_as_power_of_2) inner(
        .clock(clock), .resetn(resetn), .data_in(data_in),
        .read_enable(inner_read_enable), .write_enable(inner_write_enable),
        .data_out(data_out), .full(full), .empty(empty)
    );
endmodule

module tb_rw_adressed_fifo();
    logic clock, resetn;
    logic [3:0] active_read_adress;
    logic [3:0] active_write_adress;
    logic [7:0] data_in;
    logic [7:0] data_out;
    logic full, empty;
    logic read_enable, write_enable;

    adressed_fifo #(.self_adress('d7), .length_as_power_of_2(2)) rw_fifo(
        .clock(clock), .resetn(resetn), .active_read_adress(active_read_adress),
        .active_write_adress(active_write_adress), .data_in(data_in),
        .read_enable(read_enable), .write_enable(write_enable),
        .data_out(data_out), .full(full), .empty(empty)
    );

    initial begin
        clock = 0;
        resetn = 0;
        active_read_adress = 'd7;
        active_write_adress = 'd7;
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
