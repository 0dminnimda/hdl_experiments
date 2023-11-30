`timescale 1ns/1ps

module delays(input logic a, b);
   logic bb, n1, n2;
   assign #1ns bb = ~b;
   assign #2ns n1 = bb;
   assign #2ns n2 = a & bb;
endmodule

module tb_delays ();
	reg a, b;

	delays mod(.a(a), .b(b));

	initial begin
		a <= 0;
		b <= 0;
	end

	always #4ns b <= ~b;
	always #2ns a <= ~a;
endmodule
