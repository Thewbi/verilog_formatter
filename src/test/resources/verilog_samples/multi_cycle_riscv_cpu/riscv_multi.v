module riscv_multi(

    output  wire [31:0] PC,

    output  wire [31:0] WriteData,
    input   wire [31:0] ReadData

);

    // the wishbone response contains data in the lower word
    wire [31:0] Instr;
    assign Instr = rsp_word[31:0];

    wire        ALUSrc;
    wire        RegWrite;
    wire        Jump;
    wire        Zero;
    wire [1:0]  ResultSrc;
    wire [1:0]  ImmSrc;
    wire [2:0]  ALUControl;

    // initial
    // begin

    //     //
    //     // Read
    //     //

    //     #60

    //     $display("");
    //     $display("-----------------------------------------------------------------");
    //     $display("[CPU] reading 1 ...");

    //     //
    //     // address
    //     //

    //     $display("[CPU] ADDRESS ADDRESS ADDRESS");

    //     cmd_stb = 1;
    //     // formulate a read command
    //     // set new base address without increment feature
    //     cmd_word = { 2'b10, 1'b0, 1'b1, 30'b000000000000000000000000000000 };

    //     #10

    //     $display("");
    //     $display("[CPU] READ READ READ");

    //     cmd_stb = 1;
    //     cmd_word = { 2'b00, 32'b00000000000000000000000000000000 };

    //     #20

    //     $display("");
    //     $display("-----------------------------------------------------------------");
    //     $display("[CPU] reading 1 done.");

    //     $display("[CPU] rsp_word = %0h, rsp_word = %08h, Instr = %08h", rsp_word, rsp_word[31:0], Instr);

    //     cmd_stb = 0;
    //     cmd_word = 0;
    // end

    // wishbone memory access
    // interface between the host and the master
    wire        cmd_stb;
    wire [33:0] cmd_word;
    wire        cmd_busy;
    wire        rsp_stb;
    wire [33:0] rsp_word;

    wire [6:0]  op; // TODO: this is not connected
    wire [2:0]  funct3;
    wire [1:0]  ALUSrcB;
    wire [1:0]  ALUSrcA;

    // TODO: use the register and immediate offset to compute the target address
    // and encode that target address into the command for the wishbone master.

    // TODO: the controller has to wait in the read memory stage and process
    // the wishbone signals until the wishbone master says, that it has
    // succesfully performed a read / write
    //
    controller ctr (
        // Instr[6:0],     // [in]
        // Instr[14:12],   // [in]
        // Instr[30],      // [in]
        // Zero,
        // ResultSrc,
        // MemWrite, // this signal says wether to read or write. Build this into the command for the wishbone master. whishbone_master.i_cmd_word[33:32] == 2'b00 for read and 2'b01 for write
        // PCSrc,
        // ALUSrc,
        // RegWrite,
        // Jump,
        // ImmSrc,
        // ALUControl

        // // wishbone memory access
        // // interface between the host and the master
        // cmd_stb,
        // cmd_word,
        // cmd_busy,
        // rsp_stb,
        // rsp_word,

        clk,
        reset,
        op,
        funct3,
        funct7b5,
        Zero,
        PCWrite,
        AdrSrc,
        MemWrite,
        IRWrite,
        ResultSrc,
        ALUControl,
        ALUSrcB,
        ALUSrcA,
        ImmSrc,
        RegWrite,

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

        // input
        PCWrite,
        AdrSrc,
        MemWrite,
        IRWrite,
        ResultSrc,
        ALUControl,
        ALUSrcB,
        ALUSrcA,
        ImmSrc,
        RegWrite
    );

endmodule