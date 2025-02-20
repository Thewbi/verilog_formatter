module datapath(
    input   wire        clk,
    input   wire        reset,
    // input wire [1:0] ResultSrc,
    // input wire PCSrc,
    input wire [1:0] ALUSrcA,
    input wire [1:0] ALUSrcB,
    // input wire RegWrite,
    // input wire [1:0] ImmSrc,
    // input wire [2:0] ALUControl,
    // output wire Zero,
    output  wire [31:0] PC,         // currently stored value in the PCNext flip flop
    input   wire [31:0] Instr,      // the instruction to execute
    // output wire [31:0] ALUResult,
    output  wire [31:0] WriteData,   // instruction sb, sh, sw wants to write data to memory
    input        [31:0] ReadData     // instruction lb, lh, lw wants to read data to memory
);

    wire [31:0] PCNext; // input to pcreg. connects the mux infront of pcreg to pcreg.
    wire [31:0] InstrNext;
    // wire [31:0] PCPlus4;
    // wire [31:0] PCTarget;

    // ALU signals
    wire [31:0] ImmExt;
    wire [31:0] SrcB;
    wire [31:0] Result;
    wire [31:0] SrcA;

    // next PC logic (PCNext is the input which is stored in posedge clock.)
    // The flip flop will output the stored data onto PC
    flopr #(32) pcreg(clk, reset, PCNext, PC);

    // adder pcadd4(PC, 32'd4, PCPlus4);
    // adder pcaddbranch(PC, ImmExt, PCTarget);
    // mux2 #(32) pcmux(PCPlus4, PCTarget, PCSrc, PCNext);

    mux2 #(32) addrmux(PCPlus4, PCTarget, PCSrc, PCNext);

    flopr #(32) Instr(clk, reset, PCNext, PC);

    // register file logic
    regfile rf (
        clk,                // [in] clock
        RegWrite,           // [in] write enable, register a3 is written with wd3
        Instr[19:15],       // [in] register 1 to read (no clock tick needed)
        Instr[24:20],       // [in] register 2 to read (no clock tick needed)
        Instr[11:7],        // [in] register to write
        Result,             // [in] data value to write
        SrcA,               // [out] the output where the value from register a1 appears
        WriteData           // [out] the output where the value from register a2 appears
    );

    // causes coersion and brakes the value inside Instr
    //flopr #(32) instrreg(clk, reset, InstrNext, Instr);
    flopr #(32) instrreg(clk, reset, Instr, InstrNext);

    // sign extend module
    extend ext(Instr[31:7], ImmSrc, ImmExt);

    // ALU logic
    mux3 #(32) srcbmux(PC, OldPC, rd1, ALUSrcA, SrcA);
    mux3 #(32) srcbmux(rd2, ImmExt, 32'h00000004, ALUSrcB, SrcB);
    alu alu(SrcA, SrcB, ALUControl, ALUResult, Zero);

    // this mux decides, which value is driving the result BUS
    mux3 #(32) resultmux(ALUResult, ReadData, PCPlus4, ResultSrc, Result);

endmodule