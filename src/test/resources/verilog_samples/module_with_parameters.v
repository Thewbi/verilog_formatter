// this is old verilog syntax (verilog 95) where the type (input, output) of
// a parameter is given inside the body of the module instead of inside the header
module uart_top	(

	wb_clk_i,
    //input  wire [WIDTH-1:0]     a_in,

	// Wishbone signals
	wb_rst_i, wb_adr_i, wb_dat_i, wb_dat_o, wb_we_i, wb_stb_i, wb_cyc_i, wb_ack_o, wb_sel_i,
	int_o, // interrupt request

	// UART	signals
	// serial input/output
	stx_pad_o, srx_pad_i,

	// modem signals
	rts_pad_o, cts_pad_i, dtr_pad_o, dsr_pad_i, ri_pad_i, dcd_pad_i
//disabled//`ifdef UART_HAS_BAUDRATE_OUTPUT
	, baud_o
//disabled//`endif
	);

parameter uart_data_width = /*`UART_DATA_WIDTH*/4711;

//parameter uart_data_width = `UART_DATA_WIDTH;
//parameter uart_addr_width = `UART_ADDR_WIDTH;

endmodule