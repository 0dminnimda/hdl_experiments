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
    drvh.seq_item_port.connect(m_sequencer.seq_item_export);
  endfunction
endclass : buff_uart_rx_agent

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

class buff_uart_rx_config extends uvm_object;
  `uvm_object_utils(buff_uart_rx_config)

  virtual buff_uart_if vif;

  function new(string name = "buff_uart_rx_config");
    super.new(name);
  endfunction
endclass

class buff_uart_rx_driver extends uvm_driver #(buff_uart_rx_sequence_item);
  `uvm_component_utils(buff_uart_rx_driver)

  virtual buff_uart_if vif;
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

class buff_uart_rx_monitor extends uvm_monitor;
  `uvm_component_utils(buff_uart_rx_monitor)

  virtual buff_uart_if vif;
  buff_uart_rx_config conf;
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
    data_recv = buff_uart_rx_sequence_item::type_id::create("data_recv");
    @(negedge vif.clk);
    if (!vif.reset_n) begin
      data_recv.rx <= vif.rx;
      monitor_port.write(data_recv);
    end
  endtask
endclass : buff_uart_rx_monitor

class buff_uart_rx_sequence extends uvm_sequence #(buff_uart_rx_sequence_item);
  `uvm_object_utils(buff_uart_rx_sequence)

  buff_uart_rx_sequence_item req;

  function new(string name = "buff_uart_rx_sequence");
    super.new(name);
  endfunction

  task body();
    req = buff_uart_rx_sequence_item::type_id::create("req");
    `uvm_do_with(req, { rx_sample == 8'b10110110; act == RESET; })
    `uvm_do_with(req, { rx_sample == 8'b01010101; act == NORMAL; })
    `uvm_do_with(req, { rx_sample == 8'b01001001; act == NORMAL; })
    // `uvm_do_with(req, { rx_sample == 8'b11111111; act == NORMAL; })
    // `uvm_do_with(req, { recv_ack == 0; rx_sample == 8'b11110000; act == RESET; })
    // repeat(10) begin
    //   req = buff_uart_rx_sequence_item::type_id::create("req");
    //   start_item(req);
    //   assert(req.randomize());
    //   finish_item(req);
    //   end
    // for(int i = 5; i < 256; i += 16) begin
    //   `uvm_do_with(req, { rx_sample == i; act == NORMAL; })
    // end
  endtask

endclass : buff_uart_rx_sequence

class buff_uart_rx_sequence_item extends uvm_sequence_item;
  rand bit rx;

  `uvm_object_utils_begin(buff_uart_rx_sequence_item)
    `uvm_field_int(rx, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "buff_uart_rx_sequence_item");
    super.new(name);
  endfunction

endclass : buff_uart_rx_sequence_item

class buff_uart_rx_sequencer extends uvm_sequencer #(buff_uart_rx_sequence_item);
  `uvm_component_utils(buff_uart_rx_sequencer)

  virtual buff_uart_if vif;
  buff_uart_rx_config  conf;

  function new(string name = "buff_uart_rx_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(buff_uart_rx_config)::get(this, "", "buff_uart_rx_config", conf))
      `uvm_fatal("CONFIG", "Cannot get() conf from uvm_config_db. Have you set() it?")
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.vif = conf.vif;
  endfunction

endclass : buff_uart_rx_sequencer
