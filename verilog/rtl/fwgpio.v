
/****************************************************************************
 * fwgpio.v
 ****************************************************************************/
`include "rv_addr_line_en_macros.svh"

// Registers
// CTRL -- Controls mode and muxing
// STAT -- Read value of pin in GPIO mode
//

/**
 * Module: fwgpio
 * 
 * TODO: Add module documentation
 */
module fwgpio #(
		// Number of I/Os
		parameter N_PINS=32,
		// Number of mapping banks provided
		parameter N_BANKS=2
		) (
		input						clock,
		input						reset,
		`RV_ADDR_LINE_EN_TARGET_PORT(rt_, 4, 32),
		
		input[N_BANKS*N_PINS-1:0]	banks_o,
		output[N_BANKS*N_PINS-1:0]	banks_i,
		input[N_BANKS*N_PINS-1:0]	banks_oe,
		
		output[N_PINS-1:0]	pin_o,
		input[N_PINS-1:0]	pin_i,
		output[N_PINS-1:0]	pin_oe
		);

	localparam BANKSEL_WIDTH = 4; // TODO:
	localparam RT_ADR_WIDTH = 4; // TODO:
	
	initial begin
		if (N_BANKS > 16) begin
			$display("Error: Max of 16 banks supported");
		end
	end
	
	reg[BANKSEL_WIDTH-1:0]		banksel[N_PINS-1:0];

	// Connects active bank to GPIO
	reg							bank_en[N_PINS-1:0];
	// Output value when the bank is in GPIO mode
	reg							gpio_out_v[N_PINS-1:0];
	// GPIO output-enable control
	reg							gpio_out_oe[N_PINS-1:0];

	reg access_state = 0;
	reg[31:0] dat_r = {32{1'b0}};
	reg[31:0] dat_o;
	assign rt_ready = access_state;
	assign rt_dat_r = dat_r;
	
	// Register-access handler
	always @(posedge clock) begin
		if (reset) begin
			access_state <= 0;
			dat_r <= {32{1'b0}};
		end else begin
			case (access_state) 
				0: begin
					if (rt_valid) begin
						access_state <= 1;
						if (rt_we) begin
							dat_r <= {32{1'b0}};
						end else begin
							dat_r <= dat_o;
						end
					end
				end
				1: begin
					access_state <= 0;
				end
			endcase
		end
	end
	
	// Register output-data mux
	always @* begin
		if (rt_adr[0]) begin
			// Status register
			dat_o = {31'b0, pin_i[rt_adr[RT_ADR_WIDTH-1:1]]};
		end else begin
			// CTRL register
			dat_o = {
					{32-11{1'b0}},
					gpio_out_oe[rt_adr[RT_ADR_WIDTH-1:1]],
					gpio_out_v[rt_adr[RT_ADR_WIDTH-1:1]],
					bank_en[rt_adr[RT_ADR_WIDTH-1:1]],
					{8-BANKSEL_WIDTH{1'b0}},
					banksel[rt_adr[RT_ADR_WIDTH-1:1]]
					};
		end
	end
		
	generate 
		always @(posedge clock) begin
			if (reset) begin
			
			end else begin
			end
		end
	endgenerate
	
	generate
		genvar pin_ii, bank_ii;
		for (pin_ii=0; pin_ii<N_PINS; pin_ii=pin_ii+1) begin
			always @(posedge clock) begin
				if (reset) begin
					banksel[pin_ii] <= {BANKSEL_WIDTH{1'b0}};
					bank_en[pin_ii] <= 1'b0;     // Default is to connect GPIO
					gpio_out_v[pin_ii] <= 1'b0;
					gpio_out_oe[pin_ii] <= 1'b0;  // Default is for pin in input mode
				end else begin
					if (rt_we && !rt_adr[0] && rt_adr[RT_ADR_WIDTH-1:1] == pin_ii) begin
						banksel[pin_ii] <= rt_dat_w[BANKSEL_WIDTH-1:0];
						bank_en[pin_ii] <= rt_dat_w[8];
						gpio_out_v[pin_ii] <= rt_dat_w[9];
						gpio_out_oe[pin_ii] <= rt_dat_w[10];
					end
				end
			end

			assign pin_o[pin_ii]  = (bank_en[pin_ii])?banks_o[banksel[pin_ii]]:gpio_out_v[pin_ii];
			assign pin_oe[pin_ii] = (bank_en[pin_ii])?banks_oe[banksel[pin_ii]]:gpio_out_oe[pin_ii];
			always @* begin
				if (bank_en[pin_ii]) begin
				end else begin
				end
			end
			for (bank_ii=0; bank_ii<N_BANKS; bank_ii=bank_ii+1) begin
				// Connect inputs back
				assign banks_i[N_PINS*bank_ii+pin_ii] = 
					(bank_en[pin_ii] && banksel[pin_ii]==bank_ii)?pin_i[N_PINS*bank_ii+pin_ii]:1'b0;
			end
		end
	endgenerate

endmodule


