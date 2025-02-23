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
    input   wire [2:0]  funct3,     // funct3 for instruction identification
    input   wire        funct7b5,   // funct7b5
    input   wire        Zero,       // the ALU has computed a result that is zero (for branching instruction making)

    // output
    output  reg         PCWrite,    // the PC flip flop enable line, the flip flop stores PCNext and outputs PC
    output  reg         AdrSrc,     // address source selector
    output  reg         MemWrite,   // write enable for the memory module
    output  reg         IRWrite,    // instruction register write
    output  reg  [1:0]  ResultSrc,  // controls the multiplexer that decides what goes onto the Result bus
    output  reg  [2:0]  ALUControl, // tells the ALU which operation to perform
    output  reg  [1:0]  ALUSrcB,    // decides which line goes into the ALU B parameter input
    output  reg  [1:0]  ALUSrcA,    // decides which line goes into the ALU A parameter input
    output  wire [1:0]  ImmSrc,     // enable sign extension of the immediate value
    output  reg         RegWrite,   // write enable for the register file

    // wishbone memory access
    // interface between the host and the master
    output  reg         cmd_stb,
    output  reg [33:0]  cmd_word,
    input   wire        cmd_busy,
    input   wire        rsp_stb,
    input   wire [33:0] rsp_word
);

    //
    // All states of the Moore state machine (= output only depends on the current state)
    //
    // Strategy: https://www.fpga4student.com/2017/09/verilog-code-for-moore-fsm-sequence-detector.html
    //

    parameter
        FetchState          = 4'b0000,      // S0 "Fetch" State
        DecodeState         = 4'b0001,      // S1 "Decode" State
        MemAddrState        = 4'b0010,      // S2 "MemAddr" State
        MemReadState        = 4'b0011,      // S3 "MemRead" State
        MemWBState          = 4'b0100,      // S4 "MemWB" State
        MemWriteState       = 4'b0101,      // S5 "MemWrite" State
        ExecuteRState       = 4'b0110,      // S6 "ExecuteR" State
        ALUWriteBackState   = 4'b0111,      // S7 "ALUWriteBackState" State
        ExecuteIState       = 4'b1000,      // S8 "ExecuteI" State // execute I-Type instruction
        JALState            = 4'b1001,      // S9 "JAL" State
        BEQState            = 4'b1010,      // S10 "BEQ" State
                                            // S11
                                            // S12
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
            current_state <= FetchState;
        end
        else
        begin
            $display("[controller] next state");
            // otherwise, next state
            current_state <= next_state;
        end
    end

    //
    // next state
    //
    // combinational logic of the Moore FSM
    // to determine next state
    //

    always @(current_state, op)
    begin
        case(current_state)

            // S0 "Fetch" State
            FetchState:
            begin
                $display("goto FetchState -> DecodeState");
                next_state = DecodeState;
            end

            // S1 "Decode" State
            DecodeState:
            begin
                if ((op == 7'b0000011) || (op == 7'b010011)) // lw or sw
                    next_state = MemAddrState;
                else if (op == 7'b0110011) // R-Type
                begin
                    $display("goto DecodeState -> ExecuteRState");
                    next_state = ExecuteRState;
                end
                else if (op == 7'b0010011) // I-Type ALU
                    next_state = ExecuteIState;
                else if (op == 7'b1101111) // JAL
                    next_state = JALState;
                else if (op == 7'b1100011) // BEQ
                    next_state = BEQState;
                else
                    next_state = ErrorState;
            end

            // S2 "MemAddr" State
            MemAddrState:
            begin
                if (op == 7'b0000011) // lw
                    next_state = MemReadState;
                else if (op == 7'b0100011) // sw
                    next_state = MemWriteState;
                else
                    next_state = ErrorState;
            end

            // S3 "MemRead" State
            MemReadState:
            begin
                next_state = MemWBState;
            end

            // S4 "MemWB" State
            MemWBState:
            begin
                next_state = FetchState;
            end

            // S5 "MemWrite" State
            MemWriteState:
            begin
                next_state = FetchState;
            end

            // S6 "ExecuteR" State
            ExecuteRState:
            begin
                $display("goto ExecuteRState -> ALUWriteBackState");
                next_state = ALUWriteBackState;
            end

            // S7 "ALUWB" State
            ALUWriteBackState:
            begin
                $display("goto ALUWriteBackState -> FetchState");
                next_state = ALUWriteBackState;
            end

            // S8 "ExecuteI" State // execute I-Type instruction
            ExecuteIState:
            begin
                next_state = ALUWriteBackState;
            end

            // S9 "JAL" State
            JALState:
            begin
                next_state = ALUWriteBackState;
            end

            // S10 "BEQ" State
            BEQState:
            begin
                next_state = FetchState;
            end

            // S15 "ERROR" State
            ErrorState:
            begin
                next_state = ErrorState;
            end

            default:
                next_state = ErrorState;

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
            // S0 "Fetch" State
            FetchState:
            begin
                $display("[CTRL.OUTPUT.FETCH_STATE]");
                // Instr <- Mem[PC]
                AdrSrc <= 0;            // address for memory access is taken from the PC register
                IRWrite <= 1;           // write enable the register that will store the data retrieved from memory
                // PC <- PC + 4
                ALUSrcA <= 2'b00;       // A input to the ALU: use the content of PC
                ALUSrcB <= 2'b10;       // B input to the ALU: hardcoded 4 to increment PC by one 32bit instruction
                // ALU
                ALUControl <= 3'b000;   // operation add?
                ResultSrc <= 2'b00;     // ALU result goes onto the result bus
            end

            // S1 "Decode" State
            DecodeState:
            begin
                $display("[CTRL.OUTPUT.DECODE_STATE]");
                // ALUOut <- PCTarget (this computes the target address of a jump/branch instruction)
                ALUSrcA <= 2'b01;       // A input to the ALU: use the oldPC
                ALUSrcB <= 2'b01;       // B input to the ALU: sign extended immediate
                ALUControl <= 3'b000;   // some operation (add?)
            end

            // S2 "MemAddr" State
            MemAddrState:
            begin
                $display("[CTRL.OUTPUT.MEMADDR_STATE]");
                // ALUOut <- rs1 + imm
                ALUSrcA <= 2'b10;       // A input to the ALU: value currently stored in the register identified by rd1
                ALUSrcB <= 2'b01;       // B input to the ALU: sign extended immediate
                ALUControl <= 3'b000;   // some operation (add?)
            end

            // S3 "MemRead" State
            MemReadState:
            begin
                $display("[CTRL.OUTPUT.MEMREAD_STATE]");
                // Data <- Mem[ALUOut]
                ResultSrc = 2'b00;      // ALUOut is the value that is placed onto the ResultSrc bus
                AdrSrc = 1'b1;          // The ResultSrc bus is used as an input to the memory module
            end

            // S4 "MemWB" State
            MemWBState:
            begin
                $display("[CTRL.OUTPUT.MEMWB_STATE]");
                // rd <- Data           // write the memmory value back into the register file to the rd register
                ResultSrc = 2'b01;      // data read from memory is the value that is placed onto the ResultSrc bus
                RegWrite = 1'b1;        // write enable the register file
            end

            // S5 "MemWrite" State
            MemWriteState:
            begin
                $display("[CTRL.OUTPUT.MEMWRITE_STATE]");
                // Mem[ALUOut] <- rd    // value in the rd register goes into memory
                ResultSrc = 2'b00;
                AdrSrc = 1'b1;
                MemWrite = 1'b1;        // Write enable the memory
            end

            // S6 "ExecuteR" State
            ExecuteRState:
            begin
                $display("[CTRL.OUTPUT.EXECUTER_STATE]");
                // ALUOut <- rs1oprs2   // an operator is applied to rs1 and rs2
                ALUSrcA <= 2'b10;       // A input to the ALU: value currently stored in the register identified by rd1
                ALUSrcB <= 2'b00;       // B input to the ALU: sign extended immediate
                ALUControl <= 3'b010;   // some operation (?)
            end

            // S7 "ALUWriteBackState" State
            ALUWriteBackState:
            begin
                $display("[CTRL.OUTPUT.ALUWriteBackState]");
                // rd <- ALUOut         // write the ALU result back into the register file to the rd register
                ResultSrc = 2'b01;      // data value goes on to the result bus
                RegWrite = 1'b1;        // write enable the register file
            end

            // S8 "ExecuteI" State // execute I-Type instruction
            ExecuteIState:
            begin
                $display("[CTRL.OUTPUT.EXECUTEI_STATE]");
                // ALUOut <- rs1opimm   // an operator is applied to rs1 and the immediate value
                ALUSrcA <= 2'b10;       // A input to the ALU: value currently stored in the register identified by rd1
                ALUSrcB <= 2'b01;       // B input to the ALU: ???
                ALUControl <= 3'b010;   // some operation (?)
            end

            // S9 "JAL" State
            JALState:
            begin
                $display("[CTRL.OUTPUT.JAL_STATE]");
                // PC = ALUOut; ALUOut = PC + 4
                ALUSrcA <= 2'b01;       // old PC
                ALUSrcB <= 2'b10;       // hardcoded value 4
                ALUControl <= 3'b000;   // some operation (add?)
                ResultSrc <= 2'b00;     // ALU goes onto the result bus
                PCWrite <= 1'b1;        // enable the PC write
            end

            // S10 "BEQ" State
            BEQState:
            begin
                $display("[CTRL.OUTPUT.BEQ_STATE]");
                // ALUResult = rs1-rs2; if Zero, PC = ALUOut
                ALUSrcA <= 2'b10;       // register file rs1
                ALUSrcB <= 2'b00;       // register file rs2
                ALUControl <= 3'b001;   // some operation (minus?)
                ResultSrc <= 2'b00;     // ALU goes onto the result bus
                PCWrite <= 1'b1;        // branch ???
            end

            // S105 "ERROR" State
            BEQState:
            begin
                $display("[CTRL.OUTPUT.ERROR_STATE]");
            end

            default:
            begin
                $display("[CTRL.OUTPUT.?]");
            end
        endcase
    end

endmodule;