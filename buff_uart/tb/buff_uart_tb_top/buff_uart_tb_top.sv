`include "uvm.sv"
`include "uvm_macros.svh"
import uvm_pkg::*;

`include "../env/env_config.sv"
`include "../env/uart_env.sv"

`include "../buff_uart_tx_agent/buff_uart_tx_sequence_item.sv"
`include "../buff_uart_tx_agent/buff_uart_tx_config.sv"
`include "../buff_uart_tx_agent/buff_uart_tx_driver.sv"
`include "../buff_uart_tx_agent/buff_uart_tx_monitor.sv"
`include "../buff_uart_tx_agent/buff_uart_tx_sequencer.sv"
`include "../buff_uart_tx_agent/buff_uart_tx_agent.sv"
`include "../buff_uart_tx_agent/buff_uart_tx_agent_top.sv"
`include "../buff_uart_tx_agent/buff_uart_tx_sequence.sv"

`include "../buff_uart_rx_agent/buff_uart_rx_sequence_item.sv"
`include "../buff_uart_rx_agent/buff_uart_rx_config.sv"
`include "../buff_uart_rx_agent/buff_uart_rx_driver.sv"
`include "../buff_uart_rx_agent/buff_uart_rx_monitor.sv"
`include "../buff_uart_rx_agent/buff_uart_rx_sequencer.sv"
`include "../buff_uart_rx_agent/buff_uart_rx_sequence.sv"
`include "../buff_uart_rx_agent/buff_uart_rx_agent.sv"
`include "../buff_uart_rx_agent/buff_uart_rx_agent_top.sv"

`include "../test/base_test.sv"

`timescale 1us / 1us

module buff_uart_tb_top;
  uvm_root _UVM_Root;

  buff_uart_if #(
      .rx_address('d3),
      .tx_address('d4)
  ) bui ();

  localparam nanoseconds_in_second = 10 ** 9;
  localparam clock_period = nanoseconds_in_second / bui.clock_freq;

  always #(clock_period / 2) begin
    bui.clock = ~bui.clock;
  end

  buff_uart dut (bui);

  initial begin
    bui.clock = 0;
  end

  initial begin
    _UVM_Root = uvm_root::get();
    // factory.print();
    uvm_config_db#(virtual uart_interface)::set(null, "*", "vif_0", intf);
    _UVM_Root.run_test("base_test");
  end
endmodule
