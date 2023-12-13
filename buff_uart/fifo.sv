`include "if/fifo_if.sv"

module fifo(fifo_if.DUT fifo_if);
    localparam size_width = $clog2(fifo_if.length);

    logic [fifo_if.width-1:0] queued [fifo_if.length-1:0];
    logic [size_width:0] size;  // intentionally +1 bit to store the fifo_if.length indicating the full state

    assign fifo_if.full = (size >= fifo_if.length);
    assign fifo_if.empty = (size == 0);

    logic can_read, can_write;

    assign can_read = fifo_if.read_enable && !fifo_if.full;
    assign can_write = fifo_if.write_enable && !fifo_if.empty;

    integer i;

    always_ff @(posedge fifo_if.clock, posedge fifo_if.resetn) begin
        if (!fifo_if.resetn) begin
            size <= 0;
            fifo_if.data_out <= 0;
        end else begin
            if (fifo_if.read_enable && fifo_if.write_enable) begin
                if (can_read && can_write) begin
                    for (i = 0; i < size - 1; i = i + 1) begin
                        queued[i] <= queued[i+1];
                    end
                    queued[size - 1] <= fifo_if.data_in;
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
                for (i = 0; i < fifo_if.length - 1; i = i + 1) begin
                    queued[i] <= queued[i+1];
                end
                size <= size - 1;
                fifo_if.data_out <= queued[0];
            end else begin
                fifo_if.data_out <= 0;
            end
        end
    end
endmodule

module fifo_model(fifo_if.DUT fifo_if);
    logic [fifo_if.width-1:0] queued [$:fifo_if.length];

    assign fifo_if.full = (queued.size() >= fifo_if.length);
    assign fifo_if.empty = (queued.size() == 0);

    logic can_read, can_write;

    assign can_read = fifo_if.read_enable && !fifo_if.full;
    assign can_write = fifo_if.write_enable && !fifo_if.empty;

    always_ff @(posedge fifo_if.clock, posedge fifo_if.resetn) begin
        if (!fifo_if.resetn) begin
            queued.delete();
            fifo_if.data_out <= 0;
        end else begin
            if (fifo_if.read_enable && fifo_if.write_enable) begin
                if (can_read && can_write) begin
                    fifo_if.data_out <= queued.pop_front();
                    queued.push_back(fifo_if.data_in);
                end else begin
                    // do not allow to do one action when two are requested
                    // thus do no actions
                    fifo_if.data_out <= 0;
                end
            end else if (can_read) begin
                queued.push_back(fifo_if.data_in);
                fifo_if.data_out <= 0;
            end else if (can_write) begin
                fifo_if.data_out <= queued.pop_front();
            end else begin
                fifo_if.data_out <= 0;
            end
        end
    end
endmodule
