module imem(
    input wire [31:0] a,
    output wire [31:0] rd);

    reg [31:0] RAM[127:0];

    initial
    begin
        //$readmemh("progmem.txt", RAM);

        //
        // Harris & Harris, modified sample
        //

        RAM[32'd00] = 32'h00500113;  // addi x2, x0, 5
        RAM[32'd04] = 32'h00c00193;  // addi x3, x0, 12
        RAM[32'd08] = 32'hFF718393;  // addi x7, x3, -9
        RAM[32'd12] = 32'h0023E233;  // or x4, x7, x2
        RAM[32'd16] = 32'h0041F2B3;  // and x5, x3, x4
        RAM[32'd20] = 32'h004282B3;  // add x5, x5, x4
        RAM[32'd24] = 32'h02728863;  // beq x5, x7, end      # should NOT be taken
        RAM[32'd28] = 32'h0041A233;  // slt x4, x3, x4
        RAM[32'd32] = 32'h00020463;  // beq x4, x0, around   # should be taken
        RAM[32'd36] = 32'h00000293;  // addi x5, x0, 0
        RAM[32'd40] = 32'h0023A233;  // slt x4, x7, x2
        RAM[32'd44] = 32'h005203B3;  // add x7, x4, x5
        RAM[32'd48] = 32'h402383B3;  // sub x7, x7, x2
        RAM[32'd52] = 32'h00000033;  // add x0, x0, x0
        RAM[32'd56] = 32'h00000033;  // add x0, x0, x0
        RAM[32'd60] = 32'h005104B3;  // add x9, x2, x5
        RAM[32'd64] = 32'h00000033;  // add x0, x0, x0
        RAM[32'd68] = 32'h00100113;  // addi x2, x0, 1
        RAM[32'd72] = 32'h00910133;  // add x2, x2, x9
        RAM[32'd76] = 32'h00000033;  // add x0, x0, x0
        RAM[32'd80] = 32'h00210063;  // beq x2, x2, done
        RAM[32'd84] = 32'h00000000;
        RAM[32'd88] = 32'h00000000;
    end

    assign rd = RAM[a[31:2]]; // word aligned
endmodule