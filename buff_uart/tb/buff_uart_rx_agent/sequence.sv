class buff_uart_rx_sequence extends uvm_sequence #(buff_uart_rx_sequence_item);
  `uvm_object_utils(buff_uart_rx_sequence)

  buff_uart_rx_sequence_item req;

  function new(string name = "buff_uart_rx_sequence");
    super.new(name);
  endfunction

  task body();
    req = buff_uart_rx_sequence_item::type_id::create("req");
    `uvm_do_with(req, { rx_sample == 8'b10110110; act == RESET; })
    `uvm_do_with(req, { rx_sample == 8'b01010101; act == NORMAL; })
    `uvm_do_with(req, { rx_sample == 8'b01001001; act == NORMAL; })
    // `uvm_do_with(req, { rx_sample == 8'b11111111; act == NORMAL; })
    // `uvm_do_with(req, { recv_ack == 0; rx_sample == 8'b11110000; act == RESET; })
    // repeat(10) begin
    //   req = buff_uart_rx_sequence_item::type_id::create("req");
    //   start_item(req);
    //   assert(req.randomize());
    //   finish_item(req);
    //   end
    // for(int i = 5; i < 256; i += 16) begin
    //   `uvm_do_with(req, { rx_sample == i; act == NORMAL; })
    // end
  endtask

endclass : buff_uart_rx_sequence
