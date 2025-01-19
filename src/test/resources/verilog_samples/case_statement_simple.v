module design_top;
    always @ (curr_state or i_input) begin
        case (curr_state)
            S0: begin
                next_state <= S1;
            end
            S1: begin
                next_state <= S2;
            end
            default: next_state <= S0;
        endcase
    end
endmodule