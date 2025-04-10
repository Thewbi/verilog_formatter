module design_top;

    always @ (a, b, c, sel)
    begin
        case(sel)
            2'b00    : out = a;
            2'b01    : out = b;
            2'b10    : out = c;
            default  : out = 0;
        endcase
    end

    // always @(curr_state or i_input) begin
    //     case (lcr[1:0])
    //         2'b00 : begin rbit_counter <= #1 3'b100; end
    //         2'b00 : rbit_counter <= #1 3'b100;
    //         S0: begin
    //             if (i_input == 2'b01)
    //                 next_state <= S1;
    //             else
    //                 next_state <= S0;
    //         end
    //     endcase
    // end

endmodule