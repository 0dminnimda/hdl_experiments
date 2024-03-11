class env_config extends uvm_object;
  `uvm_object_utils(env_config)

  virtual buff_uart_if vif;
  buff_uart_tx_config tx_conf;
  buff_uart_rx_config rx_conf;

  function new(string name = "env_config");
    super.new(name);
  endfunction : new
endclass : env_config
