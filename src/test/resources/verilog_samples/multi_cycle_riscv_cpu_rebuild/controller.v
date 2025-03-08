

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
    input   wire [6:0]  oldOp,
    input   wire [2:0]  funct3,     // funct3 for instruction identification. This encodes the operation that the ALU has to execute
    input   wire [30:0] funct7b5,     // funct7b5
    input   wire [6:0]  funct7,     // funct7b5
    input   wire        Zero,       // the ALU has computed a result that is zero (for branching instruction making)
    input   wire [31:0] PC,
    input   wire [31:0] ReadData,
    // input   wire [31:0] ReadDData,

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

    function [2:0] decodeAluOp (input [6:0] opcode, input [2:0] funct3, input [6:0] funct7);
    begin
        $display("decode() op: %b, funct3: %b, funct7: %b", op, funct3, funct7);
        case (opcode)

            7'b0010011:
            begin

                case (funct3)

                    3'b000:
                    begin
                        // addi
                        //$display("[ALU_DEC] addi");
                        decodeAluOp = 3'b000; // add, addi
                    end

                    3'b010:
                    begin
                        // slti
                        $display("[ALU_DEC] slti");
                        decodeAluOp = 3'b101; // slt, slti
                    end

                    3'b011:
                    begin
                        // sltiu
                    end

                    3'b100:
                    begin
                        // xori
                    end

                    3'b110:
                    begin
                        // ori
                        $display("[ALU_DEC] ori");
                        decodeAluOp = 3'b011; // or, ori
                    end

                    3'b111:
                    begin
                        // andi
                        $display("[ALU_DEC] andi");
                        decodeAluOp = 3'b010; // and, andi
                    end

                    3'b001:
                    begin
                        // slli
                    end

                    3'b101:
                    begin
                        case (funct7)

                            7'b0000000:
                            begin
                                // srli
                            end

                            7'b0100000:
                            begin
                                // srai
                            end

                        endcase
                    end

                endcase
            end

            7'b0110011:
            begin

                case (funct3)

                    3'b000:
                    begin

                        case (funct7)

                            7'b0000000:
                            begin
                                // add
                                $display("[ALU_DEC] add");
                                decodeAluOp = 3'b000; // addition
                            end

                            7'b0100000:
                            begin
                                // sub
                                $display("[ALU_DEC] sub");
                                decodeAluOp = 3'b001; // subtraction
                            end

                        endcase

                    end

                    3'b001:
                    begin
                        // sll
                    end

                    3'b010:
                    begin
                        // slt
                        $display("[ALU_DEC] slt");
                        decodeAluOp = 3'b101; // slt, slti
                    end

                    3'b011:
                    begin
                        // sltu
                    end

                    3'b100:
                    begin
                        // xor
                    end

                    3'b101:
                    begin

                        case (funct7)

                            7'b0000000:
                            begin
                                // srl
                            end

                            7'b0100000:
                            begin
                                // sra
                            end

                        endcase

                    end

                    3'b110:
                    begin
                        // or
                        $display("[ALU_DEC] or");
                        decodeAluOp = 3'b110; // or, ori
                    end

                    3'b111:
                    begin
                        // and
                        $display("[ALU_DEC] and");
                        decodeAluOp = 3'b010; // and, andi
                    end

                endcase
            end

            7'b1101111:
            begin
                $display("[ALU_DEC] jal jal jal jal jal jal");
                decodeAluOp = 3'b000; // addition
            end

            default:
            begin
                $display("[ALU_DEC] default");
                decodeAluOp = 3'bxxx;
            end

        endcase
    end
    endfunction

    function [2:0] decodeImmSrc (input [6:0] opcode, input [2:0] funct3, input [6:0] funct7);
    begin
        $display("decodeImmSrc() op: %b, funct3: %b, funct7: %b", op, funct3, funct7);
        case (opcode)

            7'b0010011:
            begin

                case (funct3)

                    3'b000:
                    begin
                        // addi
                        //$display("[ALU_DEC] addi");
                        decodeImmSrc = 2'b00; // addi, I-Type
                    end

                    3'b010:
                    begin
                        // slti
                        $display("[ALU_DEC] slti");
                        decodeImmSrc = 2'b00; // slti, I-Type
                    end

                    3'b011:
                    begin
                        // sltiu
                        $finish(1);
                    end

                    3'b100:
                    begin
                        // xori
                        $finish(2);
                    end

                    3'b110:
                    begin
                        // ori
                        $display("[ALU_DEC] ori");
                        decodeImmSrc = 2'b00; // ori, I-Type
                    end

                    3'b111:
                    begin
                        // andi
                        $display("[ALU_DEC] andi");
                        decodeImmSrc = 2'b00; // I-Type
                    end

                    3'b001:
                    begin
                        // slli
                        $finish(3);
                    end

                    3'b101:
                    begin
                        case (funct7)

                            7'b0000000:
                            begin
                                // srli, I-Type
                                decodeImmSrc = 2'b00; // I-Type
                            end

                            7'b0100000:
                            begin
                                // srai, I-Type
                                decodeImmSrc = 2'b00; // I-Type
                            end

                        endcase
                    end

                endcase
            end

            7'b0110011:
            begin

                case (funct3)

                    3'b000:
                    begin

                        case (funct7)

                            7'b0000000:
                            begin
                                // add
                                $display("[ALU_DEC] add");
                                decodeImmSrc = 2'bxx; // addition, no immediate encoded within the instruction
                            end

                            7'b0100000:
                            begin
                                // sub
                                $display("[ALU_DEC] sub");
                                decodeImmSrc = 2'bxx; // subtraction, no immediate encoded within the instruction
                            end

                        endcase

                    end

                    3'b001:
                    begin
                        // sll
                        $finish(4);
                    end

                    3'b010:
                    begin
                        // slt
                        $display("[ALU_DEC] slt");
                        decodeImmSrc = 2'bxx; // no immediate
                    end

                    3'b011:
                    begin
                        // sltu
                        $finish(5);
                    end

                    3'b100:
                    begin
                        // xor
                        $finish(6);
                    end

                    3'b101:
                    begin

                        case (funct7)

                            7'b0000000:
                            begin
                                // srl
                                $finish(7);
                            end

                            7'b0100000:
                            begin
                                // sra
                                $finish(8);
                            end

                        endcase

                    end

                    3'b110:
                    begin
                        // or
                        $display("[ALU_DEC] or");
                        decodeImmSrc = 2'bxx; // or R-Type has no immediate!
                    end

                    3'b111:
                    begin
                        // and
                        $display("[ALU_DEC] and");
                        decodeImmSrc = 2'bxx; // and R-Type has no immediate!
                    end

                endcase
            end

            7'b1101111:
            begin
                $display("[ALU_DEC] jal jal jal jal jal jal");
                decodeImmSrc = 2'b11; // I-Type
            end

            default:
            begin
                $display("[ALU_DEC] default");
                decodeImmSrc = 2'bxx;
            end

        endcase
    end
    endfunction

    function [7:0] sum (input [7:0] a, b);
    begin
        sum = a + b;
    end
    endfunction

    // wire [6:0]  op2;
    // assign op2 = ReadData[6:0];

    // wire [1:0] ALUOp;

    // //aludec ad(op[5], funct3, funct7b5, ALUOp, ALUControl);
    // wire [2:0] ALUControlAluDec;
    // aludec ad(op, funct3, funct7, ALUControlAluDec);

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
        ResetState          = 4'b0000,      // S0 "Reset" State
        FetchState_1        = 4'b0001,      // S1 "FetchState_1" State
        FetchState_2        = 4'b0010,      // S2 "FetchState_2" State
        DecodeState         = 4'b0011,      // S3 "Decode" State
        MemAddrState        = 4'b0100,      // S4 "MemAddr" State
        MemReadState        = 4'b0101,      // S5 "MemRead" State
        MemWBState          = 4'b0110,      // S6 "MemWB" State
        MemWriteState       = 4'b0111,      // S7 "MemWrite" State
        ExecuteRState       = 4'b1000,      // S8 "ExecuteR" State
        ALUWriteBackState   = 4'b1001,      // S9 "ALUWriteBack"
        ExecuteIState       = 4'b1010,      // S10 "ExecuteI" State // execute I-Type instruction
        JALState            = 4'b1011,      // S11 "JAL" State
        BEQState            = 4'b1100,      // S12 "BEQ" State
        BRANCH_TAKEN_CHECK  = 4'b1101,      // S13 "BRANCH_TAKEN_CHECK" State
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
            // when reset=1, reset the state of the FSM to "FetchState_1" State
            current_state = FetchState_1;

            // PCWrite = 1'b0;
            // ALUSrcA = 2'b00;
            // ALUSrcB = 2'b00;
            // ALUControl = 3'b000;
            // ResultSrc = 2'b00;
            // AdrSrc = 1'b0;
            // RegWrite = 1'b0;
            // MemWrite = 1'b0;
            // ImmSrc = 2'b00;
            // IRWrite = 1'b0;

            PCWrite = 1'b1;

            // ACTION 1 - read the instruction at PC. connect PC to instruction memory address input port
            AdrSrc = 1'b0; // this connects the PC flip flop to the instruction memory

            MemWrite = 1'b0; // not writing into memory

            IRWrite = 1'b1; // fill Instr FlipFlop with read instruction from memory. Store PC into oldPC.

            RegWrite = 1'b0;

            ImmSrc = 2'bxx; // no immediate extension required

            // ACTION 2 - increment PC
            ALUSrcA = 2'b00; // PC
            ALUSrcB = 2'b10; // hardcoded 4

            ALUControl = 3'b000; // add operation

            //ALUSrcA = 2'b00;
            //ALUSrcB = 2'b00;

            ResultSrc = 2'b10; // place the ALU result onto the result bus immediately so that the incremented PC goes into PCNext

        end
        else
        begin
            $display("[controller] next state");
            // otherwise, next state
            current_state = next_state;
        end
    end

    //
    // current state combinational logic
    //
    // combinational logic to determine the output
    // of the Moore FSM, output only depends on current state
    // Moore == output only depends on the current state
    //

    always @(current_state)
    begin
        case(current_state)

            // S0 "Fetch_1" State
            FetchState_1:
            begin
                $display("");
                $display("");
                $display("[CTRL.OUTPUT.FETCH_STATE_1] op: %b, oldOp: %b, funct3: %b, funct7: %b", op, oldOp, funct3, funct7);

                PCWrite = 1'b1;

                // ACTION 1 - read the instruction at PC. connect PC to instruction memory address input port
                AdrSrc = 1'b0; // this connects the PC flip flop to the instruction memory

                MemWrite = 1'b0; // not writing into memory

                IRWrite = 1'b1; // fill Instr FlipFlop with read instruction from memory. Store PC into oldPC.

                RegWrite = 1'b0;

                // ACTION 2 - increment PC
                ALUSrcA = 2'b00; // PC
                ALUSrcB = 2'b10; // hardcoded 4

                // if (Zero == 1)
                // begin
                //     $display("[CTRL.OUTPUT.FETCH_STATE_1] Branch taken");
                //     ImmSrc = 2'b10; // BEQ immediate extension required
                //     ALUSrcB = 2'b01; // immediate sign extended
                // end
                // else
                // begin
                ImmSrc = 2'bxx; // no immediate extension required

                // end

                ALUControl = 3'b000; // add operation

                //ALUSrcA = 2'b00;
                //ALUSrcB = 2'b00;

                ResultSrc = 2'b10; // place the ALU result onto the result bus immediately so that the incremented PC goes into PCNext

            end

            // S1 "Decode" State
            DecodeState:
            begin
                $display("");
                $display("");
                $display("[CTRL.OUTPUT.DECODE_STATE] op: %b, funct3: %b, funct7: %b", op, funct3, funct7);

                PCWrite = 1'b0;
                ALUSrcA = 2'b01; // oldPC
                ALUSrcB = 2'b01; // immediate sign extended (this will compute the jump target for JAL)
                //ALUControl = 3'b000;
                ALUControl = decodeAluOp(op, funct3, funct7);
                ResultSrc = 2'bxx;
                AdrSrc = 1'bx;
                RegWrite = 1'b0;
                MemWrite = 1'b0;
                //ImmSrc = 2'b00;
                ImmSrc = decodeImmSrc(op, funct3, funct7);
                IRWrite = 1'b0;
            end

            // S4 "MemAddr" State
            // sw rs2, offset(rs1) add offset to rs1 and store the value
            // rs2(31:0) → mem[rs1 + imm12]
            // sw x7, 84(x3)
            MemAddrState:
            begin
                $display("");
                $display("");
                $display("[CTRL.OUTPUT.MemAddrState] op: %b, oldOp: %b, funct3: %b, funct7: %b", op, oldOp, funct3, funct7);

                // compute the target address as rs1 + imm12

                PCWrite = 1'b0;
                ALUSrcA = 2'b10; // register
                ALUSrcB = 2'b01; // immediate sign extended
                ALUControl = 3'b000; // add
                ResultSrc = 2'b00;
                AdrSrc = 1'b0;
                RegWrite = 1'b0;
                MemWrite = 1'b0;
                ImmSrc = 2'b01; // set the sign extender to S−type (stores)
                IRWrite = 1'b0;
            end

            // S5 "MemRead" State
            MemReadState:
            begin
                $display("");
                $display("");
                $display("[CTRL.OUTPUT.MemReadState] op: %b, oldOp: %b, funct3: %b, funct7: %b", op, oldOp, funct3, funct7);

                PCWrite = 1'b0;
                // ALUSrcA = 2'bxx;
                // ALUSrcB = 2'bxx;
                // ALUControl = 3'bxxx;
                ResultSrc = 2'b10; // ALUOut register to Result bus
                AdrSrc = 1'b1; // Result bus is connected to the memory addr port
                RegWrite = 1'b0;
                MemWrite = 1'b0;
                ImmSrc = 2'b00;
                IRWrite = 1'b0;
            end

            // S6 "MemWB" State
            MemWBState:
            begin
                $display("");
                $display("");
                $display("[CTRL.OUTPUT.MemWBState] op: %b, oldOp: %b, funct3: %b, funct7: %b", op, oldOp, funct3, funct7);

                // $display("[CTRL.OUTPUT.MemWBState] ReadDData: 0x%0h", ReadDData);

                PCWrite = 1'b0;
                ALUSrcA = 2'b00;
                ALUSrcB = 2'b00;
                ALUControl = 3'b000;
                ResultSrc = 2'b01; // take the value from the Data register and place it onto the result bus
                AdrSrc = 1'bx;
                RegWrite = 1'b1;
                MemWrite = 1'b0;
                ImmSrc = 2'b00;
                IRWrite = 1'b0;
            end

            // S7 "MemWrite" State
            MemWriteState:
            begin
                $display("");
                $display("");
                $display("[CTRL.OUTPUT.MemWriteState] op: %b, oldOp: %b, funct3: %b, funct7: %b", op, oldOp, funct3, funct7);

                PCWrite = 1'b0;
                // ALUSrcA = 2'bxx;
                // ALUSrcB = 2'bxx;
                // ALUControl = 3'bxxx;
                ResultSrc = 2'b10; // place ALU out onto the result bus
                AdrSrc = 1'b1; // connect the result bus to the address line of the memory
                RegWrite = 1'b0;
                MemWrite = 1'b1; // enable a write to memory
                ImmSrc = 2'b01;
                IRWrite = 1'b0;
            end

            // S8 "ExecuteRState" State // execute R-Type instruction
            ExecuteRState:
            begin

                $display("");
                $display("");
                $display("[CTRL.OUTPUT.ExecuteRState] op: %b, funct3: %b, funct7: %b", op, funct3, funct7);

                PCWrite = 1'b0;

                ALUSrcA = 2'b10; // register
                ALUSrcB = 2'b00; // register

                //ALUControl = 3'b000;
                // ALUControl = decode(op, funct3, funct7);

                ResultSrc = 2'b00;
                AdrSrc = 1'b0;
                RegWrite = 1'b0;
                MemWrite = 1'b0;
                ImmSrc = 2'b00;
                IRWrite = 1'b0;
            end

            // S9 "ALUWriteBackState" State
            ALUWriteBackState:
            begin
                $display("");
                $display("");
                $display("[CTRL.OUTPUT.ALUWB_STATE]");

                PCWrite = 1'b0;
                ALUSrcA = 2'b00;
                ALUSrcB = 2'b00;
                ALUControl = 3'b000;
                ResultSrc = 2'b00; // Result bus is ALUOut flip flop
                AdrSrc = 1'b0;
                RegWrite = 1'b1; // enable the RegWrite feature of the register file so it stores the result bus into the destination register rd
                MemWrite = 1'b0;
                ImmSrc = 2'b00;
                IRWrite = 1'b0;
            end

            // S10 "ExecuteI" State // execute I-Type instruction
            ExecuteIState:
            begin
                $display("");
                $display("");
                $display("[CTRL.OUTPUT.EXECUTEI_STATE]");

                PCWrite = 1'b0;

                ALUSrcA = 2'b10; // register
                ALUSrcB = 2'b01; // immediate sign extended

                ALUControl = 3'b000;

                ResultSrc = 2'b00;
                AdrSrc = 1'b0;
                RegWrite = 1'b0;
                MemWrite = 1'b0;

                ImmSrc = 2'b00; // Immediate sign extend

                IRWrite = 1'b0;
            end

            // S11 "JAL" State // execute J Type instruction
            JALState:
            begin
                $display("");
                $display("");
                $display("[CTRL.OUTPUT.JALState]");

                PCWrite = 1'b1; // Write into the PC register

                ALUSrcA = 2'b01; // oldPC
                ALUSrcB = 2'b10; // hard coded 4

                ALUControl = 3'b000; // add

                ResultSrc = 2'b00; // ALUOut goes onto the result bus
                AdrSrc = 1'bx; // confuse the muxer so it does not perform any action
                RegWrite = 1'b0;
                MemWrite = 1'b0;

                ImmSrc = 2'b11; // Immediate sign extend (J-Type)

                IRWrite = 1'b0;
            end

            // S12 "BEQ" State
            BEQState:
            begin
                $display("");
                $display("");
                $display("[CTRL.OUTPUT.BEQ_STATE]");

                PCWrite = 1'b0;
                ALUSrcA = 2'b10; // register
                ALUSrcB = 2'b00; // register
                ALUControl = 3'b001; // subtraction
                ResultSrc = 2'b00; // Result bus is ALUOut flip flop
                AdrSrc = 1'b0;
                RegWrite = 1'b0;
                MemWrite = 1'b0;
                ImmSrc = 2'b00;
                IRWrite = 1'b0;

                // if (Zero == 1)
                // begin
                //     $display("[CTRL.OUTPUT.BEQ_STATE] Branch taken");
                // end
            end

            // S13 "BRANCH_TAKEN_CHECK" State
            BRANCH_TAKEN_CHECK:
            begin
                $display("");
                $display("");
                $display("[CTRL.OUTPUT.BRANCH_TAKEN_CHECK]");

                if (Zero == 1)
                begin
                    $display("[CTRL.OUTPUT.BEQ_STATE] Branch taken. Zero: %d", Zero);

                    PCWrite = 1'b1;
                    //ALUSrcA = 2'b10; // register
                    ALUSrcA = 2'b01; // oldPC
                    //ALUSrcA = 2'b00; // PC
                    ALUSrcB = 2'b01; // immext
                    ALUControl = 3'b000; // add
                    ResultSrc = 2'b10;
                    AdrSrc = 1'b0;
                    RegWrite = 1'b0;
                    MemWrite = 1'b0;
                    ImmSrc = 2'b10;
                    IRWrite = 1'b0;
                end
                else
                begin
                    $display("[CTRL.OUTPUT.BEQ_STATE] Branch NOT taken");
                end
            end

            default:
            begin
                $display("[CTRL.OUTPUT.?] No case in always @(current_state) current_state = %d", current_state);
            end
        endcase
    end

    //
    // next state combinational logic
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
                end
            end

            // S1 "Fetch_1" State
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
                $display("[controller DecodeState] op: %b", op);
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
                else if (op == 7'b0000000) // nop
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

            // // S3 "MemRead" State
            // MemReadState:
            // begin
            //     $display("[controller] goto MemReadState -> MemWBState");
            //     next_state = MemWBState;
            // end

            // S4 "MemAddr" State
            MemAddrState:
            begin
                // $display("[controller] goto MemAddr -> FetchState_1");
                // next_state = FetchState_1;

                if (oldOp == 7'b0000011) // lw
                begin
                    $display("[controller] goto MemAddrState -> MemReadState");
                    next_state = MemReadState;
                end
                else if (oldOp == 7'b0100011) // sw
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
            // MemAddrState:
            // begin
            //     if (op2 == 7'b0000011) // lw
            //     begin
            //         $display("[controller] goto MemAddrState -> MemReadState");
            //         next_state = MemReadState;
            //     end
            //     else if (op2 == 7'b0100011) // sw
            //     begin
            //         $display("[controller] goto MemAddrState -> MemWriteState");
            //         next_state = MemWriteState;
            //     end
            //     else
            //     begin
            //         $display("[controller] goto MemAddrState -> ErrorState");
            //         next_state = ErrorState;
            //     end
            // end

            // S5 "MemRead" State
            MemReadState:
            begin
                $display("[controller] goto MemReadState -> MemWBState");
                next_state = MemWBState;
            end

            // S6 "MemWB" State
            MemWBState:
            begin
                $display("[controller] goto MemWBState -> FetchState_1");
                next_state = FetchState_1;
            end

            // S7 "MemWrite" State
            MemWriteState:
            begin
                $display("[controller] goto MemWriteState -> FetchState_1");
                next_state = FetchState_1;
            end

            // S8 "ExecuteR" State
            ExecuteRState:
            begin
                $display("[controller] goto ExecuteRState -> ALUWriteBackState");
                next_state = ALUWriteBackState;
            end

            // S9 "ALUWB" State
            ALUWriteBackState:
            begin
                $display("[controller] goto ALUWriteBackState -> FetchState_1");
                next_state = FetchState_1;
            end

            // S10 "ExecuteI" State // execute I-Type instruction
            ExecuteIState:
            begin
                $display("[controller] goto ExecuteIState -> ALUWriteBackState");
                next_state = ALUWriteBackState;
            end

            // S11 "JAL" State
            JALState:
            begin
                $display("[controller] goto JALState -> ALUWriteBackState");
                next_state = ALUWriteBackState;
            end

            // S12 "BEQ" State
            BEQState:
            begin
                // if (Zero == 1)
                // begin
                    //$display("[controller] goto BEQState -> BRANCH_TAKEN_CHECK. Zero = %d", Zero);
                    $display("[controller] goto BEQState -> BRANCH_TAKEN_CHECK.");
                    next_state = BRANCH_TAKEN_CHECK;
                // end
                // else
                // begin
                    // $display("[controller] goto BEQState -> FetchState_1. Zero = %d", Zero);
                    // next_state = FetchState_1;
                // end
            end

            // S13 "BRANCH_TAKEN_CHECK" State
            BRANCH_TAKEN_CHECK:
            begin
                $display("[controller] goto BRANCH_TAKEN_CHECK -> FetchState_1.");
                next_state = FetchState_1;
            end

            // // S15 "ERROR" State
            // ErrorState:
            // begin
            //     $display("[controller] goto ErrorState -> ErrorState");
            //     next_state = ErrorState;
            // end

            default:
            begin
                $display("[controller] default goto default -> ErrorState");
                next_state = ErrorState;
            end

        endcase
    end

endmodule;