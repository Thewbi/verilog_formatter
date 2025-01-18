module design_top;
    always @(posedge CLK) begin
        if (do_refresh == 1) begin
            WE_A  <= 1;
        end
        if (do_refresh == 2) begin
            WE_B  <= 2;
        end
    end
endmodule