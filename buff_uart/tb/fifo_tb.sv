`ifndef EDAPLAYGROUND
`include "../fifo.sv"
`else
`include "fifo.sv"
`endif

module tb_fifo();
    logic clock, resetn;
    fifo_if #(.width(8), .length(4)) fifo_if();
    fifo fifo(fifo_if, clock, resetn);
    // fifo_model fifo(fifo_if, clock, resetn);

    initial begin
        clock = 0;
        resetn = 0;
        fifo_if.read_enable = 0;
        fifo_if.write_enable = 0;
        fifo_if.data_in = 0;

        repeat (1) @ (negedge clock);

        resetn = 1;

        repeat (1) @ (negedge clock);

        assert (fifo_if.data_out == 0);
        assert (fifo_if.full == 0);
        assert (fifo_if.empty == 1);

        fifo_if.read_enable = 1;
        for (int i = 1; i <= 16; i = i + 1) begin
            fifo_if.data_in = i;

            repeat (1) @ (negedge clock);

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
            repeat (1) @ (negedge clock);

            assert (fifo_if.data_out == 0);
            assert (fifo_if.full == 1);
            assert (fifo_if.empty == 0);
        end

        fifo_if.write_enable = 1;

        repeat (1) @ (negedge clock);

        assert (fifo_if.data_out == 1);
        assert (fifo_if.full == 0);
        assert (fifo_if.empty == 0);

        repeat (1) @ (negedge clock);

        assert (fifo_if.data_out == 2);
        assert (fifo_if.full == 0);
        assert (fifo_if.empty == 0);

        repeat (1) @ (negedge clock);

        assert (fifo_if.data_out == 3);
        assert (fifo_if.full == 0);
        assert (fifo_if.empty == 0);

        repeat (1) @ (negedge clock);

        assert (fifo_if.data_out == 4);
        assert (fifo_if.full == 0);
        assert (fifo_if.empty == 1);
        for (int i = 1; i <= 16; i = i + 1) begin
            repeat (1) @ (negedge clock);

            assert (fifo_if.data_out == 0);
            assert (fifo_if.full == 0);
            assert (fifo_if.empty == 1);
        end

        repeat (1) @ (negedge clock);
    end

    always #5ns clock = ~clock;
endmodule
