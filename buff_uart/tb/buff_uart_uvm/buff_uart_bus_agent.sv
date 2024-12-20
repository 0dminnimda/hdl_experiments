class buff_uart_bus_agent extends uvm_agent;
  `uvm_component_utils(buff_uart_bus_agent)

  buff_uart_bus_config conf;
  buff_uart_bus_driver drvh;
  buff_uart_bus_monitor monh;
  buff_uart_bus_sequencer m_sequencer;

  function new(string name = "buff_uart_bus_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(buff_uart_bus_config)::get(this, "", "buff_uart_bus_config", conf))
      `uvm_fatal("CONFIG", "cannot get() conf from uvm_config_db. Have you set it?")

    monh = buff_uart_bus_monitor::type_id::create("monh", this);
    drvh = buff_uart_bus_driver::type_id::create("drvh", this);
    m_sequencer = buff_uart_bus_sequencer::type_id::create("m_sequencer", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    drvh.seq_item_port.connect(m_sequencer.seq_item_export);
  endfunction
endclass : buff_uart_bus_agent

class buff_uart_bus_agent_top extends uvm_env;
  `uvm_component_utils(buff_uart_bus_agent_top)

  buff_uart_bus_agent bus_agent;
  env_config env_conf;

  function new(string name = "buff_uart_bus_agent_top", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(env_config)::get(this, "", "env_config", env_conf))
      `uvm_fatal("CONFIG_ENV", "cannot get() env_config from uvm_config_db. Have you set() it?")

    uvm_config_db#(buff_uart_bus_config)::set(this, "bus_agent*", "buff_uart_bus_config",
                                              env_conf.bus_conf);
    bus_agent = buff_uart_bus_agent::type_id::create("bus_agent", this);
    super.build_phase(phase);
  endfunction
endclass : buff_uart_bus_agent_top

class buff_uart_bus_config extends uvm_object;
  `uvm_object_utils(buff_uart_bus_config)

  virtual buff_uart_if vif;

  function new(string name = "buff_uart_bus_config");
    super.new(name);
    ticks_per_bit_min = ticks_per_bit + ticks_per_bit * 100 / ticks_variation_percentage;
    ticks_per_bit_max = ticks_per_bit - ticks_per_bit * 100 / ticks_variation_percentage;
  endfunction

  function void connect_phase(uvm_phase phase);
    ticks_per_bit = conf.vif.clock_freq / conf.vif.baud_rate;
  endfunction
endclass

typedef uvm_tlm_analysis_fifo#(buff_uart_bus_sequence_item) buff_uart_bus_analysis_fifo;

class buff_uart_bus_driver extends uvm_driver #(buff_uart_bus_sequence_item);
  `uvm_component_utils(buff_uart_bus_driver)

  virtual buff_uart_if vif;
  buff_uart_bus_analysis_fifo als_fifo;
  buff_uart_bus_config conf;

  function new(string name = "buff_uart_bus_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(buff_uart_bus_config)::get(this, "", "buff_uart_bus_config", conf))
      `uvm_fatal("CONFIG", "Cannot get() conf from uvm_config_db. Have you set() it?")
  endfunction

  function void connect_phase(uvm_phase phase);
    vif = conf.vif;
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    @(negedge vif.clock) begin
      bui.resetn <= 0;
    end

    forever begin
      buff_uart_bus_sequence_item req;
      seq_item_port.get_next_item(req);
      drive_data(req);
      // req.print();
      seq_item_port.item_done();
    end
  endtask

  task drive_data(buff_uart_bus_sequence_item req);
    vif.bus <= req.bus;
    repeat (req.period) @(posedge vif.clock);
  endtask
endclass : buff_uart_bus_driver

class buff_uart_bus_monitor extends uvm_monitor;
  `uvm_component_utils(buff_uart_bus_monitor)

  virtual buff_uart_if vif;
  buff_uart_bus_config conf;
  buff_uart_bus_analysis_fifo als_fifo;
  buff_uart_bus_sequence_item data_recv;

  function new(string name = "buff_uart_bus_monitor", uvm_component parent);
    super.new(name, parent);
    als_fifo = new("als_fifo", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(buff_uart_bus_config)::get(this, "", "buff_uart_bus_config", conf))
      `uvm_fatal("CONFIG", "Cannot get() conf from uvm_config_db. Have you set() it?")
  endfunction

  function void connect_phase(uvm_phase phase);
    vif = conf.vif;
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(negedge vif.clk);
      if (!vif.reset_n && vif.rx_fifo_not_empty) begin
        if (prev != vif.tx && count) begin
          data_recv = buff_uart_tx_sequence_item::type_id::create("data_recv");
          data_recv.tx = vif.tx;
          data_recv.count = count;
          monitor_port.write(data_recv);
        end
        count = count + 1;
      end
      //   data_recv = buff_uart_tx_sequence_item::type_id::create("data_recv");
      //   if (vif.rx_fifo_not_empty)
      // //   `RX_ADDRESS
      // // `TX_ADDRESS
      // //   get_and_drain_items(data_recv);
      //   analysis_fifo.write(data_recv);
    end

    // bit prev = 0;
    // int count = 0;
    // forever begin
    //   @(negedge vif.clk);
    //   if (vif.reset_n) begin
    //     count = 0;
    //   end else begin
    //     if (prev != vif.tx && count) begin
    //       data_recv = buff_uart_tx_sequence_item::type_id::create("data_recv");
    //       data_recv.tx = vif.tx;
    //       data_recv.count = count;
    //       monitor_port.write(data_recv);
    //     end
    //     count = count + 1;
    //   end
    // end
  endtask
endclass : buff_uart_bus_monitor

class buff_uart_bus_sequence extends uvm_sequence #(buff_uart_bus_sequence_item);
  `uvm_object_utils(buff_uart_bus_sequence)

  rand int data;
  buff_uart_bus_config conf;
  buff_uart_bus_sequence_item req;

  function new(string name = "buff_uart_bus_sequence");
    super.new(name);
  endfunction

  task body();
    if (!uvm_config_db#(buff_uart_bus_config)::get(this, "", "buff_uart_bus_config", conf))
      `uvm_fatal("CONFIG", "Cannot get() conf from uvm_config_db. Have you set() it?")

    forever begin
      req = buff_uart_bus_sequence_item::type_id::create("req");
      start_item(req);

      `randomize_with_eh(req, {period inside {[conf.ticks_per_bit_min : conf.ticks_per_bit_max]};})
      // if (!req.randomize() with {period inside {[conf.ticks_per_bit_min : conf.ticks_per_bit_max]};}) begin
      //   `uvm_error("RANDOMIZE_FAILED", "Randomization failed for buff_uart_bus_sequence_item")
      // end
      req.bit = seed[i];

      finish_item(req);
    end
  endtask

endclass : buff_uart_bus_sequence

typedef enum logic [0:0] {READ, WRITE} BUS_DIRECTION;

class buff_uart_bus_sequence_item extends uvm_sequence_item;
  logic [ADDRESS_WIDTH-1:0] address;
  BUS_DIRECTION direction;

  `uvm_object_utils_begin(buff_uart_bus_sequence_item)
    `uvm_field_int(address, UVM_ALL_ON)
    `uvm_field_enum(BUS_DIRECTION, direction, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "buff_uart_bus_sequence_item");
    super.new(name);
  endfunction

endclass : buff_uart_bus_sequence_item

typedef uvm_sequencer#(buff_uart_bus_sequence_item) buff_uart_bus_sequencer;
