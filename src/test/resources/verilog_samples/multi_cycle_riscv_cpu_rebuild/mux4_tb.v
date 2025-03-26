// this is a post-synthesis testbench and also a normal testbench
// depending on the existence of the parameter -D POST_SYNTHESIS
//
// C:\iverilog\bin\iverilog.exe -o build/mux4_pre.vvp mux4.v mux4_tb.v
//
// synthesize to .blif file
// yosys.exe -p "synth_ice40 -top mux4 -blif build/mux4.blif -json build/mux4.json" mux4.v
//
// convert .blif file back to verilog file containing post synthesis code
// yosys.exe -o build/mux4_syn.v build/mux4.blif
//
// build a .vvp file from the testbench in post-synthesis mode
// C:\iverilog\bin\iverilog.exe -o build/mux4_post.vvp -D NO_ICE40_DEFAULT_ASSIGNMENTS -D POST_SYNTHESIS mux4_tb.v build/mux4_syn.v C:\Users\wolfg\Downloads\oss-cad-suite\share\yosys\ice40\cells_sim.v
//
// C:\iverilog\bin\vvp.exe build/mux4_pre.vvp
// C:\iverilog\bin\vvp.exe build/mux4_post.vvp
//
// gtkwave build/mux4_pre.vcd
// gtkwave build/mux4_post.vcd

/*
cheat sheet for pre synthesis (iverilog only)

C:\iverilog\bin\iverilog.exe -o build/mux4_pre.vvp mux4.v mux4_tb.v
C:\iverilog\bin\vvp.exe build/mux4_pre.vvp
*/

/*
cheat sheet for post synthesis

yosys.exe -p "synth_ice40 -top mux4 -blif build/mux4.blif -json build/mux4.json" mux4.v
yosys.exe -o build/mux4_syn.v build/mux4.blif
C:\iverilog\bin\iverilog.exe -o build/mux4_post.vvp -D NO_ICE40_DEFAULT_ASSIGNMENTS -D POST_SYNTHESIS mux4_tb.v build/mux4_syn.v C:\Users\wolfg\Downloads\oss-cad-suite\share\yosys\ice40\cells_sim.v
C:\iverilog\bin\vvp.exe build/mux4_post.vvp

*/
module testbench;

    reg     [31:0]  d0; // input A (s == 0)
    reg     [31:0]  d1; // input B (s == 1)
    reg     [31:0]  d2; // input C (s == 2)
    reg     [31:0]  d3; // input D (s == 3)
    reg     [1:0]   s;  // selector
    wire    [31:0]  y;  // output

    initial
    begin

        // #0
        // resetn = 0;

        // //repeat (10) @(posedge clk);

        // #10
        // resetn = 1;

        #10
        d0 = 32'h0000AAAA;
        d1 = 32'hBBBB0000;
        d2 = 32'h00CCCC00;
        d3 = 32'hDD0000DD;
        s = 2'b00;
        #1
        $display("d0: %h, d1: %h, d2: %h, d3: %h, s: %b, y: %h", d0, d1, d2, d3, s, y); // expected q = 32'h0000AAAA

        #10
        d0 = 32'h0000AAAA;
        d1 = 32'hBBBB0000;
        d2 = 32'h00CCCC00;
        d3 = 32'hDD0000DD;
        s = 2'b01;
        #1
        $display("d0: %h, d1: %h, d2: %h, d3: %h, s: %b, y: %h", d0, d1, d2, d3, s, y); // expected q = 32'hBBBB0000

        #10
        d0 = 32'h0000AAAA;
        d1 = 32'hBBBB0000;
        d2 = 32'h00CCCC00;
        d3 = 32'hDD0000DD;
        s = 2'b10;
        #1
        $display("d0: %h, d1: %h, d2: %h, d3: %h, s: %b, y: %h", d0, d1, d2, d3, s, y); // expected q = 32'h00CCCC00

        #10
        d0 = 32'h0000AAAA;
        d1 = 32'hBBBB0000;
        d2 = 32'h00CCCC00;
        d3 = 32'hDD0000DD;
        s = 2'b11;
        #1
        $display("d0: %h, d1: %h, d2: %h, d3: %h, s: %b, y: %h", d0, d1, d2, d3, s, y); // expected q = 32'hDD0000DD

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

        mux4 uut (

            . \d0[0]  (d0[0]),
            . \d0[1]  (d0[1]),
            . \d0[2]  (d0[2]),
            . \d0[3]  (d0[3]),
            . \d0[4]  (d0[4]),
            . \d0[5]  (d0[5]),
            . \d0[6]  (d0[6]),
            . \d0[7]  (d0[7]),
            . \d0[8]  (d0[8]),
            . \d0[9]  (d0[9]),
            . \d0[10] (d0[10]),
            . \d0[11] (d0[11]),
            . \d0[12] (d0[12]),
            . \d0[13] (d0[13]),
            . \d0[14] (d0[14]),
            . \d0[15] (d0[15]),
            . \d0[16] (d0[16]),
            . \d0[17] (d0[17]),
            . \d0[18] (d0[18]),
            . \d0[19] (d0[19]),
            . \d0[20] (d0[20]),
            . \d0[21] (d0[21]),
            . \d0[22] (d0[22]),
            . \d0[23] (d0[23]),
            . \d0[24] (d0[24]),
            . \d0[25] (d0[25]),
            . \d0[26] (d0[26]),
            . \d0[27] (d0[27]),
            . \d0[28] (d0[28]),
            . \d0[29] (d0[29]),
            . \d0[30] (d0[30]),
            . \d0[31] (d0[31]),

            . \d1[0]  (d1[0]),
            . \d1[1]  (d1[1]),
            . \d1[2]  (d1[2]),
            . \d1[3]  (d1[3]),
            . \d1[4]  (d1[4]),
            . \d1[5]  (d1[5]),
            . \d1[6]  (d1[6]),
            . \d1[7]  (d1[7]),
            . \d1[8]  (d1[8]),
            . \d1[9]  (d1[9]),
            . \d1[10] (d1[10]),
            . \d1[11] (d1[11]),
            . \d1[12] (d1[12]),
            . \d1[13] (d1[13]),
            . \d1[14] (d1[14]),
            . \d1[15] (d1[15]),
            . \d1[16] (d1[16]),
            . \d1[17] (d1[17]),
            . \d1[18] (d1[18]),
            . \d1[19] (d1[19]),
            . \d1[20] (d1[20]),
            . \d1[21] (d1[21]),
            . \d1[22] (d1[22]),
            . \d1[23] (d1[23]),
            . \d1[24] (d1[24]),
            . \d1[25] (d1[25]),
            . \d1[26] (d1[26]),
            . \d1[27] (d1[27]),
            . \d1[28] (d1[28]),
            . \d1[29] (d1[29]),
            . \d1[30] (d1[30]),
            . \d1[31] (d1[31]),

            . \d2[0]  (d2[0]),
            . \d2[1]  (d2[1]),
            . \d2[2]  (d2[2]),
            . \d2[3]  (d2[3]),
            . \d2[4]  (d2[4]),
            . \d2[5]  (d2[5]),
            . \d2[6]  (d2[6]),
            . \d2[7]  (d2[7]),
            . \d2[8]  (d2[8]),
            . \d2[9]  (d2[9]),
            . \d2[10] (d2[10]),
            . \d2[11] (d2[11]),
            . \d2[12] (d2[12]),
            . \d2[13] (d2[13]),
            . \d2[14] (d2[14]),
            . \d2[15] (d2[15]),
            . \d2[16] (d2[16]),
            . \d2[17] (d2[17]),
            . \d2[18] (d2[18]),
            . \d2[19] (d2[19]),
            . \d2[20] (d2[20]),
            . \d2[21] (d2[21]),
            . \d2[22] (d2[22]),
            . \d2[23] (d2[23]),
            . \d2[24] (d2[24]),
            . \d2[25] (d2[25]),
            . \d2[26] (d2[26]),
            . \d2[27] (d2[27]),
            . \d2[28] (d2[28]),
            . \d2[29] (d2[29]),
            . \d2[30] (d2[30]),
            . \d2[31] (d2[31]),

            . \d3[0]  (d3[0]),
            . \d3[1]  (d3[1]),
            . \d3[2]  (d3[2]),
            . \d3[3]  (d3[3]),
            . \d3[4]  (d3[4]),
            . \d3[5]  (d3[5]),
            . \d3[6]  (d3[6]),
            . \d3[7]  (d3[7]),
            . \d3[8]  (d3[8]),
            . \d3[9]  (d3[9]),
            . \d3[10] (d3[10]),
            . \d3[11] (d3[11]),
            . \d3[12] (d3[12]),
            . \d3[13] (d3[13]),
            . \d3[14] (d3[14]),
            . \d3[15] (d3[15]),
            . \d3[16] (d3[16]),
            . \d3[17] (d3[17]),
            . \d3[18] (d3[18]),
            . \d3[19] (d3[19]),
            . \d3[20] (d3[20]),
            . \d3[21] (d3[21]),
            . \d3[22] (d3[22]),
            . \d3[23] (d3[23]),
            . \d3[24] (d3[24]),
            . \d3[25] (d3[25]),
            . \d3[26] (d3[26]),
            . \d3[27] (d3[27]),
            . \d3[28] (d3[28]),
            . \d3[29] (d3[29]),
            . \d3[30] (d3[30]),
            . \d3[31] (d3[31]),

            . \s[0] (s[0]),
            . \s[1] (s[1]),

            . \y[0]  (y[0]),
            . \y[1]  (y[1]),
            . \y[2]  (y[2]),
            . \y[3]  (y[3]),
            . \y[4]  (y[4]),
            . \y[5]  (y[5]),
            . \y[6]  (y[6]),
            . \y[7]  (y[7]),
            . \y[8]  (y[8]),
            . \y[9]  (y[9]),
            . \y[10] (y[10]),
            . \y[11] (y[11]),
            . \y[12] (y[12]),
            . \y[13] (y[13]),
            . \y[14] (y[14]),
            . \y[15] (y[15]),
            . \y[16] (y[16]),
            . \y[17] (y[17]),
            . \y[18] (y[18]),
            . \y[19] (y[19]),
            . \y[20] (y[20]),
            . \y[21] (y[21]),
            . \y[22] (y[22]),
            . \y[23] (y[23]),
            . \y[24] (y[24]),
            . \y[25] (y[25]),
            . \y[26] (y[26]),
            . \y[27] (y[27]),
            . \y[28] (y[28]),
            . \y[29] (y[29]),
            . \y[30] (y[30]),
            . \y[31] (y[31])
        );

    `else

        mux4 #(32) uut (
            .d0(d0),
            .d1(d1),
            .d2(d2),
            .d3(d3),
            .s(s),
            .y(y)
        );

    `endif

endmodule;