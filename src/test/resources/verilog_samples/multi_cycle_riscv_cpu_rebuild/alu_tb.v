// this is a post-synthesis testbench and also a normal testbench
// depending on the existence of the parameter -D POST_SYNTHESIS
module testbench;

    reg clk = 1;
    reg resetn = 0;

    wire [7:0] tx_Data;
    wire tx_DataValid;

    reg [31:0] a_in;
    reg [31:0] b_in;

    reg [2:0] ALUControl;

    wire [31:0] ALUResult;
    wire Z;

    always #5 clk = ~clk;

    initial begin
        resetn <= 0;
        repeat (10) @(posedge clk);
        resetn <= 1;

        repeat (1) @(posedge clk);
        $display("Add b001 + b0100 = b0101, Zero = 0");
        a_in = 32'b001;
        b_in = 32'b100;
        ALUControl = 3'b000; // add

        repeat (1) @(posedge clk);
        $display("Add b0000 + b0000 = b0000, Zero = 1");
        a_in = 32'b0;
        b_in = 32'b0;
        ALUControl = 3'b000; // add with zero result

        repeat (1) @(posedge clk);
        a_in = 32'b101;
        b_in = 32'b1;
        ALUControl = 3'b001; // sub

        repeat (1) @(posedge clk);
        a_in = 32'b101;
        b_in = 32'b101;
        ALUControl = 3'b001; // sub with zero result

        repeat (1) @(posedge clk);
        a_in = 32'b1101;
        b_in = 32'b1000;
        ALUControl = 3'b010; // and

        repeat (1) @(posedge clk);
        a_in = 32'b1010;
        b_in = 32'b0101;
        ALUControl = 3'b010; // and with zero result

        repeat (1) @(posedge clk);
        a_in = 32'b1100;
        b_in = 32'b1010;
        ALUControl = 3'b011; // xor

        repeat (1) @(posedge clk);
        a_in = 32'b1100;
        b_in = 32'b1010;
        ALUControl = 3'b011; // xor with zero result

        repeat (1) @(posedge clk);
        a_in = 32'b0001;
        b_in = 32'b1000;
        ALUControl = 3'b101; // slti

        repeat (1) @(posedge clk);
        a_in = 32'b1000;
        b_in = 32'b0001;
        ALUControl = 3'b101; // slti with zero result

        repeat (1) @(posedge clk);
        a_in = 32'b0001;
        b_in = 32'b1000;
        ALUControl = 3'b110; // or

        repeat (1) @(posedge clk);
        a_in = 32'b0000;
        b_in = 32'b0000;
        ALUControl = 3'b110; // or with zero result

        repeat (1) @(posedge clk);
        a_in = 32'b0000;
        b_in = 32'b0000;
        ALUControl = 3'b111; // undefined

        repeat (20) @(posedge clk);
        $finish;
    end

    always @(posedge clk) begin
        $display("Result: %b, Zero: %b", ALUResult, Z);
    end

    `ifdef POST_SYNTHESIS

        // the post synthesis file, build/alu_syn.v removes all parameters
        // and resolves them by splitting the array syntax of wires and registers
        // into individual items. Therefore to instantiate the post synthesis
        // module, you have to fulfill the post synthesis interface which has
        // a million individually resolved ports when your design is based on
        // array constraints that are in turn based on parameters.

        alu uut (
            . \a_in[0]  (a_in[0]),
            . \a_in[1]  (a_in[1]),
            . \a_in[2]  (a_in[2]),
            . \a_in[3]  (a_in[3]),
            . \a_in[4]  (a_in[4]),
            . \a_in[5]  (a_in[5]),
            . \a_in[6]  (a_in[6]),
            . \a_in[7]  (a_in[7]),
            . \a_in[8]  (a_in[8]),
            . \a_in[9]  (a_in[9]),
            . \a_in[10] (a_in[10]),
            . \a_in[11] (a_in[11]),
            . \a_in[12] (a_in[12]),
            . \a_in[13] (a_in[13]),
            . \a_in[14] (a_in[14]),
            . \a_in[15] (a_in[15]),
            . \a_in[16] (a_in[16]),
            . \a_in[17] (a_in[17]),
            . \a_in[18] (a_in[18]),
            . \a_in[19] (a_in[19]),
            . \a_in[20] (a_in[20]),
            . \a_in[21] (a_in[21]),
            . \a_in[22] (a_in[22]),
            . \a_in[23] (a_in[23]),
            . \a_in[24] (a_in[24]),
            . \a_in[25] (a_in[25]),
            . \a_in[26] (a_in[26]),
            . \a_in[27] (a_in[27]),
            . \a_in[28] (a_in[28]),
            . \a_in[29] (a_in[29]),
            . \a_in[30] (a_in[30]),
            . \a_in[31] (a_in[31]),
            . \b_in[0]  (b_in[0]),
            . \b_in[1]  (b_in[1]),
            . \b_in[2]  (b_in[2]),
            . \b_in[3]  (b_in[3]),
            . \b_in[4]  (b_in[4]),
            . \b_in[5]  (b_in[5]),
            . \b_in[6]  (b_in[6]),
            . \b_in[7]  (b_in[7]),
            . \b_in[8]  (b_in[8]),
            . \b_in[9]  (b_in[9]),
            . \b_in[10] (b_in[10]),
            . \b_in[11] (b_in[11]),
            . \b_in[12] (b_in[12]),
            . \b_in[13] (b_in[13]),
            . \b_in[14] (b_in[14]),
            . \b_in[15] (b_in[15]),
            . \b_in[16] (b_in[16]),
            . \b_in[17] (b_in[17]),
            . \b_in[18] (b_in[18]),
            . \b_in[19] (b_in[19]),
            . \b_in[20] (b_in[20]),
            . \b_in[21] (b_in[21]),
            . \b_in[22] (b_in[22]),
            . \b_in[23] (b_in[23]),
            . \b_in[24] (b_in[24]),
            . \b_in[25] (b_in[25]),
            . \b_in[26] (b_in[26]),
            . \b_in[27] (b_in[27]),
            . \b_in[28] (b_in[28]),
            . \b_in[29] (b_in[29]),
            . \b_in[30] (b_in[30]),
            . \b_in[31] (b_in[31]),
            . \ALUControl[0] (ALUControl[0]),
            . \ALUControl[1] (ALUControl[1]),
            . \ALUControl[2] (ALUControl[2]),
            . \tx_Data[0] (tx_Data[0]),
            . \tx_Data[1] (tx_Data[1]),
            . \tx_Data[2] (tx_Data[2]),
            . \tx_Data[3] (tx_Data[3]),
            . \tx_Data[4] (tx_Data[4]),
            . \tx_Data[5] (tx_Data[5]),
            . \tx_Data[6] (tx_Data[6]),
            . \tx_Data[7] (tx_Data[7]),
            . tx_DataValid (tx_DataValid),
            . \ALUResult[0]     (ALUResult[0]),
            . \ALUResult[1]     (ALUResult[1]),
            . \ALUResult[2]     (ALUResult[2]),
            . \ALUResult[3]     (ALUResult[3]),
            . \ALUResult[4]     (ALUResult[4]),
            . \ALUResult[5]     (ALUResult[5]),
            . \ALUResult[6]     (ALUResult[6]),
            . \ALUResult[7]     (ALUResult[7]),
            . \ALUResult[8]     (ALUResult[8]),
            . \ALUResult[9]     (ALUResult[9]),
            . \ALUResult[10]    (ALUResult[10]),
            . \ALUResult[11]    (ALUResult[11]),
            . \ALUResult[12]    (ALUResult[12]),
            . \ALUResult[13]    (ALUResult[13]),
            . \ALUResult[14]    (ALUResult[14]),
            . \ALUResult[15]    (ALUResult[15]),
            . \ALUResult[16]    (ALUResult[16]),
            . \ALUResult[17]    (ALUResult[17]),
            . \ALUResult[18]    (ALUResult[18]),
            . \ALUResult[19]    (ALUResult[19]),
            . \ALUResult[20]    (ALUResult[20]),
            . \ALUResult[21]    (ALUResult[21]),
            . \ALUResult[22]    (ALUResult[22]),
            . \ALUResult[23]    (ALUResult[23]),
            . \ALUResult[24]    (ALUResult[24]),
            . \ALUResult[25]    (ALUResult[25]),
            . \ALUResult[26]    (ALUResult[26]),
            . \ALUResult[27]    (ALUResult[27]),
            . \ALUResult[28]    (ALUResult[28]),
            . \ALUResult[29]    (ALUResult[29]),
            . \ALUResult[30]    (ALUResult[30]),
            . \ALUResult[31]    (ALUResult[31]),
            . Z (Z)
        );

    `else

        alu #(32) uut (
            // DEBUG UART
            .tx_Data(tx_Data),
            .tx_DataValid(tx_DataValid),

            // input
            .a_in(a_in),
            .b_in(b_in),
            .ALUControl(ALUControl), // operation to perform

            // output
            .ALUResult(ALUResult), // result to output
            .Z(Z) // zero
        );

    `endif

endmodule;