module design_top;
    always @(posedge CLK) begin
        if (do_precharge) begin
            oe1  <= oe_shift[0];
        end
    end
endmodule