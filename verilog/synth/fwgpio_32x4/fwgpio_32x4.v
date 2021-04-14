
`include "rv_addr_line_en_macros.svh"

module fwgpio_32x4(
		input			clock,
		input			reset,
		`RV_ADDR_LINE_EN_TARGET_PORT(rt_, 4, 32),
		
		input[4*32-1:0]	banks_o,
		output[4*32-1:0]	banks_i,
		input[4*32-1:0]	banks_oe,
		
		output[32-1:0]	pin_o,
		input[32-1:0]	pin_i,
		output[32-1:0]	pin_oe);

	fwgpio #(
		.N_PINS(32),
		.N_BANKS(4)) u_core (
		.clock(clock),
		.reset(reset),
		`RV_ADDR_LINE_EN_CONNECT(rt_, rt_),
		.banks_o(banks_o),
		.banks_i(banks_i),
		.banks_oe(banks_oe),
		.pin_o(pin_o),
		.pin_i(pin_i),
		.pin_oe(pin_oe)
	);

endmodule


