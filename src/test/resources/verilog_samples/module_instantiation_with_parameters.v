module design_top;

    fwb_master #(
        .AW(32),
        .DW(32),
        .F_MAX_STALL(1),
        .F_MAX_ACK_DELAY(1),
        .F_LGDEPTH(4),
        .F_MAX_REQUESTS(0),
        // OPT_BUS_ABORT: If true, the master can drop CYC at any time
        // and must drop CYC following any bus error
        .OPT_BUS_ABORT(1'b1),
        //
        // If true, allow the bus to be kept open when there are no
        // outstanding requests.  This is useful for any master that
        // might execute a read modify write cycle, such as an atomic
        // add.
        .F_OPT_RMW_BUS_OPTION (1),
        //
        //
        // If true, allow the bus to issue multiple discontinuous
        // requests.
        // Unlike F_OPT_RMW_BUS_OPTION, these requests may be issued
        // while other requests are outstanding
        .F_OPT_DISCONTINUOUS(1),
        //
        //
        // If true, insist that there be a minimum of a single clock
        // delay between request and response.  This defaults to off
        // since the wishbone specification specifically doesn't
        // require this.  However, some interfaces do, so we allow it
        // as an option here.
        .F_OPT_MINCLOCK_DELAY(1)
    ) fwb_master_instance_1 (
        // {{{
        .i_clk(i_clk_signal),
        .i_reset(!i_rst_n),
        // The Wishbone bus
        .i_wb_cyc(o_wb_cyc_data),
        .i_wb_stb(o_wb_stb_data),
        .i_wb_we(o_wb_we_data),
        .i_wb_addr(o_wb_addr_data),
        .i_wb_data(o_wb_data_data),
        .i_wb_sel(o_wb_sel_data),
        //
        .i_wb_ack(i_wb_ack_data),
        .i_wb_stall(i_wb_stall_data),
        .i_wb_idata(i_wb_data_data),
        .i_wb_err(1'b0),
        // Some convenience output parameters
        .f_nreqs(),
        .f_nacks(),
        .f_outstanding(f_outstanding)
        // }}}
    );

endmodule