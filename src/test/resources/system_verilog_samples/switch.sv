module ALU(
    input  definitions::instruction_t  IW,
    input  logic                       clock,
    output logic [31:0]                result
);

    always_ff @(posedge clock) begin
        case (IW.opcode)
            definitions::ADD : result = IW.a + IW.b;
            definitions::SUB : result = IW.a - IW.b;
            definitions::MUL : result = definitions::multiplier(IW.a, IW.b);
        endcase
    end

endmodule