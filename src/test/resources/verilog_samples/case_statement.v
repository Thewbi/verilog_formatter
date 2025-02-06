module design_top;
    always @(curr_state or i_input) begin
        case (curr_state)
            S0: begin
                if (i_input == 2'b01)
                    next_state <= S1;
                else
                    next_state <= S0;
            end
            S1: begin
                if (i_input == 2'b01)
                    next_state <= S2;
                else
                    next_state <= S1;
            end
            S2: begin
                if (i_input == 2'b01)
                    next_state <= S3;
                else
                    next_state <= S2;
            end
            S3: begin
                if (i_input == 2'b01)
                    next_state <= S0;
                else
                    next_state <= S3;
            end
            default: next_state <= S0;
        endcase
    end
endmodule