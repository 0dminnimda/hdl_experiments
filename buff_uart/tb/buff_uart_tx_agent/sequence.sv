class buff_uart_tx_sequence extends uvm_sequence #(buff_uart_tx_sequence_item);
  `uvm_object_utils(buff_uart_tx_sequence)

  buff_uart_tx_sequence_item req;

  function new(string name = "buff_uart_tx_sequence");
    super.new(name);
  endfunction

  task body();
    req = uart_transmitter_sequence_item::type_id::create("req");
    `uvm_do_with(req, {send_req == 1; act == RESET; din == 8'b11001100;})
    `uvm_do_with(req, {send_req == 1; din == 8'b11001101; })
    #5;
    `uvm_do_with(req, {send_req == 1; din == 8'b11000011; })
    // `uvm_do_with(req, {send_req == 1; din == 8'b01010101; })
    // `uvm_do_with(req, {send_req == 1; din == 8'b00000000; })
    // `uvm_do_with(req, {send_req == 1; din == 8'b10000001; })
    // `uvm_do_with(req, {send_req == 1; din == 8'b10011001; })
    // `uvm_do_with(req, {send_req == 0; act == RESET; })
    // repeat(10) begin
    //   req = uart_transmitter_sequence_item::type_id::create("req");
    //   start_item(req);
    //   assert(req.randomize());
    //   finish_item(req);
    //   end
    // for(int i = 5; i < 256; i += 16) begin
    //   `uvm_do_with(req, { din == i; act == NORMAL; })
    // end
  endtask

endclass : buff_uart_tx_sequence
