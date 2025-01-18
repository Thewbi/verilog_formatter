module design_top;
    always @(posedge CLK) begin
        if ((do_precharge == 1) & ((oe4 == 1) | (rw_flag == 1))) begin
            RAS_N <= 1;
            CAS_N <= 1;
            WE_N  <= 0;
        end
    end
endmodule