logic [31:0] reg_0 = 0;

// timer0 peripheral configuration register placed at address 0x40020014 
always_ff@(posedge clk)
    if (reset_n == 0)
        reg_0 <= 0;
    else if(wren)
        reg_0 <= data;

assign TIMER_0_ENABLE     = reg_0[0];
assign TIMER_0_OVF_EN     = reg_0[1];
assign TIMER_0_OVF_IRQ_EN = reg_0[2];