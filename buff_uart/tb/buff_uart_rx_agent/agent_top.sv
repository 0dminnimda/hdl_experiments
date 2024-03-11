class buff_uart_rx_agent_top extends uvm_env;
  `uvm_component_utils(buff_uart_rx_agent_top)

  buff_uart_rx_agent rx_agent;
  env_config env_conf;

  function new(string name = "buff_uart_rx_agent_top", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(env_config)::get(this, "", "env_config", env_conf))
      `uvm_fatal("CONFIG_ENV", "cannot get() env_config from uvm_config_db. Have you set() it?")

    uvm_config_db#(buff_uart_rx_config)::set(this, "rx_agent*", "buff_uart_rx_config",
                                             env_conf.rx_conf);
    rx_agent = buff_uart_rx_agent::type_id::create("rx_agent", this);
    super.build_phase(phase);
  endfunction
endclass : buff_uart_rx_agent_top
