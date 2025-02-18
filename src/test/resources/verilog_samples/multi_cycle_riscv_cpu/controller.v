// control unit or control logic for the multicycle CPU
module controller (
    input   wire        clk,
    input   wire        reset,
    input   wire [6:0]  op,
    input   wire [2:0]  funct3,
    input   wire        funct7b5,
    input   wire        Zero,
    output  wire [1:0]  ResultSrc,
    output  wire        MemWrite,
    output  wire        PCSrc,
    output  wire        ALUSrc,
    output  wire        RegWrite,
    output  wire        Jump,
    output  wire [1:0]  ImmSrc,
    output  wire [2:0]  ALUControl
);

    //
    // All states of the Moore state machine (= output only depends on the current state)
    //
    // Strategy: https://www.fpga4student.com/2017/09/verilog-code-for-moore-fsm-sequence-detector.html
    //

    parameter
        FetchState       = 4'b0000,     // S0 "Fetch" State
        DecodeState      = 4'b0001,     // S1 "Decode" State
        MemAddrState     = 4'b0010,     // S2 "MemAddr" State
        MemReadState     = 4'b0011,     // S3 "MemRead" State
        MemWBState       = 4'b0100,     // S4 "MemWB" State
        MemWriteState    = 4'b0101,     // S5 "MemWrite" State
        ExecuteRState    = 4'b0110,     // S6 "ExecuteR" State
        ALUWBState       = 4'b0111,     // S7 "ALUWB" State
        ExecuteIState    = 4'b1000,     // S8 "ExecuteI" State // execute I-Type instruction
        JALState         = 4'b1001,     // S9 "JAL" State
        BEQState         = 4'b1010,     // S10 "BEQ" State
                                        // S11
                                        // S12
                                        // S13
                                        // S14
        ErrorState       = 4'b1111      // S15 "ERROR" State
        ;

    // current state and next state
    reg [3:0] current_state;
    reg [3:0] next_state;

    // sequential memory of the Moore FSM
    always @(posedge clk, posedge reset)
    begin
        if (reset == 1)
        begin
            // when reset=1, reset the state of the FSM to "Fetch" State
            current_state <= FetchState;
        end
        else
        begin
            // otherwise, next state
            current_state <= next_state;
        end
    end

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
                next_state = DecodeState;
            end

            // S1 "Decode" State
            DecodeState:
            begin
                if ((op == 7'b0000011) || (op == 7'b010011))
                    next_state = MemAddrState;
                else if (op == 7'b0110011)
                    next_state = ExecuteRState;
                else if (op == 7'b0010011)
                    next_state = ExecuteIState;
                else if (op == 7'b1101111)
                    next_state = JALState;
                else if (op == 7'b1100011)
                    next_state = BEQState;
                else
                    next_state = ErrorState;
            end

            // S2 "MemAddr" State
            MemAddrState:
            begin
                if (op == 7'b0000011)
                    next_state = MemReadState;
                else if (op == 7'b0100011)
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
                next_state = ALUWBState;
            end

            // S7 "ALUWB" State
            ALUWBState:
            begin
                next_state = FetchState;
            end

            // S8 "ExecuteI" State // execute I-Type instruction
            ExecuteIState:
            begin
                next_state = ALUWBState;
            end

            // S9 "JAL" State
            JALState:
            begin
                next_state = ALUWBState;
            end

            // S10 "BEQ" State
            BEQState:
            begin
                next_state = FetchState;
            end

            // S15 "ERROR" State
            BEQState:
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
            end

            // S1 "Decode" State
            DecodeState:
            begin
                $display("[CTRL.OUTPUT.DECODE_STATE]");
            end

            // S2 "MemAddr" State
            MemAddrState:
            begin
                $display("[CTRL.OUTPUT.MEMADDR_STATE]");
            end

            // S3 "MemRead" State
            MemReadState:
            begin
                $display("[CTRL.OUTPUT.MEMREAD_STATE]");
            end

            // S4 "MemWB" State
            MemWBState:
            begin
                $display("[CTRL.OUTPUT.MEMWB_STATE]");
            end

            // S5 "MemWrite" State
            MemWriteState:
            begin
                $display("[CTRL.OUTPUT.MEMWRITE_STATE]");
            end

            // S6 "ExecuteR" State
            ExecuteRState:
            begin
                $display("[CTRL.OUTPUT.EXECUTER_STATE]");
            end

            // S7 "ALUWB" State
            ALUWBState:
            begin
                $display("[CTRL.OUTPUT.ALUWB_STATE]");
            end

            // S8 "ExecuteI" State // execute I-Type instruction
            ExecuteIState:
            begin
                $display("[CTRL.OUTPUT.EXECUTEI_STATE]");
            end

            // S9 "JAL" State
            JALState:
            begin
                $display("[CTRL.OUTPUT.JAL_STATE]");
            end

            // S10 "BEQ" State
            BEQState:
            begin
                $display("[CTRL.OUTPUT.BEQ_STATE]");
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