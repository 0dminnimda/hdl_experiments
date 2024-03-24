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

class buff_uart_tx_config extends uvm_object;
  `uvm_object_utils(buff_uart_tx_config)

  virtual buff_uart_if vif;

  function new(string name = "buff_uart_tx_config");
    super.new(name);
  endfunction
endclass

class buff_uart_tx_driver extends uvm_driver #(buff_uart_tx_sequence_item);
  `uvm_component_utils(buff_uart_tx_driver)

  function new(string name = "buff_uart_tx_driver", uvm_component parent);
    super.new(name, parent);
  endfunction
endclass : buff_uart_tx_driver

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

class buff_uart_tx_sequence extends uvm_sequence #(buff_uart_tx_sequence_item);
  `uvm_object_utils(buff_uart_tx_sequence)

  buff_uart_tx_sequence_item req;

  function new(string name = "buff_uart_tx_sequence");
    super.new(name);
  endfunction

  task body();
    req = uart_transmitter_sequence_item::type_id::create("req");
    `uvm_do_with(req, {send_req == 1; act == RESET; din == 8'b11001100;})
    `uvm_do_with(req, {send_req == 1; din == 8'b11001101; })
    #5;
    `uvm_do_with(req, {send_req == 1; din == 8'b11000011; })
    // `uvm_do_with(req, {send_req == 1; din == 8'b01010101; })
    // `uvm_do_with(req, {send_req == 1; din == 8'b00000000; })
    // `uvm_do_with(req, {send_req == 1; din == 8'b10000001; })
    // `uvm_do_with(req, {send_req == 1; din == 8'b10011001; })
    // `uvm_do_with(req, {send_req == 0; act == RESET; })
    // repeat(10) begin
    //   req = uart_transmitter_sequence_item::type_id::create("req");
    //   start_item(req);
    //   assert(req.randomize());
    //   finish_item(req);
    //   end
    // for(int i = 5; i < 256; i += 16) begin
    //   `uvm_do_with(req, { din == i; act == NORMAL; })
    // end
  endtask
endclass : buff_uart_tx_sequence

class buff_uart_tx_sequence_item extends uvm_sequence_item;
  rand bit tx;

  `uvm_object_utils_begin(buff_uart_tx_sequence_item)
    `uvm_field_int(tx, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "buff_uart_tx_sequence_item");
    super.new(name);
  endfunction

endclass : buff_uart_tx_sequence_item

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
