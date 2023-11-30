module our (clk);
   reg r0;
   initial r0 = 1'b1;
   input clk;  // Clock is required to get initial activation
   always @(posedge clk) begin
      r0 <= ~r0;
      $display(r0);
      $display("Hello World");
      // $finish;
   end
endmodule
