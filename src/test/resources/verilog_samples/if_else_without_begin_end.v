module design_top;
    always @(posedge CLK) begin
        if (REF_REQ == 1)
            do_refresh <= 1;
        else
            do_refresh <= 0;
    end
endmodule