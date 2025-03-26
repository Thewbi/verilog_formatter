// this is a post-synthesis testbench and also a normal testbench
// depending on the existence of the parameter -D POST_SYNTHESIS
//
// C:\iverilog\bin\iverilog.exe -o build/extend_pre.vvp extend.v extend_tb.v
//
// synthesize to .blif file
// yosys.exe -p "synth_ice40 -top extend -blif build/extend.blif -json build/extend.json" extend.v
//
// convert .blif file back to verilog file containing post synthesis code
// yosys.exe -o build/extend_syn.v build/extend.blif
//
// build a .vvp file from the testbench in post-synthesis mode
// C:\iverilog\bin\iverilog.exe -o build/extend_post.vvp -D NO_ICE40_DEFAULT_ASSIGNMENTS -D POST_SYNTHESIS extend_tb.v build/extend_syn.v C:\Users\wolfg\Downloads\oss-cad-suite\share\yosys\ice40\cells_sim.v
//
// C:\iverilog\bin\vvp.exe build/extend_pre.vvp
// C:\iverilog\bin\vvp.exe build/extend_post.vvp
//
// gtkwave build/extend_pre.vcd
// gtkwave build/extend_post.vcd
/*
cheat sheet for pre synthesis (iverilog only)

C:\iverilog\bin\iverilog.exe -o build/extend_pre.vvp extend.v extend_tb.v
C:\iverilog\bin\vvp.exe build/extend_pre.vvp
*/
/*
cheat sheet for post synthesis

yosys.exe -p "synth_ice40 -top extend -blif build/extend.blif -json build/extend.json" extend.v
yosys.exe -o build/extend_syn.v build/extend.blif
C:\iverilog\bin\iverilog.exe -o build/extend_post.vvp -D NO_ICE40_DEFAULT_ASSIGNMENTS -D POST_SYNTHESIS extend_tb.v build/extend_syn.v C:\Users\wolfg\Downloads\oss-cad-suite\share\yosys\ice40\cells_sim.v
C:\iverilog\bin\vvp.exe build/extend_post.vvp

*/
module testbench;

    // reg             clk = 1;
    // reg             resetn = 0;

    // input
    reg     [31:0]  instr;
    reg     [2:0]   immsrc;

    // output
    wire    [31:0]  immext;

    // always #5 clk = ~clk;

    initial begin
        // resetn <= 0;
        // repeat (10) @(posedge clk);
        // resetn <= 1;

        #10

        // I-Type
        instr = 32'h00134313; // xori x6, x6, 1
        immsrc = 3'b000; // I-Type
        #1 // the system needs at least some time to transfer the signals
        $display("instr: %h, immsrc: %b, immext: %h", instr, immsrc, immext); // expected immext = 32'h00000001

        // S-Type
        instr = 32'h02602e23; // sw x6, 60(x0)
        immsrc = 3'b001; // S-Type
        #1 // the system needs at least some time to transfer the signals
        $display("instr: %h, immsrc: %b, immext: %h", instr, immsrc, immext); // expected immext = 32'h0000003C = 60 dec

        // B-Type
        instr = 32'h00728e63; // beq x5, x7, 28
        immsrc = 3'b010; // B-Type
        #1 // the system needs at least some time to transfer the signals
        $display("instr: %h, immsrc: %b, immext: %h", instr, immsrc, immext); // expected immext = 32'h0000001C = 28 dec

        // U-Type
        instr = 32'h000163b7; // lui x7, 0
        immsrc = 3'b100; // U-Type
        #1 // the system needs at least some time to transfer the signals
        $display("instr: %h, immsrc: %b, immext: %h", instr, immsrc, immext); // expected immext = 32'h00000016 = 22 dec

        // J-Type
        instr = 32'hfd9ff06f; // jal x0, -40
        immsrc = 3'b011; // J-Type
        #1 // the system needs at least some time to transfer the signals
        $display("instr: %h, immsrc: %b, immext: %h", instr, immsrc, immext); // expected immext = 32'hffffffd8 = -40 dec

        #100
        $finish;
    end

    // always @(posedge clk) begin
    //     $display("Result: %b, Zero: %b", ALUResult, Z);
    // end

    `ifdef POST_SYNTHESIS

        // the post synthesis file, build/alu_syn.v removes all parameters
        // and resolves them by splitting the array syntax of wires and registers
        // into individual items. Therefore to instantiate the post synthesis
        // module, you have to fulfill the post synthesis interface which has
        // a million individually resolved ports when your design is based on
        // array constraints that are in turn based on parameters.

        extend uut (
            // . \instr[0]  (instr[0]),
            // . \instr[1]  (instr[1]),
            // . \instr[2]  (instr[2]),
            // . \instr[3]  (instr[3]),
            // . \instr[4]  (instr[4]),
            // . \instr[5]  (instr[5]),
            // . \instr[6]  (instr[6]),
            . \instr[7]  (instr[7]),
            . \instr[8]  (instr[8]),
            . \instr[9]  (instr[9]),
            . \instr[10] (instr[10]),
            . \instr[11] (instr[11]),
            . \instr[12] (instr[12]),
            . \instr[13] (instr[13]),
            . \instr[14] (instr[14]),
            . \instr[15] (instr[15]),
            . \instr[16] (instr[16]),
            . \instr[17] (instr[17]),
            . \instr[18] (instr[18]),
            . \instr[19] (instr[19]),
            . \instr[20] (instr[20]),
            . \instr[21] (instr[21]),
            . \instr[22] (instr[22]),
            . \instr[23] (instr[23]),
            . \instr[24] (instr[24]),
            . \instr[25] (instr[25]),
            . \instr[26] (instr[26]),
            . \instr[27] (instr[27]),
            . \instr[28] (instr[28]),
            . \instr[29] (instr[29]),
            . \instr[30] (instr[30]),
            . \instr[31] (instr[31]),

            . \immsrc[0] (immsrc[0]),
            . \immsrc[1] (immsrc[1]),
            . \immsrc[2] (immsrc[2]),

            . \immext[0]  (immext[0]),
            . \immext[1]  (immext[1]),
            . \immext[2]  (immext[2]),
            . \immext[3]  (immext[3]),
            . \immext[4]  (immext[4]),
            . \immext[5]  (immext[5]),
            . \immext[6]  (immext[6]),
            . \immext[7]  (immext[7]),
            . \immext[8]  (immext[8]),
            . \immext[9]  (immext[9]),
            . \immext[10] (immext[10]),
            . \immext[11] (immext[11]),
            . \immext[12] (immext[12]),
            . \immext[13] (immext[13]),
            . \immext[14] (immext[14]),
            . \immext[15] (immext[15]),
            . \immext[16] (immext[16]),
            . \immext[17] (immext[17]),
            . \immext[18] (immext[18]),
            . \immext[19] (immext[19]),
            . \immext[20] (immext[20]),
            . \immext[21] (immext[21]),
            . \immext[22] (immext[22]),
            . \immext[23] (immext[23]),
            . \immext[24] (immext[24]),
            . \immext[25] (immext[25]),
            . \immext[26] (immext[26]),
            . \immext[27] (immext[27]),
            . \immext[28] (immext[28]),
            . \immext[29] (immext[29]),
            . \immext[30] (immext[30]),
            . \immext[31] (immext[31])
        );

    `else

        extend uut (
            .instr(instr[31:7]),
            .immsrc(immsrc),
            .immext(immext)
        );

    `endif

endmodule;