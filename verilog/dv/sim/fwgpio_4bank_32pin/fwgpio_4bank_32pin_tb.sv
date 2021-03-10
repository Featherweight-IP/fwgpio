
/****************************************************************************
 * fwgpio_4bank_32pin_tb.sv
 ****************************************************************************/
`ifdef NEED_TIMESCALE
	`timescale 1ns/1ns
`endif

`include "rv_addr_line_en_macros.svh"
  
/**
 * Module: fwgpio_4bank_32pin_tb
 * 
 * TODO: Add module documentation
 */
module fwgpio_4bank_32pin_tb(input clock);
	
`ifdef HAVE_HDL_CLOCKGEN
	reg clock_r = 0;
	initial begin
		forever begin
`ifdef NEED_TIMESCALE
			#10;
`else
			#10ns;
`endif
			clock_r <= ~clock_r;
		end
	end
	assign clock = clock_r;
`endif
	
`ifdef IVERILOG
	`include "iverilog_control.svh"
`endif
	
	reg      reset /* verilator public */ = 0;
	reg[7:0] reset_cnt = 0;
	
	always @(posedge clock) begin
		case (reset_cnt)
			2: begin
				reset <= 1;
				reset_cnt <= reset_cnt + 1;
			end
			20: begin
				reset <= 0;
			end
			default: begin
				reset_cnt <= reset_cnt + 1;
			end
		endcase
	end
	
	
	localparam N_PINS = 32;
	localparam N_BANKS = 4;
	
	wire[N_BANKS*N_PINS-1:0] 	banks_o;
	wire[N_BANKS*N_PINS-1:0] 	banks_i;
	wire[N_BANKS*N_PINS-1:0] 	banks_oe;

	// BFMs to drive the DUT bank inputs
	generate
		genvar func_ii;
		for (func_ii=0; func_ii<N_BANKS; func_ii=func_ii+1) begin
			
			gpio_bfm #(
					.N_PINS(N_PINS),
					.N_BANKS(1)
				) u_bank_bfm (
					.clock(clock),
					.reset(reset),
					.pin_i(banks_i[N_PINS*(func_ii+1)-1:N_PINS*func_ii]),
					.pin_o(banks_o[N_PINS*(func_ii+1)-1:N_PINS*func_ii]),
					.pin_oe(banks_oe[N_PINS*(func_ii+1)-1:N_PINS*func_ii]),
					.banks_o({N_PINS{1'b0}}),
					.banks_oe({N_PINS{1'b0}})
				);
		end
	endgenerate
	
	wire[N_PINS-1:0]		pin_o;
	wire[N_PINS-1:0]		pin_i;
	wire[N_PINS-1:0]		pin_oe;
	
	`RV_ADDR_LINE_EN_WIRES(bfm2dut_, 4, 32);
	
	rv_addr_line_en_initiator_bfm #(
		.ADR_WIDTH  (4 ), 
		.DAT_WIDTH  (32 )
		) u_reg_bfm (
		.clock      (clock     ), 
		.reset      (reset     ), 
		`RV_ADDR_LINE_EN_CONNECT( , bfm2dut_));
	
	fwgpio #(
		.N_PINS    (N_PINS   ), 
		.N_BANKS   (N_BANKS  )
		) u_dut (
		.clock     (clock    ), 
		.reset     (reset    ), 
		`RV_ADDR_LINE_EN_CONNECT(rt_, bfm2dut_),
		.banks_o   (banks_o  ), 
		.banks_i   (banks_i  ), 
		.banks_oe  (banks_oe ), 
		.pin_o     (pin_o    ), 
		.pin_i     (pin_i    ), 
		.pin_oe    (pin_oe   ));
	

	wire[N_PINS*N_BANKS-1:0]	pinmux_banks_i;
	wire[N_PINS*N_BANKS-1:0]	pinmux_banks_o;
	wire[N_PINS*N_BANKS-1:0]	pinmux_banks_oe;

	// BFM to act as a mirror for the GPIO
	gpio_bfm #(
			.N_PINS(N_PINS),
			.N_BANKS(N_BANKS)
		) u_pinmux_bfm (
			.clock(clock),
			.reset(reset),
			.pin_i(pin_o),
			.pin_o(pin_i),
			// Don't control pin_oe
			.banks_i(pinmux_banks_i),
			.banks_o(pinmux_banks_o),
			.banks_oe(pinmux_banks_oe)
		);

	// BFM to check state of the OE pins
	gpio_bfm #(
			.N_PINS(N_PINS),
			.N_BANKS(1)
		) u_oe_bfm (
			.clock(clock),
			.reset(reset),
			.pin_i(pin_oe),
			.banks_o({N_PINS{1'b0}}),
			.banks_oe({N_PINS{1'b0}})
		);

	// BFMs to drive the Pinmux BFM bank inputs
	generate
		genvar pinmux_func_ii;
		for (pinmux_func_ii=0; pinmux_func_ii<N_BANKS; pinmux_func_ii=pinmux_func_ii+1) begin
			gpio_bfm #(
					.N_PINS(N_PINS),
					.N_BANKS(1)
				) u_pin_bfm (
					.clock(clock),
					.reset(reset),
					.pin_i(pinmux_banks_i[N_PINS*(pinmux_func_ii+1)-1:N_PINS*pinmux_func_ii]),
					.pin_o(pinmux_banks_o[N_PINS*(pinmux_func_ii+1)-1:N_PINS*pinmux_func_ii]),
					.pin_oe(pinmux_banks_oe[N_PINS*(pinmux_func_ii+1)-1:N_PINS*pinmux_func_ii]),
					.banks_o({N_PINS{1'b0}}),
					.banks_oe({N_PINS{1'b0}})
				);
		end
	endgenerate

endmodule


