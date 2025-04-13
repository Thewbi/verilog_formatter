module design_top(
    input wire[31:0] i_rs1, i_rs2,
    output wire[31:0] o_rs2 //source register 2 value
);
    always @(posedge CLK) begin
       if ((REF_REQ == 1 | REFRESH == 1) & command_done == 0 & do_refresh == 0 & rp_done == 0 & do_reada == 0 & do_writea == 0)
       begin
            RAS_N <= 1;
            CAS_N <= 1;
            WE_N  <= 0;
        end
    end
endmodule