class buff_uart_tx_agent_top extends uvm_env;
  `uvm_component_utils(buff_uart_tx_agent_top)

  buff_uart_tx_agent tx_agent;
  env_config env_conf;

  function new(string name = "buff_uart_tx_agent_top", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(env_config)::get(this, "", "env_config", env_conf))
      `uvm_fatal("CONFIG_ENV", "cannot get() env_config from uvm_config_db. Have you set() it?")

    uvm_config_db#(buff_uart_tx_config)::set(this, "tx_agent*", "buff_uart_tx_config",
                                             env_conf.rx_conf);
    tx_agent = buff_uart_tx_agent::type_id::create("tx_agent", this);
    super.build_phase(phase);
  endfunction
endclass : buff_uart_tx_agent_top
