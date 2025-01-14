module multistage_mux_4_4bit_comb(
    input logic [3:0] d0, d1, 
    input logic [2:0] select,
    output logic [3:0] q_0, q_1
);

    always_comb
        case(select)
            0: q_0 = d0;
            1: begin
                q_0 = d0 + d1;
                q_1 = d0 - d1;
            end
            2,3,4 : q_0 = ~d1;
            default:
                q_0 = 4'b0000;
        endcase

endmodule
