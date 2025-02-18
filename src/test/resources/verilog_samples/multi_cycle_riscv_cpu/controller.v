module controller (
    input wire [6:0] op,
    input wire [2:0] funct3,
    input wire funct7b5,
    input wire Zero,
    output wire [1:0] ResultSrc,
    output wire MemWrite,
    output wire PCSrc, ALUSrc,
    output wire RegWrite, Jump,
    output wire [1:0] ImmSrc,
    output wire [2:0] ALUControl
);

endmodule;