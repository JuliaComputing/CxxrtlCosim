`define LEDS_NR 4
`define WIDTH 12

module top (
	input clk,
	output [`LEDS_NR-1:0] led
);

reg [`WIDTH:0] ctr_q;
wire [`WIDTH:0] ctr_d;

// Sequential code (flip-flop)
always @(posedge clk)
	ctr_q <= ctr_d;

// Combinational code (boolean logic)
assign ctr_d = ctr_q + 1'b1;
assign led = ctr_q[`WIDTH:`WIDTH-`LEDS_NR];

endmodule
