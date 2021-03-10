
/****************************************************************************
 * fwgpio_wb.v
 ****************************************************************************/
`include "wishbone_macros.svh"
`include "rv_addr_line_en_macros.svh"
  
/**
 * Module: fwgpio_wb
 * 
 * TODO: Add module documentation
 */
module fwgpio_wb #(
		// Number of I/Os
		parameter N_PINS=32,
		// Number of mapping banks provided
		parameter N_BANKS=2
		) (
		input						clock,
		input						reset,
		`WB_TARGET_PORT(rt_, 4, 32),
		
		input[N_BANKS*N_PINS-1:0]	banks_o,
		output[N_BANKS*N_PINS-1:0]	banks_i,
		output[N_BANKS*N_PINS-1:0]	banks_oe,
		
		output[N_PINS-1:0]	pin_o,
		input[N_PINS-1:0]	pin_i,
		output[N_PINS-1:0]	pin_oe
		);
	
	`RV_ADDR_LINE_EN_WIRES(rv_, 4, 32);
	
	assign rv_valid = (rt_cyc && rt_stb);
	assign rv_dat_w = rt_dat_w;
	assign rt_dat_r = rv_dat_r;
	assign rv_we = rt_we;
	assign rt_ack = (rv_ready & rv_valid);
		
	
	fwgpio #(
			.N_PINS(N_PINS),
			.N_BANKS(N_BANKS)
		) u_core (
			.clock(clock),
			.reset(reset),
			`RV_ADDR_LINE_EN_CONNECT(rt_, rv_),
			.banks_o(banks_o),
			.banks_i(banks_i),
			.banks_oe(banks_oe),
			.pin_o(pin_o),
			.pin_i(pin_i),
			.pin_oe(pin_oe)
		);

endmodule


