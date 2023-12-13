`include "../fifo.sv"

module tb_fifo();
    fifo_if #(.width(8), .length(4)) fifo_if();
    fifo fifo(fifo_if);
    // fifo_model fifo(fifo_if);

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
    end

    always #5ns fifo_if.clock = ~fifo_if.clock;
endmodule
