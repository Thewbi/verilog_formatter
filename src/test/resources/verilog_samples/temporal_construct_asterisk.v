module design_top;
    always @(*) begin
        if (do_precharge) begin
            oe1  <= oe_shift[0];
        end
    end
endmodule