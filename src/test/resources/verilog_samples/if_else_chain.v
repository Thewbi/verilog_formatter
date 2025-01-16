module design_top;

always @(posedge CLK ) begin

        if ( do_refresh==1 ) begin                        // Refresh: S=00, RAS=0, CAS=0, WE=1
                RAS_N <= 0;
                CAS_N <= 0;
                WE_N  <= 1;
        end
        else if ((do_precharge==1) & ((oe4 == 1) | (rw_flag == 1))) begin      // burst terminate if write is active
                RAS_N <= 1;
                CAS_N <= 1;
                WE_N  <= 0;
        end
        else if (do_precharge==1) begin                 // Precharge All: S=00, RAS=0, CAS=1, WE=0
                RAS_N <= 0;
                CAS_N <= 1;
                WE_N  <= 0;
        end
        else if (do_load_mode==1) begin                 // Mode Write: S=00, RAS=0, CAS=0, WE=0
                RAS_N <= 0;
                CAS_N <= 0;
                WE_N  <= 0;
        end
        else if (do_reada == 1 | do_writea == 1) begin  // Activate: S=01 or 10, RAS=0, CAS=1, WE=1
                RAS_N <= 0;
                CAS_N <= 1;
                WE_N  <= 1;
        end
        else if (do_rw == 1) begin                      // Read/Write: S=01 or 10, RAS=1, CAS=0, WE=0 or 1
                RAS_N <= 1;
                CAS_N <= 0;
                WE_N  <= rw_flag;
        end
        else if (do_initial ==1) begin
                RAS_N <= 1;
                CAS_N <= 1;
                WE_N  <= 1;
        end
        else begin                                      // No Operation: RAS=1, CAS=1, WE=1
                RAS_N <= 1;
                CAS_N <= 1;
                WE_N  <= 1;
        end
end

endmodule