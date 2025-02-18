module controller_testbench();

    wire        clk;
    wire        reset;
    wire [6:0]  op;
    wire [2:0]  funct3;
    wire        funct7b5;
    wire        Zero;
    wire [1:0]  ResultSrc;
    wire        MemWrite;
    wire        PCSrc;
    wire        ALUSrc;
    wire        RegWrite;
    wire        Jump;
    wire [1:0]  ImmSrc;
    wire [2:0]  ALUControl;

    controller ctrl (
        clk,
        reset,
        op,         // [in]
        funct3,     // [in]
        funct7b5,   // [in]
        Zero,       // [in]
        ResultSrc,  // [output]
        MemWrite,   // [output]
        PCSrc,      // [output]
        ALUSrc,     // [output]
        RegWrite,   // [output]
        Jump,       // [output]
        ImmSrc,     // [output]
        ALUControl  // [output]
    );

endmodule