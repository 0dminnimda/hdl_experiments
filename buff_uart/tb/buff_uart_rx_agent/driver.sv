class buff_uart_rx_driver extends uvm_driver #(buff_uart_rx_sequence_item);
  `uvm_component_utils(buff_uart_rx_driver)

  virtual uart_interface vif;
  buff_uart_rx_config conf;
  int ticks_per_bit;

  function new(string name = "buff_uart_rx_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(buff_uart_rx_config)::get(this, "", "buff_uart_rx_config", conf))
      `uvm_fatal("CONFIG", "Cannot get() conf from uvm_config_db. Have you set() it?")
  endfunction

  function void connect_phase(uvm_phase phase);
    vif = conf.vif;
    ticks_per_bit = conf.vif.clock_freq / conf.vif.baud_rate;
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    @(negedge vif.clock) begin
      bui.resetn <= 0;
    end

    forever begin
      buff_uart_rx_sequence_item req;
      seq_item_port.get_next_item(req);
      drive_data(req);
      // req.print();
      seq_item_port.item_done();
    end
  endtask

  task drive_data(buff_uart_rx_sequence_item req);
    vif.rx <= req.rx;
    repeat (ticks_per_bit * 2) @(posedge vif.clock);
    // repeat (req.shift ($urandom_range(0, 5))) @(posedge vif.clock);
  endtask
endclass : buff_uart_rx_driver
