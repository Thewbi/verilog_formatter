module extend(
    input wire [31:7] instr,
    input wire [2:0] immsrc,

    output reg [31:0] immext
);

    always @(instr, immsrc)

        case(immsrc)

            // I−type, load word (lw)
            // lui (00134313)
            3'b000:
            begin
                $display("[extend] I Type");
                immext = { { 20{instr[31]} }, instr[31:20] };
            end

            // S−type (stores)
            3'b001:
            begin
                $display("[extend] S Type");
                immext = { { 20{instr[31]} }, instr[31:25], instr[11:7] };
            end

            // B−type (branches) (BEQ, ...)
            3'b010:
            begin
                $display("[extend] B Type");
                immext = { { 20{instr[31]} }, instr[7], instr[30:25], instr[11:8], 1'b0 };
            end

            // U−type (lui)
            // example: 000003b7
            3'b100:
            begin
                $display("[extend] U Type");
                //immext = { { 12{instr[31]} }, instr[31:12] };
                immext = { instr[31:12], 12'b000000000000 };
            end

            // J−type (jal)
            3'b011:
            begin
                immext = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
                $display("[extend] J Type. immext = 0x%08h", immext);
            end

            default:
            begin
                $display("[extend] default");
                $display("[extend] instr: %h, immsrc: %d", instr, immsrc);
                immext = 32'bx; // undefined
            end
        endcase

endmodule