module extend(
    input wire [31:7] instr,
    input wire [2:0] immsrc,
    output reg [31:0] immext
);

    //always @*
    always @(instr, immsrc, immext)
    begin

        case(immsrc)

            // I−type
            // example lui (32'h00134313), expected result: 32'h00000001
            3'b000:
            begin
                immext = { { 20{instr[31]} }, instr[31:20] };
                //$display("[extend] I Type. immext = %h", immext);
            end

            // S−type (stores)
            // example: 32'h02602e23, expected result: 32'b00000000000000000000000000111100 == 32'h0000003C
            3'b001:
            begin
                immext = { { 20{instr[31]} }, instr[31:25], instr[11:7] };
                //$display("[extend] S Type");
            end

            // B−type (branches) (BEQ, ...)
            3'b010:
            begin
                immext = { { 20{instr[31]} }, instr[7], instr[30:25], instr[11:8], 1'b0 };
                //$display("[extend] B Type");
            end

            // U−type (lui)
            // example: 000003b7
            3'b100:
            begin
                immext = { { 12{instr[31]} }, instr[31:12] };
                //$display("[extend] U Type");
            end

            // J−type (jal)
            3'b011:
            begin
                immext = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
                //$display("[extend] J Type. immext = 0x%08h", immext);
                //$display("[extend] J Type");
            end

            default:
            begin
                //$display("[extend] instr: %h, immsrc: %d", instr, immsrc);
                immext = 32'bx; // undefined
                //$display("[extend] default");
            end
        endcase

    end

endmodule