module design_top;
    always @(posedge CLK) begin
        if (do_refresh == 1) begin
            RAS_N <= 2;
            CAS_N <= 3;
            WE_N  <= 4;
        end
    end
    always @(posedge CLK or negedge RESET_N)
    begin
        if (do_refresh == 1) begin
            RAS_N <= 2;
        end
    end
endmodule