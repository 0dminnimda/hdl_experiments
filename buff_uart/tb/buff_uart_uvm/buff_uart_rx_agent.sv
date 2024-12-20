class buff_uart_rx_sequence_item extends uvm_sequence_item;
  int bits;

  `uvm_object_utils_begin(buff_uart_rx_sequence_item)
    `uvm_field_int(bits, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "buff_uart_rx_sequence_item");
    super.new(name);
  endfunction

endclass : buff_uart_rx_sequence_item

typedef uvm_sequencer#(buff_uart_rx_sequence_item) buff_uart_rx_sequencer;

class buff_uart_rx_sequence extends uvm_sequence #(buff_uart_rx_sequence_item);
  `uvm_object_utils(buff_uart_rx_sequence)

  rand int data;
  buff_uart_rx_config conf;
  buff_uart_rx_sequence_item req;

  function new(string name = "buff_uart_rx_sequence");
    super.new(name);
  endfunction

  task body();
    if (!uvm_config_db#(buff_uart_rx_config)::get(null, get_full_name(), "buff_uart_rx_config", conf))
      `uvm_fatal("CONFIG", "Cannot get() conf from uvm_config_db. Have you set() it?")

    req = buff_uart_rx_sequence_item::type_id::create("req");
    req.bits = data;
    start_item(req);
    finish_item(req);
  endtask

endclass : buff_uart_rx_bit_sequence

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
    bit prev = 0;
    int count = 0;
    forever begin
      @(negedge vif.clock);
      if (vif.resetn) begin
        count = 0;
      end else begin
        if (prev != vif.rx && count) begin
          data_recv = buff_uart_rx_sequence_item::type_id::create("data_recv");
          data_recv.rx = vif.rx;
          monitor_port.write(data_recv);
        end
        count = count + 1;
      end
    end
  endtask
endclass : buff_uart_rx_monitor

class buff_uart_rx_driver extends uvm_driver #(buff_uart_rx_sequence_item);
  `uvm_component_utils(buff_uart_rx_driver)

  virtual buff_uart_if vif;
  buff_uart_rx_config conf;

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
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    @(negedge vif.clock) begin
      vif.resetn <= 0;
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
    for (int i = 0; i < 8; i += 1) begin
      req.rx = req.data[i];
    end
    repeat (req.period) @(posedge vif.clock);
  endtask
endclass : buff_uart_rx_driver

class buff_uart_rx_config extends uvm_object;
  `uvm_object_utils(buff_uart_rx_config)

  virtual buff_uart_if vif;
  int ticks_per_bit;
  int ticks_variation_percentage = 5;
  int ticks_per_bit_min;
  int ticks_per_bit_max;

  function new(string name = "buff_uart_rx_config");
    super.new(name);
    ticks_per_bit_min = ticks_per_bit + ticks_per_bit * 100 / ticks_variation_percentage;
    ticks_per_bit_max = ticks_per_bit - ticks_per_bit * 100 / ticks_variation_percentage;
  endfunction

  function void connect_phase(uvm_phase phase);
    ticks_per_bit = vif.clock_freq / vif.baud_rate;
  endfunction
endclass

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

