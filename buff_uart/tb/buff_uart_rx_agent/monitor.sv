class buff_uart_rx_monitor extends uvm_monitor;
  `uvm_component_utils(buff_uart_rx_monitor)

  virtual buff_uart_if vif;
  buff_uart_rx_config conf;
  buff_uart_rx_driver driver;
  buff_uart_rx_sequence_item data_recv;

  uvm_analysis_port #(buff_uart_rx_sequence_item) monitor_port;

  function new(string name = "buff_uart_rx_monitor", uvm_component parent);
    super.new(name, parent);
    monitor_port = new("monitor_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(buff_uart_rx_config)::get(this, "", "buff_uart_rx_config", conf))
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
    forever begin
      data_recv = buff_uart_rx_sequence_item::type_id::create("data_recv");
      @(negedge vif.clk);
      if (!vif.reset_n) begin
        data_recv.reset_n  <= vif.reset_n;
        data_recv.rx       <= vif.rx;
        data_recv.recv_req <= vif.recv_req;
        data_recv.recv_ack <= vif.recv_ack;
        repeat ((vif.bit_time) / 2) @(posedge vif.clk);
        for (int i = 0; i < 8; i++) begin
          data_recv.dout[i] <= vif.rx;
          repeat (vif.bit_time) @(posedge vif.clk);
        end
        monitor_port.write(data_recv);
      end
    end
  endtask
endclass : buff_uart_rx_monitor
