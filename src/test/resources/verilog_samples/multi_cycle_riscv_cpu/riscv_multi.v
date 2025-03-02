module riscv_multi(
    // clock and reset
    input wire clk,
    input wire reset
);

    wire [31:0] Instr;
    wire        ALUSrc;
    wire        RegWrite;
    wire        Jump;
    wire        Zero;
    wire [31:0] PC;
    wire [1:0]  ResultSrc;
    wire [1:0]  ImmSrc;
    wire [2:0]  ALUControl;

    wire [6:0]  op;
    wire [2:0]  funct3;
    wire [1:0]  ALUSrcB;
    wire [1:0]  ALUSrcA;

    controller ctr (
        // clock and reset
        clk,
        reset,

        // input
        op,             // operation code from within the instruction
        funct3,
        funct7b5,
        Zero,           // ALU result is zero
        PC,             // current programm counter

        // output
        PCWrite,
        AdrSrc,
        MemWrite,
        IRWrite,
        ResultSrc,      // controls the multiplexer that decides what goes onto the Result bus
        ALUControl,     // tells the ALU which operation to perform
        ALUSrcB,        // decides which line goes into the ALU B parameter input
        ALUSrcA,        // decides which line goes into the ALU A parameter input
        ImmSrc,         // enable sign extension of the immediate value
        RegWrite       // write enable for the register file
    );

    datapath dp (
        // clock and reset
        clk,
        reset,

        // output
        op,
        funct3,
        funct7b5,
        Zero,
        PC,

        // input
        PCWrite,
        AdrSrc,
        MemWrite,
        IRWrite,
        ResultSrc,      // controls the multiplexer that decides what goes onto the Result bus
        ALUControl,     // tells the ALU which operation to perform
        ALUSrcB,        // decides which line goes into the ALU B parameter input
        ALUSrcA,        // decides which line goes into the ALU A parameter input
        ImmSrc,         // enable sign extension of the immediate value
        RegWrite       // write enable for the register file
    );

endmodule