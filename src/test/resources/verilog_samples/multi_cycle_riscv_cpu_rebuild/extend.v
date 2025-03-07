module extend(
    input wire [31:7] instr,
    input wire [1:0] immsrc,
    output reg [31:0] immext
);

    always @(instr, immsrc, immext)

        case(immsrc)

            // I−type
            2'b00:
            begin
                $display("[extend] I Type");
                immext = { {20{instr[31]}}, instr[31:20] };
            end

            // S−type (stores)
            2'b01:
            begin
                $display("[extend] S Type");
                immext = { {20{instr[31]}}, instr[31:25], instr[11:7] };
            end

            // B−type (branches) (BEQ, ...)
            2'b10:
            begin
                $display("[extend] B Type");
                immext = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0 };
            end

            // J−type (jal)
            2'b11:
            begin
                $display("[extend] J Type");
                immext = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
            end

            default:
            begin
                $display("[extend] default");
                $display("instr: %h, immsrc: %d", instr, immsrc);
                immext = 32'bx; // undefined
            end
        endcase

endmodule