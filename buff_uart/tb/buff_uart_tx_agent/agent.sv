class buff_uart_tx_agent extends uvm_agent;
  `uvm_component_utils(buff_uart_tx_agent)

  buff_uart_tx_config conf;
  buff_uart_tx_driver drvh;
  buff_uart_tx_monitor monh;
  buff_uart_tx_sequencer m_sequencer;

  function new(string name = "buff_uart_tx_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(buff_uart_tx_config)::get(this, "", "buff_uart_tx_config", conf))
      `uvm_fatal("CONFIG", "cannot get() conf from uvm_config_db. Have you set it?")

    monh = buff_uart_tx_monitor::type_id::create("monh", this);
  endfunction
endclass : buff_uart_tx_agent
