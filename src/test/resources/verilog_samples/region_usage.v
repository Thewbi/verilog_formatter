module design_top;
    initial begin
        if (!i_cmd_word[1])
            o_wb_addr <= i_cmd_word[29:0];
        else
            o_wb_addr <= i_cmd_word[29:0] + o_wb_addr;
    end
endmodule