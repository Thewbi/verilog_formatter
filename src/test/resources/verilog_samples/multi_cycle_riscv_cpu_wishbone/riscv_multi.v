module riscv_multi(

    // clock and reset
    input wire clk,
    input wire reset,

    // output  wire [31:0] PC,

    output  wire [31:0] WriteData,
    input   wire [31:0] ReadData

);

    // the wishbone response contains data in the lower word
    wire [31:0] Instr;
    assign      Instr = rsp_word[31:0];

    wire        ALUSrc;
    wire        RegWrite;
    wire        Jump;
    wire        Zero;
    wire [31:0] PC;
    wire [1:0]  ResultSrc;
    wire [1:0]  ImmSrc;
    wire [2:0]  ALUControl;

    // wishbone memory access
    // interface between the host and the master
    wire        cmd_stb;
    wire [33:0] cmd_word;
    wire        cmd_busy;
    wire        rsp_stb;
    wire [33:0] rsp_word;

    wire [6:0]  op;
    wire [2:0]  funct3;
    wire [1:0]  ALUSrcB;
    wire [1:0]  ALUSrcA;

    initial
    begin
        $monitor("PC: %d", PC);
    end

    // TODO: use the register and immediate offset to compute the target address
    // and encode that target address into the command for the wishbone master.

    // TODO: the controller has to wait in the read memory stage and process
    // the wishbone signals until the wishbone master says, that it has
    // succesfully performed a read / write
    //
    controller ctr (
        // clock and reset
        clk,
        reset,

        // input
        op, // operation code from within the instruction
        funct3,
        funct7b5,
        Zero,
        PC,

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
        RegWrite,       // write enable for the register file

        // wishbone memory access
        // interface between the host and the master
        cmd_stb,
        cmd_word,
        cmd_busy,
        rsp_stb,
        rsp_word
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
        RegWrite,       // write enable for the register file

        // wishbone memory access
        // interface between the host and the master
        cmd_stb,
        cmd_word,
        cmd_busy,
        rsp_stb,
        rsp_word
    );

endmodule