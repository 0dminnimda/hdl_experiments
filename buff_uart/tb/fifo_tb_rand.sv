`include "../fifo.sv"

module driver(fifo_if fifo_actual, fifo_if fifo_model, output logic clock, logic resetn);
    logic [7:0] data_in;
    logic read_enable, write_enable;

    initial begin
        clock = 0;
        resetn = 0;

        fifo_actual.read_enable = 0;
        fifo_actual.write_enable = 0;
        fifo_actual.data_in = 0;

        fifo_model.read_enable = 0;
        fifo_model.write_enable = 0;
        fifo_model.data_in = 0;

        repeat (1) @ (negedge clock);

        resetn = 1;

        repeat (1) @ (negedge clock);

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

            repeat (1) @ (negedge clock);
        end
    end

    always #5ns begin
        clock = ~clock;
    end
endmodule

module monitor(fifo_if fifo_actual, fifo_if fifo_model, input logic clock, logic resetn);
    always_ff @(posedge clock) begin
        if (fifo_actual.data_out !== fifo_model.data_out) begin
            $display("mismatch at %t", $time);
            $display("    actual = %p", fifo_actual);
            $display("    model  = %p", fifo_model);
        end
    end
endmodule

module tb_fifo();
    logic clock, resetn;
    fifo_if #(.width(8), .length(4)) fifo_actual(), fifo_model();
    driver driver(fifo_actual, fifo_model, clock, resetn);
    fifo fifo(fifo_actual, clock, resetn);
    fifo_model model(fifo_model, clock, resetn);
    monitor monitor(fifo_actual, fifo_model, clock, resetn);
endmodule
