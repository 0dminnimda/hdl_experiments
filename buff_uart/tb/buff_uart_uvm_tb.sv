`include "uvm_macros.svh"
`include "../buff_uart.sv"

package my_pkg;

  import uvm_pkg::*;

  class my_transaction extends uvm_sequence_item #(parameter address_width = 4);
  
    `uvm_object_utils(my_transaction)

    rand bit rx;

    rand bit read_enable;
    rand bit write_enable;

    rand bit [address_width-1:0] active_address;
  
    // constraint c_active_address { active_address >= 0; active_address < 256; }

    function new (string name = "");
      super.new(name);
    endfunction

    function string convert2string;
      return $sformatf("rx=%b, re=%b, we=%b", rx, read_enable, write_enable);  // active_address
    endfunction

    function void do_copy(uvm_object rhs);
      my_transaction tract;
      $cast(tract, rhs);
      rx  = tract.rx;
      read_enable = tract.read_enable;
      write_enable = tract.write_enable;
      active_address = tract.active_address;
    endfunction
    
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      my_transaction tract;
      bit status = 1;
      $cast(tract, rhs);
      status &= (rx == tract.rx);
      status &= (read_enable == tract.read_enable);
      status &= (write_enable == tract.write_enable);
      status &= (active_address == tract.active_address);
      return status;
    endfunction

  endclass: my_transaction

  class my_config extends uvm_object;

    rand int count;

    constraint c_count { count > 0; count < 128; }

  endclass: my_config


  typedef uvm_sequencer #(my_transaction) my_sequencer;


  class my_sequence extends uvm_sequence #(my_transaction);

    `uvm_object_utils(my_sequence)

    function new (string name = "");
      super.new(name);
    endfunction

    task body;
      if (starting_phase != null)
        starting_phase.raise_objection(this);

      my_config cfg;
      int count;

      if ( uvm_config_db #(my_config)::get(p_sequencer, "", "config", cfg) ) begin
        count = cfg.count;
      end else begin
        count = 1;
      end

      for (int i = 0; i < count; i++) begin
        req = my_transaction::type_id::create("req");
        start_item(req);
        if( !req.randomize() )
          `uvm_error("", "Randomize failed")
        finish_item(req);
      end

      if (starting_phase != null)
        starting_phase.drop_objection(this);
    endtask: body
   
  endclass: my_sequence

  class my_driver extends uvm_driver #(my_transaction);
  
    `uvm_component_utils(my_driver)

    virtual buff_uart_if dut_vi;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      if( !uvm_config_db #(virtual buff_uart_if)::get(this, "", "buff_uart_if", dut_vi) )
        `uvm_error("", "uvm_config_db::get failed")
    endfunction 

    task run_phase(uvm_phase phase);
      forever
      begin
        seq_item_port.get_next_item(req);

        dut_vi.rx  = req.rx;
        dut_vi.read_enable = req.read_enable;
        dut_vi.write_enable = req.write_enable;
        dut_vi.active_address = req.active_address;
        @(posedge dut_vi.clock);

        seq_item_port.item_done();
      end
    endtask

  endclass: my_driver

  class my_env extends uvm_env;

    `uvm_component_utils(my_env)

    my_sequencer m_seqr;
    my_driver m_driv;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
 
    function void build_phase(uvm_phase phase);
      m_seqr = my_sequencer::type_id::create("m_seqr", this);
      m_driv = my_driver::type_id::create("m_driv", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
      m_driv.seq_item_port.connect( m_seqr.seq_item_export );
    endfunction
    
  endclass: my_env

  class my_test extends uvm_test;
  
    `uvm_component_utils(my_test)
    
    my_env m_env;
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      m_env = my_env::type_id::create("m_env", this);
    endfunction
    
    task run_phase(uvm_phase phase);
      my_config cfg;
      my_sequence seq;
      uvm_component component;
      my_sequencer sequencer;

      cfg = new;
      if ( !cfg.randomize() )
        `uvm_error("", "Randomize failed")
      uvm_config_db #(my_config)::set(this, "*.m_seqr", "config", cfg);
      
      seq = my_sequence::type_id::create("seq");
      if( !seq.randomize() ) 
        `uvm_error("", "Randomize failed")
      seq.starting_phase = phase;

      component = uvm_top.find("*.m_seqr");
      if ($cast(sequencer, component))
        seq.start(sequencer);
    endtask
     
  endclass: my_test

endpackage: my_pkg


module top;

  import uvm_pkg::*;
  import my_pkg::*;
  
  
  buff_uart_if #(.rx_address('d3), .tx_address('d4)) bui();
  logic clock, resetn;

  buff_uart dut(bui, clock, resetn);

  localparam ticks_per_bit = bui.clock_freq / bui.baud_rate;

  logic [bui.width-1:0] check_data [1:0];
  logic check_clock;

  localparam nanoseconds_in_second = 10**9;
  localparam clock_period = nanoseconds_in_second / bui.clock_freq;

  initial begin
    dut_if1.clock = 0;
    forever #(clock_period / 2) clock = ~clock;
  end

  initial begin
    uvm_config_db #(virtual buff_uart_if)::set(null, "*", "buff_uart_if", bui);

    uvm_top.finish_on_completion = 1;

    run_test("my_test");
  end

endmodule: top
