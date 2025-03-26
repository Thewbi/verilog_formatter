// this is a post-synthesis testbench and also a normal testbench
// depending on the existence of the parameter -D POST_SYNTHESIS
//
// C:\iverilog\bin\iverilog.exe -o build/flopenr_pre.vvp flopenr.v flopenr_tb.v
//
// synthesize to .blif file
// yosys.exe -p "synth_ice40 -top flopenr -blif build/flopenr.blif -json build/flopenr.json" flopenr.v
//
// convert .blif file back to verilog file containing post synthesis code
// yosys.exe -o build/flopenr_syn.v build/flopenr.blif
//
// build a .vvp file from the testbench in post-synthesis mode
// C:\iverilog\bin\iverilog.exe -o build/flopenr_post.vvp -D NO_ICE40_DEFAULT_ASSIGNMENTS -D POST_SYNTHESIS flopenr_tb.v build/flopenr_syn.v C:\Users\wolfg\Downloads\oss-cad-suite\share\yosys\ice40\cells_sim.v
//
// C:\iverilog\bin\vvp.exe build/flopenr_pre.vvp
// C:\iverilog\bin\vvp.exe build/flopenr_post.vvp
//
// gtkwave build/flopenr_pre.vcd
// gtkwave build/flopenr_post.vcd
/*
cheat sheet for pre synthesis (iverilog only)

C:\iverilog\bin\iverilog.exe -o build/flopenr_pre.vvp flopenr.v flopenr_tb.v
C:\iverilog\bin\vvp.exe build/flopenr_pre.vvp
*/
/*
cheat sheet for post synthesis

yosys.exe -p "synth_ice40 -top flopenr -blif build/flopenr.blif -json build/flopenr.json" flopenr.v
yosys.exe -o build/flopenr_syn.v build/flopenr.blif
C:\iverilog\bin\iverilog.exe -o build/flopenr_post.vvp -D NO_ICE40_DEFAULT_ASSIGNMENTS -D POST_SYNTHESIS flopenr_tb.v build/flopenr_syn.v C:\Users\wolfg\Downloads\oss-cad-suite\share\yosys\ice40\cells_sim.v
C:\iverilog\bin\vvp.exe build/flopenr_post.vvp

*/
module testbench;

    // DEBUG id of this instance
    reg [2:0] id = 3'b000;

    // clock and reset
    reg clk;
    reg resetn;

    reg en;
    reg [31:0] d;

    // output
    wire [31:0] q;

    always #5 clk = ~clk;

    initial
    begin

        #0
        resetn = 0;

        //repeat (10) @(posedge clk);

        #10
        resetn = 1;

        #10
        en = 1'b1; // enable so store new value
        d = 32'h0000AAAA;
        #1
        $display("en: %h, d: %b, q: %h", en, d, q); // expected q = 32'h0000AAAA

        #10
        en = 1'b0; // disable so hold old value
        d = 32'hBBBB0000;
        #1
        $display("en: %h, d: %b, q: %h", en, d, q); // expected q = 32'h0000AAAA

        #10
        en = 1'b1; // enable so store new value
        d = 32'hBBBB0000;
        #1
        $display("en: %h, d: %b, q: %h", en, d, q); // expected q = 32'hBBBB0000

        #10
        en = 1'b0; // disable
        resetn = 0; // reset

        #10
        resetn = 1;

        $display("en: %h, d: %b, q: %h", en, d, q); // expected q = 32'h00000000

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

        flopenr uut (

            . \id[0] (id[0]),
            . \id[1] (id[1]),
            . \id[2] (id[2]),

            . \clk (clk),

            . \resetn (resetn),

            . \en (en),

            . \d[0]  (d[0]),
            . \d[1]  (d[1]),
            . \d[2]  (d[2]),
            . \d[3]  (d[3]),
            . \d[4]  (d[4]),
            . \d[5]  (d[5]),
            . \d[6]  (d[6]),
            . \d[7]  (d[7]),
            . \d[8]  (d[8]),
            . \d[9]  (d[9]),
            . \d[10] (d[10]),
            . \d[11] (d[11]),
            . \d[12] (d[12]),
            . \d[13] (d[13]),
            . \d[14] (d[14]),
            . \d[15] (d[15]),
            . \d[16] (d[16]),
            . \d[17] (d[17]),
            . \d[18] (d[18]),
            . \d[19] (d[19]),
            . \d[20] (d[20]),
            . \d[21] (d[21]),
            . \d[22] (d[22]),
            . \d[23] (d[23]),
            . \d[24] (d[24]),
            . \d[25] (d[25]),
            . \d[26] (d[26]),
            . \d[27] (d[27]),
            . \d[28] (d[28]),
            . \d[29] (d[29]),
            . \d[30] (d[30]),
            . \d[31] (d[31]),

            . \q[0]  (q[0]),
            . \q[1]  (q[1]),
            . \q[2]  (q[2]),
            . \q[3]  (q[3]),
            . \q[4]  (q[4]),
            . \q[5]  (q[5]),
            . \q[6]  (q[6]),
            . \q[7]  (q[7]),
            . \q[8]  (q[8]),
            . \q[9]  (q[9]),
            . \q[10] (q[10]),
            . \q[11] (q[11]),
            . \q[12] (q[12]),
            . \q[13] (q[13]),
            . \q[14] (q[14]),
            . \q[15] (q[15]),
            . \q[16] (q[16]),
            . \q[17] (q[17]),
            . \q[18] (q[18]),
            . \q[19] (q[19]),
            . \q[20] (q[20]),
            . \q[21] (q[21]),
            . \q[22] (q[22]),
            . \q[23] (q[23]),
            . \q[24] (q[24]),
            . \q[25] (q[25]),
            . \q[26] (q[26]),
            . \q[27] (q[27]),
            . \q[28] (q[28]),
            . \q[29] (q[29]),
            . \q[30] (q[30]),
            . \q[31] (q[31])
        );

    `else

        flopenr #(32) uut (
            .id(id),
            .clk(clk),
            .resetn(resetn),
            .en(en),
            .d(d),
            .q(q)
        );

    `endif

endmodule;