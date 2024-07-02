class buff_uart_tx_config extends uvm_object;
  `uvm_object_utils(buff_uart_tx_config)

  virtual buff_uart_if vif;

  function new(string name = "buff_uart_tx_config");
    super.new(name);
  endfunction
endclass

class buff_uart_tx_sequence_item extends uvm_sequence_item;
  bit tx;
  int period;

  `uvm_object_utils_begin(buff_uart_tx_sequence_item)
    `uvm_field_int(tx, UVM_ALL_ON)
    `uvm_field_int(period, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "buff_uart_tx_sequence_item");
    super.new(name);
  endfunction

endclass : buff_uart_tx_sequence_item

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
    bit prev = 0;
    int count = 0;
    forever begin
      @(negedge vif.clk);
      if (vif.reset_n) begin
        count = 0;
      end else begin
        if (prev != vif.tx && count) begin
          data_recv = buff_uart_tx_sequence_item::type_id::create("data_recv");
          data_recv.tx = vif.tx;
          data_recv.count = count;
          monitor_port.write(data_recv);
        end
        count = count + 1;
      end
    end
  endtask
endclass : buff_uart_tx_monitor

class buff_uart_tx_agent extends uvm_agent;
  `uvm_component_utils(buff_uart_tx_agent)

  buff_uart_tx_config conf;
  buff_uart_tx_driver drvh;
  buff_uart_tx_monitor monh;

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

