module controller_testbench();

    reg         clk;
    reg         reset;
    reg  [6:0]  op;
    wire [2:0]  funct3;
    wire        funct7b5;
    wire        Zero;
    wire [1:0]  ResultSrc;
    wire        MemWrite;
    wire        PCSrc;
    wire        ALUSrc;
    wire        RegWrite;
    wire        Jump;
    wire [1:0]  ImmSrc;
    wire [2:0]  ALUControl;

    controller ctrl (
        clk,
        reset,

        op,         // [in]
        funct3,     // [in]
        funct7b5,   // [in]
        Zero,       // [in]

        ResultSrc,  // [output]
        MemWrite,   // [output]
        PCSrc,      // [output]
        ALUSrc,     // [output]
        RegWrite,   // [output]
        Jump,       // [output]
        ImmSrc,     // [output]
        ALUControl  // [output]
    );

    initial
    begin

        $display("start");
        clk <= 0;
        reset <= 0;

        #1

        $display("reset");
        reset <= 1;

        #1

        reset <= 0;

        #1

        $display("add");
        op <= 7'b0110011; // 32'h00000033; // add x0, x0, x0, R-TYPE

        #1
        #1
        #1
        #1
        #1

        #3;

        $finish;

    end

    // generate clock to sequence tests
    always
    begin
        //$display("tick %d", $time);
        clk <= 1;
        #1;
        clk <= 0;
        #1;
    end

    initial
    begin
        //$monitor("%t, clk = %0d, o_wb_data = %0h", $time, clk, o_wb_data);
        $monitor("%t, clk = %0d, reset = %0d", $time, clk, reset);
    end

endmodule