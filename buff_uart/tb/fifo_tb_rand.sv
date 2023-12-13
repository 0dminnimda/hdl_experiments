`include "../fifo.sv"

module fifo_driver(fifo_if fifo_actual, fifo_if fifo_model);
    logic [7:0] data_in;
    logic read_enable, write_enable;

    initial begin
        fifo_actual.clock = 0;
        fifo_actual.resetn = 0;
        fifo_actual.read_enable = 0;
        fifo_actual.write_enable = 0;
        fifo_actual.data_in = 0;

        fifo_model.clock = 0;
        fifo_model.resetn = 0;
        fifo_model.read_enable = 0;
        fifo_model.write_enable = 0;
        fifo_model.data_in = 0;

        repeat (1) @ (negedge fifo_actual.clock);

        fifo_actual.resetn = 1;
        fifo_model.resetn = 1;

        repeat (1) @ (negedge fifo_actual.clock);

        forever begin
            data_in = $random;
            read_enable = $random;
            write_enable = $random;

            fifo_actual.data_in = data_in;
            fifo_actual.read_enable = read_enable;
            fifo_actual.write_enable = write_enable;

            fifo_model.data_in = data_in;
            fifo_model.read_enable = read_enable;
            fifo_model.write_enable = write_enable;

            repeat (1) @ (negedge fifo_actual.clock);
        end
    end

    always #5ns begin
        fifo_actual.clock = ~fifo_actual.clock;
        fifo_model.clock = ~fifo_model.clock;
    end
endmodule

module fifo_monitor(fifo_if fifo_actual, fifo_if fifo_model);
    always_ff @(posedge fifo_actual.clock) begin
        if (fifo_actual.data_out !== fifo_model.data_out) begin
            $display("mismatch at %t", $time);
            $display("    actual = %p", fifo_actual);
            $display("    model  = %p", fifo_model);
        end
    end
endmodule

module tb_fifo();
    fifo_if #(.width(8), .length(4)) fifo_actual(), fifo_model();
    fifo_driver fifo_driver(fifo_actual, fifo_model);
    fifo fifo(fifo_actual);
    fifo_model model(fifo_model);
    fifo_monitor fifo_monitor(fifo_actual, fifo_model);
endmodule
