// control unit or control logic for the multicycle CPU
//
// This module implements a state machine that produces
// controll signals based on the operation processed currently
module controller (

    // clk and reset
    input   wire        clk,
    input   wire        reset,

    // input
    input   wire [6:0]  op,         // operation code from within the instruction
    input   wire [2:0]  funct3,     // funct3 for instruction identification. This encodes the operation that the ALU has to execute
    input   wire [30:0]  funct7b5,     // funct7b5
    input   wire [6:0]  funct7,     // funct7b5
    input   wire        Zero,       // the ALU has computed a result that is zero (for branching instruction making)
    input   wire [31:0] PC,
    input   wire [31:0] ReadData,

    // output
    output  reg         PCWrite,    // the PC flip flop enable line, the flip flop stores PCNext and outputs PC
    output  reg         AdrSrc,     // address source selector
    output  reg         MemWrite,   // write enable for the memory module
    output  reg         IRWrite,    // instruction register write
    output  reg [1:0]   ResultSrc,  // controls the multiplexer that decides what goes onto the Result bus
    output  reg [2:0]   ALUControl, // tells the ALU which operation to perform
    output  reg [1:0]   ALUSrcB,    // decides which line goes into the ALU B parameter input
    output  reg [1:0]   ALUSrcA,    // decides which line goes into the ALU A parameter input
    output  reg [1:0]   ImmSrc,     // enable sign extension of the immediate value
    output  reg         RegWrite   // write enable for the register file
);

    wire [6:0]  op2;
    assign op2 = ReadData[6:0];

    wire [1:0] ALUOp;


    //aludec ad(op[5], funct3, funct7b5, ALUOp, ALUControl);
    wire [2:0] ALUControlAluDec;
    aludec ad(op, funct3, funct7, ALUControlAluDec);

    // initial
    // begin
    //     $monitor("[controller], rsp_word = %h, current_state = %d, cmd_busy = %d", rsp_word, current_state, cmd_busy);
    // end

    initial
    begin
        PCWrite = 1'b0;
        ALUSrcA = 2'b00;
        ALUSrcB = 2'b00;
        ALUControl = 3'b000;
        ResultSrc = 2'b00;
        AdrSrc = 1'b0;
        RegWrite = 1'b0;
        MemWrite = 1'b0;
        ImmSrc = 2'b00;
        IRWrite = 1'b0;
    end

    //
    // All states of the Moore state machine (= output only depends on the current state)
    //
    // Strategy: https://www.fpga4student.com/2017/09/verilog-code-for-moore-fsm-sequence-detector.html
    //

    parameter
        ResetState          = 4'b0000,      // S0 "Fetch_1" State
        FetchState_1        = 4'b0001,      // S1 "Decode" State
        FetchState_2        = 4'b0010,      // S2 "MemAddr" State
        DecodeState         = 4'b0011,      // S3 "MemRead" State
        MemAddrState        = 4'b0100,      // S4 "MemWB" State
        MemReadState        = 4'b0101,      // S5 "MemWrite" State
        MemWBState          = 4'b0110,      // S6 "ExecuteR" State
        MemWriteState       = 4'b0111,      // S7 "ALUWriteBackState" State
        ExecuteRState       = 4'b1000,      // S8 "ExecuteI" State // execute I-Type instruction
        ALUWriteBackState   = 4'b1001,      // S9 "JAL" State
        ExecuteIState       = 4'b1010,      // S10 "BEQ" State
        JALState            = 4'b1011,      // S11
        BEQState            = 4'b1100,      // S12
                                            // S13
                                            // S14
        ErrorState          = 4'b1111       // S15 "ERROR" State
        ;

    // current state and next state
    reg [3:0] current_state;
    reg [3:0] next_state;

    // sequential memory of the Moore FSM
    always @(posedge clk, posedge reset)
    begin
        if (reset == 1)
        begin
            $display("[controller] reset");
            // when reset=1, reset the state of the FSM to "Fetch" State
            current_state = ResetState;

            PCWrite = 1'b0;
            ALUSrcA = 2'b00;
            ALUSrcB = 2'b00;
            ALUControl = 3'b000;
            ResultSrc = 2'b00;
            AdrSrc = 1'b0;
            RegWrite = 1'b0;
            MemWrite = 1'b0;
            ImmSrc = 2'b00;
            IRWrite = 1'b0;
        end
        else
        begin
            $display("[controller] next state");



            // if (Zero == 1 && PC != 0 && current_state == BEQState)
            //     begin
            //         $display("[CTRL.OUTPUT.BEQ_STATE] Branch taken");
            //         // ResultSrc = 2'b00;     // ALU goes onto the result bus

            //         // //ALUSrcB = 2'b01;

            //         // PCWrite = 1'b1;

            //         ImmSrc = 2'b10;

            //         // PC <- PC + 4
            //         ALUSrcA = 2'b01;       // A input to the ALU: use the content of PC
            //         ALUSrcB = 2'b01;       // B input to the ALU: hardcoded 4 to increment PC by one 32bit instruction
            //         // ALU
            //         ALUControl = 3'b000;   // operation add. We need the ALU to compute an ADD operation to increment the PC no matter what the real instruction in the PC is actually. It can be an or, slt, beq. It does not matter! Right nNow we need to compute an add!
            //         ResultSrc = 2'b10;     // ALU result goes onto the result bus

            //         PCWrite = 1'b1;        // enable the PC write to store the incremented PC

            //         IRWrite = 1'b1; // write the fetched instruction into the instruction flipflop.
            //     end;


            // otherwise, next state
            current_state = next_state;


        end
    end



    //
    // combinational logic to determine the output
    // of the Moore FSM, output only depends on current state
    // Moore == output only depends on the current state
    //

    always @(current_state)
    begin
        case(current_state)

            // S0 "Reset" State
            ResetState:
            begin
                $display("[CTRL.OUTPUT.ResetState]");
                PCWrite = 1'b0;
            end

            // S0 "Fetch_1" State
            FetchState_1:
            begin
                $display("");
                $display("");
                $display("[CTRL.OUTPUT.FETCH_STATE_1] Zero: %d", Zero);

                // if (Zero == 1)
                // begin
                //     $display("[CTRL.OUTPUT.BEQ_STATE] Branch taken");
                //     ALUSrcA = 00;
                //     ALUSrcB = 01;
                //     ResultSrc = 2'b10;     // ALU goes onto the result bus
                //     PCWrite = 1'b1;
                //     IRWrite = 1'b1; // write the fetched instruction into the instruction flipflop.

                //     PC = 0;
                // end;

                // turn off register file write
                //RegWrite = 1'b0;

                //
                // increment PC
                //

                // in the first cycle, ZERO is 1 but we do not want to execute zero
                if (Zero == 0 || PC == 0)
                begin
                    // PC <- PC + 4
                    ALUSrcA = 2'b00;       // A input to the ALU: use the content of PC
                    ALUSrcB = 2'b10;       // B input to the ALU: hardcoded 4 to increment PC by one 32bit instruction
                    // ALU
                    ALUControl = 3'b000;   // operation add. We need the ALU to compute an ADD operation to increment the PC no matter what the real instruction in the PC is actually. It can be an or, slt, beq. It does not matter! Right nNow we need to compute an add!
                    ResultSrc = 2'b10;     // ALU result goes onto the result bus

                    PCWrite = 1'b1;        // enable the PC write to store the incremented PC

                    IRWrite = 1'b1; // write the fetched instruction into the instruction flipflop.
                end
                else if (Zero == 1 && PC != 0)
                begin
                    $display("[CTRL.OUTPUT.BEQ_STATE] Branch taken");
                    // ResultSrc = 2'b00;     // ALU goes onto the result bus

                    // //ALUSrcB = 2'b01;

                    // PCWrite = 1'b1;

                    ImmSrc = 2'b10;

                    // PC <- PC + 4
                    ALUSrcA = 2'b00;       // A input to the ALU: use the content of PC
                    ALUSrcB = 2'b01;       // B input to the ALU: hardcoded 4 to increment PC by one 32bit instruction
                    // ALU
                    ALUControl = 3'b000;   // operation add. We need the ALU to compute an ADD operation to increment the PC no matter what the real instruction in the PC is actually. It can be an or, slt, beq. It does not matter! Right nNow we need to compute an add!
                    ResultSrc = 2'b10;     // ALU result goes onto the result bus

                    PCWrite = 1'b1;        // enable the PC write to store the incremented PC

                    IRWrite = 1'b1; // write the fetched instruction into the instruction flipflop.
                end;

                // dont cares
                //PCWrite = 1'b0;
                //ALUSrcA = 2'b00;
                //ALUSrcB = 2'b00;
                //ALUControl = 3'b000;
                //ResultSrc = 2'b00;
                AdrSrc = 1'b0;
                RegWrite = 1'b0;
                MemWrite = 1'b0;
                //ImmSrc = 2'b00;
                //IRWrite = 1'b0; // do not write the fetched instruction into the instruction flipflop.



                $display("[controller] PC PC PC :::::::::::::::::::::::::::: 0x%0h", PC);
                $display("[controller] ReadData :::::::::::::::::::::::::::: 0x%0h", ReadData);

            end

            // S1 "Decode" State
            DecodeState:
            begin
                $display("[CTRL.OUTPUT.DECODE_STATE]");

                PCWrite = 1'b0;     // Do not write into the Programm Counter
                RegWrite = 1'b0;    // Do not write into the register file
                IRWrite = 1'b0;     // Do not write into the the buffer after the register file

                // ALUOut <- PCTarget (this computes the target address of a jump/branch instruction)
                ALUSrcA = 2'b01;       // A input to the ALU: use the oldPC (because BEQ is PC relative)
                ALUSrcB = 2'b01;       // B input to the ALU: sign extended immediate (Because BEQ stores the offset as an immediate within the instruction)
                ALUControl = 3'b000;   // some operation (add)

                //  This tells the sign extension module which instruction is sign extended!
                $display("[controller decode state logic] op: %b", op2);

                if ((op2 == 7'b0000011) || (op2 == 7'b0010011))
                begin
                    //7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
                    //7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I–type ALU

                    // I−type
                    ImmSrc = 2'b00;
                end

                if (op2 == 7'b0100011)
                begin
                    //7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw

                    // S−type (stores)
                    ImmSrc = 2'b01;
                end

                if (op2 == 7'b0110011)
                begin
                    //7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R–type

                    // R–type
                    ImmSrc = 2'bxx;
                end

                if (op2 == 7'b1100011)
                begin
                    //7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq

                    // B−type (branches) (BEQ, ...)
                    ImmSrc = 2'b10;

                    // if (Zero == 1)
                    // begin
                        //$display("[CTRL.OUTPUT.BEQ_STATE] Branch taken");
                        ALUSrcA <= 01;
                        ALUSrcB <= 01;
                        ResultSrc <= 2'b10;     // ALU goes onto the result bus
                        // PCWrite <= 1'b1;
                        IRWrite <= 1'b1; // write the fetched instruction into the instruction flipflop.
                    //end;

                    // Dont cares
                    PCWrite = 1'b0;
                    //ALUSrcA = 2'b00;
                    //ALUSrcB = 2'b00;
                    //ALUControl = 3'b000;
                    ResultSrc = 2'b00;
                    AdrSrc = 1'b0;
                    // RegWrite = 1'b0;
                    MemWrite = 1'b0;
                    // ImmSrc = 2'b00;
                    IRWrite = 1'b0;

                    // // ALUResult = rs1-rs2; if Zero, PC = ALUOut
                    // ALUSrcA = 2'b10;       // register file rs1
                    // ALUSrcB = 2'b00;       // register file rs2
                    // ALUControl = 3'b001;   // Minus operation

                    // // if (Zero == 1)
                    // // begin
                    // //     $display("[CTRL.OUTPUT.BEQ_STATE] Branch taken");
                    // //     ResultSrc = 2'b00;     // ALU goes onto the result bus
                    // // end
                    // // else
                    // // begin
                    // //     $display("[CTRL.OUTPUT.BEQ_STATE] Branch NOT taken");

                    // //     // PC = ALUOut; ALUOut = PC + 4
                    // //     ALUSrcA = 2'b01;       // old PC
                    // //     ALUSrcB = 2'b10;       // hardcoded value 4
                    // //     ALUControl = 3'b000;   // some operation (add?)
                    // //     ResultSrc = 2'b00;     // ALU goes onto the result bus

                    // //     // PCWrite = 1'b1;        // enable the PC write to store the incremented PC
                    // // end

                    // // Dont cares
                    // PCWrite = 1'b0;
                    // //ALUSrcA = 2'b00;
                    // //ALUSrcB = 2'b00;
                    // //ALUControl = 3'b000;
                    // ResultSrc = 2'b00;
                    // AdrSrc = 1'b0;
                    // RegWrite = 1'b0;
                    // MemWrite = 1'b0;
                    // ImmSrc = 2'b00;
                    // IRWrite = 1'b0;

                end

                if (op2 == 7'b1101111)
                begin
                    //7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal

                    // J−type (jal)
                    ImmSrc = 2'b11;
                end

                // // dont cares
                // ResultSrc = 2'b00;
                // AdrSrc = 1'b0;
                // MemWrite = 1'b0;
                // ImmSrc = 2'b00;



                //ImmSrc = 10;        // TODO: This tells the sign extension module which instruction is sign extended!
                                    // This has to be adjusted to the instruction at hand!

                // if(cmd_busy == 0)
                // begin
                //     cmd_stb = 0;
                // end
            end

            // S2 "MemAddr" State
            MemAddrState:
            begin
                $display("[CTRL.OUTPUT.MEMADDR_STATE]");

                PCWrite = 1'b0;

                // ALUOut <- rs1 + imm
                ALUSrcA = 2'b10;       // A input to the ALU: value currently stored in the register identified by rd1
                ALUSrcB = 2'b01;       // B input to the ALU: sign extended immediate
                ALUControl = 3'b000;   // some operation (add)

                // dont cares
                //PCWrite = 1'b0;
                //ALUSrcA = 2'b00;
                //ALUSrcB = 2'b00;
                //ALUControl = 3'b000;
                ResultSrc = 2'b00;
                AdrSrc = 1'b0;
                RegWrite = 1'b0;
                MemWrite = 1'b0;
                ImmSrc = 2'b00;
                IRWrite = 1'b0;
            end

            // S3 "MemRead" State
            MemReadState:
            begin
                $display("[CTRL.OUTPUT.MEMREAD_STATE]");

                PCWrite = 1'b0;

                // Data <- Mem[ALUOut]
                ResultSrc = 2'b00;      // ALUOut is the value that is placed onto the ResultSrc bus
                AdrSrc = 1'b1;          // The ResultSrc bus is used as an input to the memory module

                // dont cares
                //PCWrite = 1'b0;
                ALUSrcA = 2'b00;
                ALUSrcB = 2'b00;
                ALUControl = 3'b000;
                //ResultSrc = 2'b00;
                //AdrSrc = 1'b0;
                RegWrite = 1'b0;
                MemWrite = 1'b0;
                ImmSrc = 2'b00;
                IRWrite = 1'b0;
            end

            // S4 "MemWB" State
            MemWBState:
            begin
                $display("[CTRL.OUTPUT.MEMWB_STATE]");

                PCWrite = 1'b0;

                // rd <- Data           // write the memmory value back into the register file to the rd register
                ResultSrc = 2'b01;      // data read from memory is the value that is placed onto the ResultSrc bus
                RegWrite = 1'b1;        // write enable the register file

                // dont cares
                //PCWrite = 1'b0;
                ALUSrcA = 2'b00;
                ALUSrcB = 2'b00;
                ALUControl = 3'b000;
                //ResultSrc = 2'b00;
                AdrSrc = 1'b0;
                //RegWrite = 1'b0;
                MemWrite = 1'b0;
                ImmSrc = 2'b00;
                IRWrite = 1'b0;
            end

            // S5 "MemWrite" State
            MemWriteState:
            begin
                $display("[CTRL.OUTPUT.MEMWRITE_STATE]");

                PCWrite = 1'b0;

                // Mem[ALUOut] <- rd    // value in the rd register goes into memory
                ResultSrc = 2'b00;
                AdrSrc = 1'b1;
                MemWrite = 1'b1;        // Write enable the memory

                // dont care
                //PCWrite = 1'b0;
                ALUSrcA = 2'b00;
                ALUSrcB = 2'b00;
                ALUControl = 3'b000;
                //ResultSrc = 2'b00;
                //AdrSrc = 1'b0;
                RegWrite = 1'b0;
                //MemWrite = 1'b0;
                ImmSrc = 2'b00;
                IRWrite = 1'b0;
            end

            // S6 "ExecuteR" State
            ExecuteRState:
            begin
                $display("[CTRL.OUTPUT.EXECUTER_STATE] funct3: %d", funct3);

                PCWrite = 1'b0;

                // ALUOut <- rs1oprs2   // an operator is applied to rs1 and rs2
                ALUSrcA = 2'b10;       // A input to the ALU: value currently stored in the register identified by rd1
                ALUSrcB = 2'b00;       // B input to the ALU: sign extended immediate

                //ALUControl = 3'b010;   // some operation (?)
                //ALUControl = funct3;
                ALUControl = ALUControlAluDec;

                // dont care
                //PCWrite = 1'b0;
                //ALUSrcA = 2'b00;
                //ALUSrcB = 2'b00;
                //ALUControl = 3'b000;
                ResultSrc = 2'b00;
                AdrSrc = 1'b0;
                RegWrite = 1'b0;
                MemWrite = 1'b0;
                ImmSrc = 2'b00;
                IRWrite = 1'b0;
            end

            // S7 "ALUWriteBackState" State
            ALUWriteBackState:
            begin
                $display("[CTRL.OUTPUT.ALUWriteBackState]");

                PCWrite = 1'b0;

                // rd <- ALUOut         // write the ALU result back into the register file to the rd register
                ResultSrc = 2'b00;      // data value goes on to the result bus
                RegWrite = 1'b1;        // write enable the register file

                // set dont cares to 0
                //PCWrite = 1'b0;
                ALUSrcA = 2'b00;
                ALUSrcB = 2'b00;
                ALUControl = 3'b000;
                //ResultSrc = 2'b00;
                AdrSrc = 1'b0;
                //RegWrite = 1'b0;
                MemWrite = 1'b0;
                ImmSrc = 2'b00;
                IRWrite = 1'b0;


                // if (Zero == 1)
                // begin
                //     $display("[CTRL.OUTPUT.ALUWriteBackState] Branch taken");
                //     ResultSrc = 2'b00;     // ALU goes onto the result bus
                //     PCWrite = 1'b1;
                // end;
            end

            // S8 "ExecuteI" State // execute I-Type instruction
            ExecuteIState:
            begin
                $display("[CTRL.OUTPUT.EXECUTEI_STATE]");

                PCWrite = 1'b0;

                // ALUOut <- rs1opimm   // an operator is applied to rs1 and the immediate value
                ALUSrcA = 2'b10;       // A input to the ALU: value currently stored in the register identified by rd1
                ALUSrcB = 2'b01;       // B input to the ALU: ???
                //ALUControl = funct3;   // determines the operation that the ALU performs
                ALUControl = ALUControlAluDec;
                ImmSrc = 2'b00;        // control the immediate extension module TODO: this has to be done for other types of instructions too!

                // dont care
                //PCWrite = 1'b0;
                //ALUSrcA = 2'b00;
                //ALUSrcB = 2'b00;
                //ALUControl = 3'b000;
                ResultSrc = 2'b00;
                AdrSrc = 1'b0;
                RegWrite = 1'b0;
                MemWrite = 1'b0;
                //ImmSrc = 2'b00;
                IRWrite = 1'b0;
            end

            // S9 "JAL" State
            JALState:
            begin
                $display("[CTRL.OUTPUT.JAL_STATE]");

                PCWrite = 1'b1;        // enable the PC write to store the incremented PC

                // PC = ALUOut; ALUOut = PC + 4
                ALUSrcA = 2'b01;       // old PC
                ALUSrcB = 2'b10;       // hardcoded value 4
                ALUControl = 3'b000;   // some operation (add?)
                ResultSrc = 2'b00;     // ALU goes onto the result bus

                // dont care
                //PCWrite = 1'b0;
                //ALUSrcA = 2'b00;
                //ALUSrcB = 2'b00;
                //ALUControl = 3'b000;
                //ResultSrc = 2'b00;
                AdrSrc = 1'b0;
                RegWrite = 1'b0;
                MemWrite = 1'b0;
                ImmSrc = 2'b00;
                IRWrite = 1'b0;
            end

            // S10 "BEQ" State
            BEQState:
            begin
                $display("[CTRL.OUTPUT.BEQ_STATE] START");

                //PCWrite = 1'b1;        // enable the PC write to store the incremented PC
                // IRWrite = 1'b0;



                if (Zero == 1)
                begin
                    $display("[CTRL.OUTPUT.BEQ_STATE] Branch taken");

                    // ALUResult = rs1-rs2; if Zero, PC = ALUOut
                    ALUSrcA = 2'b10;       // register file rs1
                    ALUSrcB = 2'b00;       // register file rs2
                    ALUControl = 3'b001;   // Minus operation

                    PCWrite = 1'b1;
                    ImmSrc = 2'b10;
                    ResultSrc = 2'b00;
                    IRWrite = 1'b0;
                end
                //     ResultSrc = 2'b00;     // ALU goes onto the result bus
                // end
                // else
                // begin
                //     $display("[CTRL.OUTPUT.BEQ_STATE] Branch NOT taken");

                //     // PC = ALUOut; ALUOut = PC + 4
                //     ALUSrcA = 2'b01;       // old PC
                //     ALUSrcB = 2'b10;       // hardcoded value 4
                //     ALUControl = 3'b000;   // some operation (add?)
                //     ResultSrc = 2'b00;     // ALU goes onto the result bus

                //     // PCWrite = 1'b1;        // enable the PC write to store the incremented PC
                // end

                // if (Zero == 1)
                // begin
                //     $display("[CTRL.OUTPUT.BEQ_STATE] Branch taken");
                //     ALUSrcA <= 01;
                //     ALUSrcB <= 01;
                //     ResultSrc <= 2'b10;     // ALU goes onto the result bus
                //     PCWrite <= 1'b1;
                //     IRWrite <= 1'b1; // write the fetched instruction into the instruction flipflop.
                // end;

                // Dont cares
                //PCWrite = 1'b0;
                //ALUSrcA = 2'b00;
                //ALUSrcB = 2'b00;
                //ALUControl = 3'b000;
                //ResultSrc = 2'b00;
                AdrSrc = 1'b0;
                RegWrite = 1'b0;
                MemWrite = 1'b0;
                //ImmSrc = 2'b00;
                //IRWrite = 1'b0;

                $display("[CTRL.OUTPUT.BEQ_STATE] END");
            end

            // S15 "ERROR" State
            ErrorState:
            begin
                $display("[CTRL.OUTPUT.ERROR_STATE]");

                // Dont cares
                PCWrite = 1'b0;
                ALUSrcA = 2'b00;
                ALUSrcB = 2'b00;
                ALUControl = 3'b000;
                ResultSrc = 2'b00;
                AdrSrc = 1'b0;
                RegWrite = 1'b0;
                MemWrite = 1'b0;
                ImmSrc = 2'b00;
                IRWrite = 1'b0;
            end

            default:
            begin
                $display("[CTRL.OUTPUT.?] No case in always @(current_state) current_state = %d", current_state);
            end
        endcase
    end






    //
    // next state
    //
    // combinational logic of the Moore FSM
    // to determine next state
    //

    always @(current_state, reset)
    begin

        case(current_state)

            // S0 "Reset" State
            ResetState:
            begin
                $display("reset: %d", reset);
                if (reset == 0)
                begin
                    $display("[controller] goto ResetState -> FetchState_1");
                    next_state = FetchState_1;

                    // data_available = 0;
                end
            end

            // S0 "Fetch_1" State
            FetchState_1:
            begin
                $display("[controller] goto FetchState_1 -> DecodeState");
                next_state = DecodeState;
            end

            // // S0 "Fetch_2" State
            // FetchState_2:
            // begin
            //     $display("[controller] rsp_stb: %d, cmd_busy: %d", rsp_stb, cmd_busy);
            //     //if(rsp_stb) // when the wishbone master has finished the transaction

            //     if (data_available == 1)
            //     begin
            //         $display("[controller] goto FetchState_2 -> DecodeState");
            //         next_state = DecodeState;
            //         data_available = 0;
            //     end
            // end

            // S1 "Decode" State
            DecodeState:
            begin
                $display("[controller next state logic] op2: %d", op2);
                if ((op2 == 7'b0000011) || (op2 == 7'b0100011)) // lw or sw
                begin
                    $display("[controller] goto DecodeState -> MemAddrState");
                    next_state = MemAddrState;
                end
                else if (op2 == 7'b0110011) // R-Type
                begin
                    $display("[controller] goto DecodeState -> ExecuteRState");
                    next_state = ExecuteRState;
                end
                else if (op2 == 7'b0010011) // I-Type ALU
                begin
                    $display("[controller] goto DecodeState -> ExecuteIState. op2 = %d", op2);
                    next_state = ExecuteIState;
                end
                else if (op2 == 7'b1101111) // JAL
                begin
                    $display("[controller] goto DecodeState -> JALState");
                    next_state = JALState;
                end
                else if (op2 == 7'b1100011) // BEQ
                begin
                    $display("[controller] goto DecodeState -> BEQState");
                    next_state = BEQState;
                end
                else if (op2 == 7'b0000000) // nop
                begin
                    $display("[controller] goto DecodeState -> FetchState_1 for nop");
                    next_state = FetchState_1;
                end
                else
                begin
                    $display("[controller] goto DecodeState -> ErrorState");
                    next_state = ErrorState;
                end
            end

            // S2 "MemAddr" State
            MemAddrState:
            begin
                if (op2 == 7'b0000011) // lw
                begin
                    $display("[controller] goto MemAddrState -> MemReadState");
                    next_state = MemReadState;
                end
                else if (op2 == 7'b0100011) // sw
                begin
                    $display("[controller] goto MemAddrState -> MemWriteState");
                    next_state = MemWriteState;
                end
                else
                begin
                    $display("[controller] goto MemAddrState -> ErrorState");
                    next_state = ErrorState;
                end
            end

            // S3 "MemRead" State
            MemReadState:
            begin
                $display("[controller] goto MemReadState -> MemWBState");
                next_state = MemWBState;
            end

            // S4 "MemWB" State
            MemWBState:
            begin
                $display("[controller] goto MemWBState -> FetchState_1");
                next_state = FetchState_1;
            end

            // S5 "MemWrite" State
            MemWriteState:
            begin
                $display("[controller] goto MemWriteState -> FetchState_1");
                next_state = FetchState_1;
            end

            // S6 "ExecuteR" State
            ExecuteRState:
            begin
                $display("[controller] goto ExecuteRState -> ALUWriteBackState");
                next_state = ALUWriteBackState;
            end

            // S7 "ALUWB" State
            ALUWriteBackState:
            begin
                $display("[controller] goto ALUWriteBackState -> FetchState_1");
                next_state = FetchState_1;
            end

            // S8 "ExecuteI" State // execute I-Type instruction
            ExecuteIState:
            begin
                $display("[controller] goto ExecuteIState -> ALUWriteBackState");
                next_state = ALUWriteBackState;
            end

            // S9 "JAL" State
            JALState:
            begin
                $display("[controller] goto JALState -> ALUWriteBackState");
                next_state = ALUWriteBackState;
            end

            // S10 "BEQ" State
            BEQState:
            begin
                $display("[controller] goto BEQState -> FetchState_1. Zero = %d", Zero);
                next_state = FetchState_1;


            end

            // S15 "ERROR" State
            ErrorState:
            begin
                $display("[controller] goto ErrorState -> ErrorState");
                next_state = ErrorState;
            end

            default:
            begin
                $display("[controller] default goto default -> ErrorState");
                next_state = ErrorState;
            end

        endcase
    end

endmodule;