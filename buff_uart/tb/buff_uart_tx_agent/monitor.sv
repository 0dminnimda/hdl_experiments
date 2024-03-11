class buff_uart_tx_monitor extends uvm_monitor;
  `uvm_component_utils(buff_uart_tx_monitor)

  virtual buff_uart_if vif;
  buff_uart_tx_config conf;
  buff_uart_tx_sequence_item data_recv;

  uvm_analysis_port #(buff_uart_tx_sequence_item) monitor_port;

  function new(string name = "buff_uart_tx_monitor", uvm_component parent);
    super.new(name, parent);
    monitor_port = new("monitor_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(buff_uart_tx_config)::get(this, "", "buff_uart_tx_config", conf))
      `uvm_fatal("CONFIG", "Cannot get() conf from uvm_config_db. Have you set() it?")
  endfunction

  function void connect_phase(uvm_phase phase);
    vif = conf.vif;
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      collect_data();
    end
  endtask

  task collect_data();
    data_recv = buff_uart_tx_sequence_item::type_id::create("data_recv");
    @(negedge vif.clk);
    if (!vif.reset_n) begin
      data_recv.tx <= vif.tx;
      monitor_port.write(data_recv);
    end
  endtask
endclass : buff_uart_tx_monitor
