`timescale 1ns/1ps

module our (clk);
   input clk;

   reg r0;
   initial r0 = 1'b1;

   always @(posedge clk) begin
      r0 <= ~r0;
      $display(r0);
      $display("Hello World");
   end

endmodule

module sabaka(input logic [3:0] a, output logic [3:0] y);
    assign y = ~a;
endmodule

module gates(input logic [3:0] a, b, output logic [3:0] y1, y2, y3, y4, y5);
   /*пять разных двухвходовых ЛЭ
   работают на 4-битных шинах */
   assign y1 = a & b; // AND
   assign y2 = a |b; // OR
   assign y3 = a ^ b; // XOR
   assign y4 = ~(a & b); // NAND
   assign y5 = ~(a |b); // NOR
endmodule

module and8(input logic [7:0] a, output logic y);
   assign y = &a;
   // &a записать гораздо проще, чем
   // assign y = a[7] & a[6] & a[5] &
   // a[4] & a[3] & a[2] &
   // a[1] & a[0];
endmodule

// module eq8(input logic [7:0] a, output logic y);
//    assign y = (==a);
// endmodule

module d_ff (input clk, resetn, d, output reg q);
	always @ (posedge clk)
		if (resetn)
			q <= d;
		else
			q <= 0;
endmodule

module tb_top ();
	reg clk, resetn, d;
	wire q;

	d_ff d_ff0 (.clk (clk), .resetn (resetn), .d (d), .q (q));

	always #10 clk <= ~clk;

	initial begin
		clk <= 0;
		resetn <= 0;
		d <= 0;

      // assert property (#0 (q == 0));

		#2 d <= 1;
      // assert property (#2 (q == 0));

		#5 d <= 1;
      // assert property (#5 (q == 0));

		#8 d <= 0;
      // assert property (#8 (q == 0));

		#10 d <= 1;
		#10 resetn <= 1;
      // assert property (#10 (q == 1));
	end
endmodule

module delays(input logic a, b, c, output logic y);
   logic ab, bb, cb, n1, n2, n3;
   assign #1 {ab, bb, cb} = ~{a, b, c};
   assign #2 n2 = a & bb & cb;
   assign #2 n1 = ab & bb & cb;
   assign #2 n3 = a & bb & c;
   assign #4 y = n1 | n2 | n3;
endmodule

module tb_delays ();
	reg a, b, c;
   reg y;

	delays mod(.a(a), .b(b), .c(c), .y(y));

	initial begin
		a <= 0;
		b <= 0;
		c <= 0;
		y <= 0;
	end

	always #8 c <= ~c;
	always #4 b <= ~b;
	always #2 a <= ~a;
endmodule

module inv1(input logic [3:0] a, output logic [3:0] y);
   always_comb
      y = ~a;
endmodule

module inv2(input logic [3:0] a, output logic [3:0] y);
   always @(*)
      y = ~a;
endmodule

module tb_inv();
	reg [3:0] a;
   reg [3:0] y;

	// inv1 mod(.a(a), .y(y));
	inv2 mod(.a(a), .y(y));

	initial begin
		a <= 0;
		y <= 0;
	end

	always #2 a[0] <= ~a[0];
	always #4 a[1] <= ~a[1];
	always #8 a[2] <= ~a[2];
	always #16 a[3] <= ~a[3];
endmodule

module priority_casez(input logic [3:0] a, output logic [3:0] y);
   always_comb
      casez(a)
         4'b1???: y = 4'b1000;
         4'b01??: y = 4'b0100;
         4'b001?: y = 4'b0010;
         4'b0001: y = 4'b0001;
         default: y = 4'b0000;
      endcase
endmodule

module tb_priority_casez();
	reg [3:0] a;
   reg [3:0] y;

	priority_casez mod(.a(a), .y(y));

	initial begin
		a <= 0;
		y <= 0;
	end

	always #2 a[0] <= ~a[0];
	always #4 a[1] <= ~a[1];
	always #8 a[2] <= ~a[2];
	always #16 a[3] <= ~a[3];
endmodule
