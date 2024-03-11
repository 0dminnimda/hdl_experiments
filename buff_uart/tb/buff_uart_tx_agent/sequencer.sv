class buff_uart_tx_sequencer extends uvm_sequencer #(buff_uart_tx_sequence_item);
  `uvm_component_utils(buff_uart_tx_sequencer)

  virtual buff_uart_if vif;
  buff_uart_tx_config conf;

  function new(string name = "buff_uart_tx_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(buff_uart_tx_config)::get(this, "", "buff_uart_tx_config", conf))
      `uvm_fatal("CONFIG", "Cannot get() conf from uvm_config_db. Have you set() it?")
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.vif = conf.vif;
  endfunction

endclass: buff_uart_tx_sequencer
