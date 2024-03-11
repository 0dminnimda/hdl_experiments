class buff_uart_rx_agent extends uvm_agent;
  `uvm_component_utils(buff_uart_rx_agent)

  buff_uart_rx_config conf;
  buff_uart_rx_driver drvh;
  buff_uart_rx_monitor monh;
  buff_uart_rx_sequencer m_sequencer;

  function new(string name = "buff_uart_rx_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(buff_uart_rx_config)::get(this, "", "buff_uart_rx_config", conf))
      `uvm_fatal("CONFIG", "cannot get() conf from uvm_config_db. Have you set it?")

    monh = buff_uart_rx_monitor::type_id::create("monh", this);
    drvh = buff_uart_rx_driver::type_id::create("drvh", this);
    m_sequencer = buff_uart_rx_sequencer::type_id::create("m_sequencer", this);
  endfunction


  function void connect_phase(uvm_phase phase);
    if (conf.is_active == UVM_ACTIVE) drvh.seq_item_port.connect(m_sequencer.seq_item_export);
  endfunction
endclass : buff_uart_rx_agent
