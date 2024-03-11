class buff_uart_tx_sequence_item extends uvm_sequence_item;
  rand bit tx;

  `uvm_object_utils_begin(buff_uart_tx_sequence_item)
    `uvm_field_int(tx, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "buff_uart_tx_sequence_item");
    super.new(name);
  endfunction

endclass : buff_uart_tx_sequence_item
