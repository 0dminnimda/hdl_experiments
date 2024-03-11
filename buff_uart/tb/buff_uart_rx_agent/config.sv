class buff_uart_rx_config extends uvm_object;
  `uvm_object_utils(buff_uart_rx_config)

  virtual uart_interface vif;

  function new(string name = "buff_uart_rx_config");
    super.new(name);
  endfunction
endclass
