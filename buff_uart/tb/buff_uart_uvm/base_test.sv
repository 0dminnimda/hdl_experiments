class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  virtual buff_uart_if vif;
  uart_env envh;
  env_config env_conf;

  function new(string name = "base_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void configuration();
    env_conf.tx_conf = buff_uart_tx_config::type_id::create("tx_conf");
    if (!uvm_config_db#(virtual buff_uart_if)::get(
            this, "", "vif", env_conf.tx_conf.vif
        ))
      `uvm_fatal("VIF CONFIG", "cannot get() interface vif from uvm_config_db. Have you set() it?")

    env_conf.rx_conf = buff_uart_rx_config::type_id::create("rx_conf");
    if (!uvm_config_db#(virtual buff_uart_if)::get(
            this, "", "vif", env_conf.rx_conf.vif
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
    buff_uart_rx_sequence recv_seq;
    recv_seq = new("recv_seq");
    phase.raise_objection(this);
    recv_seq.start(envh.rx_top.rx_agent.m_sequencer);
    repeat (8) begin
      one_cycle();
    end
    phase.drop_objection(this);
  endtask

  task one_cycle();
      buff_uart_rx_sequence seq = buff_uart_rx_sequence::type_id::create("seq");  
      `randomize_with_eh(seq, {data inside {[0:2**8-1]};})

      seq.start(m_sequencer, this);
  endtask

  virtual function void end_of_elaboration();
    //print's the topology
    print();
  endfunction
endclass : base_test

