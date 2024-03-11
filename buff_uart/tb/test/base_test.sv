class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  virtual buff_uart_if vif;
  uart_env envh;
  env_config env_conf;
  buff_uart_tx_config tx_conf;
  buff_uart_rx_config rx_conf;

  function new(string name = "base_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void configuration();
    env_conf.tx_conf = buff_uart_tx_config::type_id::create("tx_conf");
    if (!uvm_config_db#(virtual buff_uart_if)::get(
            this, "", $sformatf("vif_%0d", i), env_conf.tx_conf.vif
        ))
      `uvm_fatal("VIF CONFIG", "cannot get() interface vif from uvm_config_db. Have you set() it?")

    env_conf.rx_conf = buff_uart_rx_config::type_id::create("rx_conf");
    if (!uvm_config_db#(virtual buff_uart_if)::get(
            this, "", $sformatf("vif_%0d", i), env_conf.rx_conf.vif
        ))
      `uvm_fatal("VIF CONFIG", "cannot get() interface vif from uvm_config_db. Have you set() it?")
  endfunction

  function void build_phase(uvm_phase phase);
    env_conf = env_config::type_id::create("env_conf");
    configuration();
    super.build_phase(phase);
    uvm_config_db#(env_config)::set(this, "*", "env_config", env_conf);
    envh = uart_env::type_id::create("envh", this);
  endfunction

  task run_phase(uvm_phase phase);
    buff_uart_tx_sequence send_req;
    buff_uart_rx_sequence recv_req;
    send_req = new("send_seq");
    recv_req = new("recv_req");
    phase.raise_objection(this);
    send_req.start(envh.tx_top.tx_agent.m_sequencer);
    recv_req.start(envh.rx_top.rx_agent.m_sequencer);
    phase.drop_objection(this);
  endtask

  virtual function void end_of_elaboration();
    //print's the topology
    print();
  endfunction
endclass : base_test
