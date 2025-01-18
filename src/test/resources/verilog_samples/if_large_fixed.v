module design_top;
always @(posedge CLK or negedge RESET_N)
begin

/**/
	if (RESET_N == 0)
	begin
		do_reada        	<= 0;
		do_writea       	<= 0;
		do_refresh      	<= 0;
		do_precharge    	<= 0;
		do_load_mode    	<= 0;
		do_initial			<= 0;
		command_done    	<= 0;
		command_delay   	<= 0;
		rw_flag         	<= 0;
		rp_shift        	<= 0;
		rp_done         	<= 0;
		ex_read				<= 0;
		ex_write				<= 0;
	end


   else
   begin

//  Issue the appropriate command if the sdram is not currently busy
	if ( INIT_REQ == 1 )
	begin
		do_reada        	<= 0;
		do_writea       	<= 0;
		do_refresh      	<= 0;
		do_precharge    	<= 0;
		do_load_mode    	<= 0;
		do_initial			<= 1;
		command_done    	<= 0;
		command_delay   	<= 0;
		rw_flag         	<= 0;
		rp_shift        	<= 0;
		rp_done         	<= 0;
		ex_read				<= 0;
		ex_write				<= 0;
	end
	else
	begin
		do_initial <= 0;


	// Refresh
	if ((REF_REQ == 1 | REFRESH == 1) & command_done == 0 & do_refresh == 0 & rp_done == 0 & do_reada == 0 & do_writea == 0)
	do_refresh <= 1;
	else
	do_refresh <= 0;

    // READA
	if ((READA == 1) & (command_done == 0) & (do_reada == 0) & (rp_done == 0) & (REF_REQ == 0))
	begin
	do_reada <= 1;
	ex_read <= 1;
	end
	else
	do_reada <= 0;

    // WRITEA
	if ((WRITEA == 1) & (command_done == 0) & (do_writea == 0) & (rp_done == 0) & (REF_REQ == 0))
	begin
	do_writea <= 1;
	ex_write <= 1;
	end
	else
	do_writea <= 0;

    // PRECHARGE
	if ((PRECHARGE == 1) & (command_done == 0) & (do_precharge == 0))
	do_precharge <= 1;
	else
	do_precharge <= 0;

    // LOADMODE
	if ((LOAD_MODE == 1) & (command_done == 0) & (do_load_mode == 0))
	do_load_mode <= 1;
	else
	do_load_mode <= 0;

	// set command_delay shift register and command_done flag
	// The command delay shift register is a timer that is used to ensure that
	// the SDRAM devices have had sufficient time to finish the last command.

  if (( do_refresh == 1 ) | ( do_reada == 1 ) | ( do_writea == 1 ) | ( do_precharge == 1 ) | ( do_load_mode == 1 ))
    begin
      command_delay <= 8'b11111111;
      command_done <= 1;
      rw_flag <= do_reada;
    end
  else
    begin
      command_done <= command_delay [ 0 ];
      command_delay <= ( command_delay >> 1 );
    end


	// start additional timer that is used for the refresh, writea, reada commands
	if (command_delay[0] == 0 & command_done == 1)
	begin
		rp_shift <= 4'b1111;
		rp_done <= 1;
	end
	else
	begin
	if(SC_PM == 0)
	begin
	rp_shift	<= (rp_shift>>1);
	rp_done		<= rp_shift[0];
	end
	else
	begin
	if( (ex_read == 0) && (ex_write == 0) )
	begin
	rp_shift	<= (rp_shift>>1);
	rp_done <= rp_shift[0];
	end
	else
	begin
	if( PM_STOP==1 )
	begin
	rp_shift	<= (rp_shift>>1);
	rp_done     <= rp_shift[0];
	ex_read		<= 1'b0;
	ex_write	<= 1'b0;
	end
	end
	end
end
end

end
end


always @(posedge CLK or negedge RESET_N)
begin
        if (RESET_N == 0)
        begin
                oe_shift <= 0;
                oe1      <= 0;
                oe2      <= 0;
                OE       <= 0;
        end
        else
        begin
                if (SC_PM == 0)
                begin
                        if (do_writea == 1)
                        begin
                                //  Set the shift register to the appropriate
                                // value based on burst length.
                                if (SC_BL == 1)
                                        oe_shift <= 0;
                                else if (SC_BL == 2)
                                        oe_shift <= 1;
                                else if (SC_BL == 4)
                                        oe_shift <= 7;
                                else if (SC_BL == 8)
                                        oe_shift <= 127;
                                oe1 <= 1;
                        end
                        else
                        begin
                                oe_shift <= (oe_shift>>1);
                                oe1  <= oe_shift[0];
                                oe2  <= oe1;
                                oe3  <= oe2;
                                oe4  <= oe3;
                                if (SC_RCD == 2)
                                        OE <= oe3;
                                else
                                        OE <= oe4;
                        end
                end
                else
                begin
                        // OE generation for page mode accesses
                        if (do_writea == 1)
                                oe4   <= 1;
                        else if (do_precharge == 1 | do_reada == 1 | do_refresh==1 | do_initial == 1 | PM_STOP==1 )
                                oe4   <= 0;
                        OE <= oe4;
                end

        end

end

endmodule