module wishbone_master (
    input		    i_reset,
    input		    i_cmd_stb,
    input	[33:0]	i_cmd_word,
    output	reg	    o_cmd_busy,
    output		    o_rsp_stb,
    output		    o_rsp_word
);

    assign	i_cmd_rd   = (i_cmd_stb)&&(i_cmd_word[33:32] == 2'b00);
    assign	i_cmd_wr   = (i_cmd_stb)&&(i_cmd_word[33:32] == 2'b01);
    // We'll use i_cmd_bus to capture whether we have a read or write request
    assign	i_cmd_bus  = (i_cmd_stb)&&(i_cmd_word[33]    == 1'b0);
    //
    assign	i_cmd_addr = (i_cmd_stb)&&(i_cmd_word[33:32] == 2'b10);
    assign	i_cmd_special = (i_cmd_stb)&&(i_cmd_word[33:32] == 2'b11);

    initial	o_wb_cyc = 1'b0;
    initial	o_wb_stb = 1'b0;
    initial	newaddr  = 1'b0;
    initial	o_rsp_stb= 1'b0;

    always @(posedge i_clk)
    if ((i_reset)||(i_wb_err))
    begin

        //
        // during reset or error
        //

        o_wb_cyc <= 1'b0;       // to slave: no cycle (= transaction) takes place
        o_wb_stb <= 1'b0;       // to slave: no strobe takes place
        o_cmd_busy   <= 1'b0;   // to host: master is not busy
        o_rsp_stb    <= 1'b1;
        newaddr <= 0;

        // Return over the command interface that we just had an error,
        // or a bus reset
        if (i_reset)
            o_rsp_word <= `RSP_RESET; // to host: output code for Reset as data (For read requests, the host receives the read data here). For write requests, this is abused to return status code about the outcome of the write
        else
            o_rsp_word <= `RSP_BUS_ERROR; // to host: output error code.

    end
    else if ((i_cmd_stb) && (!o_cmd_busy))  // from host: i_cmd_stb - the command word is valid
                                            // to host: !o_cmd_busy - the wishbone bus master is not busy
    begin

        //
        // In the idle state
        //

        newaddr <= 0; // ???

        if (i_cmd_addr) // from host:
        begin
            if (!i_cmd_word[1])
                o_wb_addr <= i_cmd_word[29:0];
            else
                o_wb_addr <= i_cmd_word[29:0] + o_wb_addr;

            inc <= !i_cmd_word[0];

            // Acknowledge the new address -- on the next clock
            // (after the add has completed)
            newaddr <= 1'b1;
        end

        if (newaddr)
        begin
            o_rsp_stb <= 1'b1; // to host:
            o_rsp_word <= { `RSP_SUB_ADDR, o_wb_addr, 1'b0, !inc };
        end

        o_wb_we <= (i_cmd_wr); // to slave: this is a write request

        // on a read or write request, activate the bus and go to the bus
        // request state (= master has the strobe line asserted and is
        // waiting for the slave to acknowledge, stall or err-out)
        if (i_cmd_bus)
        begin
            o_wb_cyc    <= 1'b1; // to slave: start a cycle
            o_wb_stb    <= 1'b1; // to slave: start a strobe
            o_cmd_busy  <= 1'b1; // to host: master is busy
        end

        if (i_cmd_wr)
        begin
            o_wb_data <= i_cmd_word[31:0]; // to slave: data to write
        end
    end
    else if (o_wb_stb)
    begin

        //
        // In the waiting state
        //

        newaddr <= 1'b0; // to host: ???

        //
        // BUS REQUEST state
        //
        // In the state where we are commanding the bus, and waiting for
        // the bus request to be accepted
        //
        // o_wb_cyc will also be true here, since we cannot allow
        // o_wb_stb to be true if o_wb_cyc is not true. (Too many
        // peripherals depend upon this bus simplification ...) Note: this is defined in the wishbone b4 specification
        //
        if (!i_wb_stall) // the slave does not stall. Error terminating signals are not considered here!
        begin
            // The request has been accepted, don't request again.
            o_wb_stb  <= 1'b0; // to slave: master does not drive the strobe line any more
            o_wb_addr <= o_wb_addr + inc; // increment the address

            // If we get an ack on the same cycle as the request,
            // quietly transition back to idle.
            if (i_wb_ack)
            begin
                o_wb_cyc <= 1'b0; // to slave: cycle is over
                o_rsp_stb <= 1'b1; // to host: ???

                if (o_wb_we)
                    o_rsp_word <= `RSP_WRITE_ACKNOWLEDGEMENT; // to host: write has been performed, do not answer with real data since this is not a read request
                else
                    o_rsp_word <= { `RSP_SUB_DATA, i_wb_data }; // to host: here is the read data
            end
        end
    end else if (o_wb_cyc) // state to wait for the slave responding with the data read
    begin

        //
        // In the waiting state
        //

        newaddr <= 1'b0; // to host: ???

        // slave answers with an ack
        if (i_wb_ack)
        begin
            o_wb_cyc <= 1'b0;   // to slave: cycle is over
            o_cmd_busy <= 1'b0; // to host: not busy any more

            o_rsp_stb <= 1'b1;  // to host: ???

            if (o_wb_we)
                o_rsp_word <= `RSP_WRITE_ACKNOWLEDGEMENT; // to host: write has been performed, do not answer with real data since this is not a read request
            else
                o_rsp_word <= { `RSP_SUB_DATA, i_wb_data }; // to host: here is the read data
        end
    end

endmodule