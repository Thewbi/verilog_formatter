module design_top;

    always @* begin
        y_d = $signed(a) >>> b[4:0];
    end

endmodule