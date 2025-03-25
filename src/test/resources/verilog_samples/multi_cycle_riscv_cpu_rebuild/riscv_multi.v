module riscv_multi(
    // clock and reset
    input wire              clk,
    input wire              resetn,

    // output wire [31:0]      toggle_value,

    output reg [7:0]       tx_Data,
    output reg             tx_DataValid
);

    wire [31:0]     Instr;
    wire            ALUSrc;
    wire            RegWrite;
    wire            Jump;
    wire            Zero;
    wire [31:0]     PC;
    wire [31:0]     ReadData;   // instruction memory

    wire            PCWrite;
    wire            AdrSrc;
    wire            MemWrite;
    wire            IRWrite;

    // wire [31:0] ReadDData;  // data memory
    wire [1:0]      ResultSrc;
    wire [2:0]      ImmSrc;
    wire [2:0]      ALUControl;

    wire [6:0]      op;
    wire [6:0]      oldOp;
    wire [2:0]      funct3;
    wire [30:0]     funct7b5;
    wire [6:0]      funct7;
    wire [1:0]      ALUSrcB;
    wire [1:0]      ALUSrcA;

    controller ctr (
        // clock and reset
        clk,
        resetn,

        // input
        op,             // operation code from within the instruction
        oldOp,
        funct3,
        funct7b5,
        funct7,
        Zero,           // ALU result is zero
        PC,             // current programm counter
        ReadData,

        // output
        PCWrite,
        AdrSrc,
        MemWrite,       // enable line for write operation into memory
        IRWrite,
        ResultSrc,      // controls the multiplexer that decides what goes onto the Result bus
        ALUControl,     // tells the ALU which operation to perform
        ALUSrcB,        // decides which line goes into the ALU B parameter input
        ALUSrcA,        // decides which line goes into the ALU A parameter input
        ImmSrc,         // enable sign extension of the immediate value
        RegWrite,       // write enable for the register file

        // UART
        tx_Data,
        tx_DataValid
    );

    datapath dp (

        // clock and reset
        clk,
        resetn,

        // output
        op,
        oldOp,
        funct3,
        funct7b5,
        funct7,
        Zero,
        PC,
        ReadData,       // instruction memory

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
        RegWrite,       // write enable for the register file

        // toggle_value,

        // UART
        tx_Data,
        tx_DataValid
    );

endmodule