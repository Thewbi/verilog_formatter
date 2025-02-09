module ALU(
    input  instruction_t  IW,
    input  logic                       clock,
    output logic [31:0]                result
);

    always @(posedge clock) begin
        case (opcode)
            ADD : result = a + b;
            SUB : result = a - b;
            MUL : result = multiplier(a, b);
        endcase
    end

endmodule