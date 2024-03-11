class buff_uart_rx_config extends uvm_object;
  `uvm_object_utils(buff_uart_rx_config)

  virtual buff_uart_if vif;

  function new(string name = "buff_uart_rx_config");
    super.new(name);
  endfunction
endclass
