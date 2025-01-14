module ALU
(
    input definitions::instruction_t IW,
    input logic clock,
    output logic [31:0] result
);

    import definitions::ADD;
    import definitions::SUB;
    import definitions::MUL;
    import definitions::multiplier;
    // import definitions::*; // wildcard import

    always_comb begin
        case (IW.opcode)
            ADD : result = IW.a + IW.b;
            SUB : result = IW.a - IW.b;
            MUL : result = multiplier(IW.a, IW.b);
        endcase
    end

endmodule