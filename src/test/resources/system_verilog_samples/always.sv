module top;
    logic clk;

    initial clk = 0;

    always clk = #10 ~clk;

endmodule