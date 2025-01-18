module design_top;
    always @(posedge CLK) begin
        if (do_refresh == 1) begin
            WE_A  <= 1;
            WE_B  <= 2;
        end
        else if (do_refresh == 2) begin
            RAS_N <= 3;
            if (do_refresh == 1) begin
                WE_A  <= 1;
                WE_B  <= 2;
            end
        end
        else begin
            RAS_N <= 4;
        end
    end
endmodule