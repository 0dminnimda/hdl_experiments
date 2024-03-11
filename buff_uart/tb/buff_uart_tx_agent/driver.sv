class buff_uart_tx_driver extends uvm_driver #(buff_uart_tx_sequence_item);
  `uvm_component_utils(buff_uart_tx_driver)

  function new(string name = "buff_uart_tx_driver", uvm_component parent);
    super.new(name, parent);
  endfunction
endclass : buff_uart_tx_driver
