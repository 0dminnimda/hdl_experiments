class uart_env extends uvm_env;
  `uvm_component_utils(uart_env)

  env_config env_conf;
  buff_uart_tx_agent_top tx_top;
  buff_uart_rx_agent_top rx_top;

  function new(string name = "uart_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(env_config)::get(this, "", "env_config", env_conf))
      `uvm_fatal("CONFIG", "Cannot get() env_conf  from uvm_config")
    super.build_phase(phase);

    tx_top = buff_uart_tx_agent_top::type_id::create("tx_top", this);
    rx_top = buff_uart_rx_agent_top::type_id::create("rx_top", this);
  endfunction
endclass
