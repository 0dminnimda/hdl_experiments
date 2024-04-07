`timescale 1us / 1us

`include "uvm.sv"
`include "uvm_macros.svh"
import uvm_pkg::*;

`define randomize_eh(transaction) \
 if (!(transaction.randomize())) begin \
    `uvm_error(get_type_name(), "Randomization failed for " + transaction.get_type_name()) \
 end  

`define randomize_with_eh(transaction, constraints) \
 if (!(transaction.randomize() with constraints)) begin \
    `uvm_error(get_type_name(), "Randomization with constraints failed for " + transaction.get_type_name()) \
 end

`ifndef EDAPLAYGROUND
`include "../../buff_uart.sv"
`else
`include "buff_uart.sv"
`endif

`include "env.sv"
`include "buff_uart_tx_agent.sv"
`include "buff_uart_rx_agent.sv"
`include "base_test.sv"


module top;
  import uvm_pkg::*;

  buff_uart_if #(
      .rx_address('d3),
      .tx_address('d4)
  ) bui ();
  logic clock, resetn;

  buff_uart dut (
      bui,
      clock,
      resetn
  );

  localparam nanoseconds_in_second = 10 ** 9;
  localparam clock_period = nanoseconds_in_second / bui.clock_freq;

  initial begin
    clock = 0;
    forever #(clock_period / 2) clock = ~clock;
  end

  initial begin
    uvm_config_db#(virtual buff_uart_if)::set(null, "*", "buff_uart_if", bui);

    uvm_top.finish_on_completion = 1;

    run_test("base_test");
  end

endmodule : top
