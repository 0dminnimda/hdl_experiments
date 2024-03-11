class uart_env extends uvm_env;
  `uvm_component_utils(uart_env)

  virtual uart_interface vif;
  buff_uart_tx_sequencer tx_seqr;
  buff_uart_rx_sequencer rx_seqr;
  env_config env_conf;
  buff_uart_tx_agent_top tx_top;
  buff_uart_rx_agent_top rx_top;
  virtual_sequencer v_seqrh;

  function new(string name = "uart_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(env_config)::get(this, "", "env_config", env_conf))
      `uvm_fatal("CONFIG", "Cannot get() env_conf  from uvm_config")
    super.build_phase(phase);

    vif = env_conf.vif;
    wtop = buff_uart_tx_agent_top::type_id::create("wtop", this);
    rtop = buff_uart_rx_agent_top::type_id::create("rtop", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    tx_seqr = tx_top.tx_agent.m_sequencer;
    rx_seqr = rx_top.rx_agent.m_sequencer;
  endfunction
endclass
