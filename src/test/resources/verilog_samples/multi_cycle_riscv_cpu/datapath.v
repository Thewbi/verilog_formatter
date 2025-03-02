module datapath(

    // clock and reset
    input   wire            clk,
    input   wire            reset,

    // output
    output  wire [6:0]      op,             // operation code from within the instruction
    output  wire [2:0]      funct3,         // funct3 for instruction identification
    output  wire            funct7b5,       // funct7b5
    output  wire            Zero,           // the ALU has computed a result that is zero (for branching instructions)
    output  wire [31:0]     PC,

    // input
    input  wire             PCWrite,        // the PC flip flop enable line, the flip flop stores PCNext and outputs PC
    input  wire             AdrSrc,         // address source selector
    input  wire             MemWrite,       // write enable for the memory module
    input  wire             IRWrite,        // instruction register write
    input  wire [1:0]       ResultSrc,      // controls the multiplexer that decides what goes onto the Result bus
    input  wire [2:0]       ALUControl,     // tells the ALU which operation to perform
    input  wire [1:0]       ALUSrcB,        // decides which line goes into the ALU B parameter input
    input  wire [1:0]       ALUSrcA,        // decides which line goes into the ALU A parameter input
    input  wire [1:0]       ImmSrc,         // enable sign extension of the immediate value
    input  wire             RegWrite,       // write enable for the register file

    // interface between the host and the master
    input                   cmd_stb,        // the host tells the master that it has provided address and data and that the strobe can begin
    input   [33:0]          cmd_word,       // (34 bits) data to write wrapped in a command
    output  wire            cmd_busy,       // the client stalls the master, the master forwards the stall signal to the host here
    output  wire            rsp_stb,        // when this value is 1, then the master is ready to start a strobe
    output  wire [33:0]     rsp_word        // (34 bits) data that has been read (or dummy data on a read)

);

    reg [3:0] wb_sel;

    initial
        begin
            // fill indexes into wb_data to show where data to be written is located
            // In this case all four bytes of the word are written
            wb_sel[0] = 1'b1;
            wb_sel[1] = 1'b1;
            wb_sel[2] = 1'b1;
            wb_sel[3] = 1'b1;

            //PC <= 0;

            //$monitor("PC: %d", PC);
        end

    // wire [31:0] PC;
    wire [31:0] OldPC;
    // wire [31:0] PCNext; // input to pcreg. connects the mux infront of pcreg to pcreg.
    wire [31:0] adr;
    wire [31:0] data;
    wire [31:0] Instr;
    wire [31:0] InstrNext;
    wire [31:0] RD1;
    wire [31:0] RD2;
    wire [31:0] A;
    wire [31:0] WriteData;
    wire [31:0] ALUResult;
    wire [31:0] ALUOut;
    // wire [31:0] PCPlus4;
    // wire [31:0] PCTarget;

    // ALU signals
    wire [31:0] ImmExt;
    wire [31:0] SrcB;
    wire [31:0] Result;
    wire [31:0] SrcA;

    // next PC logic (PCNext is the input which is stored in posedge clock.)
    // The flip flop will output the stored data onto PC
    //                    id        clock       reset,      enable,     input       output
    //flopenr #(32) pcreg(id        clk,        reset,      PCWrite,    PCNext,     PC);
    flopenr #(32) pcreg(3'b000,     clk,        reset,      PCWrite,    Result,     PC);

    mux2 #(32) addrmux(PC, Result, AdrSrc, adr);

    // interface between the master and the slave
    wire            wb_err;         // an error occured, the wishbone master has to reset
    wire            wb_stall;       // slave stalls
    wire            wb_ack;         // slave acknowledges the execution of the wishbone transaction
    wire [31:0]     wb_data;        //
    wire            wb_cyc;         //
    wire            wb_stb;         //
    wire [ 9:0]     wb_addr;        //
    wire            wb_we;          //
    wire [31:0]     wb_data_output; //

    // wire  [33:0] cmd_word;
    // assign cmd_word = { 2'b00, adr[9:0] }; // set new base address without increment feature

    // wire [33:0]      rsp_word;

    // wishbone master
    wishbone_master master (

        // clock and reset
        clk,            // i_clk
        reset,          // i_reset,

        // interface between the host and the master
        cmd_stb,        // i_cmd_stb,       // TODO: I think the strobe has to be generated by the control logic
        cmd_word,       // i_cmd_word,
        cmd_busy,       // o_cmd_busy,      // the master is busy processing a command
        rsp_stb,        // o_rsp_stb,       // when this value is 1, then the master is ready to start a strobe
        rsp_word,       // o_rsp_word,      // (34 bits) data that has been read (or dummy data on a read)

        // interface between the master and the slave
        wb_err,
        wb_stall,
        wb_ack,
        wb_data,        // slave returns read data
        wb_cyc,
        wb_stb,
        wb_addr,
        wb_we,
        wb_data_output
    );

    // wishbone slave for memory
    main_memory mem (

        // clock
        clk,

        // // debug interface (Access to memory without wishbone)
        // i_inst_addr,
        // o_inst_out,
        // i_stb_inst,
        // o_ack_inst,

        // wishbone interface
        wb_cyc,         // cycle
        wb_stb,         // strobe
        wb_we,          // 1 = write, 0 = read
        wb_addr,        // address to read to / write from
        wb_data_output, // data to write
        wb_sel,         // index into data to write
        wb_ack,         // slave acknowledge
        wb_stall,       // slave stall
        wb_data         // slave returns read data
    );

    always @(wb_data)
    begin
        $display("[datapath] abc wb_data: 0x%h", wb_data);
    end

    //                     id     clock     reset,      enable,     input       output
    flopenr #(32) OldPCFF(3'b001, clk,      reset,      IRWrite,    PC,         OldPC);
    flopenr #(32) InstrFF(3'b010, clk,      reset,      IRWrite,    wb_data,    Instr);

    flopr #(32) DataFF(clk, reset, wb_data, data);

    assign op = Instr[6:0];
    assign funct3 = Instr[14:12];
    assign funct7b5 = Instr[30:0];

    // register file logic
    regfile rf (
        clk,                // [in] clock
        RegWrite,           // [in] write enable, register a3 is written with wd3
        Instr[19:15],       // [in] register 1 to read (no clock tick needed)
        Instr[24:20],       // [in] register 2 to read (no clock tick needed)
        Instr[11:7],        // [in] register to write
        Result,             // [in] data value to write
        RD1,                // [out] the output where the value from register a1 appears
        RD2                 // [out] the output where the value from register a2 appears
    );

    flopr #(32) Data_RD1(clk, reset, RD1, A);
    flopr #(32) Data_RD2(clk, reset, RD2, WriteData);

    //flopr #(32) instrreg(clk, reset, InstrNext, Instr);
    //flopr #(32) instrreg(clk, reset, Instr, InstrNext);

    // sign extend module
    // param 1 = instruction bits (part of the instruction to sign extend)
    // param 2 = type of instruction that is sign extension applied to
    // param 3 = output
    extend ext(Instr[31:7], ImmSrc, ImmExt);

    // ALU input muxes
    //                 Input A      Input B     Input C         SelectSignal        Output
    mux3 #(32) srcamux(PC,          OldPC,      A,              ALUSrcA,            SrcA);
    mux3 #(32) srcbmux(WriteData,   ImmExt,     32'h00000004,   ALUSrcB,            SrcB);

    // ALU
    //      input A     input B     operation       result output       zero flag
    alu alu(SrcA,       SrcB,       ALUControl,     ALUResult,          Zero);

    flopr #(32) aluResult(clk, reset, ALUResult, ALUOut);

    // this mux decides, which value is driving the result BUS
    //                      Input A (00)     Input B (01)       Input C (10)        SelectSignal        Output
    mux3 #(32) resultmux(   ALUOut,          data,              ALUResult,          ResultSrc,          Result);

endmodule