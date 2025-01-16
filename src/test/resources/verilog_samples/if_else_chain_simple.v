module design_top;

    always @(posedge CLK) begin

        if (do_refresh == 1) begin
            RAS_N <= 0;
            CAS_N <= 0;
            WE_N  <= 1;
        end

    end

endmodule