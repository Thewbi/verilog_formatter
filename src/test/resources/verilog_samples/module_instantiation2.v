module design_top;
	uart_debug_if dbg(/*AUTOINST*/
        // Outputs
        .wb_dat32_o				 (wb_dat32_o[31:0]),
        // Inputs
        .wb_adr_i				 (wb_adr_int[/*`UART_ADDR_WIDTH*/0-1:0]),
        .ier						 (ier[3:0]),
        .iir						 (iir[3:0]),
        .fcr						 (fcr[1:0]),
        .mcr						 (mcr[4:0]),
        .lcr						 (lcr[7:0]),
        .msr						 (msr[7:0]),
        .lsr						 (lsr[7:0]),
        .rf_count				 (rf_count[/*`UART_FIFO_COUNTER_W*/0-1:0]),
        .tf_count				 (tf_count[/*`UART_FIFO_COUNTER_W*/0-1:0]),
        .tstate					 (tstate[2:0]),
        .rstate					 (rstate[3:0])
    );
endmodule

