module testbench();

    logic [31:0] a, b;
    logic [31:0] y;

    // instantiate device to be tested
    adder dut(a, b, y);

    initial
        begin
            a <= 0;
            b <= 0;

            #5

            a <= 1;
            b <= 2;
        end

endmodule