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
    input   wire        funct7b5,   // funct7b5
    input   wire        Zero,       // the ALU has computed a result that is zero (for branching instruction making)
    input   wire [31:0] PC,

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
    output  reg         RegWrite,   // write enable for the register file

    // wishbone memory access
    // interface between the host and the master
    output  reg         cmd_stb,
    output  reg [33:0]  cmd_word,
    input   wire        cmd_busy,
    input   wire        rsp_stb,
    input   wire [33:0] rsp_word
);
    reg data_available = 0;

    initial
    begin
        $monitor("[controller], rsp_word = %h, current_state = %d, cmd_busy = %d", rsp_word, current_state, cmd_busy);

        RegWrite = 1'b0;        // write disable the register file
    end

    initial
    begin
        cmd_stb = 0;
        cmd_word = 0;
        // cmd_busy = 0;
        // rsp_stb = 0;
        // rsp_word = 0;

        data_available = 0;
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
            current_state <= ResetState;
        end
        else
        begin
            $display("[controller] next state");
            // otherwise, next state
            current_state <= next_state;
        end
    end

    always @(negedge cmd_busy)
    begin
        $display("[controller] data_available!");
        data_available = 1;

        cmd_stb <= 0; // make the wishbone master go to "NO STATE"
    end

    //
    // next state
    //
    // combinational logic of the Moore FSM
    // to determine next state
    //

    //always @(current_state, reset)
    always @(current_state, reset, data_available)
    //always @(current_state, op, reset, data_available)
    begin

        case(current_state)

            // S0 "Reset" State
            ResetState:
            begin
                $display("reset: %d", reset);
                if (reset == 0)
                begin
                    $display("[controller] rsp_stb: %d, cmd_busy: %d", rsp_stb, cmd_busy);
                    $display("[controller] goto ResetState -> FetchState_1");
                    next_state = FetchState_1;

                    data_available = 0;
                end
            end

            // S0 "Fetch_1" State
            FetchState_1:
            begin
                $display("[controller] rsp_stb: %d, cmd_busy: %d", rsp_stb, cmd_busy);
                $display("[controller] goto FetchState_1 -> FetchState_2");
                next_state = FetchState_2;
            end

            // S0 "Fetch_2" State
            FetchState_2:
            begin
                $display("[controller] rsp_stb: %d, cmd_busy: %d", rsp_stb, cmd_busy);
                //if(rsp_stb) // when the wishbone master has finished the transaction

                if (data_available == 1)
                begin
                    $display("[controller] goto FetchState_2 -> DecodeState");
                    next_state = DecodeState;
                    data_available = 0;
                end
            end

            // S1 "Decode" State
            DecodeState:
            begin
                $display("[controller] op: %b", op);
                if ((op == 7'b0000011) || (op == 7'b0100011)) // lw or sw
                begin
                    $display("[controller] goto DecodeState -> MemAddrState");
                    next_state = MemAddrState;
                end
                else if (op == 7'b0110011) // R-Type
                begin
                    $display("[controller] goto DecodeState -> ExecuteRState");
                    next_state = ExecuteRState;
                end
                else if (op == 7'b0010011) // I-Type ALU
                begin
                    $display("[controller] goto DecodeState -> ExecuteIState");
                    next_state = ExecuteIState;
                end
                else if (op == 7'b1101111) // JAL
                begin
                    $display("[controller] goto DecodeState -> JALState");
                    next_state = JALState;
                end
                else if (op == 7'b1100011) // BEQ
                begin
                    $display("[controller] goto DecodeState -> BEQState");
                    next_state = BEQState;
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
                if (op == 7'b0000011) // lw
                begin
                    $display("[controller] goto MemAddrState -> MemReadState");
                    next_state = MemReadState;
                end
                else if (op == 7'b0100011) // sw
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
                $display("[CTRL.OUTPUT.FETCH_STATE_1]");

                // PCWrite = 1'b1;



                // turn off register file write
                RegWrite = 1'b0;

                // activate wishbone interface
                cmd_stb = 1;

                //
                // increment PC
                //


                // if (Zero == 0)
                // begin
                    // PC <- PC + 4
                    ALUSrcA <= 2'b00;       // A input to the ALU: use the content of PC
                    ALUSrcB <= 2'b10;       // B input to the ALU: hardcoded 4 to increment PC by one 32bit instruction
                    // ALU
                    ALUControl <= 3'b000;   // operation add?
                    ResultSrc <= 2'b10;     // ALU result goes onto the result bus

                    PCWrite <= 1'b1;        // enable the PC write to store the incremented PC
                // end

                if (Zero == 1)
                begin
                    $display("[CTRL.OUTPUT.BEQ_STATE] Branch taken");
                    ResultSrc = 2'b00;     // ALU goes onto the result bus
                    PCWrite <= 1'b1;
                end;



                // formulate a read command
                // set new base address without increment feature
                //cmd_word = { 2'b10, 1'b0, 1'b1, 30'b000000000000000000000000000000 };

                $display("[controller] PC PC PC :::::::::::::::::::::::::::: 0x%0h", PC);

                $display("[CPU] ADDRESS ADDRESS ADDRESS");
                // Read/Write, add to bus adddres, incrememnt on each read, address value
                cmd_word = { 2'b10, 1'b0, 1'b0, PC[29:0] };

            end

            // S0 "Fetch_2" State
            FetchState_2:
            begin

                PCWrite = 0;

                // Instr <- Mem[PC]
                AdrSrc = 0;            // address for memory access is taken from the PC register
                RegWrite = 0;
                IRWrite = 1;           // write enable the register that will store the data retrieved from memory

                $display("[CPU] READ READ READ COMMAND");

                cmd_stb = 1;
                cmd_word = { 2'b00, 32'b00000000000000000000000000000000 }; // the 32 bits are ignored for a read command

                $display("[CTRL.OUTPUT.FETCH_STATE_2]");

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
                ALUControl = 3'b000;   // some operation (add?)

                //  This tells the sign extension module which instruction is sign extended!
                if ((op == 7'b0000011) || (op == 7'b0010011))
                begin
                    //7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
                    //7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I–type ALU

                    // I−type
                    ImmSrc = 2'b00;
                end

                if (op == 7'b0100011)
                begin
                    //7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw

                    // S−type (stores)
                    ImmSrc = 2'b01;
                end

                if (op == 7'b0110011)
                begin
                    //7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R–type

                    // R–type
                    ImmSrc = 2'bxx;
                end

                if (op == 7'b1100011)
                begin
                    //7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq

                    // B−type (branches) (BEQ, ...)
                    ImmSrc = 2'b10;
                end

                if (op == 7'b1101111)
                begin
                    //7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal

                    // J−type (jal)
                    ImmSrc = 2'b11;
                end






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
                ALUControl = 3'b000;   // some operation (add?)
            end

            // S3 "MemRead" State
            MemReadState:
            begin
                $display("[CTRL.OUTPUT.MEMREAD_STATE]");

                PCWrite = 1'b0;

                // Data <- Mem[ALUOut]
                ResultSrc = 2'b00;      // ALUOut is the value that is placed onto the ResultSrc bus
                AdrSrc = 1'b1;          // The ResultSrc bus is used as an input to the memory module
            end

            // S4 "MemWB" State
            MemWBState:
            begin
                $display("[CTRL.OUTPUT.MEMWB_STATE]");

                PCWrite = 1'b0;

                // rd <- Data           // write the memmory value back into the register file to the rd register
                ResultSrc = 2'b01;      // data read from memory is the value that is placed onto the ResultSrc bus
                RegWrite = 1'b1;        // write enable the register file
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
            end

            // S6 "ExecuteR" State
            ExecuteRState:
            begin
                $display("[CTRL.OUTPUT.EXECUTER_STATE]");

                PCWrite = 1'b0;

                // ALUOut <- rs1oprs2   // an operator is applied to rs1 and rs2
                ALUSrcA = 2'b10;       // A input to the ALU: value currently stored in the register identified by rd1
                ALUSrcB = 2'b00;       // B input to the ALU: sign extended immediate
                //ALUControl <= 3'b010;   // some operation (?)
                ALUControl = funct3;
            end

            // S7 "ALUWriteBackState" State
            ALUWriteBackState:
            begin
                $display("[CTRL.OUTPUT.ALUWriteBackState]");

                PCWrite = 1'b0;

                // rd <- ALUOut         // write the ALU result back into the register file to the rd register
                ResultSrc = 2'b00;      // data value goes on to the result bus
                RegWrite = 1'b1;        // write enable the register file
            end

            // S8 "ExecuteI" State // execute I-Type instruction
            ExecuteIState:
            begin
                $display("[CTRL.OUTPUT.EXECUTEI_STATE]");

                PCWrite = 1'b0;

                // ALUOut <- rs1opimm   // an operator is applied to rs1 and the immediate value
                ALUSrcA = 2'b10;       // A input to the ALU: value currently stored in the register identified by rd1
                ALUSrcB = 2'b01;       // B input to the ALU: ???
                ALUControl = funct3;   // determines the operation that the ALU performs
                ImmSrc = 2'b00;        // control the immediate extension module TODO: this has to be done for other types of instructions too!
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


            end

            // S10 "BEQ" State
            BEQState:
            begin
                $display("[CTRL.OUTPUT.BEQ_STATE]");

                PCWrite <= 1'b1;        // enable the PC write to store the incremented PC
                // IRWrite <= 1'b0;

                // ALUResult = rs1-rs2; if Zero, PC = ALUOut
                ALUSrcA = 2'b10;       // register file rs1
                ALUSrcB = 2'b00;       // register file rs2
                ALUControl = 3'b001;   // Minus operation

                // if (Zero == 1)
                // begin
                //     $display("[CTRL.OUTPUT.BEQ_STATE] Branch taken");
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

                //     // PCWrite <= 1'b1;        // enable the PC write to store the incremented PC
                // end
            end

            // S15 "ERROR" State
            ErrorState:
            begin
                $display("[CTRL.OUTPUT.ERROR_STATE]");
            end

            default:
            begin
                $display("[CTRL.OUTPUT.?] No case in always @(current_state) current_state = %d", current_state);
            end
        endcase
    end

endmodule;