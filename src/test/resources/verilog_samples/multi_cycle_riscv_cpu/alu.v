// from: https://itsembedded.com/dhd/verilator_1/

module alu #(parameter WIDTH = 32) (
        input       [WIDTH-1:0]             a_in,
        input       [WIDTH-1:0]             b_in,
        input  wire [2:0]                   ALUControl,
        output reg  [WIDTH-1:0]             ALUResult,
        output reg                          Z // zero
);

    // compute the result
    always @*
    begin

        ALUResult = 1'b0;

        case (ALUControl)

            // add (see alu_decoder.sv)
            //3'b000: {C, ALUResult} = a_in + b_in; // this works in questa
            3'b000:
            begin
                ALUResult = a_in + b_in;
                $display("[ALU] add. a_in=%d, b_in=%d, ALUResult=%d", a_in, b_in, ALUResult);
            end

            // sub
            //3'b001: {C, ALUResult} = a_in + (~b_in + 1'b1); // this works in questa
            3'b001:
            begin
                $display("[ALU] sub");
                ALUResult = a_in + (~b_in + 1'b1);
            end

            // and, andi
            3'b010:
            begin
                $display("[ALU] and, andi");
                ALUResult = a_in & b_in;
            end

            // or, ori
            3'b011:
            begin
                $display("[ALU] or, ori");
                ALUResult = a_in | b_in;
            end

            // slt, slti
            // SLTI (set less than immediate) places the value 1 in register rd if
            // register rs1 is less than the signextended immediate when both are treated
            // as signed numbers, else 0 is written to rd.
            3'b101:
            begin
                $display("[ALU] slt, slti");
                ALUResult = a_in < b_in ? 1 : 0;
            end

            default:
            begin
                $display("[ALU] default");
                ALUResult = 1'b0;
            end

        endcase

        // compute zero
        Z = ALUResult == 0;

    end

endmodule